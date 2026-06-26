import 'dart:convert';

SendMessageModels sendMessageModelsFromJson(String str) =>
    SendMessageModels.fromJson(json.decode(str));

String sendMessageModelsToJson(SendMessageModels data) =>
    json.encode(data.toJson());

class SendMessageModels {
  bool? success;
  String? message;
  MessageData? data;
  dynamic meta;

  SendMessageModels({this.success, this.message, this.data, this.meta});

  factory SendMessageModels.fromJson(Map<String, dynamic> json) =>
      SendMessageModels(
        success: json["success"],
        message: json["message"],
        data: json["data"] != null ? MessageData.fromJson(json["data"]) : null,
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
    "meta": meta,
  };
}

class MessageData {
  String? id;
  Ticket? ticket;
  Sender? sender;
  String? senderType;
  String? message;
  List<dynamic>? attachments;
  bool? isRead;
  dynamic readAt;
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

  factory MessageData.fromJson(Map<String, dynamic> json) => MessageData(
    id: json["_id"],
    ticket: json["ticket"] != null ? Ticket.fromJson(json["ticket"]) : null,
    sender: json["sender"] != null ? Sender.fromJson(json["sender"]) : null,
    senderType: json["senderType"],
    message: json["message"],
    attachments: json["attachments"] == null
        ? []
        : List<dynamic>.from(json["attachments"].map((x) => x)),
    isRead: json["isRead"],
    readAt: json["readAt"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "ticket": ticket?.toJson(),
    "sender": sender?.toJson(),
    "senderType": senderType,
    "message": message,
    "attachments": attachments == null
        ? []
        : List<dynamic>.from(attachments!.map((x) => x)),
    "isRead": isRead,
    "readAt": readAt,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
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

class Ticket {
  String? id;
  String? ticketNumber;
  String? subject;

  Ticket({this.id, this.ticketNumber, this.subject});

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
    id: json["_id"],
    ticketNumber: json["ticketNumber"],
    subject: json["subject"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "ticketNumber": ticketNumber,
    "subject": subject,
  };
}
