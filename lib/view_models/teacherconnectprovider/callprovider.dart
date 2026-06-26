import 'dart:async';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/repo/mentors/call_repositories.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view_models/teacherconnectprovider/agoracall_servies.dart';
import 'package:firstedu/view_models/teacherconnectprovider/callsocket_services.dart';
import 'package:flutter/material.dart';

enum CallState {
  idle,
  requesting,
  waitingTeacher,
  joiningChannel,
  active,
  ended,
}

enum CallEndReason {
  none,
  teacherRejected,
  autoTimeout,
  endedByStudent,
  endedByTeacher,
  error,
}

class CallProvider extends ChangeNotifier {
  final CallRepository _callRepo;
  final CallSocketService _socketService;
  final AgoraCallService _agoraService;

  CallProvider(this._callRepo, this._socketService, this._agoraService);

  // ── State ────────────────────────────────────────────────────────────────
  CallState _state = CallState.idle;
  CallState get state => _state;

  CallEndReason _endReason = CallEndReason.none;
  CallEndReason get endReason => _endReason;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String _sessionId = '';
  String get sessionId => _sessionId;

  String _teacherId = '';
  String _teacherName = '';
  String get teacherName => _teacherName;

  bool get isMuted => _agoraService.isMuted;
  bool get isSpeakerOn => _agoraService.isSpeakerOn;
  bool get isTeacherInChannel => _agoraService.isTeacherInChannel;

  Duration _callDuration = Duration.zero;
  Duration get callDuration => _callDuration;
  Timer? _durationTimer;

  Timer? _autoCancelTimer;

  // ✅ FIX: Track a "call generation" counter so stale async callbacks from
  // a previous call attempt cannot affect the current state. Any async
  // continuation that captures a generation that no longer matches the
  // current one is silently dropped.
  int _callGeneration = 0;

  // ✅ FIX: Guard flag so _endCall() logic runs at most once per call.
  bool _isEnding = false;

