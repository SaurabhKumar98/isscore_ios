// lib/view_models/teacherconnectprovider/chatprovider.dart

import 'dart:async';
import 'dart:io';
import 'package:firstedu/core/localstorage/localstorage.dart';
import 'package:firstedu/data/models/api_models/teacherconnect/chatmessage.dart';
import 'package:firstedu/view_models/teacherconnectprovider/chatsocket_services.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

export 'package:firstedu/data/models/api_models/teacherconnect/chatmessage.dart'
    show ChatStatus;

class ChatProvider extends ChangeNotifier {
  final ChatSocketService _socketService;

  ChatProvider(this._socketService);

  // ── Status ────────────────────────────────────────────────────────
  ChatStatus _status = ChatStatus.idle;
  ChatStatus get status => _status;

  bool get isIdle       => _status == ChatStatus.idle;
  bool get isRequesting => _status == ChatStatus.requesting;
  bool get isJoining    => _status == ChatStatus.joining;
  bool get isActive     => _status == ChatStatus.active;
  bool get isEnded      => _status == ChatStatus.ended;

  // ── Session ───────────────────────────────────────────────────────
  String? _sessionId;
  String? get sessionId => _sessionId;

  String? _pendingTeacherName;
  String? get pendingTeacherName => _pendingTeacherName;

  String? _pendingTeacherId;

  // ── Messages ──────────────────────────────────────────────────────
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  // ── Billing ───────────────────────────────────────────────────────
  int _billedMinutes = 0;
  int get billedMinutes => _billedMinutes;

  // ── Error / upload state ──────────────────────────────────────────
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _endReason;
  String? get endReason => _endReason;

  bool _isUploadingFile = false;
  bool get isUploadingFile => _isUploadingFile;

  String? _uploadError;
  String? get uploadError => _uploadError;

  // ── Identity ──────────────────────────────────────────────────────
  String? _myId;

  bool _listenersRegistered = false;

  // ── Auto-cancel timer (45 s) ──────────────────────────────────────
  Timer? _autoCancelTimer;

  void _startAutoCancelTimer() {
    _autoCancelTimer?.cancel();
    _autoCancelTimer = Timer(const Duration(seconds: 45), () {
      if (isRequesting || isJoining) {
        debugPrint("⏱️ Auto-cancel: teacher did not respond in 45s");
        _socketService.cancelRequest(
          sessionId:    _sessionId,
          reason:       'teacher_no_response_timeout',
          autoCancelled: true,
        );
        _status       = ChatStatus.idle;
        _errorMessage = "Teacher did not respond. Please try again.";
        _sessionId          = null;
        _pendingTeacherName = null;
        _pendingTeacherId   = null;
        notifyListeners();
      }
    });
  }

  void _cancelAutoCancelTimer() {
    _autoCancelTimer?.cancel();
    _autoCancelTimer = null;
  }

  // ─────────────────── INIT ──────────────────────────────────────

  Future<void> init() async {
    final token = await UserLocalStorage.getAccessToken();
    _myId = await UserLocalStorage.getUserId();

    if (token == null) {
      debugPrint("⚠️ ChatProvider: No token found");
      return;
    }

    _socketService.connect(token);
    await Future.delayed(const Duration(milliseconds: 500));

    if (!_listenersRegistered) {
      _registerListeners();
      _listenersRegistered = true;
    }
  }

  void _registerListeners() {
    final socket = _socketService.socket;
    if (socket == null) return;

    socket.on("chat_request_sent",      _onRequestSent);
    socket.on("chat_accepted",          _onAccepted);
    socket.on("chat_rejected",          _onRejected);
    socket.on("joined_chat_session",    _onJoined);
    socket.on("chat_message",           _onMessage);
    socket.on("chat_session_ended",     _onSessionEnded);
    socket.on("chat_error",             _onError);
    socket.on("chat_request_cancelled", _onRequestCancelled);
    socket.on("chat_request_withdrawn", _onRequestWithdrawn);
    socket.on("chat_minute_billed",     _onMinuteBilled);

    socket.on("connect", (_) {
      debugPrint("🔄 Socket reconnected");
      if (isActive && _sessionId != null) {
        _socketService.joinSession(_sessionId!);
      }
    });

    debugPrint("✅ ChatProvider: Listeners registered");
  }

