// ─── lib/data/models/api_models/report/chatteachermodels.dart ─────────────

// ── helper ────────────────────────────────────────────────────────────────
// Safely converts any JSON value to a List<String>.
// Guards against the API returning null, a Map, or a non-string element
// inside the array — all of which cause "Map is not a subtype of List".
List<String> _toStringList(dynamic value) {
  if (value is! List) return [];
  return value.map((e) => e?.toString() ?? '').toList();
}

// Safely converts a raw JSON map (which Dio can give back as
// Map<dynamic,dynamic>) to Map<String,dynamic> without throwing.
Map<String, dynamic> _toMap(dynamic value) {
  if (value == null) return {};
  if (value is Map<String, dynamic>) return value;
  // Dio sometimes gives Map<dynamic,dynamic>
  return Map<String, dynamic>.from(value as Map);
}

// ─────────────────────────────────────────────────────────────────────────

class ChatTeacherModel {
  final String id;
  final String name;
  final String profileImage;
  final List<String> skills;

  const ChatTeacherModel({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.skills,
  });

  factory ChatTeacherModel.fromJson(Map<String, dynamic> json) =>
      ChatTeacherModel(
        id: json['_id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        profileImage: json['profileImage']?.toString() ?? '',
        skills: _toStringList(json['skills']), // ← safe
      );
}

class AttachmentModel {
  final String url;
  final String name;
  final String type;
  final int size;

  const AttachmentModel({
    required this.url,
    required this.name,
    required this.type,
    required this.size,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) =>
      AttachmentModel(
        url: json['url']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        size: (json['size'] as num?)?.toInt() ?? 0,
      );
}

class LastMessageModel {
  final String text;
  final String from;
  final String sentAt;
  final AttachmentModel? attachment;

  const LastMessageModel({
    required this.text,
    required this.from,
    required this.sentAt,
    this.attachment,
  });

  factory LastMessageModel.fromJson(Map<String, dynamic> json) =>
      LastMessageModel(
        text: json['text']?.toString() ?? '',
        from: json['from']?.toString() ?? '',
        sentAt: json['sentAt']?.toString() ?? '',
        attachment: json['attachment'] != null && json['attachment'] is Map
            ? AttachmentModel.fromJson(_toMap(json['attachment']))
            : null,
      );
}

/// One row in the Chat Report teacher list.
class ChatConversationModel {
  final String teacherId;
  final ChatTeacherModel teacher;
  final int messageCount;
  final String lastActivityAt;
  final LastMessageModel lastMessage;

  const ChatConversationModel({
    required this.teacherId,
    required this.teacher,
    required this.messageCount,
    required this.lastActivityAt,
    required this.lastMessage,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) =>
      ChatConversationModel(
        teacherId: json['teacherId']?.toString() ?? '',
        teacher: ChatTeacherModel.fromJson(_toMap(json['teacher'])),
        messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
        lastActivityAt: json['lastActivityAt']?.toString() ?? '',
        lastMessage: LastMessageModel.fromJson(_toMap(json['lastMessage'])),
      );
}

/// Single chat message in the detail thread.
class ChatMessageModel {
  final String id;
  final String session;
  final String from;
  final String senderId;
  final String senderName;
  final String text;
  final AttachmentModel? attachment;
  final String sentAt;

  const ChatMessageModel({
    required this.id,
    required this.session,
    required this.from,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.attachment,
    required this.sentAt,
  });

  bool get isStudent => from == 'student';
  bool get hasAttachment => attachment != null;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        id: json['_id']?.toString() ?? '',
        session: json['session']?.toString() ?? '',
        from: json['from']?.toString() ?? '',
        senderId: json['senderId']?.toString() ?? '',
        senderName: json['senderName']?.toString() ?? '',
        text: json['text']?.toString() ?? '',
        attachment: json['attachment'] != null && json['attachment'] is Map
            ? AttachmentModel.fromJson(_toMap(json['attachment']))
            : null,
        sentAt: json['sentAt']?.toString() ?? '',
      );
}