  // ── Duration timer ───────────────────────────────────────────────────────
  void _startDurationTimer() {
    _durationTimer?.cancel();
    _callDuration = Duration.zero;
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _callDuration += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  // ── Auto-cancel (45 s) ───────────────────────────────────────────────────
  void _startAutoCancelTimer() {
    _autoCancelTimer?.cancel();
    _autoCancelTimer = Timer(const Duration(seconds: 45), () {
      if (_state == CallState.requesting ||
          _state == CallState.waitingTeacher) {
        debugPrint('⏱️ [CallProvider] 45s timeout — auto-cancelling');
        _socketService.cancelCallRequest(
          _sessionId,
          reason: 'teacher_no_response_timeout',
          autoCancelled: true,
        );
        _finishCall(
          reason: CallEndReason.autoTimeout,
          message: 'Teacher did not respond in time. Please try again.',
        );
      }
    });
  }

  void _cancelAutoCancelTimer() {
    _autoCancelTimer?.cancel();
    _autoCancelTimer = null;
  }

  // ── Start Call ───────────────────────────────────────────────────────────
  Future<void> startCall(
    BuildContext context, {
    required String teacherId,
    required String teacherName,
    String subject = '',
  }) async {
    // ✅ FIX: If a previous call is still winding down, fully reset first.
    if (_state != CallState.idle) {
      debugPrint(
          '⚠️ [CallProvider] startCall called but state=$_state — resetting first');
      await resetCall();
    }

    _teacherId = teacherId;
    _teacherName = teacherName;
    _errorMessage = '';
    _sessionId = '';
    _isEnding = false;

    // ✅ FIX: Bump generation so all stale async continuations are invalidated.
    final generation = ++_callGeneration;

    final token = ApiEndpoint.cachedToken;
    if (token == null || token.isEmpty) {
      if (context.mounted) {
        AppToast.error(context,
            title: 'Auth Error', message: 'Please log in again.');
      }
      return;
    }

    _setState(CallState.requesting);

    // ✅ FIX: Always clear old callbacks BEFORE wiring new ones.
    // This ensures no stale closure from the previous call can fire.
    _socketService.clearCallbacks();

    // Wire ALL callbacks before connect() so none are missed
    // even if the socket connects synchronously.
    _socketService.onConnected = () {
      // ✅ FIX: Guard generation — ignore if this is a stale reconnect
      // from a socket that survived a resetCall().
      if (_callGeneration != generation) return;
      debugPrint('📤 [CallProvider] Connected — emitting call_request');
      _socketService.sendCallRequest(
          teacherId: teacherId, subject: subject);
    };

    _socketService.onCallRequestSent = (session) {
      if (_callGeneration != generation) return;
      _onCallRequestSent(session);
    };

    _socketService.onCallAccepted = (session) {
      if (_callGeneration != generation) return;
      _onCallAccepted(context, session, generation);
    };

    _socketService.onCallRejected = (reason) {
      if (_callGeneration != generation) return;
      _onCallRejected(reason);
    };

    _socketService.onCallRequestCancelled = (reason) {
      if (_callGeneration != generation) return;
      _onCallRequestCancelled(reason);
    };

    _socketService.onCallRequestWithdrawn = (reason) {
      if (_callGeneration != generation) return;
      _onCallRequestWithdrawn(reason);
    };

    _socketService.onJoinedCallSession = (session) {
      if (_callGeneration != generation) return;
      _onJoinedCallSession(session);
    };

    _socketService.onCallSessionEnded = (reason, session) {
      if (_callGeneration != generation) return;
      _onCallSessionEnded(reason, session);
    };

    _socketService.onCallEndedAck = (_) {};

    _socketService.onError = (err) {
      if (_callGeneration != generation) return;
      _onSocketError(context, err);
    };

    // ✅ FIX: connect() after callbacks are wired.
    _socketService.connect(token);
  }

  // ── Socket Handlers ──────────────────────────────────────────────────────

  void _onCallRequestSent(Map<String, dynamic> session) {
    final id = session['_id']?.toString() ??
        session['id']?.toString() ??
        session['sessionId']?.toString() ??
        '';
    if (id.isNotEmpty) _sessionId = id;
    debugPrint('📨 [CallProvider] Session created: $_sessionId');
    _startAutoCancelTimer();
    _setState(CallState.waitingTeacher);
  }

  Future<void> _onCallAccepted(
    BuildContext context,
    Map<String, dynamic> session,
    int generation,
  ) async {
    // ✅ FIX: Don't process accept if we're already ending/ended.
    if (_isEnding || _state == CallState.ended) return;
    _cancelAutoCancelTimer();

    final id = session['_id']?.toString() ??
        session['id']?.toString() ??
        session['sessionId']?.toString() ??
        _sessionId;
    if (id.isNotEmpty) _sessionId = id;

    debugPrint('✅ [CallProvider] Accepted — sessionId=$_sessionId');
    _setState(CallState.joiningChannel);
    _socketService.joinCallSession(_sessionId);

    try {
      // ✅ FIX: Dispose Agora before getting token so the engine is clean.
      await _agoraService.dispose();

      // ✅ FIX: Guard generation after every await — the user may have
      // cancelled while the HTTP request was in flight.
      if (_callGeneration != generation || _isEnding) return;

      final tokenData = await _callRepo
          .getAgoraToken(_sessionId)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException(
            'Server took too long to respond. Please retry.');
      });

      if (_callGeneration != generation || _isEnding) return;

      // ✅ FIX: Set ALL Agora callbacks before calling init() so no event
      // is missed if init() completes synchronously.
      _agoraService.onJoinSuccess = () {
        if (_callGeneration != generation || _isEnding) return;
        debugPrint('✅ [CallProvider] Joined Agora channel');
        _setState(CallState.active);
      };

      _agoraService.onTeacherJoined = () {
        if (_callGeneration != generation || _isEnding) return;
        debugPrint('✅ [CallProvider] Teacher joined — starting timer');
        if (_durationTimer == null || !_durationTimer!.isActive) {
          _startDurationTimer();
        }
        notifyListeners();
      };

      _agoraService.onTeacherLeft = () {
        if (_callGeneration != generation || _isEnding) return;
        debugPrint('⚠️ [CallProvider] Teacher left channel');
        // ✅ FIX: If teacher drops, wait 8 s then treat as ended.
        // This handles the case where the server call_session_ended
        // event is delayed or never arrives.
        _teacherDisconnectGuard(generation);
        notifyListeners();
      };

      _agoraService.onError = (msg) {
        if (_callGeneration != generation || _isEnding) return;
        _onAgoraError(context, msg);
      };

      await _agoraService.init(tokenData.appId);

      if (_callGeneration != generation || _isEnding) return;

      await _agoraService.joinChannel(
        token: tokenData.token,
        channelName: tokenData.channelName,
        uid: tokenData.uid,
      );
    } catch (e) {
      if (_callGeneration != generation || _isEnding) return;
      debugPrint('❌ [CallProvider] Failed to join channel: $e');
      final msg = e is TimeoutException
          ? e.message ?? 'Connection timed out.'
          : 'Could not join audio session. Please retry.';
      _finishCall(reason: CallEndReason.error, message: msg);
      if (context.mounted) {
        AppToast.error(context, title: 'Call Failed', message: msg);
      }
    }
  }

  // ✅ FIX: If teacher leaves Agora channel but server doesn't send
  // call_session_ended within 8 s, end the call locally.
  Timer? _teacherLeaveTimer;

  void _teacherDisconnectGuard(int generation) {
    _teacherLeaveTimer?.cancel();
    _teacherLeaveTimer = Timer(const Duration(seconds: 8), () {
      if (_callGeneration != generation || _isEnding) return;
      if (!_agoraService.isTeacherInChannel &&
          _state == CallState.active) {
        debugPrint(
            '⚠️ [CallProvider] Teacher still gone after 8s — ending call');
        _finishCall(
          reason: CallEndReason.endedByTeacher,
          message: 'Teacher disconnected from the session.',
          leaveAgora: true,
        );
      }
    });
  }

  void _onCallRejected(String reason) {
    debugPrint('❌ [CallProvider] Rejected: $reason');
    _cancelAutoCancelTimer();
    _finishCall(
      reason: CallEndReason.teacherRejected,
      message: reason.isNotEmpty ? reason : 'Teacher declined the call.',
    );
  }

  void _onCallRequestCancelled(String reason) {
    debugPrint('⏰ [CallProvider] Cancelled: $reason');
    _cancelAutoCancelTimer();
    _finishCall(
      reason: CallEndReason.autoTimeout,
      message: reason.isNotEmpty ? reason : 'Teacher did not respond in time.',
    );
  }

  void _onCallRequestWithdrawn(String reason) {
    debugPrint('✅ [CallProvider] Withdrawn: $reason');
    _cancelAutoCancelTimer();
    // Student cancelled — state already handled by cancelCall()
  }

  void _onJoinedCallSession(Map<String, dynamic> session) {
    debugPrint('✅ [CallProvider] Joined session room');
  }

 void _onCallSessionEnded(String reason, Map<String, dynamic> session) {
  debugPrint('📨 [CallProvider] Session ended by server: $reason');
  _cancelAutoCancelTimer();
  _teacherLeaveTimer?.cancel();

  // Resolve our own pending end-call wait, if any.
  if (_endCallEcho != null && !_endCallEcho!.isCompleted) {
    _endCallEcho!.complete();
  }

  if (_isEnding) return; // we already finished locally via endCall()'s own path

  final endCode = session['sessionEndReason']?.toString() ?? '';
  _finishCall(
    reason: endCode == 'ended_by_student'
        ? CallEndReason.endedByStudent
        : CallEndReason.endedByTeacher,
    message: reason,
    leaveAgora: true,
  );
}
  void _onSocketError(BuildContext context, dynamic err) {
    final msg = err.toString();
    debugPrint('🔴 [CallProvider] Socket error: $msg (state=$_state)');

    final isAuthError = msg.toLowerCase().contains('login') ||
        msg.toLowerCase().contains('auth') ||
        msg.toLowerCase().contains('token') ||
        msg.toLowerCase().contains('unauthorized');

    final isBalanceError = msg.toLowerCase().contains('balance') ||
        msg.toLowerCase().contains('wallet') ||
        msg.toLowerCase().contains('insufficient');

    // During active call, ignore transient network errors
    if (_state == CallState.active && !isAuthError && !isBalanceError) {
      debugPrint('⚠️ Minor socket error during active call — ignoring');
      return;
    }

    _cancelAutoCancelTimer();
    _finishCall(reason: CallEndReason.error, message: msg);

    if (context.mounted) {
      AppToast.error(
        context,
        title: isBalanceError
            ? 'Insufficient Balance'
            : isAuthError
                ? 'Session Expired'
                : 'Call Failed',
        message: msg.isNotEmpty ? msg : 'Could not connect. Please retry.',
      );
    }
  }

  void _onAgoraError(BuildContext context, String msg) {
    debugPrint('🔴 [CallProvider] Agora error: $msg');
    if (context.mounted) {
      AppToast.error(context, title: 'Audio Error', message: msg);
    }
  }

  // ── Student Actions ──────────────────────────────────────────────────────

  Future<void> toggleMute() async {
    await _agoraService.toggleMute();
    notifyListeners();
  }

  Future<void> toggleSpeaker() async {
    await _agoraService.toggleSpeaker();
    notifyListeners();
  }

