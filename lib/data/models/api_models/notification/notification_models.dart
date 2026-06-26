import 'dart:convert';

NotificationModels notificationModelsFromJson(String str) =>
    NotificationModels.fromJson(json.decode(str));

String notificationModelsToJson(NotificationModels data) =>
    json.encode(data.toJson());

class NotificationModels {
  bool success;
  String message;
  List<NotificationItem> data;
  Meta? meta;

  NotificationModels({
    required this.success,
    required this.message,
    required this.data,
    this.meta,
  });

  factory NotificationModels.fromJson(Map<String, dynamic> json) =>
      NotificationModels(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] == null
            ? []
            : List<NotificationItem>.from(
                json["data"].map((x) => NotificationItem.fromJson(x))),
        meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data.map((x) => x.toJson()).toList(),
        "meta": meta?.toJson(),
      };
}

class NotificationItem {
  String? id;
  String? title;
  String? body;
  Recipient? recipient;
  SentBy? sentBy;
  bool isRead;
  DateTime? readAt;
  Data? data;
  Type? type;
  bool fcmSent;
  DateTime? fcmSentAt;
  int? v;
  DateTime? createdAt;
  DateTime? updatedAt;

  NotificationItem({
    this.id,
    this.title,
    this.body,
    this.recipient,
    this.sentBy,
    this.isRead = false,
    this.readAt,
    this.data,
    this.type,
    this.fcmSent = false,
    this.fcmSentAt,
    this.v,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: json["_id"],
        title: json["title"],
        body: json["body"],
        recipient: recipientValues.map[json["recipient"]],
        sentBy:
            json["sentBy"] == null ? null : SentBy.fromJson(json["sentBy"]),
        isRead: json["isRead"] ?? false,
        readAt: json["readAt"] != null
            ? DateTime.tryParse(json["readAt"])
            : null,
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        type: typeValues.map[json["type"]],
        fcmSent: json["fcmSent"] ?? false,
        fcmSentAt: json["fcmSentAt"] != null
            ? DateTime.tryParse(json["fcmSentAt"])
            : null,
        v: json["__v"],
        createdAt: json["createdAt"] != null
            ? DateTime.tryParse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.tryParse(json["updatedAt"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "body": body,
        "recipient": recipientValues.reverse[recipient],
        "sentBy": sentBy?.toJson(),
        "isRead": isRead,
        "readAt": readAt?.toIso8601String(),
        "data": data?.toJson(),
        "type": typeValues.reverse[type],
        "fcmSent": fcmSent,
        "fcmSentAt": fcmSentAt?.toIso8601String(),
        "__v": v,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

class Data {
  Type? type;

  Data({this.type});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        type: typeValues.map[json["type"]],
      );

  Map<String, dynamic> toJson() => {
        "type": typeValues.reverse[type],
      };
}

enum Type { ANNOUNCEMENT, COURSE, EVENT, GENERAL }

final typeValues = EnumValues({
  "announcement": Type.ANNOUNCEMENT,
  "course": Type.COURSE,
  "event": Type.EVENT,
  "general": Type.GENERAL,
});

enum Recipient { UNKNOWN }

final recipientValues = EnumValues({
  "69a666cbf33b06225705ac8c": Recipient.UNKNOWN,
});

class SentBy {
  String? id;
  String? name;
  String? email;

  SentBy({this.id, this.name, this.email});

  factory SentBy.fromJson(Map<String, dynamic> json) => SentBy(
        id: json["_id"],
        name: json["name"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "email": email,
      };
}

class Meta {
  int? page;
  int? limit;
  int? total;
  int? pages;

  Meta({this.page, this.limit, this.total, this.pages});

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        page: json["page"],
        limit: json["limit"],
        total: json["total"],
        pages: json["pages"],
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "limit": limit,
        "total": total,
        "pages": pages,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap ??= map.map((k, v) => MapEntry(v, k));
    return reverseMap!;
  }
}