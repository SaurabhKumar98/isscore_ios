import 'dart:async';
import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/examhall/examinstractionmodel.dart';
import 'package:firstedu/data/models/api_models/examhall/examinstructionmodels.dart';
import 'package:firstedu/data/models/api_models/examhall/examsessionmodels.dart';
import 'package:firstedu/data/models/api_models/examhall/resultmodels.dart';
import 'package:firstedu/data/models/api_models/examhall/vistiquestionmodels.dart';
import 'package:firstedu/data/repo/examhall/examsessionrepositories.dart';
import 'package:firstedu/view_models/examhallprovider/examhallwebsocket.dart';
import 'package:flutter/material.dart';

enum ExamStatus { idle, starting, inProgress, submitting, completed, error }

enum ExamStartResult { started, alreadyCompleted, notPurchased, error }

class ExamSessionProvider extends ChangeNotifier {
  final ExamSessionRepository _repository;
  final ExamSocketService _socketService;

  static const int maxViolations = 3;

  ExamSessionProvider(this._repository, this._socketService) {
    _socketService.onTimerUpdate = _onSocketTimerUpdate;
    _socketService.onAutoSubmitted = _onSocketAutoSubmitted;
    _socketService.onProctoringLogged = _onSocketProctoringLogged;
    _socketService.onError = _onSocketError;
    _socketService.onSessionExpired = _onSocketSessionExpired;
  }

  // ── Core state ────────────────────────────────────────────────────────────
  ExamStatus _status = ExamStatus.idle;
  ExamStatus get status => _status;

  String _sessionId = '';
  String? get sessionId => _sessionId.isEmpty ? null : _sessionId;

  List<QuestionItem> _questions = [];
  List<QuestionItem> get questions => _questions;

  // ── Section state ─────────────────────────────────────────────────────────
  List<SectionedQuestionGroup> _sectionedQuestions = [];
  List<SectionedQuestionGroup> get sectionedQuestions => _sectionedQuestions;

  bool get hasSections => _sectionedQuestions.isNotEmpty;

  int get currentSectionIndex => currentQuestion?.question.sectionIndex ?? 0;

  final Set<String> _expiredQuestionIds = {};

  /// For regular questions: checks by questionId.
  /// For sub-questions: checks by subId directly (we store sub IDs in the set).
  bool isQuestionExpired(String questionId) =>
      _expiredQuestionIds.contains(questionId);

  /// Check if a specific sub-question is expired.
  bool isSubQuestionExpired(String parentId, String subId) =>
      _expiredQuestionIds.contains(subId);