Completer<void>? _endCallEcho;

Future<void> endCall() async {
  if (_isEnding) return;
  _cancelAutoCancelTimer();
  _teacherLeaveTimer?.cancel();

  if (_sessionId.isNotEmpty && _state == CallState.active) {
    _endCallEcho = Completer<void>();

    _socketService.endCall(
      sessionId: _sessionId,
      durationSeconds: _callDuration.inSeconds,
    );

    // Wait for the server's own call_session_ended broadcast to echo
    // back to us — this is the real confirmation the server processed
    // end_call (and therefore the teacher's socket got it too).
    await _endCallEcho!.future.timeout(
      const Duration(seconds: 4),
      onTimeout: () {
        debugPrint('⚠️ [CallProvider] No call_session_ended echo within 4s — ending locally anyway');
      },
    );
  }

  if (!_isEnding) {
    _finishCall(
      reason: CallEndReason.endedByStudent,
      message: '',
      leaveAgora: true,
    );
  }
}


  void cancelCall() {
    if (_isEnding) return;
    _cancelAutoCancelTimer();
    _teacherLeaveTimer?.cancel();

    if (_sessionId.isNotEmpty) {
      _socketService.cancelCallRequest(
        _sessionId,
        reason: 'student_cancelled',
        autoCancelled: false,
      );
    }
    _finishCall(
      reason: CallEndReason.endedByStudent,
      message: '',
      leaveAgora: false,
    );
  }

  // ✅ FIX: Single unified "finish a call" method.
  // All paths that end a call go through here so state is always consistent.
  void _finishCall({
    required CallEndReason reason,
    required String message,
    bool leaveAgora = false,
  }) {
    if (_isEnding) return; // ✅ Idempotent — only runs once
    _isEnding = true;

    _endReason = reason;
    _errorMessage = message;
    _stopDurationTimer();
    _teacherLeaveTimer?.cancel();

    if (leaveAgora) _agoraService.leaveChannel();
    _socketService.disconnect(); // sets _isIntentionalDisconnect=true
    _socketService.clearCallbacks(); // ✅ prevent any further callback fires

    _setState(CallState.ended);
  }

  // ✅ FIX: Full async reset — awaits Agora dispose so the engine is
  // completely torn down before a new call can start.
  Future<void> resetCall() async {
    _cancelAutoCancelTimer();
    _teacherLeaveTimer?.cancel();
    _stopDurationTimer();

    // ✅ Bump generation to invalidate any in-flight async continuations
    _callGeneration++;
    _isEnding = false;

    _socketService.disconnect();
    _socketService.clearCallbacks();
    await _agoraService.dispose();

    _state = CallState.idle;
    _endReason = CallEndReason.none;
    _errorMessage = '';
    _sessionId = '';
    _teacherId = '';
    _teacherName = '';
    _callDuration = Duration.zero;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelAutoCancelTimer();
    _teacherLeaveTimer?.cancel();
    _stopDurationTimer();
    _socketService.clearCallbacks();
    _socketService.disconnect();
    _agoraService.dispose();
    super.dispose();
  }

  void _setState(CallState state) {
    _state = state;
    notifyListeners();
  }

  String get formattedDuration {
    final m = _callDuration.inMinutes.toString().padLeft(2, '0');
    final s = (_callDuration.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}