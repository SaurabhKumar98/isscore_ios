import 'dart:convert';

LiveCompetetionDrawerModels liveCompetetionModelsFromJson(String str) =>
    LiveCompetetionDrawerModels.fromJson(json.decode(str));

String liveCompetetionModelsToJson(LiveCompetetionDrawerModels data) =>
    json.encode(data.toJson());

class LiveCompetetionDrawerModels {
  bool? success;
  String? message;
  List<LiveCompetitionDrawer>? data;
  dynamic meta;

  LiveCompetetionDrawerModels({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory LiveCompetetionDrawerModels.fromJson(Map<String, dynamic> json) =>
      LiveCompetetionDrawerModels(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] != null
            ? List<LiveCompetitionDrawer>.from(
                json["data"].map((x) => LiveCompetitionDrawer.fromJson(x)))
            : [],
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data != null
            ? List<dynamic>.from(data!.map((x) => x.toJson()))
            : [],
        "meta": meta,
      };
}

class LiveCompetitionDrawer {
  String? id;
  String? name;
  String? description;
  String? submissionType;
  List<dynamic>? allowedFileTypes;
  bool? isActive;
  String? createdBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  LiveCompetitionDrawer({
    this.id,
    this.name,
    this.description,
    this.submissionType,
    this.allowedFileTypes,
    this.isActive,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory LiveCompetitionDrawer.fromJson(Map<String, dynamic> json) =>
      LiveCompetitionDrawer(
        id: json["_id"] ?? "",
        name: json["name"] ?? "",
        description: json["description"] ?? "",
        submissionType: json["submissionType"] ?? "",
        allowedFileTypes: json["allowedFileTypes"] != null
            ? List<dynamic>.from(json["allowedFileTypes"])
            : [],
        isActive: json["isActive"] ?? false,
        createdBy: json["createdBy"] ?? "",
        createdAt: json["createdAt"] != null
            ? DateTime.tryParse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.tryParse(json["updatedAt"])
            : null,
        v: json["__v"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "description": description,
        "submissionType": submissionType,
        "allowedFileTypes": allowedFileTypes ?? [],
        "isActive": isActive,
        "createdBy": createdBy,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}