import 'dart:convert';

TicketListModel ticketListModelFromJson(String str) =>
    TicketListModel.fromJson(json.decode(str));

String ticketListModelToJson(TicketListModel data) =>
    json.encode(data.toJson());

class TicketListModel {
  bool? success;
  String? message;
  List<Ticket>? data;
  Meta? meta;

  TicketListModel({this.success, this.message, this.data, this.meta});

  factory TicketListModel.fromJson(Map<String, dynamic> json) =>
      TicketListModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<Ticket>.from(json["data"].map((x) => Ticket.fromJson(x))),
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

class Ticket {
  String? id;
  String? ticketNumber;
  String? subject;
  String? description;
  String? category;
  String? priority;
  String? status;
  AssignedTo? assignedTo;
  String? openedAt;
  dynamic resolvedAt;
  dynamic closedAt;
  String? lastMessageAt;
  String? createdAt;
  String? updatedAt;

  Ticket({
    this.id,
    this.ticketNumber,
    this.subject,
    this.description,
    this.category,
    this.priority,
    this.status,
    this.assignedTo,
    this.openedAt,
    this.resolvedAt,
    this.closedAt,
    this.lastMessageAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
    id: json["_id"],
    ticketNumber: json["ticketNumber"],
    subject: json["subject"],
    description: json["description"],
    category: json["category"],
    priority: json["priority"],
    status: json["status"],
    assignedTo: json["assignedTo"] != null
        ? AssignedTo.fromJson(json["assignedTo"])
        : null,
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
    "subject": subject,
    "description": description,
    "category": category,
    "priority": priority,
    "status": status,
    "assignedTo": assignedTo?.toJson(),
    "openedAt": openedAt,
    "resolvedAt": resolvedAt,
    "closedAt": closedAt,
    "lastMessageAt": lastMessageAt,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}

class AssignedTo {
  String? id;
  String? name;
  String? email;

  AssignedTo({this.id, this.name, this.email});

  factory AssignedTo.fromJson(Map<String, dynamic> json) =>
      AssignedTo(id: json["_id"], name: json["name"], email: json["email"]);

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
