// lib/view_models/teacherconnectprovider/chatsocket_services.dart

import 'dart:io';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatSocketService {
  static final ChatSocketService _instance = ChatSocketService._internal();
  factory ChatSocketService() => _instance;
  ChatSocketService._internal();

  IO.Socket? _socket;
  IO.Socket? get socket => _socket;
  bool get isConnected => _socket?.connected ?? false;

  // ─────────────────── CONNECT ─────────────────────────────────────

  void connect(String token) {
    if (_socket != null) {
      _socket!.clearListeners();
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }

    _socket = IO.io(
      "${ApiEndpoint.socketBaseUrl}/teacher-chat",
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setAuth({'token': token})
          .enableReconnection()
          .setReconnectionAttempts(double.maxFinite.toInt())
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(30000)
          .setTimeout(30000)
          .enableForceNew()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) =>
        print("✅ Chat socket connected. ID: ${_socket?.id}"));
    _socket!.onDisconnect((r) =>
        print("❌ Chat socket disconnected: $r"));
    _socket!.onConnectError((e) =>
        print("❌ Chat socket connect error: $e"));
    _socket!.on("reconnect_attempt", (a) =>
        print("🔄 Reconnect attempt #$a"));
  }

  // ─────────────────── ACTIONS ────────────────────────────────────

  void requestChat({required String teacherId, String? subject}) {
    if (!isConnected) {
      print("❌ Cannot send chat_request — socket not connected");
      return;
    }
    _socket?.emit("chat_request", {
      "teacherId": teacherId,
      if (subject != null) "subject": subject,
    });
  }

  void joinSession(String sessionId) {
    _socket?.emit("join_chat_session", {"sessionId": sessionId});
  }

  /// Plain text message — no attachment.
// ChatSocketService
void sendMessage({
  required String sessionId,
  required String text,
  required String clientId,
}) {
  if (!isConnected) return;
  _socket?.emit("send_chat_message", {
    "sessionId": sessionId,
    "text": text.trim(),
    "clientId": clientId,
  });
}
  /// File message — reads the file into bytes and sends everything over
  /// the socket in a single emit, exactly as the backend expects:
  ///
  /// {
  ///   sessionId:  String,
  ///   text:       String,   // caption, may be empty
  ///   attachment: {
  ///     name: String,
  ///     type: String,       // mime type, e.g. "image/jpeg"
  ///     size: int,          // byte length
  ///     data: Uint8List,    // raw bytes
  ///   }
  /// }
  ///
  /// Returns true if the emit was sent, false if the socket is disconnected
  /// or the file could not be read.
  Future<bool> sendFileMessage({
    required String  sessionId,
    required File    file,
    required String  fileName,
    required String  mimeType,   // e.g. "image/jpeg", "application/pdf"
    String           text = '',
  }) async {
    if (!isConnected) {
      print("❌ Cannot send file — socket not connected");
      return false;
    }

    try {
      final bytes = await file.readAsBytes();

      print("📤 Emitting send_chat_message with attachment "
            "— file: $fileName  size: ${bytes.length}B  mime: $mimeType");

      _socket?.emit("send_chat_message", {
        "sessionId":  sessionId,
        "text":       text.trim(),
        "attachment": {
          "name": fileName,
          "type": mimeType,
          "size": bytes.length,
          "data": bytes,          // Uint8List — socket.io-client serialises this correctly
        },
      });

      return true;
    } catch (e) {
      print("❌ sendFileMessage error reading file: $e");
      return false;
    }
  }

  void cancelRequest({
    String? sessionId,
    String  reason        = 'student_cancelled',
    bool    autoCancelled = false,
  }) {
    _socket?.emit("cancel_chat_request", {
      if (sessionId != null) "sessionId": sessionId,
      "reason":        reason,
      "autoCancelled": autoCancelled,
      "timeoutMs":     45000,
    });
  }

  void endChat(String sessionId) {
    _socket?.emit("end_chat", {"sessionId": sessionId});
  }

  void disconnect() {
    _socket?.clearListeners();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}