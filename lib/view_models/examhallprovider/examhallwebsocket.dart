import 'dart:async';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// ── Callback typedefs ────────────────────────────────────────────────────────
typedef OnTimerUpdate = void Function(int remainingTimeMs);
typedef OnAutoSubmitted = void Function(String reason);
typedef OnProctoringLogged = void Function(int violationCount, String message);
typedef OnError = void Function(String message);
typedef OnSessionExpired = void Function();

class ExamSocketService {
  static const String _socketBaseUrl = '${ApiEndpoint.websocket}';

  IO.Socket? _socket;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // ── Callbacks set by the provider ─────────────────────────────────────────
  OnTimerUpdate? onTimerUpdate;
  OnAutoSubmitted? onAutoSubmitted;
  OnProctoringLogged? onProctoringLogged;
  OnError? onError;
  OnSessionExpired? onSessionExpired;

  // ── Active session being tracked ──────────────────────────────────────────
  String? _currentSessionId;

  // ── Connect (call once when user enters ExamScreen) ───────────────────────
  Future<void> connect(String accessToken) async {
    if (_isConnected) return;

    _socket = IO.io(
      '$_socketBaseUrl/exam',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableForceNew()
          .setAuth({'token': accessToken})
          .setTimeout(5000)
          .setReconnectionAttempts(3)
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      debugPrint('✅ ExamSocket connected');
      // Re-join if we were already in a session
      if (_currentSessionId != null) {
        joinSession(_currentSessionId!);
      }
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      debugPrint('⚡ ExamSocket disconnected');
    });

    _socket!.onConnectError((err) {
      _isConnected = false;
      debugPrint('❌ ExamSocket connect error: $err');
      onError?.call('Connection error. Timer running locally.');
    });

    _socket!.onError((err) {
      debugPrint('❌ ExamSocket error: $err');
    });

    _setupListeners();
  }

  // ── Setup all server → client listeners ───────────────────────────────────
  void _setupListeners() {
    // Joined confirmation → sync timer immediately
    _socket!.on('joined_exam_session', (data) {
      debugPrint('📋 Joined exam session: $data');
      if (data is Map && data['remainingTime'] != null) {
        onTimerUpdate?.call(data['remainingTime'] as int);
      }
    });

    // Periodic timer sync from server
    _socket!.on('timer_update', (data) {
      if (data is Map &&
          data['sessionId'] == _currentSessionId &&
          data['remainingTime'] != null) {
        onTimerUpdate?.call(data['remainingTime'] as int);
      }
    });

    // Auto-submitted by server (time expired OR proctoring violations)
    _socket!.on('exam_auto_submitted', (data) {
      debugPrint('🚨 exam_auto_submitted: $data');
      if (data is Map && data['sessionId'] == _currentSessionId) {
        final reason = data['reason']?.toString() ?? 'time_expired';
        onAutoSubmitted?.call(reason);
      }
    });

    // Proctoring event logged — show warning toast
    _socket!.on('proctoring_event_logged', (data) {
      if (data is Map && data['sessionId'] == _currentSessionId) {
        final count = data['violationCount'] as int? ?? 0;
        final msg =
            data['message']?.toString() ?? 'Proctoring violation logged';
        onProctoringLogged?.call(count, msg);
      }
    });

    // Heartbeat ack — optionally sync timer
    _socket!.on('heartbeat_ack', (data) {
      if (data is Map &&
          data['sessionId'] == _currentSessionId &&
          data['remainingTime'] != null) {
        onTimerUpdate?.call(data['remainingTime'] as int);
      }
    });

    // Session expired (server-side)
    _socket!.on('session_expired', (data) {
      if (data is Map && data['sessionId'] == _currentSessionId) {
        onSessionExpired?.call();
      }
    });

    // Generic error from server
    _socket!.on('error', (data) {
      final msg = data is Map
          ? data['message']?.toString() ?? 'Socket error'
          : data.toString();
      onError?.call(msg);
    });
  }

  // ── Join an exam session room ──────────────────────────────────────────────
  void joinSession(String sessionId) {
    _currentSessionId = sessionId;
    if (!_isConnected) return;
    _socket!.emit('join_exam_session', sessionId);
    debugPrint('📤 Emitted join_exam_session: $sessionId');
  }

  // ── Leave the exam session room ────────────────────────────────────────────
  void leaveSession(String sessionId) {
    if (!_isConnected) return;
    _socket!.emit('leave_exam_session', sessionId);
    _currentSessionId = null;
    debugPrint('📤 Emitted leave_exam_session: $sessionId');
  }

  // ── Emit a proctoring event ────────────────────────────────────────────────
  void emitProctoringEvent(
    String sessionId,
    String eventType, {
    Map<String, dynamic>? metadata,
  }) {
    if (!_isConnected) return;
    _socket!.emit('proctoring_event', {
      'sessionId': sessionId,
      'eventType': eventType,
      'metadata': metadata ?? {},
    });
    debugPrint('📤 Proctoring event: $eventType');
  }

  // ── Request a timer sync from server ──────────────────────────────────────
  void requestTimerUpdate(String sessionId) {
    if (!_isConnected) return;
    _socket!.emit('request_timer_update', sessionId);
  }

  // ── Send heartbeat ────────────────────────────────────────────────────────
  void sendHeartbeat(String sessionId) {
    if (!_isConnected) return;
    _socket!.emit('heartbeat', sessionId);
  }

  // ── Disconnect (call when leaving exam flow entirely) ─────────────────────
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    _currentSessionId = null;
    debugPrint('🔌 ExamSocket disconnected & disposed');
  }
}
