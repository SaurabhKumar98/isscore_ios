import 'dart:convert';

JoinRoomChallengeModel joinRoomChallengeModelFromJson(String str) =>
    JoinRoomChallengeModel.fromJson(json.decode(str));

String joinRoomChallengeModelToJson(JoinRoomChallengeModel data) =>
    json.encode(data.toJson());

class JoinRoomChallengeModel {
  bool? success;
  String? message;
  ChallengeRoomData? data;
  dynamic meta;

  JoinRoomChallengeModel({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory JoinRoomChallengeModel.fromJson(Map<String, dynamic>? json) =>
      JoinRoomChallengeModel(
        success: json?["success"] ?? false,
        message: json?["message"] ?? "",
        data: json?["data"] != null
            ? ChallengeRoomData.fromJson(json?["data"])
            : null,
        meta: json?["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
        "meta": meta,
      };
}

class ChallengeRoomData {
  String? id;
  String? title;
  String? description;
  String? test;
  String? createdBy;
  String? creatorType;
  String? roomCode;
  String? roomStatus;
  dynamic startedAt;
  dynamic completedAt;
  bool? isActive;
  List<Participant>? participants;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  ChallengeRoomData({
    this.id,
    this.title,
    this.description,
    this.test,
    this.createdBy,
    this.creatorType,
    this.roomCode,
    this.roomStatus,
    this.startedAt,
    this.completedAt,
    this.isActive,
    this.participants,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory ChallengeRoomData.fromJson(Map<String, dynamic>? json) =>
      ChallengeRoomData(
        id: json?["_id"],
        title: json?["title"],
        description: json?["description"],
        test: json?["test"],
        createdBy: json?["createdBy"],
        creatorType: json?["creatorType"],
        roomCode: json?["roomCode"],
        roomStatus: json?["roomStatus"],
        startedAt: json?["startedAt"],
        completedAt: json?["completedAt"],
        isActive: json?["isActive"] ?? false,
        participants: json?["participants"] != null
            ? List<Participant>.from(
                json!["participants"].map((x) => Participant.fromJson(x)))
            : [],
        createdAt: json?["createdAt"] != null
            ? DateTime.tryParse(json!["createdAt"])
            : null,
        updatedAt: json?["updatedAt"] != null
            ? DateTime.tryParse(json!["updatedAt"])
            : null,
        v: json?["__v"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "description": description,
        "test": test,
        "createdBy": createdBy,
        "creatorType": creatorType,
        "roomCode": roomCode,
        "roomStatus": roomStatus,
        "startedAt": startedAt,
        "completedAt": completedAt,
        "isActive": isActive,
        "participants":
            participants?.map((x) => x.toJson()).toList() ?? [],
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

class Participant {
  String? student;
  DateTime? joinedAt;
  String? id;

  Participant({
    this.student,
    this.joinedAt,
    this.id,
  });

  factory Participant.fromJson(Map<String, dynamic>? json) =>
      Participant(
        student: json?["student"],
        joinedAt: json?["joinedAt"] != null
            ? DateTime.tryParse(json!["joinedAt"])
            : null,
        id: json?["_id"],
      );

  Map<String, dynamic> toJson() => {
        "student": student,
        "joinedAt": joinedAt?.toIso8601String(),
        "_id": id,
      };
}