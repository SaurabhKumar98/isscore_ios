import 'dart:convert';

WorkshopResponse workshopResponseFromJson(String str) =>
    WorkshopResponse.fromJson(json.decode(str));

String workshopResponseToJson(WorkshopResponse data) =>
    json.encode(data.toJson());

class WorkshopResponse {
  final bool success;
  final String message;
  final List<Workshop> workshops;
  final PaginationMeta? meta;

  WorkshopResponse({
    required this.success,
    required this.message,
    required this.workshops,
    this.meta,
  });

  factory WorkshopResponse.fromJson(Map<String, dynamic> json) {
    return WorkshopResponse(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      workshops: (json["data"] as List<dynamic>?)
              ?.map((e) => Workshop.fromJson(e))
              .toList() ??
          [],
      meta: json["meta"] != null
          ? PaginationMeta.fromJson(json["meta"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": workshops.map((e) => e.toJson()).toList(),
        "meta": meta?.toJson(),
      };
}

class Workshop {
  final String workshopId;
  final String title;
  final String? description;
  final DateTime? startTime;
  final DateTime? endTime;
  final int price;
  final int? maxParticipants;
  final String? eventType;
  final String status;
  final bool isRegistered;

  Workshop({
    required this.workshopId,
    required this.title,
    this.description,
    this.startTime,
    this.endTime,
    required this.price,
    this.maxParticipants,
    this.eventType,
    required this.status,
    required this.isRegistered,
  });

  factory Workshop.fromJson(Map<String, dynamic> json) {
    return Workshop(
      workshopId: json["_id"] ?? "",
      title: json["title"] ?? "",
      description: json["description"],
      startTime: json["startTime"] != null
          ? DateTime.tryParse(json["startTime"])
          : null,
      endTime: json["endTime"] != null
          ? DateTime.tryParse(json["endTime"])
          : null,
      price: json["price"] ?? 0,
      maxParticipants: json["maxParticipants"],
      eventType: json["eventType"],
      status: json["status"] ?? "",
      isRegistered: json["isRegistered"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": workshopId,
        "title": title,
        "description": description,
        "startTime": startTime?.toIso8601String(),
        "endTime": endTime?.toIso8601String(),
        "price": price,
        "maxParticipants": maxParticipants,
        "eventType": eventType,
        "status": status,
        "isRegistered": isRegistered,
      };
}

class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json["page"] ?? 1,
      limit: json["limit"] ?? 10,
      total: json["total"] ?? 0,
      totalPages: json["totalPages"] ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        "page": page,
        "limit": limit,
        "total": total,
        "totalPages": totalPages,
      };
}