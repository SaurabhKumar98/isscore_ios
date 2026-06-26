// lib/data/models/api_models/teacherconnect/chatmessage.dart

enum ChatStatus { idle, requesting, joining, active, ended }

/// The type of a chat message attachment.
enum MessageFileType { image, document, none }

class ChatMessage {
  final String id;
  final String text;
  final String senderId;
  final bool isMine;
  final DateTime sentAt;

  // ── File / attachment fields ──────────────────────────────────────
  final String? fileUrl;       // remote URL (from server) or local path (optimistic)
  final String? fileName;      // original file name, e.g. "notes.pdf"
  final MessageFileType fileType; // image | document | none

  const ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.isMine,
    required this.sentAt,
    this.fileUrl,
    this.fileName,
    this.fileType = MessageFileType.none,
  });

  /// True when this message carries an attachment.
  bool get hasFile => fileType != MessageFileType.none && fileUrl != null;

  /// True when the attachment is an image.
  bool get isImage => fileType == MessageFileType.image;

  /// True when the attachment is a document (PDF, DOCX, …).
  bool get isDocument => fileType == MessageFileType.document;

  // ── JSON helpers ──────────────────────────────────────────────────

  factory ChatMessage.fromJson(Map<String, dynamic> json, String myId) {
    final senderId  = json['senderId']?.toString() ?? '';
    final rawType   = json['fileType']?.toString();
    final fileType  = _parseFileType(rawType);
    final fileUrl   = json['fileUrl']?.toString();
    final fileName  = json['fileName']?.toString();

    return ChatMessage(
      id:       json['_id']?.toString() ??
                json['id']?.toString()  ??
                '${senderId}_${DateTime.now().millisecondsSinceEpoch}',
      text:     json['text']?.toString() ??
                json['message']?.toString() ?? '',
      senderId: senderId,
      isMine:   senderId == myId,
      sentAt:   json['sentAt'] != null
                    ? (DateTime.tryParse(json['sentAt'].toString()) ?? DateTime.now())
                    : DateTime.now(),
      fileUrl:  fileUrl,
      fileName: fileName,
      fileType: fileType,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':       id,
    'text':     text,
    'senderId': senderId,
    'sentAt':   sentAt.toIso8601String(),
    if (fileUrl  != null) 'fileUrl':  fileUrl,
    if (fileName != null) 'fileName': fileName,
    if (fileType != MessageFileType.none)
      'fileType': fileType == MessageFileType.image ? 'image' : 'document',
  };

  static MessageFileType _parseFileType(String? raw) {
    switch (raw) {
      case 'image':    return MessageFileType.image;
      case 'document': return MessageFileType.document;
      default:         return MessageFileType.none;
    }
  }
}