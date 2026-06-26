export 'package:firstedu/view_models/examhallprovider/examsessionprovider.dart';
import 'package:firstedu/data/models/api_models/examhall/examsessionmodels.dart';
import 'package:firstedu/data/models/api_models/examhall/resultmodels.dart';
import 'package:firstedu/data/repo/examhall/examsessionrepositories.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_button.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view/indexscreen/entryscreen.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/instantresultscreen.dart';
import 'package:firstedu/view_models/examhallprovider/examsessionprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ExamScreen extends StatefulWidget {
  final String testId;
  final String examTitle;
  final String? existingSessionId;
  final bool isBundleTest;
  final bool isHost;
  final bool showPauseButton;
  final String? categoryId;
  final bool showInstantResult;
  final DateTime? resultDeclaredAt;

  const ExamScreen({
    super.key,
    required this.testId,
    required this.examTitle,
    this.existingSessionId,
    this.isBundleTest = false,
    this.isHost = false,
    this.showPauseButton = false,
    this.categoryId,
    this.showInstantResult = true,
    this.resultDeclaredAt,
  });

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> with WidgetsBindingObserver {
  bool _showQuestionPalette = false;
  bool _violationDialogShowing = false;
  int _lastShownViolationCount = 0;
  bool _autoSubmitHandled = false;

  // Prevents multiple simultaneous back-press submits
  bool _isSubmittingViaBack = false;

  ExamSessionProvider? _cachedProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cachedProvider = context.read<ExamSessionProvider>();
      _initExam();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // dispose no longer pauses — pause is only via the pause button
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final provider = context.read<ExamSessionProvider>();
    if (provider.status != ExamStatus.inProgress) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      provider.logProctoringEvent(ProctoringEventType.windowBlur);
    }
  }

  // ── Called when user presses the hardware/gesture back button ──────────────
  Future<bool> _onWillPop() async {
    final provider = _cachedProvider ?? context.read<ExamSessionProvider>();

    // If exam is not in progress, allow normal pop
    if (provider.status != ExamStatus.inProgress) return true;

    // Prevent double-tap
    if (_isSubmittingViaBack) return false;

    // Show confirmation dialog before submitting
    final confirmed = await _showBackSubmitDialog(provider);
    return false; // We handle navigation ourselves inside the dialog
  }

  Future<bool> _showBackSubmitDialog(ExamSessionProvider p) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.exit_to_app_rounded,
                      color: Colors.red,
                      size: 42.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  CustomText(
                    text: 'Submit & Exit?',
                    size: 20,
                    weight: FontWeight.w700,
                    color: Colors.black87,
                    align: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  CustomText(
                    text:
                        'Going back will submit your exam immediately.\nAre you sure you want to exit?',
                    size: 13,
                    color: Colors.grey.shade600,
                    align: TextAlign.center,
                    maxLines: 4,
                  ),
                  SizedBox(height: 20.h),
                  _statsWidget(p),
                  SizedBox(height: 24.h),
                  // Submit & Exit button
                  CustomButton(
                    title: 'Submit & Exit',
                    onTap: () async {
                      Navigator.of(context, rootNavigator: true).pop(true);
                      await _submitAndExit(p);
                    },
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    icon: Icons.send_rounded,
                    height: 50.h,
                  ),
                  SizedBox(height: 12.h),
                  // Stay in exam button
                  CustomButton(
                    title: 'Continue Exam',
                    onTap: () =>
                        Navigator.of(context, rootNavigator: true).pop(false),
                    primary: false,
                    backgroundColor: Colors.white,
                    textColor: drawerColor,
                    borderColor: drawerColor,
                    icon: Icons.play_arrow_rounded,
                    height: 50.h,
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }

  Future<void> _submitAndExit(ExamSessionProvider p) async {
    if (_isSubmittingViaBack) return;
    setState(() => _isSubmittingViaBack = true);

    try {
      final results = await p.submitExam();
      if (!mounted) return;

      if (results != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => ExamResultsScreen(
              sessionId: p.sessionId ?? '',
              preloadedResults: results,
              showInstantResult: widget.showInstantResult,
              resultDeclaredAt: widget.resultDeclaredAt,
            ),
          ),
          (route) => route.isFirst,
        );
      } else {
        AppToast.error(
          context,
          title: 'Submit Failed',
          message: p.errorMessage,
        );
        setState(() => _isSubmittingViaBack = false);
      }
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, title: 'Submit Failed', message: e.toString());
      setState(() => _isSubmittingViaBack = false);
    }
  }

  bool _isOptionSelected(QuestionItem item, QuestionOption option) {
    final answerId = item.answerId;
    // ✅ primary: match by ID (handles duplicate text)
    if (answerId != null) {
      if (answerId is List) return answerId.contains(option.id);
      return answerId == option.id;
    }
    // fallback: match by text (for resumed sessions where answerId is null)
    final answer = item.answer;
    if (answer == null) return false;
    if (answer is List) return answer.contains(option.text);
    return answer == option.text;
  }

  void _maybeShowViolationDialog(
    BuildContext context,
    ExamSessionProvider provider,
  ) {
    final count = provider.violationCount;
    if (count == 0) return;
    if (count <= _lastShownViolationCount) return;
    if (_violationDialogShowing) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_violationDialogShowing) return;

      _lastShownViolationCount = count;
      _violationDialogShowing = true;

      final isFinal = count >= ExamSessionProvider.maxViolations;

      if (isFinal) {
        provider.submitExam().then((_) {
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => _violationDialogWidget(context, provider, count),
          ).then((_) => _violationDialogShowing = false);
        });
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => _violationDialogWidget(context, provider, count),
        ).then((_) => _violationDialogShowing = false);
      }
    });
  }

  Widget _violationDialogWidget(
    BuildContext context,
    ExamSessionProvider provider,
    int count,
  ) {
    final isFinal = count >= ExamSessionProvider.maxViolations;
    final remaining = ExamSessionProvider.maxViolations - count;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 48.sp,
              ),
            ),
            SizedBox(height: 16.h),
            CustomText(
              text: isFinal ? 'Exam Auto-Submitted!' : 'Proctoring Warning',
              size: 20,
              weight: FontWeight.w700,
              color: Colors.black87,
              align: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(ExamSessionProvider.maxViolations, (i) {
                final filled = i < count;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 6.w),
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: filled ? Colors.red : Colors.grey.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: filled ? Colors.red : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: CustomText(
                    text: '${i + 1}',
                    size: 15,
                    weight: FontWeight.w700,
                    color: filled ? Colors.white : Colors.grey.shade400,
                  ),
                );
              }),
            ),
            SizedBox(height: 12.h),
            CustomText(
              text:
                  '$count / ${ExamSessionProvider.maxViolations} violations recorded',
              size: 14,
              weight: FontWeight.w700,
              color: Colors.red,
              align: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            CustomText(
              text: isFinal
                  ? 'You have exceeded the maximum allowed violations.\nYour exam has been auto-submitted.'
                  : 'Leaving the exam screen is not allowed.\n$remaining more violation(s) will auto-submit your exam.',
              size: 13,
              color: Colors.grey.shade600,
              align: TextAlign.center,
              maxLines: 4,
            ),
            SizedBox(height: 24.h),
            CustomButton(
              title: isFinal ? 'View Results' : 'Continue Exam',
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop();
                if (isFinal) {
                  final sid = provider.sessionId ?? '';
                  if (sid.isNotEmpty) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExamResultsScreen(
                          sessionId: sid,
                          preloadedResults: provider.results,
                          showInstantResult: widget.showInstantResult,
                          resultDeclaredAt: widget.resultDeclaredAt,
                        ),
                      ),
                      (route) => route.isFirst,
                    );
                  }
                }
              },
              backgroundColor: isFinal ? Colors.red : drawerColor,
              textColor: Colors.white,
              icon: isFinal
                  ? Icons.bar_chart_rounded
                  : Icons.play_arrow_rounded,
              height: 50.h,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initExam() async {
    _autoSubmitHandled = false;
    final provider = _cachedProvider ?? context.read<ExamSessionProvider>();
    _cachedProvider = provider;
    ExamStartResult result;

    if (widget.existingSessionId != null) {
      await provider.resumeSession(widget.existingSessionId!);
      switch (provider.status) {
        case ExamStatus.inProgress:
          result = ExamStartResult.started;
          break;
        case ExamStatus.completed:
          result = ExamStartResult.alreadyCompleted;
          break;
        default:
          result = ExamStartResult.error;
      }
    } else {
      result = await provider.startExam(
        widget.testId,
        isBundleTest: widget.isBundleTest,
        categoryId: widget.categoryId,
      );
    }

    if (!mounted) return;

    switch (result) {
      case ExamStartResult.started:
        break;
      case ExamStartResult.alreadyCompleted:
        final sessionId = provider.sessionId;
        if (sessionId != null && sessionId.isNotEmpty) {
          if (widget.existingSessionId != null) {
            AppToast.warning(
              context,
              title: 'Session Expired',
              message:
                  'Your exam time ran out while you were away. Showing your results.',
            );
          }
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => ExamResultsScreen(
                sessionId: sessionId,
                preloadedResults: provider.results,
                showInstantResult: widget.showInstantResult,
                resultDeclaredAt: widget.resultDeclaredAt,
              ),
            ),
            (route) => route.isFirst,
          );
        } else {
          AppToast.error(
            context,
            title: 'Already Completed',
            message: 'You have already completed this exam.',
          );
          Navigator.pop(context);
        }
        break;
      case ExamStartResult.notPurchased:
        AppToast.error(
          context,
          title: 'Not Purchased',
          message: provider.errorMessage,
        );
        Navigator.pop(context);
        break;
      case ExamStartResult.error:
        AppToast.error(context, title: 'Error', message: provider.errorMessage);
        Navigator.pop(context);
        break;
    }
  }

  void _handleAutoSubmit(ExamSessionProvider p) {
    if (_autoSubmitHandled) return;
    if (p.status == ExamStatus.completed && p.results != null && mounted) {
      _autoSubmitHandled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final reason = p.autoSubmitReason ?? '';
        if (reason.isNotEmpty) {
          AppToast.warning(
            context,
            title: reason == 'proctoring_violation'
                ? 'Auto Submitted'
                : 'Time Expired',
            message: reason == 'proctoring_violation'
                ? 'Exam auto-submitted due to proctoring violations.'
                : 'Time is up! Your exam has been submitted.',
          );
        }
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => ExamResultsScreen(
              sessionId: p.sessionId ?? '',
              preloadedResults: p.results,
              showInstantResult: widget.showInstantResult,
              resultDeclaredAt: widget.resultDeclaredAt,
            ),
          ),
          (route) => route.isFirst,
        );
      });
    }
  }

  // ── Pause button: only pauses, does NOT submit ─────────────────────────────
  void _onPauseTap(ExamSessionProvider p) {
    p.pauseForExit();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const EntryScreen(initialIndex: 0)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope intercepts back button and hardware back gesture
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Consumer<ExamSessionProvider>(
        builder: (context, provider, _) {
          _handleAutoSubmit(provider);
          _maybeShowViolationDialog(context, provider);

          if (provider.status == ExamStatus.idle ||
              provider.status == ExamStatus.starting) {
            return _loadingScaffold();
          }
          if (provider.status == ExamStatus.error) {
            return _errorScaffold(provider);
          }

          // Show loading overlay while submitting via back
          if (_isSubmittingViaBack) {
            return _submittingScaffold();
          }

          final question = provider.currentQuestion;
          if (question == null) {
            return Scaffold(
              body: Center(
                child: Text(
                  "No questions available",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: const Color(0xFFF6F7FB),
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(provider),
                  if (provider.hasSections) _buildSectionTabs(provider),
                  _buildQuickNav(provider),
                  if (_showQuestionPalette) _buildExpandedPalette(provider),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          _buildQuestionCard(provider, question),
                          SizedBox(height: 16.h),
                          _buildActionButtons(provider),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),
                  _buildNavigationBar(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Shown while submitting in the background after back press ──────────────
  Widget _submittingScaffold() => Scaffold(
    backgroundColor: const Color(0xFFF6F7FB),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: drawerColor),
          SizedBox(height: 16.h),
          CustomText(
            text: 'Submitting exam…',
            size: 15,
            color: Colors.grey.shade600,
          ),
        ],
      ),
    ),
  );

  Widget _buildHeader(ExamSessionProvider p) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [drawerColor, drawerColor.withOpacity(0.9)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: widget.examTitle,
                  size: 16,
                  weight: FontWeight.w700,
                  color: Colors.white,
                  maxLines: 1,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    CustomText(
                      text: 'Q${p.currentIndex + 1}/${p.questions.length}',
                      size: 13,
                      weight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                    if (p.violationCount > 0) ...[
                      SizedBox(width: 10.w),
                      _violationHeaderBadge(p),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (widget.showPauseButton) ...[
            GestureDetector(
              onTap: () => _onPauseTap(p),
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: accentOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: accentOrange, width: 1.5),
                ),
                child: Icon(
                  Icons.pause_rounded,
                  size: 22.sp,
                  color: accentOrange,
                ),
              ),
            ),
            SizedBox(width: 12.w),
          ],
          SizedBox(width: 12.w),
          _timerBadge(
            label: p.formattedTime,
            icon: Icons.access_time_rounded,
            isLow: p.isLowTime,
            padded: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTabs(ExamSessionProvider p) {
    return Container(
      height: 44.h,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        itemCount: p.sectionedQuestions.length,
        itemBuilder: (_, i) {
          final section = p.sectionedQuestions[i];
          final isActive = p.currentSectionIndex == section.index;

          final sectionQIds = section.questions
              .map((q) => q.questionId)
              .toSet();
          final answeredInSection = p.questions
              .where(
                (q) =>
                    sectionQIds.contains(q.questionId) &&
                    q.status == 'answered',
              )
              .length;

          final diffColor = _difficultyColor(section.difficulty);

          return GestureDetector(
            onTap: () => p.goToSection(section.index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: isActive ? drawerColor : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isActive ? drawerColor : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7.w,
                    height: 7.h,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white70 : diffColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  CustomText(
                    text: section.name,
                    size: 12,
                    weight: FontWeight.w700,
                    color: isActive ? Colors.white : Colors.black87,
                  ),
                  SizedBox(width: 6.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withOpacity(0.25)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: CustomText(
                      text: '$answeredInSection/${section.count}',
                      size: 10,
                      weight: FontWeight.w700,
                      color: isActive ? Colors.white : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

Widget _buildQuickNav(ExamSessionProvider p) {
  final skippedCount = p.questions
      .where((q) => q.status == 'skipped' && !p.isQuestionExpired(q.questionId))
      .length;
  final timeLockedCount = p.questions
      .where((q) => p.isQuestionExpired(q.questionId))
      .length;

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 10.w,
            runSpacing: 4.h,
            children: [
              _dot(successColor, p.answeredCount, 'Done'),
              _dot(Colors.orange, p.markedCount, 'Review'),
              _dot(Colors.cyan.shade400, skippedCount, 'Skip'),
              if (timeLockedCount > 0)
                _dot(Colors.grey.shade400, timeLockedCount, 'Locked'),
            ],
          ),
        ),
        GestureDetector(
          onTap: () =>
              setState(() => _showQuestionPalette = !_showQuestionPalette),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: _showQuestionPalette
                  ? drawerColor
                  : drawerColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: drawerColor, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _showQuestionPalette
                      ? Icons.grid_view_rounded
                      : Icons.grid_view_outlined,
                  size: 16.sp,
                  color: _showQuestionPalette ? Colors.white : drawerColor,
                ),
                SizedBox(width: 4.w),
                CustomText(
                  text: 'Questions',
                  size: 12,
                  weight: FontWeight.w600,
                  color: _showQuestionPalette ? Colors.white : drawerColor,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
  Widget _dot(Color color, int count, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 9.w,
        height: 9.h,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      SizedBox(width: 4.w),
      CustomText(
        text: '$count $label',
        size: 12,
        weight: FontWeight.w600,
        color: Colors.black87,
      ),
    ],
  );

  Widget _buildExpandedPalette(ExamSessionProvider p) {
    return Container(
      constraints: BoxConstraints(maxHeight: 320.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: p.hasSections
          ? _buildSectionedPalette(p)
          : _buildFlatPalette(p, p.questions, 0),
    );
  }

  Widget _buildSectionedPalette(ExamSessionProvider p) {
    return DefaultTabController(
      length: p.sectionedQuestions.length,
      initialIndex: p.currentSectionIndex.clamp(
        0,
        p.sectionedQuestions.length - 1,
      ),
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            labelColor: drawerColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: drawerColor,
            labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
            tabs: p.sectionedQuestions.map((s) => Tab(text: s.name)).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: p.sectionedQuestions.map((section) {
                final startIdx = p.questions.indexWhere(
                  (q) => q.questionId == section.questions.first.questionId,
                );
                return _buildFlatPalette(
                  p,
                  section.questions,
                  startIdx < 0 ? 0 : startIdx,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlatPalette(
    ExamSessionProvider p,
    List<QuestionItem> qs,
    int globalOffset,
  ) {
    return Column(
      children: [
        // ── Legend ────────────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 4.h),
          child: Wrap(
            spacing: 12.w,
            runSpacing: 6.h,
            children: [
              _paletteLegendDot(successColor, 'Answered'),
              _paletteLegendDot(Colors.orange, 'Marked'),
              _paletteLegendDot(Colors.cyan.shade400, 'Skipped'),
              _paletteLegendDot(Colors.grey.shade400, 'Locked'),
              _paletteLegendDot(accentOrange, 'Current', isBorder: true),
            ],
          ),
        ),
        const Divider(height: 1),
        // ── Grid ──────────────────────────────────────────────────────────────
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(14.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 10.h,
              crossAxisSpacing: 10.w,
              childAspectRatio: 1.1,
            ),
            itemCount: qs.length,
          itemBuilder: (_, localIdx) {
  final globalIdx = globalOffset + localIdx;
  final q = qs[localIdx];
  final isCurrent = globalIdx == p.currentIndex;
  final isReachable = globalIdx <= p.maxReachedIndex + 1;
  final isLocked = !isReachable;
  final isTimeLocked = isReachable && p.isQuestionExpired(q.questionId);

  Color bgColor() {
    if (isLocked) return Colors.grey.shade200;         // unreachable — light grey, no lock
    if (isCurrent) return drawerColor;
    if (isTimeLocked) return Colors.grey.shade500;     // time expired — darker grey + lock
    switch (q.status) {
      case 'answered': return successColor;
      case 'marked_for_review': return Colors.orange;
      case 'skipped': return Colors.cyan.shade400;     // skipped NOT expired = cyan
      default: return Colors.grey.shade200;
    }
  }

  final bg = bgColor();
  final isLight = bg == Colors.grey.shade200;
  final textColor = isLight ? Colors.black38 : Colors.white;

  return GestureDetector(
    onTap: isReachable
        ? () {
            p.goToQuestion(globalIdx);
            setState(() => _showQuestionPalette = false);
          }
        : null,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isCurrent ? accentOrange : Colors.transparent,
          width: isCurrent ? 2.5 : 0,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: accentOrange.withOpacity(0.4),
                  blurRadius: 6.r,
                  offset: Offset(0, 2.h),
                )
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: isTimeLocked
          // ✅ ONLY time-expired shows lock icon
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_rounded, size: 11.sp, color: Colors.white),
                SizedBox(height: 1.h),
                CustomText(
                  text: '${globalIdx + 1}',
                  size: 11,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ],
            )
          // ✅ Unreachable = just faded number, no lock
          : Opacity(
              opacity: isLocked ? 0.45 : 1.0,
              child: CustomText(
                text: '${globalIdx + 1}',
                size: 15,
                weight: FontWeight.w700,
                color: textColor,
              ),
            ),
    ),
  );
},
          ),
        ),
      ],
    );
  }

  Widget _paletteLegendDot(Color color, String label, {bool isBorder = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14.w,
          height: 14.h,
          decoration: BoxDecoration(
            color: isBorder ? Colors.white : color,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: isBorder ? 2.5 : 0),
          ),
        ),
        SizedBox(width: 5.w),
        CustomText(
          text: label,
          size: 11,
          weight: FontWeight.w600,
          color: Colors.black87,
        ),
      ],
    );
  }

  List<Widget> _buildLockedOptions(QuestionDetail detail, QuestionItem item) {
    return detail.options.asMap().entries.map((entry) {
      final idx = entry.key;
      final option = entry.value;
      final label = String.fromCharCode(65 + idx);
      final wasSelected = _isOptionSelected(item, option);

      return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: wasSelected ? Colors.red.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: wasSelected ? Colors.red.shade300 : Colors.grey.shade300,
            width: wasSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38.w,
              height: 38.h,
              decoration: BoxDecoration(
                color: wasSelected ? Colors.red.shade300 : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: CustomText(
                text: label,
                size: 15,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: option.isImageOption
                  ? _buildOptionImage(option.imageUrl!, locked: true)
                  : CustomText(
                      text: option.text,
                      size: 15,
                      weight: wasSelected ? FontWeight.w600 : FontWeight.w400,
                      color: wasSelected
                          ? Colors.red.shade700
                          : Colors.grey.shade500,
                      maxLines: 10,
                      height: 1.4,
                    ),
            ),
            if (wasSelected)
              Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Icon(
                  Icons.lock_rounded,
                  color: Colors.red.shade400,
                  size: 20.sp,
                ),
              ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildSelectableOptions(
    ExamSessionProvider p,
    QuestionDetail detail,
    QuestionItem item,
  ) {
    return detail.options.asMap().entries.map((entry) {
      final idx = entry.key;
      final option = entry.value;
      final label = String.fromCharCode(65 + idx);
      final isSelected = _isOptionSelected(item, option);

      return GestureDetector(
        onTap: () => p.selectAnswer(option.id, optionText: option.text),
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      accentOrange.withOpacity(0.1),
                      accentOrange.withOpacity(0.04),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isSelected ? accentOrange : Colors.grey.shade300,
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accentOrange.withOpacity(0.15),
                      blurRadius: 6.r,
                      offset: Offset(0, 3.h),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38.w,
                height: 38.h,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [accentOrange, accentOrange.withOpacity(0.8)],
                        )
                      : null,
                  color: isSelected ? null : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: CustomText(
                  text: label,
                  size: 15,
                  weight: FontWeight.w700,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: option.isImageOption
                    ? _buildOptionImage(option.imageUrl!)
                    : CustomText(
                        text: option.text,
                        size: 15,
                        weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: Colors.black87,
                        maxLines: 10,
                        height: 1.4,
                      ),
              ),
              if (isSelected)
                Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: accentOrange,
                    size: 22.sp,
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildQuestionCard(ExamSessionProvider p, QuestionItem item) {
    final detail = item.question;
    final qRemaining = p.currentQuestionRemainingSeconds;
    final qTotal = item.recommendedTimeSeconds;
    final qFraction = qTotal > 0 ? (qRemaining / qTotal).clamp(0.0, 1.0) : 0.0;
    final isQLow = p.isQuestionLowTime;
    final isExpired = p.isQuestionExpired(item.questionId);

    Color timerColor() {
      if (qFraction > 0.5) return successColor;
      if (qFraction > 0.2) return Colors.orange;
      return Colors.red;
    }

    return CustomCard(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: detail.isConnected
          ? _buildConnectedQuestionBody(
              p,
              item,
              qRemaining,
              qTotal,
              qFraction,
              timerColor(),
              isQLow,
              isExpired,
            )
          : _buildRegularQuestionBody(
              p,
              item,
              qRemaining,
              qTotal,
              qFraction,
              timerColor(),
              isQLow,
              isExpired,
            ),
    );
  }

  Widget _buildRegularQuestionBody(
    ExamSessionProvider p,
    QuestionItem item,
    int qRemaining,
    int qTotal,
    double qFraction,
    Color timerColor,
    bool isQLow,
    bool isExpired,
  ) {
    final detail = item.question;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Passage block (carries its own image if set)
        if (detail.paragraph != null && detail.paragraph!.trim().isNotEmpty)
          _buildPassageBlock(detail.paragraph!, detail.imageUrls),

        // Question-level images (shown only when there's no paragraph)
        if (detail.imageUrls.isNotEmpty &&
            (detail.paragraph == null || detail.paragraph!.trim().isEmpty))
          _buildQuestionImagesBlock(detail.imageUrls),

        // Question number + text
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [drawerColor, drawerColor.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: CustomText(
                text: 'Q${p.currentIndex + 1}',
                size: 14,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CustomText(
                text: detail.questionText ?? '',
                size: 16,
                weight: FontWeight.w600,
                color: Colors.black87,
                maxLines: 20,
                height: 1.5,
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        Wrap(
          spacing: 8.w,
          runSpacing: 6.h,
          children: [
            _questionTypeBadge(detail.questionType),
            if (detail.difficulty != null) _difficultyBadge(detail.difficulty!),
            _marksBadge('+${detail.marks}', successColor),
            if (detail.negativeMarks > 0)
              _marksBadge('-${detail.negativeMarks}', Colors.red),
          ],
        ),

        SizedBox(height: 12.h),

        _buildQuestionTimer(
          remaining: qRemaining,
          total: qTotal,
          fraction: qFraction,
          color: timerColor,
          isLow: isQLow,
          isExpired: isExpired,
        ),

        SizedBox(height: 20.h),

        if (isExpired)
          ..._buildLockedOptions(detail, item)
        else
          ..._buildSelectableOptions(p, detail, item),
      ],
    );
  }

  Widget _buildConnectedQuestionBody(
    ExamSessionProvider p,
    QuestionItem item,
    int qRemaining,
    int qTotal,
    double qFraction,
    Color timerColor,
    bool isQLow,
    bool isExpired,
  ) {
    final detail = item.question;
    final totalSubs = detail.subQuestions.length;
    final activeIdx = p.activeSubIndex.clamp(0, totalSubs - 1);
    final activeSubQ = detail.subQuestions[activeIdx];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Passage block ─────────────────────────────────────────────────────
        if (detail.paragraph != null && detail.paragraph!.trim().isNotEmpty)
          _buildPassageBlock(detail.paragraph!, detail.imageUrls, detail.title),

        // ── Question header ───────────────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [drawerColor, drawerColor.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: CustomText(
                text: 'Q${p.currentIndex + 1}',
                size: 14,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: detail.title?.isNotEmpty == true
                        ? detail.title!
                        : 'Passage Question',
                    size: 15,
                    weight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  SizedBox(height: 4.h),
                  CustomText(
                    text:
                        '${detail.subQuestions.length} sub-question${detail.subQuestions.length == 1 ? '' : 's'}',
                    size: 12,
                    weight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        Wrap(
          spacing: 8.w,
          runSpacing: 6.h,
          children: [
            _questionTypeBadge('connected'),
            if (detail.difficulty != null) _difficultyBadge(detail.difficulty!),
          ],
        ),

        SizedBox(height: 16.h),

        // ── Sub-question step indicator (dot/pill row) ────────────────────────
        _buildSubStepIndicator(p, item, totalSubs, activeIdx),

        SizedBox(height: 16.h),

        // ── Active sub-question card (only ONE shown at a time) ───────────────
        _buildSubQuestionCard(
          p: p,
          parentItem: item,
          subQ: activeSubQ,
          subIndex: activeIdx,
        ),

        SizedBox(height: 8.h),

        // ── Prev / Next navigation row ────────────────────────────────────────
        _buildSubNavRow(p, totalSubs, activeIdx),
      ],
    );
  }

  Widget _buildSubNavRow(ExamSessionProvider p, int totalSubs, int activeIdx) {
    final isFirst = activeIdx == 0;
    final isLast = activeIdx == totalSubs - 1;

    return Row(
      children: [
        // ── Previous ─────────────────────────────────────────────────────────
        Expanded(
          child: GestureDetector(
            onTap: isFirst ? null : () => p.setActiveSubIndex(activeIdx - 1),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: isFirst ? 0.35 : 1.0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: drawerColor, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 14.sp,
                      color: drawerColor,
                    ),
                    SizedBox(width: 6.w),
                    CustomText(
                      text: 'Previous',
                      size: 13,
                      weight: FontWeight.w700,
                      color: drawerColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: 12.w),

        // ── Counter pill ──────────────────────────────────────────────────────
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: drawerColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: drawerColor.withOpacity(0.2)),
          ),
          child: CustomText(
            text: '${activeIdx + 1} / $totalSubs',
            size: 13,
            weight: FontWeight.w700,
            color: drawerColor,
          ),
        ),

        SizedBox(width: 12.w),

        // ── Next ──────────────────────────────────────────────────────────────
        Expanded(
          child: GestureDetector(
            onTap: isLast ? null : () => p.setActiveSubIndex(activeIdx + 1),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: isLast ? 0.35 : 1.0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: drawerColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      text: 'Next',
                      size: 13,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14.sp,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubStepIndicator(
    ExamSessionProvider p,
    QuestionItem parentItem,
    int totalSubs,
    int activeIdx,
  ) {
    return Row(
      children: List.generate(totalSubs, (i) {
        final subQ = parentItem.question.subQuestions[i];
        final isActive = i == activeIdx;
        final isExpired = p.isSubQuestionExpired(
          parentItem.questionId,
          subQ.id,
        );
        final isAnswered = subQ.isAnswered;

        Color dotColor() {
          if (isExpired) return Colors.red;
          if (isAnswered) return successColor;
          if (isActive) return drawerColor;
          return Colors.grey.shade400;
        }

        final label = '${p.currentIndex + 1}${String.fromCharCode(97 + i)}';

        return Expanded(
          child: GestureDetector(
            onTap: () => p.setActiveSubIndex(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: isActive ? dotColor() : dotColor().withOpacity(0.10),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: dotColor(),
                  width: isActive ? 2 : 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: CustomText(
                text: label,
                size: 12,
                weight: FontWeight.w700,
                color: isActive ? Colors.white : dotColor(),
              ),
            ),
          ),
        );
      }),
    );
  }

  // REPLACE the entire _buildPassageBlock method:
  Widget _buildPassageBlock(
    String paragraph, [
    List<String> imageUrls = const [], // ← changed from String? imageUrl
    String? titleOverride,
  ]) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: drawerColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: drawerColor.withOpacity(0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              border: Border(
                bottom: BorderSide(color: drawerColor.withOpacity(0.15)),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.menu_book_rounded, size: 16.sp, color: drawerColor),
                SizedBox(width: 8.w),
                CustomText(
                  text:
                      (titleOverride != null && titleOverride.trim().isNotEmpty)
                      ? titleOverride
                      : 'Passage',
                  size: 13,
                  weight: FontWeight.w700,
                  color: drawerColor,
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── All passage images ────────────────────────────────────
                if (imageUrls.isNotEmpty)
                  ...imageUrls.map(
                    (url) => Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Image.network(
                        url,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 120.h,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!
                                  : null,
                              color: drawerColor,
                              strokeWidth: 2,
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),

                // ── Paragraph text ────────────────────────────────────────
                Text(
                  paragraph,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.65,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionImagesBlock(List<String> urls) {
    if (urls.isEmpty) return const SizedBox.shrink();

    return Column(
      children: urls.map((url) {
        return Container(
          margin: EdgeInsets.only(bottom: 10.h),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
          child: Image.network(
            url,
            width: double.infinity,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(
                height: 140.h,
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                      : null,
                  color: drawerColor,
                  strokeWidth: 2,
                ),
              );
            },
            errorBuilder: (_, __, ___) => Container(
              height: 60.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.broken_image_outlined,
                color: Colors.grey.shade400,
                size: 28.sp,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubQuestionCard({
    required ExamSessionProvider p,
    required QuestionItem parentItem,
    required SubQuestion subQ,
    required int subIndex,
  }) {
    final isSubExpired = p.isSubQuestionExpired(parentItem.questionId, subQ.id);
    final subRemaining = p.subQuestionRemainingSeconds(
      parentItem.questionId,
      subQ.id,
    );
    final subTotal =
        subQ.remainingQuestionTimeSeconds ?? parentItem.recommendedTimeSeconds;
    final subFraction = subTotal > 0
        ? (subRemaining / subTotal).clamp(0.0, 1.0)
        : 0.0;

    Color subTimerColor() {
      if (subFraction > 0.5) return successColor;
      if (subFraction > 0.2) return Colors.orange;
      return Colors.red;
    }

    final isSubLow = p.isSubQuestionLowTime;
    final subLabel =
        '${p.currentIndex + 1}${String.fromCharCode(97 + subIndex)}';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFF),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: drawerColor.withOpacity(0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: drawerColor.withOpacity(0.06),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: drawerColor.withOpacity(0.07),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSubExpired ? Colors.red : drawerColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: CustomText(
                    text: subLabel,
                    size: 12,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Wrap(
                    spacing: 6.w,
                    runSpacing: 4.h,
                    children: [
                      _questionTypeBadge(subQ.questionType),
                      _marksBadge('+${subQ.marks}', successColor),
                      if (subQ.negativeMarks > 0)
                        _marksBadge('-${subQ.negativeMarks}', Colors.red),
                    ],
                  ),
                ),
                if (subQ.isAnswered && !isSubExpired)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: successColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          size: 12.sp,
                          color: successColor,
                        ),
                        SizedBox(width: 3.w),
                        CustomText(
                          text: 'Done',
                          size: 11,
                          weight: FontWeight.w700,
                          color: successColor,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ── Question text ───────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 0),
            child: CustomText(
              text: subQ.questionText ?? '',
              size: 15,
              weight: FontWeight.w600,
              color: Colors.black87,
              maxLines: 20,
              height: 1.5,
            ),
          ),

          // ── Sub-question images ─────────────────────────────────────────────
          // ✅ NEW: renders all images (supports String, List, or null from backend)
          if (subQ.imageUrls.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 0),
              child: Column(
                children: subQ.imageUrls.map((url) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Image.network(
                      url,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          height: 120.h,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                : null,
                            color: drawerColor,
                            strokeWidth: 2,
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        height: 50.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.grey.shade400,
                          size: 22.sp,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          SizedBox(height: 12.h),

          // ── Per-sub-question timer ──────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: _buildQuestionTimer(
              remaining: subRemaining,
              total: subTotal,
              fraction: subFraction,
              color: subTimerColor(),
              isLow: isSubLow,
              isExpired: isSubExpired,
            ),
          ),

          SizedBox(height: 14.h),

          // ── Options ─────────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
            child: Column(
              children: isSubExpired
                  ? _buildSubLockedOptions(subQ)
                  : _buildSubSelectableOptions(p, subQ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSubOptionSelected(SubQuestion subQ, QuestionOption option) {
    final answer = subQ.studentAnswer;
    if (answer == null) return false;
    if (answer is List) return answer.contains(option.text);
    return answer == option.text;
  }

  List<Widget> _buildSubLockedOptions(SubQuestion subQ) {
    return subQ.options.asMap().entries.map((entry) {
      final label = String.fromCharCode(65 + entry.key);
      final option = entry.value;
      final wasSelected = _isSubOptionSelected(subQ, option);

      return Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: wasSelected ? Colors.red.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: wasSelected ? Colors.red.shade300 : Colors.grey.shade300,
            width: wasSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34.w,
              height: 34.h,
              decoration: BoxDecoration(
                color: wasSelected ? Colors.red.shade300 : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: CustomText(
                text: label,
                size: 14,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: option.isImageOption
                  ? _buildOptionImage(
                      option.imageUrl!,
                      locked: true,
                      small: true,
                    )
                  : CustomText(
                      text: option.text,
                      size: 14,
                      weight: wasSelected ? FontWeight.w600 : FontWeight.w400,
                      color: wasSelected
                          ? Colors.red.shade700
                          : Colors.grey.shade500,
                      maxLines: 10,
                      height: 1.4,
                    ),
            ),
            if (wasSelected)
              Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Icon(
                  Icons.lock_rounded,
                  color: Colors.red.shade400,
                  size: 18.sp,
                ),
              ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildSubSelectableOptions(
    ExamSessionProvider p,
    SubQuestion subQ,
  ) {
    return subQ.options.asMap().entries.map((entry) {
      final label = String.fromCharCode(65 + entry.key);
      final option = entry.value;
      final isSelected = _isSubOptionSelected(subQ, option);

      return GestureDetector(
        onTap: () =>
            p.selectSubAnswer(subQ.id, option.id, optionText: option.text),
        child: Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      accentOrange.withOpacity(0.10),
                      accentOrange.withOpacity(0.04),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? accentOrange : Colors.grey.shade300,
              width: isSelected ? 2 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accentOrange.withOpacity(0.12),
                      blurRadius: 6.r,
                      offset: Offset(0, 2.h),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34.w,
                height: 34.h,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [accentOrange, accentOrange.withOpacity(0.8)],
                        )
                      : null,
                  color: isSelected ? null : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: CustomText(
                  text: label,
                  size: 14,
                  weight: FontWeight.w700,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: option.isImageOption
                    ? _buildOptionImage(option.imageUrl!, small: true)
                    : CustomText(
                        text: option.text,
                        size: 14,
                        weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: Colors.black87,
                        maxLines: 10,
                        height: 1.4,
                      ),
              ),
              if (isSelected)
                Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: accentOrange,
                    size: 20.sp,
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildOptionImage(
    String url, {
    bool locked = false,
    bool small = false,
  }) {
    final minH = small ? 80.h : 100.h;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: ColorFiltered(
        // Greyscale filter when locked
        colorFilter: locked
            ? const ColorFilter.matrix(<double>[
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0,
                0,
                0,
                1,
                0,
              ])
            : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
        child: Image.network(
          url,
          width: double.infinity,
          fit: BoxFit.contain,
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Container(
              height: minH,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                    : null,
                color: drawerColor,
                strokeWidth: 2,
              ),
            );
          },
          errorBuilder: (_, __, ___) => Container(
            height: minH,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.grey.shade400,
              size: 24.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionTimer({
    required int remaining,
    required int total,
    required double fraction,
    required Color color,
    required bool isLow,
    bool isExpired = false,
  }) {
    final displayColor = isExpired ? Colors.red.shade700 : color;

    final m = remaining ~/ 60;
    final s = remaining % 60;
    final timeLabel =
        '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    final totalLabel =
        '${(total ~/ 60).toString().padLeft(2, '0')}:${(total % 60).toString().padLeft(2, '0')}';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: displayColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: displayColor.withOpacity(0.3)),
      ),
      child: isExpired
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_clock_rounded,
                  size: 18.sp,
                  color: Colors.red.shade700,
                ),
                SizedBox(width: 8.w),
                CustomText(
                  text: "Time's up! This question is locked.",
                  size: 13,
                  weight: FontWeight.w700,
                  color: Colors.red.shade700,
                  align: TextAlign.center,
                ),
              ],
            )
          : Column(
              children: [
                Row(
                  children: [
                    Icon(
                      isLow ? Icons.timer_off_rounded : Icons.timer_rounded,
                      size: 16.sp,
                      color: displayColor,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      // ← ADD THIS
                      child: CustomText(
                        text: 'Time for this question',
                        size: 12,
                        weight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    // Remove Spacer() since Expanded handles it
                    CustomText(
                      text: timeLabel,
                      size: 14, // ← reduce from 16 to 14
                      weight: FontWeight.w800,
                      color: displayColor,
                    ),
                    CustomText(
                      text: ' / $totalLabel',
                      size: 11,
                      weight: FontWeight.w500,
                      color: Colors.black38,
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: fraction,
                    backgroundColor: displayColor.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(displayColor),
                    minHeight: 5.h,
                  ),
                ),
                if (isLow)
                  Padding(
                    padding: EdgeInsets.only(top: 5.h),
                    child: CustomText(
                      text: 'Hurry up! Moving to next question soon.',
                      size: 11,
                      weight: FontWeight.w600,
                      color: Colors.red,
                      align: TextAlign.center,
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _questionTypeBadge(String type) {
    IconData icon;
    Color color;
    String label;

    switch (type.toLowerCase()) {
      case 'multiple':
        icon = Icons.check_box_outlined;
        color = Colors.purple;
        label = 'Multiple Choice';
        break;
      case 'truefalse':
      case 'true_false':
        icon = Icons.toggle_on_outlined;
        color = Colors.teal;
        label = 'True / False';
        break;
      case 'connected':
        icon = Icons.menu_book_rounded;
        color = Colors.indigo;
        label = 'Passage';
        break;
      default:
        icon = Icons.radio_button_checked_rounded;
        color = Colors.blue.shade700;
        label = 'Single Choice';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: color),
          SizedBox(width: 4.w),
          CustomText(
            text: label,
            size: 11,
            weight: FontWeight.w700,
            color: color,
          ),
        ],
      ),
    );
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'hard':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _difficultyBadge(String difficulty) {
    final color = _difficultyColor(difficulty);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart_rounded, size: 11.sp, color: color),
          SizedBox(width: 4.w),
          CustomText(
            text: difficulty[0].toUpperCase() + difficulty.substring(1),
            size: 11,
            weight: FontWeight.w700,
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _marksBadge(String text, Color color) => Container(
    padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(6.r),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: CustomText(
      text: text,
      size: 11,
      weight: FontWeight.w700,
      color: color,
    ),
  );

  Widget _violationHeaderBadge(ExamSessionProvider p) {
    return GestureDetector(
      onTap: () {
        if (_violationDialogShowing) return;
        _violationDialogShowing = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => _violationDialogWidget(context, p, p.violationCount),
        ).then((_) => _violationDialogShowing = false);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.red.shade300, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, size: 12.sp, color: Colors.red),
            SizedBox(width: 4.w),
            CustomText(
              text: '${p.violationCount}/${ExamSessionProvider.maxViolations}',
              size: 11,
              weight: FontWeight.w700,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _timerBadge({
    required String label,
    required IconData icon,
    required bool isLow,
    bool padded = false,
  }) {
    final color = isLow ? Colors.red : accentOrange;
    return Container(
      padding: padded
          ? EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h)
          : EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(padded ? 20.r : 8.r),
        border: Border.all(
          color: isLow ? Colors.red.shade300 : color,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: padded ? 18.sp : 14.sp,
            color: isLow ? Colors.red : color,
          ),
          SizedBox(width: 4.w),
          CustomText(
            text: label,
            size: padded ? 15 : 12,
            weight: FontWeight.w700,
            color: isLow ? Colors.red : color,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ExamSessionProvider p) {
    final isMarked = p.currentQuestion?.status == 'marked_for_review';

    return Column(
      children: [
        // ── Row 1: Mark for Review + Clear Response ─────────────────────────
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => p.markCurrentForReview(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                  decoration: BoxDecoration(
                    color: isMarked ? Colors.orange : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.orange,
                      width: isMarked ? 0 : 1.5,
                    ),
                    boxShadow: isMarked
                        ? [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.3),
                              blurRadius: 8.r,
                              offset: Offset(0, 3.h),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isMarked ? Icons.flag_rounded : Icons.flag_outlined,
                        size: 16.sp,
                        color: isMarked ? Colors.white : Colors.orange,
                      ),
                      SizedBox(width: 6.w),
                      CustomText(
                        text: isMarked ? 'Marked ✓' : 'Mark for Review',
                        size: 13,
                        weight: FontWeight.w700,
                        color: isMarked ? Colors.white : Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CustomButton(
                title: 'Clear Response',
                onTap: () => p.clearResponse(),
                primary: false,
                icon: Icons.clear_rounded,
              ),
            ),
          ],
        ),

        SizedBox(height: 10.h),

        // ── Row 2: Skip Question (full width) ──────────────────────────────
        GestureDetector(
          onTap: () => p.skipQuestion(),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade400, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.skip_next_rounded,
                  size: 18.sp,
                  color: Colors.grey.shade600,
                ),
                SizedBox(width: 6.w),
                CustomText(
                  text: 'Skip Question',
                  size: 13,
                  weight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationBar(ExamSessionProvider p) {
    final isFirst = p.currentIndex == 0;
    final isLast = p.currentIndex == p.questions.length - 1;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: p.status == ExamStatus.submitting
          ? Container(
              height: 50.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: successColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Row(
              children: [
                if (!isFirst)
                  Expanded(
                    flex: 1,
                    child: CustomButton(
                      title: 'Prev',
                      onTap: () => p.previousQuestion(),
                      primary: false,
                      backgroundColor: Colors.white,
                      textColor: drawerColor,
                      borderColor: drawerColor,
                      icon: Icons.arrow_back_rounded,
                      height: 50.h,
                    ),
                  ),
                if (!isFirst) SizedBox(width: 12.w),
                Expanded(
                  flex: isFirst ? 1 : 2,
                  child: CustomButton(
                    title: isLast ? 'Submit Exam' : 'Next Question',
                    onTap: () =>
                        isLast ? _showSubmitDialog(p) : p.nextQuestion(),
                    backgroundColor: isLast ? successColor : accentOrange,
                    textColor: Colors.white,
                    icon: isLast
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_rounded,
                    height: 50.h,
                  ),
                ),
              ],
            ),
    );
  }

  void _showSubmitDialog(ExamSessionProvider p) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _dialog(
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [successColor, successColor.withOpacity(0.8)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 48.sp,
            ),
          ),
          SizedBox(height: 20.h),
          const CustomText(
            text: 'Submit Exam?',
            size: 22,
            weight: FontWeight.w700,
            color: Colors.black87,
            align: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          CustomText(
            text: p.notVisitedCount > 0
                ? '${p.notVisitedCount} question(s) not answered yet.'
                : 'All questions answered. Ready to submit?',
            size: 14,
            color: p.notVisitedCount > 0 ? Colors.orange : Colors.grey,
            align: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          _statsWidget(p),
          SizedBox(height: 24.h),
          CustomButton(
            title: 'Submit Exam',
            onTap: () async {
              Navigator.of(context, rootNavigator: true).pop();
              final results = await p.submitExam();
              if (!mounted) return;
              if (results != null) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExamResultsScreen(
                      sessionId: p.sessionId ?? '',
                      preloadedResults: results,
                      showInstantResult: widget.showInstantResult,
                      resultDeclaredAt: widget.resultDeclaredAt,
                    ),
                  ),
                  (route) => route.isFirst,
                );
              } else {
                AppToast.error(
                  context,
                  title: 'Submit Failed',
                  message: p.errorMessage,
                );
              }
            },
            backgroundColor: successColor,
            textColor: Colors.white,
            icon: Icons.send_rounded,
            height: 52.h,
          ),
          SizedBox(height: 12.h),
          CustomButton(
            title: 'Review Answers',
            onTap: () => Navigator.of(context, rootNavigator: true).pop(),
            primary: false,
            backgroundColor: Colors.white,
            textColor: drawerColor,
            borderColor: drawerColor,
            icon: Icons.remove_red_eye_outlined,
            height: 52.h,
          ),
        ],
      ),
    );
  }

  Widget _dialog({required List<Widget> children}) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
    child: Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20.h),
          ...children,
        ],
      ),
    ),
  );

  Widget _statsWidget(ExamSessionProvider p) => Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [drawerColor.withOpacity(0.05), drawerColor.withOpacity(0.02)],
      ),
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: drawerColor.withOpacity(0.1)),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Icon(Icons.assessment_outlined, color: drawerColor, size: 20.sp),
            SizedBox(width: 8.w),
            const CustomText(
              text: 'Your Progress',
              size: 14,
              weight: FontWeight.w700,
              color: Colors.black87,
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _statRow('Answered', p.answeredCount, successColor),
        SizedBox(height: 12.h),
        _statRow('Marked for Review', p.markedCount, Colors.orange),
        SizedBox(height: 12.h),
        _statRow('Not Answered', p.notVisitedCount, Colors.grey),
      ],
    ),
  );

  Widget _statRow(String label, int count, Color color) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Container(
            width: 12.w,
            height: 12.h,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 10.w),
          CustomText(
            text: label,
            size: 14,
            weight: FontWeight.w500,
            color: Colors.black87,
          ),
        ],
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: CustomText(
          text: count.toString(),
          size: 15,
          weight: FontWeight.w700,
          color: color,
        ),
      ),
    ],
  );

  Widget _loadingScaffold() => Scaffold(
    backgroundColor: const Color(0xFFF6F7FB),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: drawerColor),
          SizedBox(height: 16.h),
          CustomText(
            text: 'Starting exam…',
            size: 15,
            color: Colors.grey.shade600,
          ),
        ],
      ),
    ),
  );

  Widget _errorScaffold(ExamSessionProvider p) => Scaffold(
    backgroundColor: const Color(0xFFF6F7FB),
    body: Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60.sp, color: Colors.red.shade300),
            SizedBox(height: 16.h),
            CustomText(
              text: p.errorMessage,
              size: 15,
              color: Colors.grey.shade700,
              align: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            CustomButton(
              title: 'Go Back',
              onTap: () => Navigator.pop(context),
              backgroundColor: drawerColor,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// ExamResultsScreen  (unchanged)
// ═══════════════════════════════════════════════════════════════════════════════
class ExamResultsScreen extends StatefulWidget {
  final String sessionId;
  final ExamResultsData? preloadedResults;
  final ExamSessionRepository? repository;
  final bool showInstantResult; // ✅ false for tournament/olympiad
  final DateTime? resultDeclaredAt; // ✅ if set, results only after this date

  const ExamResultsScreen({
    super.key,
    required this.sessionId,
    this.preloadedResults,
    this.repository,
    this.showInstantResult = true, // ✅ default true — regular exam unchanged
    this.resultDeclaredAt,
  });

  @override
  State<ExamResultsScreen> createState() => _ExamResultsScreenState();
}

class _ExamResultsScreenState extends State<ExamResultsScreen> {
  bool _isLoading = false;
  String _error = '';
  ExamResultsData? _results;

  @override
  void initState() {
    super.initState();
    if (widget.preloadedResults != null) {
      _results = widget.preloadedResults;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchFromApi());
    }
  }

  Future<void> _fetchFromApi() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final repo = widget.repository ?? context.read<ExamSessionRepository>();
      final ExamResultsResponse response = await repo.getResults(
        widget.sessionId,
      );

      if (!mounted) return;

      debugPrint('✅ questions count: ${response.data?.questions?.length}');
      debugPrint('✅ score: ${response.data?.results.score}');
      debugPrint('✅ percentage: ${response.data?.results.percentage}');

      if (response.data != null) {
        setState(() {
          _results = response.data;
          _isLoading = false;
          _error = '';
        });
      } else {
        setState(() {
          _error = response.message.isNotEmpty
              ? response.message
              : 'Failed to load results. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      debugPrint('❌ fetchResults error: $e');
      debugPrint('❌ stack: $stack');
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<double> _buildProgression(ExamResultsData data) {
    final questions = data.questions;
    if (questions == null || questions.isEmpty) return [0.0];

    double runningScore = 0;
    final maxScore = data.results.maxScore;

    return questions.map((q) {
      if (q.isCorrect == true) {
        runningScore += (q.marksEarned ?? q.question.marks.toDouble());
      }
      return maxScore > 0
          ? (runningScore / maxScore * 100).clamp(0.0, 100.0)
          : 0.0;
    }).toList();
  }

  // ────────────────────────────── Loading Scaffold ──────────────────────────────
  Widget _loadingScaffold() => Scaffold(
    backgroundColor: const Color(0xFFF6F7FB),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: drawerColor),
          SizedBox(height: 16.h),
          CustomText(
            text: 'Loading results...',
            size: 15,
            color: Colors.grey.shade600,
          ),
        ],
      ),
    ),
  );

  // ────────────────────────────── Error Scaffold ──────────────────────────────
  Widget _errorScaffold() => Scaffold(
    backgroundColor: const Color(0xFFF6F7FB),
    body: Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60.sp, color: Colors.red.shade300),
            SizedBox(height: 16.h),
            CustomText(
              text: _error,
              size: 15,
              color: Colors.grey.shade700,
              align: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            CustomButton(
              title: 'Retry',
              onTap: _fetchFromApi,
              backgroundColor: drawerColor,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _loadingScaffold();
    }

    if (_error.isNotEmpty) {
      return _errorScaffold();
    }

    if (_results == null) {
      return _loadingScaffold();
    }

    // Tournament result declaration gate
    final bool resultsDeclared = _isResultsDeclared();
    if (!widget.showInstantResult && !resultsDeclared) {
      return _resultsPendingScaffold();
    }

    final progression = _buildProgression(_results!);

    return InstantResultsScreen(
      scoreProgression: progression.isEmpty ? [0.0] : progression,
      resultsData: _results,
    );
  }

  /// Returns true if results should be visible right now
  bool _isResultsDeclared() {
    if (widget.showInstantResult) return true;
    if (widget.resultDeclaredAt == null) return false;
    return DateTime.now().isAfter(widget.resultDeclaredAt!);
  }

  /// Shown when result is not declared yet
  Widget _resultsPendingScaffold() {
    final dt = widget.resultDeclaredAt;
    final dateStr = dt != null ? _fmtDate(dt) : 'a later date';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: drawerColor,
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  CustomText(
                    text: 'Results',
                    size: 18,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(24.w),
                        decoration: BoxDecoration(
                          color: drawerColor.withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: drawerColor.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.lock_clock_rounded,
                          size: 52.sp,
                          color: drawerColor.withOpacity(0.7),
                        ),
                      ),

                      SizedBox(height: 28.h),

                      CustomText(
                        text: 'Results Not Declared Yet',
                        size: 20,
                        weight: FontWeight.w800,
                        color: Colors.black87,
                        align: TextAlign.center,
                      ),

                      SizedBox(height: 12.h),

                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 16.sp,
                                  color: Colors.blue.shade600,
                                ),
                                SizedBox(width: 8.w),
                                CustomText(
                                  text: 'Your exam has been submitted',
                                  size: 13,
                                  weight: FontWeight.w700,
                                  color: Colors.blue.shade700,
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            CustomText(
                              text:
                                  'Results will be available on $dateStr after all participants have completed the exam.',
                              size: 13,
                              color: Colors.blue.shade700,
                              maxLines: 4,
                              align: TextAlign.left,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32.h),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: drawerColor,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            size: 18.sp,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Back to Home',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'pm' : 'am';
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $h:$m $ampm';
  }
}
