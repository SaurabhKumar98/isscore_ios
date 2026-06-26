import 'dart:convert';

MessageFetchModels messageFetchModelsFromJson(String str) =>
    MessageFetchModels.fromJson(json.decode(str));

String messageFetchModelsToJson(MessageFetchModels data) =>
    json.encode(data.toJson());

class MessageFetchModels {
  bool? success;
  String? message;
  List<MessageData>? data;
  Meta? meta;

  MessageFetchModels({this.success, this.message, this.data, this.meta});

  factory MessageFetchModels.fromJson(Map<String, dynamic> json) =>
      MessageFetchModels(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<MessageData>.from(
                json["data"].map((x) => MessageData.fromJson(x)),
              ),
        meta: json["meta"] != null ? Meta.fromJson(json["meta"]) : null,
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
    "meta": meta?.toJson(),
  };
}

class MessageData {
  String? id;
  String? ticket; // plain ticketId string (from optimistic) or parsed below
  Sender? sender;
  String? senderType;
  String? message;
  List<Attachment>? attachments;
  bool? isRead;
  String? readAt;
  String? createdAt;
  String? updatedAt;

  MessageData({
    this.id,
    this.ticket,
    this.sender,
    this.senderType,
    this.message,
    this.attachments,
    this.isRead,
    this.readAt,
    this.createdAt,
    this.updatedAt,
  });

  factory MessageData.fromJson(Map<String, dynamic> json) {
    // ✅ ticket can be a plain string id OR a nested object
    String? ticketId;
    final rawTicket = json["ticket"];
    if (rawTicket is String) {
      ticketId = rawTicket;
    } else if (rawTicket is Map) {
      ticketId = rawTicket["_id"]?.toString() ?? rawTicket["id"]?.toString();
    }

    return MessageData(
      id: json["_id"]?.toString(),
      ticket: ticketId,
      sender: json["sender"] != null ? Sender.fromJson(json["sender"]) : null,
      senderType: json["senderType"],
      message: json["message"],
      attachments: json["attachments"] == null
          ? []
          : List<Attachment>.from(
              json["attachments"].map((x) => Attachment.fromJson(x)),
            ),
      isRead: json["isRead"],
      readAt: json["readAt"]?.toString(),
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"],
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "ticket": ticket,
    "sender": sender?.toJson(),
    "senderType": senderType,
    "message": message,
    "attachments": attachments == null
        ? []
        : List<dynamic>.from(attachments!.map((x) => x.toJson())),
    "isRead": isRead,
    "readAt": readAt,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}

class Attachment {
  String? url;
  String? fileName;
  String? fileType;

  Attachment({this.url, this.fileName, this.fileType});

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
    url: json["url"],
    fileName: json["fileName"],
    fileType: json["fileType"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "fileName": fileName,
    "fileType": fileType,
  };
}

class Sender {
  String? id;
  String? name;
  String? email;

  Sender({this.id, this.name, this.email});

  factory Sender.fromJson(Map<String, dynamic> json) =>
      Sender(id: json["_id"], name: json["name"], email: json["email"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name, "email": email};
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
