import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

typedef MessageCallback = void Function(Map<String, dynamic> message);
typedef TicketUpdateCallback = void Function(Map<String, dynamic> ticket);
typedef TypingCallback = void Function(String ticketId, bool isStopped);

/// Singleton WebSocket service for Support Desk.
/// Event names matched exactly to backend useSupportSocket hook.
class SupportDeskSocketService {
  SupportDeskSocketService._();
  static final SupportDeskSocketService instance = SupportDeskSocketService._();

  io.Socket? _socket;

  // ── Callbacks ──────────────────────────────────────────────────────────────
  MessageCallback? onNewMessage;
  TicketUpdateCallback? onTicketUpdated;
  TypingCallback? onTyping; // (ticketId, isStopped)
  void Function(String)? onError;

  bool get isConnected => _socket?.connected == true;

  // ── Connect ────────────────────────────────────────────────────────────────
  Future<void> connect(String token, String baseUrl) async {
    if (isConnected) {
      debugPrint('🎧 SupportSocket already connected');
      return;
    }

    _socket?.dispose();
    _socket = null;

    // ✅ Backend connects to /support namespace (matches `io(\`\${url}/support\`)`)
    final socketUrl = '${baseUrl.replaceAll(RegExp(r'/$'), '')}';
    debugPrint('🎧 SupportSocket connecting to $socketUrl');

    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling']) // ✅ match backend order
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(999)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(10000)
          // ✅ Backend reads auth: { token, userType } from socket.handshake.auth
          .setAuth({'token': token, 'userType': 'User'})
          .build(),
    );

    _socket!
      ..onConnect((_) {
        debugPrint('🎧 SupportSocket connected ✅');
      })
      ..onDisconnect((reason) {
        debugPrint('🎧 SupportSocket disconnected: $reason');
        // ✅ Backend does: if (reason === 'io server disconnect') socket.connect()
        if (reason == 'io server disconnect') {
          _socket?.connect();
        }
      })
      ..onConnectError((e) {
        debugPrint('🎧 SupportSocket connect error: $e');
        onError?.call(e.toString());
      })
      ..onError((e) {
        debugPrint('🎧 SupportSocket error: $e');
        onError?.call(e.toString());
      })
      // ✅ Backend emits 'new_message', 'message', 'ticket_message' — listen to all 3
      ..on('new_message', _handleIncomingMessage)
      ..on('message', _handleIncomingMessage)
      ..on('ticket_message', _handleIncomingMessage)
      // ✅ Backend emits 'messages_read'
      ..on('messages_read', (data) {
        debugPrint('🎧 messages_read: $data');
        final map = _toMap(data);
        if (map != null) onTicketUpdated?.call(map);
      })
      // ✅ Backend emits 'user_typing' and 'user_stopped_typing'
      ..on('user_typing', (data) {
        debugPrint('🎧 user_typing: $data');
        final ticketId = _extractTicketId(data);
        if (ticketId != null) onTyping?.call(ticketId, false);
      })
      ..on('user_stopped_typing', (data) {
        debugPrint('🎧 user_stopped_typing: $data');
        final ticketId = _extractTicketId(data);
        if (ticketId != null) onTyping?.call(ticketId, true);
      })
      ..connect();

    // Wait up to 5s for connection
    int waited = 0;
    while (!isConnected && waited < 5000) {
      await Future.delayed(const Duration(milliseconds: 200));
      waited += 200;
    }

    debugPrint(
      isConnected
          ? '🎧 SupportSocket ready after ${waited}ms'
          : '⚠️ SupportSocket did not connect within 5s — will retry',
    );
  }

  void _handleIncomingMessage(dynamic data) {
    debugPrint('🎧 incoming message event: $data');
    // ✅ Backend wraps in payload?.message ?? payload
    Map<String, dynamic>? map;
    if (data is Map) {
      final inner = data['message'];
      map = inner is Map
          ? Map<String, dynamic>.from(inner)
          : Map<String, dynamic>.from(data);
    }
    if (map != null) onNewMessage?.call(map);
  }

  // ── Room management ────────────────────────────────────────────────────────
  void joinTicket(String ticketId) {
    if (!isConnected) {
      debugPrint('⚠️ Cannot join ticket room — socket not connected');
      return;
    }
    // ✅ Backend: s.emit('join_ticket', ticketId) — plain string, NOT a map
    _socket!.emit('join_ticket', ticketId);
    debugPrint('🎧 Joined ticket room: $ticketId');
  }

  void leaveTicket(String ticketId) {
    if (!isConnected) return;
    // ✅ Backend: socketRef.current?.emit('leave_ticket', ticketId)
    _socket!.emit('leave_ticket', ticketId);
    debugPrint('🎧 Left ticket room: $ticketId');
  }

  // ✅ Backend: s.emit('typing_start', { ticketId }) — map with ticketId key
  void emitTypingStart(String ticketId) {
    if (!isConnected) return;
    _socket!.emit('typing_start', {'ticketId': ticketId});
  }

  // ✅ Backend: s.emit('typing_stop', { ticketId })
  void emitTypingStop(String ticketId) {
    if (!isConnected) return;
    _socket!.emit('typing_stop', {'ticketId': ticketId});
  }

  // Keep old method name as alias so provider doesn't break
  void emitTyping(String ticketId) => emitTypingStart(ticketId);

  // ── Cleanup ────────────────────────────────────────────────────────────────
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    onNewMessage = null;
    onTicketUpdated = null;
    onTyping = null;
    onError = null;
    debugPrint('🎧 SupportSocket disconnected & disposed');
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Map<String, dynamic>? _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  String? _extractTicketId(dynamic data) {
    if (data is String) return data;
    if (data is Map) {
      return data['ticketId']?.toString() ??
          data['ticket']?['_id']?.toString() ??
          data['ticket']?.toString();
    }
    return null;
  }
}