  void _removeListeners() {
    final socket = _socketService.socket;
    if (socket == null) return;
    socket.off("chat_request_sent");
    socket.off("chat_accepted");
    socket.off("chat_rejected");
    socket.off("joined_chat_session");
    socket.off("chat_message");
    socket.off("chat_session_ended");
    socket.off("chat_error");
    socket.off("chat_request_cancelled");
    socket.off("chat_request_withdrawn");
    socket.off("chat_minute_billed");
    socket.off("connect");
  }

  // ─────────────────── SOCKET HANDLERS ──────────────────────────

  void _onRequestSent(dynamic data) {
    debugPrint("📤 chat_request_sent: $data");
    final payload = data is List ? data[0] : data;
    if (payload is Map) _sessionId = _extractSessionId(payload);
    _status       = ChatStatus.requesting;
    _errorMessage = null;
    _startAutoCancelTimer();
    notifyListeners();
  }

  void _onAccepted(dynamic data) {
    debugPrint("✅ chat_accepted: $data");
    _cancelAutoCancelTimer();
    final payload = data is List ? data[0] : data;
    if (payload is Map) _sessionId ??= _extractSessionId(payload);
    _status = ChatStatus.joining;
    notifyListeners();
    if (_sessionId != null) _socketService.joinSession(_sessionId!);
  }

  void _onRejected(dynamic data) {
    debugPrint("❌ chat_rejected: $data");
    _cancelAutoCancelTimer();
    final payload     = data is List ? data[0] : data;
    final reason      = payload is Map ? payload['reason']?.toString() : null;
    _errorMessage       = reason ?? "The teacher declined your request.";
    _status             = ChatStatus.idle;
    _sessionId          = null;
    _pendingTeacherName = null;
    _pendingTeacherId   = null;
    notifyListeners();
  }

  void _onJoined(dynamic data) {
    debugPrint("🚪 joined_chat_session: $data");
    final payload = data is List ? data[0] : data;
    if (payload is Map) _sessionId ??= _extractSessionId(payload);
    _messages.clear();
    _billedMinutes = 0;
    _errorMessage  = null;
    _endReason     = null;
    _status        = ChatStatus.active;
    notifyListeners();
  }

  void _onMessage(dynamic data) {
    debugPrint("💬 chat_message RAW: $data");
    final payload = data is List ? data[0] : data;
    if (payload is! Map) return;

    final text       = payload['text']?.toString() ?? '';
    // The server returns the stored URL in the attachment object
    final attachment = payload['attachment'] as Map?;
    final fileUrl    = attachment?['url']?.toString() ??
                       attachment?['fileUrl']?.toString() ??
                       payload['fileUrl']?.toString();
    final fileName   = attachment?['name']?.toString() ??
                       payload['fileName']?.toString();
    final rawMime    = attachment?['type']?.toString() ??
                       payload['fileType']?.toString();
    final fileType   = _fileTypeFromMime(rawMime);

    if (text.trim().isEmpty && fileUrl == null) return;

    final senderId = payload['senderId']?.toString() ?? '';
    final msgId    = payload['_id']?.toString() ??
                     payload['id']?.toString() ??
                     '${senderId}_${DateTime.now().millisecondsSinceEpoch}';
    final sentAt   = payload['sentAt'] != null
        ? DateTime.tryParse(payload['sentAt'].toString()) ?? DateTime.now()
        : DateTime.now();
    final isMine   = senderId == _myId;

    // ── Replace optimistic file bubble with server-confirmed one ──
    // ChatProvider._onMessage() — replace the text-based dedup block with clientId matching
final clientId = payload['clientId']?.toString();

if (isMine && clientId != null) {
  final optIdx = _messages.indexWhere((m) => m.id == clientId);
  if (optIdx != -1) {
    _messages[optIdx] = ChatMessage(
      id: msgId, text: text, senderId: senderId,
      isMine: true, sentAt: sentAt,
      fileUrl: fileUrl, fileName: fileName, fileType: fileType,
    );
    notifyListeners();
    return;
  }
}

    // ── Dedup optimistic plain-text echo ──
    if (isMine && fileUrl == null && text.trim().isNotEmpty) {
      if (_messages.any((m) => m.isMine && m.text == text.trim() && !m.hasFile)) {
        debugPrint("⚡ Skipping duplicate optimistic echo");
        return;
      }
    }

    // ── Dedup by server id ──
    if (_messages.any((m) => m.id == msgId)) return;

    _messages.add(ChatMessage(
      id: msgId, text: text, senderId: senderId,
      isMine: isMine, sentAt: sentAt,
      fileUrl: fileUrl, fileName: fileName, fileType: fileType,
    ));

    notifyListeners();
  }

void _onSessionEnded(dynamic data) {
  debugPrint("⛔ chat_session_ended: $data");
  _cancelAutoCancelTimer();
  final payload = data is List ? data[0] : data;
  if (payload is Map) _endReason = payload['reason']?.toString();
  _status = ChatStatus.ended;

  // Resolve our own pending endChat() wait, if any — this is what makes
  // the fix above actually work instead of always timing out.
  if (_endChatEcho != null && !_endChatEcho!.isCompleted) {
    _endChatEcho!.complete();
  }

  notifyListeners();
}

