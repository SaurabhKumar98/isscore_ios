import 'dart:convert';

CreateTicketModels createTicketModelsFromJson(String str) =>
    CreateTicketModels.fromJson(json.decode(str));

String createTicketModelsToJson(CreateTicketModels data) =>
    json.encode(data.toJson());

class CreateTicketModels {
  bool? success;
  String? message;
  TicketData? ticketData;
  dynamic meta;

  CreateTicketModels({this.success, this.message, this.ticketData, this.meta});

  factory CreateTicketModels.fromJson(Map<String, dynamic> json) =>
      CreateTicketModels(
        success: json["success"],
        message: json["message"],
        ticketData: json["data"] != null
            ? TicketData.fromJson(json["data"])
            : null,
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": ticketData?.toJson(),
    "meta": meta,
  };
}

class TicketData {
  String? id;
  String? ticketNumber;
  Student? student;
  String? subject;
  String? description;
  String? category;
  String? priority;
  String? status;
  dynamic assignedTo;
  List<dynamic>? internalNotes;
  String? openedAt;
  dynamic resolvedAt;
  dynamic closedAt;
  String? lastMessageAt;
  String? createdAt;
  String? updatedAt;

  TicketData({
    this.id,
    this.ticketNumber,
    this.student,
    this.subject,
    this.description,
    this.category,
    this.priority,
    this.status,
    this.assignedTo,
    this.internalNotes,
    this.openedAt,
    this.resolvedAt,
    this.closedAt,
    this.lastMessageAt,
    this.createdAt,
    this.updatedAt,
  });

  factory TicketData.fromJson(Map<String, dynamic> json) => TicketData(
    id: json["_id"],
    ticketNumber: json["ticketNumber"],
    student: json["student"] != null ? Student.fromJson(json["student"]) : null,
    subject: json["subject"],
    description: json["description"],
    category: json["category"],
    priority: json["priority"],
    status: json["status"],
    assignedTo: json["assignedTo"],
    internalNotes: json["internalNotes"] == null
        ? []
        : List<dynamic>.from(json["internalNotes"].map((x) => x)),
    openedAt: json["openedAt"],
    resolvedAt: json["resolvedAt"],
    closedAt: json["closedAt"],
    lastMessageAt: json["lastMessageAt"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "ticketNumber": ticketNumber,
    "student": student?.toJson(),
    "subject": subject,
    "description": description,
    "category": category,
    "priority": priority,
    "status": status,
    "assignedTo": assignedTo,
    "internalNotes": internalNotes == null
        ? []
        : List<dynamic>.from(internalNotes!.map((x) => x)),
    "openedAt": openedAt,
    "resolvedAt": resolvedAt,
    "closedAt": closedAt,
    "lastMessageAt": lastMessageAt,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}

class Student {
  String? id;
  String? name;
  String? email;

  Student({this.id, this.name, this.email});

  factory Student.fromJson(Map<String, dynamic> json) =>
      Student(id: json["_id"], name: json["name"], email: json["email"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name, "email": email};
}