  SectionedQuestionGroup? get currentSection {
    if (!hasSections) return null;
    final idx = currentSectionIndex;
    return _sectionedQuestions.firstWhere(
      (s) => s.index == idx,
      orElse: () => _sectionedQuestions.first,
    );
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  int _maxReachedIndex = 0;
  int get maxReachedIndex => _maxReachedIndex;

  // ── Active sub-question index (for connected/passage questions) ───────────
  // This tracks which sub-question the user is currently viewing / whose
  // timer is running inside the current connected parent question.
  int _activeSubIndex = 0;
  int get activeSubIndex => _activeSubIndex;

  // ── Global exam timer ─────────────────────────────────────────────────────
  int _remainingSeconds = 0;
  int get remainingSeconds => _remainingSeconds;

  // ── Per-question countdown ────────────────────────────────────────────────
  // KEY FORMAT:
  //   Regular question  → questionId
  //   Sub-question      → subId   (the sub-question's own _id from backend)
  //
  // We store sub-question times by their own ID because the backend treats
  // each sub-question independently for timer purposes.
  final Map<String, int> _questionRemainingTimes = {};

  // Returns the timer key for the currently active question/sub-question.
  String get _activeTimerKey {
    final q = currentQuestion;
    if (q == null) return '';
    if (q.question.isConnected && q.question.subQuestions.isNotEmpty) {
      final clampedIdx =
          _activeSubIndex.clamp(0, q.question.subQuestions.length - 1);
      return q.question.subQuestions[clampedIdx].id;
    }
    return q.questionId;
  }

  int get currentQuestionRemainingSeconds =>
      _questionRemainingTimes[_activeTimerKey] ?? 0;

  String get formattedQuestionCountdown {
    final s = currentQuestionRemainingSeconds;
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  bool get isQuestionLowTime => currentQuestionRemainingSeconds <= 10;

  /// Low-time flag scoped to the active sub-question.
  bool get isSubQuestionLowTime {
    final q = currentQuestion;
    if (q == null || !q.question.isConnected) return false;
    return currentQuestionRemainingSeconds <= 10;
  }

  /// Remaining seconds for an arbitrary sub-question (used by the UI to
  /// render each sub-question's own timer badge).
  int subQuestionRemainingSeconds(String parentId, String subId) =>
      _questionRemainingTimes[subId] ?? 0;

  // ── Timers ────────────────────────────────────────────────────────────────
  Timer? _localTimer;
  Timer? _questionTimer;

  // ── Visit debounce — prevents duplicate calls on rapid taps ───────────────
  String? _lastVisitedQuestionId;

  // ── Proctoring ────────────────────────────────────────────────────────────
  int _violationCount = 0;
  int get violationCount => _violationCount;

  // ── Results ───────────────────────────────────────────────────────────────
  ExamResultsData? _results;
  ExamResultsData? get results => _results;

  String? _autoSubmitReason;
  String? get autoSubmitReason => _autoSubmitReason;

  // ── Error ─────────────────────────────────────────────────────────────────
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // ── Pause flag ────────────────────────────────────────────────────────────
  bool _isPaused = false;
  bool _pauseApiCalled = false;

  // ── Instructions state ────────────────────────────────────────────────────
  bool _instructionsLoading = false;
  bool get instructionsLoading => _instructionsLoading;

  String _instructionsError = '';
  String get instructionsError => _instructionsError;

  Examinstructionsmodel? _instructionsData;
  Examinstructionsmodel? get instructionsData => _instructionsData;

  // ── Derived getters ───────────────────────────────────────────────────────
  QuestionItem? get currentQuestion =>
      _questions.isEmpty ? null : _questions[_currentIndex];

  int get answeredCount =>
      _questions.where((q) => q.status == 'answered').length;

  int get markedCount =>
      _questions.where((q) => q.status == 'marked_for_review').length;

  int get skippedCount => _questions.where((q) => q.status == 'skipped').length;

  int get notVisitedCount =>
      _questions.where((q) => q.status == 'not_visited').length;

  String get formattedTime {
    final h = _remainingSeconds ~/ 3600;
    final m = (_remainingSeconds % 3600) ~/ 60;
    final s = _remainingSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool get isLowTime => _remainingSeconds <= 60;

  // ─────────────────────────────────────────────────────────────────────────
  // SECTION HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  int firstIndexOfSection(int sectionIndex) {
    for (int i = 0; i < _questions.length; i++) {
      if (_questions[i].question.sectionIndex == sectionIndex) return i;
    }
    return 0;
  }

  void goToSection(int sectionIndex) {
    final idx = firstIndexOfSection(sectionIndex);
    goToQuestion(idx);
  }
// ✅ ADD THIS inside ExamSessionProvider class
void skipQuestion() {
  final q = currentQuestion;
  if (q == null) return;
  q.status = 'skipped';
  notifyListeners();
  nextQuestion();
}
  // ─────────────────────────────────────────────────────────────────────────
  // RESUME QUESTION INDEX
  // ─────────────────────────────────────────────────────────────────────────

  int _getResumeQuestionIndex(List<QuestionItem> questions) {
    if (questions.isEmpty) return 0;
    final firstNotVisited =
        questions.indexWhere((q) => q.status == 'not_visited');
    if (firstNotVisited >= 0) return firstNotVisited;
    final firstSkipped = questions.indexWhere(
      (q) => q.status == 'skipped' && q.answer == null,
    );
    if (firstSkipped >= 0) return firstSkipped;
    final firstMarked =
        questions.indexWhere((q) => q.status == 'marked_for_review');
    if (firstMarked >= 0) return firstMarked;
    return questions.length - 1;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INIT PER-QUESTION REMAINING TIMES
  //
  // For regular questions  → key = questionId
  // For connected questions → key = subQuestion.id  (each sub has its own key)
  // ─────────────────────────────────────────────────────────────────────────

  void _initQuestionRemainingTimes(List<QuestionItem> questions) {
    for (final q in questions) {
      if (q.question.isConnected) {
        // Each sub-question gets its own entry keyed by its own ID.
        for (final sub in q.question.subQuestions) {
          _questionRemainingTimes.putIfAbsent(
            sub.id,
            () =>
                sub.remainingQuestionTimeSeconds ?? q.recommendedTimeSeconds,
          );
        }
      } else {
        _questionRemainingTimes.putIfAbsent(
          q.questionId,
          () => q.recommendedTimeSeconds,
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SYNC FROM VISIT RESPONSE
  // Reads server-authoritative remaining times and patches local map.
  // ─────────────────────────────────────────────────────────────────────────

void _syncFromVisitResponse(VisitQuestionsModels response) {
  final qs = response.data?.questions;
  if (qs == null) return;

  for (final q in qs) {
    final qId = q.questionId;
    if (qId == null) continue;

    final serverSecs = q.remainingQuestionTimeSeconds;
    if (serverSecs != null && serverSecs >= 0) {
      _questionRemainingTimes[qId] = serverSecs;
    }
  }

  final sessionRemaining = response.data?.session?.remainingTime;
  if (sessionRemaining != null) {
    _remainingSeconds = (sessionRemaining / 1000).floor();
  }
}
  // ─────────────────────────────────────────────────────────────────────────
  // INSTRUCTIONS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> loadInstructions(
    String testId, {
    String? categoryId,
  }) async {
    _instructionsLoading = true;
    _instructionsError = '';
    _instructionsData = null;
    notifyListeners();

    try {
      final response = await _repository.getInstructions(
        testId,
        categoryId: categoryId,
      );

      if (response.success && response.data != null) {
        _instructionsData = response;
        _instructionsError = '';
      } else {
        _instructionsError = response.message.isNotEmpty
            ? response.message
            : 'Failed to load instructions.';
      }
    } on AppException catch (e) {
      _instructionsError = e.message;
    } catch (_) {
      _instructionsError = 'Failed to load instructions. Please try again.';
    } finally {
      _instructionsLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // START EXAM
  // ─────────────────────────────────────────────────────────────────────────

  Future<ExamStartResult> startExam(
    String testId, {
    bool isBundleTest = false,
    String? categoryId,
  }) async {
    _setStatus(ExamStatus.starting);
    _errorMessage = '';

    try {
      final response = await _repository.startExam(
        testId,
        isBundleTest: isBundleTest,
        categoryId: categoryId,
      );
      return await _applySession(response);
    } on AppException catch (e) {
      if (e.sessionId != null && e.sessionId!.isNotEmpty) {
        _sessionId = e.sessionId!;
        try {
          final res = await _repository.getResults(e.sessionId!);
          _results = res.data;
        } catch (_) {}
        _setStatus(ExamStatus.completed);
        return ExamStartResult.alreadyCompleted;
      }

      if (e.message.toLowerCase().contains('not purchased') ||
          e.message.toLowerCase().contains('access denied')) {
        _errorMessage = e.message;
        _setStatus(ExamStatus.error);
        return ExamStartResult.notPurchased;
      }

      _errorMessage = e.message;
      _setStatus(ExamStatus.error);
      return ExamStartResult.error;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      _setStatus(ExamStatus.error);
      return ExamStartResult.error;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // RESUME SESSION
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> resumeSession(String sessionId) async {
    _setStatus(ExamStatus.starting);
    _errorMessage = '';

    try {
      final response = await _repository.getSession(sessionId);
      await _applySession(response, isResume: true);
    } on AppException catch (e) {
      _errorMessage = e.message;
      _setStatus(ExamStatus.error);
    } catch (e) {
      _errorMessage = 'Failed to resume session. Please try again.';
      _setStatus(ExamStatus.error);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // APPLY SESSION DATA
  // ─────────────────────────────────────────────────────────────────────────

  Future<ExamStartResult> _applySession(
    ExamSessionResponse response, {
    bool isResume = false,
  }) async {
    final data = response.data;
    if (data == null) {
      _errorMessage = 'No session data received.';
      _setStatus(ExamStatus.error);
      return ExamStartResult.error;
    }

    final session = data.session;

    if (session.isCompleted) {
      _sessionId = session.id;
      try {
        final res = await _repository.getResults(session.id);
        _results = res.data;
      } catch (_) {}
      _setStatus(ExamStatus.completed);
      return ExamStartResult.alreadyCompleted;
    }

    _sessionId = session.id;
    _questions = data.questions;
    _sectionedQuestions = data.sectionedQuestions;
    _remainingSeconds = session.remainingSeconds;
    _lastVisitedQuestionId = null;
    _activeSubIndex = 0;

    _initQuestionRemainingTimes(_questions);

    if (isResume) {
      _currentIndex = _getResumeQuestionIndex(_questions);
      final lastVisited = _questions.lastIndexWhere(
        (q) => q.status != 'not_visited',
      );
      _maxReachedIndex =
          lastVisited > _currentIndex ? lastVisited : _currentIndex;
    } else {
      _currentIndex = 0;
      _maxReachedIndex = 0;
    }

    _isPaused = false;
    _pauseApiCalled = false;
    _stopTimers();
    _setStatus(ExamStatus.inProgress);
    _startLocalTimer();
    _connectSocket();

    // Visit the initial question so the server starts its per-question timer.
    // We call this AFTER setStatus(inProgress) so the UI is already shown.
    await _visitQuestion(_currentIndex, subIndex: 0);

    return ExamStartResult.started;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // VISIT QUESTION — central method, called from all navigation paths
  //
  // For connected questions the backend expects the SUB-QUESTION's _id,
  // not the parent passage container _id. This method handles that routing.
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _visitQuestion(int index, {int subIndex = 0}) async {
    if (_sessionId.isEmpty) return;
    if (index < 0 || index >= _questions.length) return;

    final parentItem = _questions[index];
    final isConnected = parentItem.question.isConnected;

    // Resolve the ID to send to the backend.
    // Connected questions → use sub-question's own _id.
    // Regular questions   → use the question's own id.
    String idToVisit;
    if (isConnected && parentItem.question.subQuestions.isNotEmpty) {
      final clampedSub =
          subIndex.clamp(0, parentItem.question.subQuestions.length - 1);
      idToVisit = parentItem.question.subQuestions[clampedSub].id;
    } else {
      idToVisit = parentItem.questionId;
    }

    // Don't re-visit an already-expired sub/question
    if (_expiredQuestionIds.contains(idToVisit)) return;

    // Debounce: skip if we already just visited this same ID
    if (_lastVisitedQuestionId == idToVisit) return;
    _lastVisitedQuestionId = idToVisit;

    _startQuestionCountdown();
    notifyListeners();

    try {
      final res = await _repository.visitQuestion(
        sessionId: _sessionId,
        questionId: idToVisit,
      );

      if (res.success == true) {
        _syncFromVisitResponse(res);
        if (_currentIndex == index) {
          _startQuestionCountdown();
          notifyListeners();
        }
      }
    } on AppException catch (e) {
      // Server returns 400 / error when the question/sub-question time is over.
      if (e.message.toLowerCase().contains('time is over') ||
          e.message.toLowerCase().contains('cannot open')) {
        _expiredQuestionIds.add(idToVisit);
        // Zero out the local timer for this ID
        _questionRemainingTimes[idToVisit] = 0;
        notifyListeners();
      }
      debugPrint('⚠️ visitQuestion failed for id=$idToVisit: ${e.message}');
    } catch (_) {
      debugPrint('⚠️ visitQuestion failed (non-fatal) for id=$idToVisit');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SET ACTIVE SUB-QUESTION
  //
  // Called by the UI when the user taps / scrolls into a different
  // sub-question inside the same connected passage. This switches the active
  // countdown and fires the visit API for that specific sub-question.
  // ─────────────────────────────────────────────────────────────────────────

  void setActiveSubIndex(int subIndex) {
    final q = currentQuestion;
    if (q == null || !q.question.isConnected) return;
    if (subIndex < 0 || subIndex >= q.question.subQuestions.length) return;

    // Check if new sub is already expired — still allow switching for UI
    // but don't fire the visit API.
    final subId = q.question.subQuestions[subIndex].id;
    final alreadyActive = _activeSubIndex == subIndex &&
        _lastVisitedQuestionId == subId;

    _activeSubIndex = subIndex;
    notifyListeners();

    if (!alreadyActive) {
      // Fire the visit API with the new sub-question's ID so the backend
      // pauses the previous sub's timer and starts the new one.
      _visitQuestion(_currentIndex, subIndex: subIndex);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TIMERS — GLOBAL
  // ─────────────────────────────────────────────────────────────────────────

  void _startLocalTimer() {
    _localTimer?.cancel();
    _localTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isPaused) return;
      if (_remainingSeconds <= 0) {
        _localTimer?.cancel();
        _handleTimeExpired();
        return;
      }
      _remainingSeconds--;
      notifyListeners();
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TIMERS — PER QUESTION / PER SUB-QUESTION
  //
  // Uses _activeTimerKey which resolves to:
  //   • subId        when viewing a connected question
  //   • questionId   for regular questions
  // ─────────────────────────────────────────────────────────────────────────

  void _startQuestionCountdown() {
    _questionTimer?.cancel();

    final timerKey = _activeTimerKey;
    if (timerKey.isEmpty) return;

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isPaused) return;

      final remaining = _questionRemainingTimes[timerKey] ?? 0;

      if (remaining <= 0) {
        _questionTimer?.cancel();
        _onQuestionTimeExpired();
        return;
      }

      _questionRemainingTimes[timerKey] = remaining - 1;
      notifyListeners();
    });
  }

  void _onQuestionTimeExpired() {
    final q = currentQuestion;
    if (q == null) return;

    if (q.question.isConnected) {
      // ── Connected question: expire only the active sub-question ──────────
      final clampedSub =
          _activeSubIndex.clamp(0, q.question.subQuestions.length - 1);
      final sub = q.question.subQuestions[clampedSub];

      _expiredQuestionIds.add(sub.id);
      _questionRemainingTimes[sub.id] = 0;
      // Reset debounce so the NEXT sub/question visit fires cleanly
      _lastVisitedQuestionId = null;
      notifyListeners();

      final hasMoreSubs = _activeSubIndex < q.question.subQuestions.length - 1;

      if (hasMoreSubs) {
        // Auto-advance to the next sub-question after a short grace period.
        Future.delayed(const Duration(seconds: 1), () {
          if (_status == ExamStatus.inProgress) {
            setActiveSubIndex(_activeSubIndex + 1);
          }
        });
      } else {
        // All sub-questions in this passage are done — move to the next
        // parent question (if any).
        if (_currentIndex < _questions.length - 1) {
          Future.delayed(const Duration(seconds: 1), () {
            if (_status == ExamStatus.inProgress) {
              goToQuestion(_currentIndex + 1);
            }
          });
        }
        // On the very last question: stays locked, user must submit manually.
      }
    } else {
      // ── Regular question: existing behaviour ─────────────────────────────
      final expiredQId = q.questionId;
      _expiredQuestionIds.add(expiredQId);
      _questionRemainingTimes[expiredQId] = 0;
      _lastVisitedQuestionId = null;
      notifyListeners();

      if (_currentIndex < _questions.length - 1) {
        Future.delayed(const Duration(seconds: 1), () {
          if (_status == ExamStatus.inProgress) {
            goToQuestion(_currentIndex + 1);
          }
        });
      }
    }
  }

  void _stopTimers() {
    _localTimer?.cancel();
    _questionTimer?.cancel();
    _localTimer = null;
    _questionTimer = null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SOCKET CALLBACKS
  // ─────────────────────────────────────────────────────────────────────────

  void _onSocketTimerUpdate(int remainingTimeMs) {
    _remainingSeconds = (remainingTimeMs / 1000).floor();
    notifyListeners();
  }

  void _onSocketAutoSubmitted(String reason) {
    _autoSubmitReason = reason;
    _stopTimers();
    if (_sessionId.isNotEmpty) {
      _repository
          .getResults(_sessionId)
          .then((res) {
            _results = res.data;
            _setStatus(ExamStatus.completed);
          })
          .catchError((_) => _setStatus(ExamStatus.completed));
    } else {
      _setStatus(ExamStatus.completed);
    }
  }

  void _onSocketProctoringLogged(int violationCount, String message) {
    _violationCount = violationCount;
    notifyListeners();
  }

  void _onSocketError(String message) {
    debugPrint('! Socket error (non-fatal): $message');
  }

  void _onSocketSessionExpired() {
    _handleTimeExpired();
  }

  void _handleTimeExpired() {
    if (_status == ExamStatus.completed || _status == ExamStatus.submitting) {
      return;
    }
    _autoSubmitReason = 'time_expired';
    _stopTimers();
    submitExam();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SOCKET
  // ─────────────────────────────────────────────────────────────────────────

  void _connectSocket() {
    if (_sessionId.isNotEmpty) {
      _socketService.joinSession(_sessionId);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // QUESTION NAVIGATION — all paths go through goToQuestion → _visitQuestion
  // ─────────────────────────────────────────────────────────────────────────

  void goToQuestion(int index) {
    if (index < 0 || index >= _questions.length) return;
    if (index > _maxReachedIndex + 1) return;

    _currentIndex = index;
    // Always reset to the first sub-question when switching parent questions.
    _activeSubIndex = 0;

    if (index > _maxReachedIndex) _maxReachedIndex = index;

    if (_questions[index].status == 'not_visited') {
      _questions[index].status = 'skipped';
    }

    notifyListeners();

    // Fire visit API — handles debounce, local countdown, and server sync.
    // subIndex: 0 because we always start at the first sub when entering a
    // connected question from the navigation bar / palette.
    _visitQuestion(index, subIndex: 0);
  }

  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      goToQuestion(_currentIndex + 1);
    }
  }

  void previousQuestion() {
    if (_currentIndex > 0) {
      goToQuestion(_currentIndex - 1);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ANSWER SELECTION
  // ─────────────────────────────────────────────────────────────────────────

  void selectAnswer(String optionId, {String? optionText}) {
    final q = currentQuestion;
    if (q == null) return;

    final textToStore = optionText ?? optionId;
    final type = q.question.questionType;

    if (type == 'multiple') {
      List<String> selectedTexts = [];
      List<String> selectedIds = [];
      if (q.answer is List) selectedTexts = List<String>.from(q.answer as List);
      if (q.answerId is List) {
        selectedIds = List<String>.from(q.answerId as List);
      }

      final idIndex = selectedIds.indexOf(optionId);
      if (idIndex >= 0) {
        selectedIds.removeAt(idIndex);
        selectedTexts.removeAt(idIndex);
      } else {
        selectedIds.add(optionId);
        selectedTexts.add(textToStore);
      }

      q.answer = selectedTexts.isEmpty ? null : selectedTexts;
      q.answerId = selectedIds.isEmpty ? null : selectedIds;
    } else {
      final alreadySelected = q.answerId == optionId;
      q.answer = alreadySelected ? null : textToStore;
      q.answerId = alreadySelected ? null : optionId;
    }

    q.status = q.answer != null ? 'answered' : 'skipped';
    notifyListeners();

    if (q.answer != null && _sessionId.isNotEmpty) {
      _repository
          .saveAnswer(
            sessionId: _sessionId,
            questionId: q.questionId,
            answer: q.answerId,
            status: q.status,
          )
          .catchError((_) {});
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MARK FOR REVIEW
  // ─────────────────────────────────────────────────────────────────────────

  void markCurrentForReview() {
    final q = currentQuestion;
    if (q == null) return;
    q.status = 'marked_for_review';
    notifyListeners();
    if (_sessionId.isNotEmpty) {
      _repository
          .markForReview(sessionId: _sessionId, questionId: q.questionId)
          .catchError((_) {});
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SUB-QUESTION ANSWER SELECTION (connected / passage questions)
  //
  // Saves via the parent questionId (aggregated sub-answers map) OR directly
  // via the sub-question's own ID — both are supported by the backend.
  // We use the sub-question's own ID here as per the API guide.
  // ─────────────────────────────────────────────────────────────────────────

  void selectSubAnswer(
    String subQuestionId,
    String optionId, {
    required String optionText,
  }) {
    final q = currentQuestion;
    if (q == null || !q.question.isConnected) return;

    final subQ = q.question.subQuestions
        .where((s) => s.id == subQuestionId)
        .firstOrNull;
    if (subQ == null) return;

    final valueToStore = optionText;

    if (subQ.questionType == 'multiple') {
      List<String> selected = [];
      if (subQ.studentAnswer is List) {
        selected = List<String>.from(subQ.studentAnswer as List);
      }
      if (selected.contains(valueToStore)) {
        selected.remove(valueToStore);
      } else {
        selected.add(valueToStore);
      }
      subQ.studentAnswer = selected.isEmpty ? null : selected;
    } else {
      subQ.studentAnswer =
          (subQ.studentAnswer == valueToStore) ? null : valueToStore;
    }

    subQ.status = subQ.studentAnswer != null ? 'answered' : 'skipped';

    // Rebuild parent answer as Map<subQuestionId, answer> so the existing
    // save-answer API can carry all sub-answers in one call.
    final Map<String, dynamic> answersMap = {};
    for (final s in q.question.subQuestions) {
      if (s.studentAnswer != null) {
        answersMap[s.id] = s.studentAnswer;
      }
    }
    q.answer = answersMap.isEmpty ? null : answersMap;
    q.status = q.answer != null ? 'answered' : 'skipped';

    notifyListeners();

    // Send to backend using the sub-question's own ID as per the API guide.
    if (_sessionId.isNotEmpty) {
      _repository
          .saveAnswer(
            sessionId: _sessionId,
            questionId: subQuestionId, // ← sub-question ID, not parent
            answer: subQ.studentAnswer != null ? optionId : null,
            status: subQ.status,
          )
          .catchError((_) {});
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CLEAR RESPONSE
  // ─────────────────────────────────────────────────────────────────────────

  void clearResponse() {
    final q = currentQuestion;
    if (q == null) return;

    if (q.question.isConnected) {
      for (final s in q.question.subQuestions) {
        s.studentAnswer = null;
        s.status = 'skipped';
      }
    }

    q.answer = null;
    q.answerId = null;
    q.status = 'skipped';
    notifyListeners();

    if (_sessionId.isNotEmpty) {
      _repository
          .skipQuestion(sessionId: _sessionId, questionId: q.questionId)
          .catchError((_) {});
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SUBMIT
  // ─────────────────────────────────────────────────────────────────────────

  Future<ExamResultsData?> submitExam() async {
    if (_sessionId.isEmpty) return null;
    if (_status == ExamStatus.submitting || _status == ExamStatus.completed) {
      return _results;
    }

    _setStatus(ExamStatus.submitting);
    _stopTimers();
    _socketService.leaveSession(_sessionId);

    try {
      final response = await _repository.submitExam(_sessionId);

      if (!response.success || response.data?.results == null) {
        final msg = response.message.isNotEmpty
            ? response.message
            : 'Failed to submit exam.';
        throw AppException(msg);
      }

      _results = response.data;
      _setStatus(ExamStatus.completed);
      return _results;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _setStatus(ExamStatus.error);
      return null;
    } catch (e) {
      debugPrint('submitExam error: $e');
      _errorMessage = 'Failed to submit exam. Please try again.';
      _setStatus(ExamStatus.error);
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FETCH RESULTS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> fetchResults(String sessionId) async {
    try {
      final response = await _repository.getResults(sessionId);

      if (!response.success || response.data == null) {
        throw AppException(response.message);
      }

      _results = response.data;
      notifyListeners();
    } catch (e) {
      debugPrint('fetchResults error: $e');
      _errorMessage = 'Failed to load results.';
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PROCTORING
  // ─────────────────────────────────────────────────────────────────────────

  void logProctoringEvent(ProctoringEventType eventType) {
    if (_sessionId.isEmpty) return;
    _violationCount++;
    notifyListeners();
    _socketService.emitProctoringEvent(_sessionId, eventType.value);
    _repository
        .logProctoringEvent(sessionId: _sessionId, eventType: eventType)
        .then((res) {
          if (res.data?.autoSubmitted == true) {
            _onSocketAutoSubmitted('proctoring_violation');
          }
        })
        .catchError((_) {});
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PAUSE / RESUME
  // ─────────────────────────────────────────────────────────────────────────

  void pauseForExit() {
    _isPaused = true;
    if (_sessionId.isNotEmpty && !_pauseApiCalled) {
      _pauseApiCalled = true;
      _repository.pauseSession(_sessionId).catchError((_) {});
    }
  }

  void resumeExam() {
    _isPaused = false;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  void _setStatus(ExamStatus s) {
    _status = s;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // RESET
  // ─────────────────────────────────────────────────────────────────────────

  void reset() {
    _stopTimers();
    if (_sessionId.isNotEmpty) {
      _socketService.leaveSession(_sessionId);
    }

    _status = ExamStatus.idle;
    _sessionId = '';
    _questions = [];
    _sectionedQuestions = [];
    _currentIndex = 0;
    _maxReachedIndex = 0;
    _activeSubIndex = 0;
    _remainingSeconds = 0;
    _questionRemainingTimes.clear();
    _expiredQuestionIds.clear();
    _lastVisitedQuestionId = null;
    _violationCount = 0;
    _results = null;
    _autoSubmitReason = null;
    _errorMessage = '';
    _isPaused = false;
    _pauseApiCalled = false;
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }
}