  void _onError(dynamic data) {
    debugPrint("⚠️ chat_error: $data");
    _cancelAutoCancelTimer();
    final payload = data is List ? data[0] : data;
    _errorMessage = payload is Map
        ? payload['message']?.toString() ?? "Something went wrong."
        : payload.toString();
    _status    = ChatStatus.idle;
    _sessionId = null;
    notifyListeners();
  }

  void _onRequestCancelled(dynamic data) {
    debugPrint("🚫 chat_request_cancelled: $data");
    _cancelAutoCancelTimer();
    _status             = ChatStatus.idle;
    _sessionId          = null;
    _pendingTeacherName = null;
    _pendingTeacherId   = null;
    notifyListeners();
  }

  void _onRequestWithdrawn(dynamic data) {
    debugPrint("🚫 chat_request_withdrawn: $data");
    _cancelAutoCancelTimer();
    if (isRequesting || isJoining) {
      _status             = ChatStatus.idle;
      _sessionId          = null;
      _pendingTeacherName = null;
      _pendingTeacherId   = null;
      notifyListeners();
    }
  }

  void _onMinuteBilled(dynamic data) {
    debugPrint("💰 chat_minute_billed: $data");
    _billedMinutes++;
    notifyListeners();
  }

  // ─────────────────── ACTIONS ──────────────────────────────────

