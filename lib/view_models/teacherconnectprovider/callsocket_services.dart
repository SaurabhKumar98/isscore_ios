import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class CallSocketService {
  io.Socket? _socket;
  bool _isIntentionalDisconnect = false;

  bool get isConnected => _socket?.connected ?? false;

  // ── Callbacks ─────────────────────────────────────────────────────────
  void Function()? onConnected;
  void Function(Map<String, dynamic> session)? onCallRequestSent;
  void Function(Map<String, dynamic> session)? onCallAccepted;
  void Function(String reason)? onCallRejected;
  void Function(String reason)? onCallRequestCancelled;
  void Function(String reason)? onCallRequestWithdrawn;
  void Function(Map<String, dynamic> session)? onJoinedCallSession;
  void Function(String reason, Map<String, dynamic> session)? onCallSessionEnded;
  void Function(Map<String, dynamic> session)? onCallEndedAck;
  void Function(dynamic error)? onError;

  // ── Connect ───────────────────────────────────────────────────────────
  void connect(String jwtToken) {
    // Fully tear down previous socket before creating a new one
    _tearDown();
    _isIntentionalDisconnect = false;

    _socket = io.io(
      '${ApiEndpoint.socketBaseUrl}/teacher-call',
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setAuth({'token': jwtToken})
          .setExtraHeaders({'Authorization': 'Bearer $jwtToken'})
          .enableReconnection()
          .setReconnectionAttempts(5) // ✅ Don't reconnect forever — let provider handle retry
          .setReconnectionDelay(1500)
          .setReconnectionDelayMax(10000)
          .setTimeout(20000)
          .enableForceNew()
          .build(),
    );

    _bindEvents();
    _socket!.connect();
  }

  void _bindEvents() {
    final s = _socket;
    if (s == null) return;

    s.onConnect((_) {
      print('✅ [CallSocket] Connected — ID: ${s.id}');
      // ✅ FIX: Only call onConnected if not an intentional disconnect
      // (guards against reconnect firing after we've already ended the call)
      if (!_isIntentionalDisconnect) {
        onConnected?.call();
      }
    });

    s.onDisconnect((reason) {
      print('❌ [CallSocket] Disconnected: $reason');
      if (!_isIntentionalDisconnect) {
        // Unexpected disconnect — notify provider so it can decide
        if (reason == 'ping timeout' ||
            reason == 'transport close' ||
            reason == 'transport error') {
          onError?.call('Connection lost. Please check your network.');
        }
      }
    });

    s.onConnectError((err) {
      print('⚠️ [CallSocket] Connect error: $err');
      if (!_isIntentionalDisconnect) {
        onError?.call('Could not connect to server. Please try again.');
      }
    });

    s.on('call_request_sent', (data) {
      print('📨 [CallSocket] call_request_sent: $data');
      final map = _toMap(data);
      final session = map['session'] as Map<String, dynamic>? ?? {};
      final sessionId = map['sessionId']?.toString() ??
          session['_id']?.toString() ??
          session['id']?.toString() ??
          '';
      final resolved = Map<String, dynamic>.from(session);
      if (sessionId.isNotEmpty) resolved['_id'] = sessionId;
      onCallRequestSent?.call(resolved);
    });

    s.on('call_error', (data) {
      final map = _toMap(data);
      final msg = map['message']?.toString() ??
          map['error']?.toString() ??
          'Unknown call error';
      print('🔴 [CallSocket] call_error: $msg');
      if (!_isIntentionalDisconnect) onError?.call(msg);
    });

    s.on('call_accepted', (data) {
      print('📨 [CallSocket] call_accepted RAW: $data');
      final map = _toMap(data);
      final session = map['session'] as Map<String, dynamic>? ??
          map['sessionData'] as Map<String, dynamic>? ??
          {};
      final sessionId = map['sessionId']?.toString() ??
          map['session_id']?.toString() ??
          session['_id']?.toString() ??
          session['id']?.toString() ??
          '';
      final normalized = Map<String, dynamic>.from(session);
      if (sessionId.isNotEmpty) normalized['_id'] = sessionId;
      print('📨 [CallSocket] call_accepted normalized: $normalized');
      onCallAccepted?.call(normalized);
    });

    s.on('call_rejected', (data) {
      print('📨 [CallSocket] call_rejected: $data');
      final map = _toMap(data);
      final reason = map['reason']?.toString() ??
          map['message']?.toString() ??
          'Teacher declined';
      onCallRejected?.call(reason);
    });

    s.on('call_request_cancelled', (data) {
      print('📨 [CallSocket] call_request_cancelled: $data');
      final map = _toMap(data);
      final reason = map['message']?.toString() ??
          map['reason']?.toString() ??
          'Request cancelled.';
      onCallRequestCancelled?.call(reason);
    });

    s.on('call_request_withdrawn', (data) {
      print('📨 [CallSocket] call_request_withdrawn: $data');
      final map = _toMap(data);
      final reason = map['message']?.toString() ??
          map['reason']?.toString() ??
          'Withdrawn.';
      onCallRequestWithdrawn?.call(reason);
    });

    s.on('joined_call_session', (data) {
      print('📨 [CallSocket] joined_call_session: $data');
      final map = _toMap(data);
      onJoinedCallSession?.call(map['session'] as Map<String, dynamic>? ?? {});
    });

    s.on('call_session_ended', (data) {
      print('📨 [CallSocket] call_session_ended: $data');
      final map = _toMap(data);
      final reason = map['message']?.toString() ??
          map['reason']?.toString() ??
          'Call ended';
      onCallSessionEnded?.call(
        reason,
        map['session'] as Map<String, dynamic>? ?? {},
      );
    });

    s.on('call_ended_ack', (data) {
      print('📨 [CallSocket] call_ended_ack: $data');
      final map = _toMap(data);
      onCallEndedAck?.call(map['session'] as Map<String, dynamic>? ?? {});
    });
  }

  // ── Emitters ──────────────────────────────────────────────────────────

  void sendCallRequest({required String teacherId, String subject = ''}) {
    print('📤 [CallSocket] call_request → teacherId=$teacherId');
    _socket?.emit('call_request', {
      'teacherId': teacherId,
      if (subject.isNotEmpty) 'subject': subject,
    });
  }

  void cancelCallRequest(
    String sessionId, {
    String reason = 'student_cancelled',
    bool autoCancelled = false,
  }) {
    print('📤 [CallSocket] cancel_call_request → sessionId=$sessionId');
    _socket?.emit('cancel_call_request', {
      if (sessionId.isNotEmpty) 'sessionId': sessionId,
      'reason': reason,
      'autoCancelled': autoCancelled,
      'timeoutMs': 45000,
    });
  }

  void joinCallSession(String sessionId) {
    print('📤 [CallSocket] join_call_session → sessionId=$sessionId');
    _socket?.emit('join_call_session', {'sessionId': sessionId});
  }

void endCall({required String sessionId, int? durationSeconds}) {
  print('📤 [CallSocket] end_call → sessionId=$sessionId');
  _socket?.emit('end_call', {
    'sessionId': sessionId,
    if (durationSeconds != null) 'durationSeconds': durationSeconds,
  });
}

  // ✅ FIX: Intentional disconnect sets flag so callbacks don't fire
 Future<void> disconnect({Duration? graceBeforeTeardown}) async {
  _isIntentionalDisconnect = true;
  if (graceBeforeTeardown != null) {
    await Future.delayed(graceBeforeTeardown);
  }
  _tearDown();
}

  void _tearDown() {
    _socket?.clearListeners();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  // ✅ NEW: Nullify all callbacks — call this before re-wiring a new session
  // so stale closures from the previous session can't fire into a new one.
  void clearCallbacks() {
    onConnected = null;
    onCallRequestSent = null;
    onCallAccepted = null;
    onCallRejected = null;
    onCallRequestCancelled = null;
    onCallRequestWithdrawn = null;
    onJoinedCallSession = null;
    onCallSessionEnded = null;
    onCallEndedAck = null;
    onError = null;
  }

  // ── Util ──────────────────────────────────────────────────────────────
  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is List && data.isNotEmpty && data.first is Map) {
      return Map<String, dynamic>.from(data.first as Map);
    }
    return {};
  }
}