  Future<void> requestChat({
    required String teacherId,
    required String teacherName,
    String? subject,
  }) async {
    if (!isIdle) return;

    if (!_socketService.isConnected) {
      await init();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _pendingTeacherId   = teacherId;
    _pendingTeacherName = teacherName;
    _errorMessage  = null;
    _endReason     = null;
    _sessionId     = null;
    _messages.clear();
    _billedMinutes = 0;
    _status        = ChatStatus.requesting;
    notifyListeners();

    _socketService.requestChat(teacherId: teacherId);
  }

  /// Send plain text via socket with optimistic insert.
// ChatProvider.sendMessage()
void sendMessage(String text) {
  if (_sessionId == null || text.trim().isEmpty || !isActive) return;

  final trimmed = text.trim();
  final clientId = 'local-${DateTime.now().millisecondsSinceEpoch}';

  _messages.add(ChatMessage(
    id: clientId,                 // reuse clientId as the optimistic id
    text: trimmed,
    senderId: _myId ?? '',
    isMine: true,
    sentAt: DateTime.now(),
  ));
  notifyListeners();

  _socketService.sendMessage(sessionId: _sessionId!, text: trimmed, clientId: clientId);
}
  /// Send a file via socket.
  ///
  /// 1. Adds an optimistic bubble immediately with the local file path so
  ///    the user sees it right away (image renders from disk, document shows
  ///    the filename).
  /// 2. Reads the file bytes and emits send_chat_message with the attachment
  ///    object the backend expects.
  /// 3. When the backend broadcasts the confirmed chat_message socket event,
  ///    [_onMessage] replaces the optimistic bubble with the remote URL.
  /// 4. On failure the optimistic bubble is removed and [uploadError] is set.
  Future<void> sendFile({
    required File            file,
    required String          fileName,
    required MessageFileType fileType,
    String                   caption = '',
  }) async {
    if (_sessionId == null || !isActive) return;

    _isUploadingFile = true;
    _uploadError     = null;

    // Derive mime type from file extension
    final mimeType = lookupMimeType(file.path) ??
        (fileType == MessageFileType.image ? 'image/jpeg' : 'application/octet-stream');

    // Optimistic bubble with local path for instant preview
    final optimisticId = 'opt_file_${DateTime.now().millisecondsSinceEpoch}';
    _messages.add(ChatMessage(
      id:       optimisticId,
      text:     caption,
      senderId: _myId ?? '',
      isMine:   true,
      sentAt:   DateTime.now(),
      fileUrl:  file.path,   // local path — replaced by remote URL on server echo
      fileName: fileName,
      fileType: fileType,
    ));
    notifyListeners();

    final ok = await _socketService.sendFileMessage(
      sessionId: _sessionId!,
      file:      file,
      fileName:  fileName,
      mimeType:  mimeType,
      text:      caption,
    );

    _isUploadingFile = false;

    if (!ok) {
      _messages.removeWhere((m) => m.id == optimisticId);
      _uploadError = "Failed to send file. Please try again.";
      notifyListeners();
      return;
    }

    // Success path: _onMessage will fire from the socket broadcast and
    // swap out the optimistic bubble — no extra notifyListeners needed here.
    notifyListeners(); // clears isUploadingFile in UI
  }

  void cancelRequest() {
    if (!isRequesting) return;
    _cancelAutoCancelTimer();
    _socketService.cancelRequest(
      sessionId:    _sessionId,
      reason:       'student_cancelled',
      autoCancelled: false,
    );
    _status             = ChatStatus.idle;
    _sessionId          = null;
    _pendingTeacherName = null;
    _pendingTeacherId   = null;
    notifyListeners();
  }

// add near the other Completer-style state in ChatProvider
Completer<void>? _endChatEcho;

Future<void> endChat() async {
  if (_sessionId == null || !isActive) return;

  _endChatEcho = Completer<void>();
  _socketService.endChat(_sessionId!);

  // Wait for the server's own chat_session_ended broadcast to confirm
  // it actually processed end_chat — don't just assume the emit landed.
  await _endChatEcho!.future.timeout(
    const Duration(seconds: 4),
    onTimeout: () {
      debugPrint("⚠️ No chat_session_ended echo within 4s — ending locally anyway");
    },
  );

  if (_status != ChatStatus.ended) {
    _status = ChatStatus.ended;
    notifyListeners();
  }
}


  void reset() {
    _cancelAutoCancelTimer();
    _status             = ChatStatus.idle;
    _sessionId          = null;
    _pendingTeacherName = null;
    _pendingTeacherId   = null;
    _messages.clear();
    _errorMessage    = null;
    _endReason       = null;
    _billedMinutes   = 0;
    _isUploadingFile = false;
    _uploadError     = null;
    notifyListeners();
  }

  // ─────────────────── HELPERS ──────────────────────────────────

  String? _extractSessionId(Map payload) =>
      payload['sessionId']?.toString() ??
      (payload['session'] as Map?)?['_id']?.toString() ??
      (payload['session'] as Map?)?['id']?.toString();

  /// Derive MessageFileType from a mime string returned by the server.
  static MessageFileType _fileTypeFromMime(String? mime) {
    if (mime == null) return MessageFileType.none;
    if (mime.startsWith('image/')) return MessageFileType.image;
    return MessageFileType.document;
  }

  @override
  void dispose() {
    _cancelAutoCancelTimer();
    _removeListeners();
    super.dispose();
  }
}