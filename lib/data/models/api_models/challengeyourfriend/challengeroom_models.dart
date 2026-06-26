import 'dart:convert';

ChallengeFriendJoinModel challengeFriendJoinModelFromJson(String str) =>
    ChallengeFriendJoinModel.fromJson(json.decode(str));

String challengeFriendJoinModelToJson(ChallengeFriendJoinModel data) =>
    json.encode(data.toJson());

class ChallengeFriendJoinModel {
  bool? success;
  String? message;
  List<ChallengeRoom>? data;
  Meta? meta;

  ChallengeFriendJoinModel({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory ChallengeFriendJoinModel.fromJson(Map<String, dynamic>? json) =>
      ChallengeFriendJoinModel(
        success: json?["success"] ?? false,
        message: json?["message"] ?? "",
        data: json?["data"] != null
            ? List<ChallengeRoom>.from(
                json!["data"].map((x) => ChallengeRoom.fromJson(x)))
            : [],
        meta: json?["meta"] != null ? Meta.fromJson(json?["meta"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.map((x) => x.toJson()).toList() ?? [],
        "meta": meta?.toJson(),
      };
}

class ChallengeRoom {
  String? id;
  String? title;
  String? description;
  TestModel? test;
  UserModel? createdBy;
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

  ChallengeRoom({
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

  factory ChallengeRoom.fromJson(Map<String, dynamic>? json) =>
      ChallengeRoom(
        id: json?["_id"],
        title: json?["title"],
        description: json?["description"],
        test: json?["test"] != null
            ? TestModel.fromJson(json?["test"])
            : null,
        createdBy: json?["createdBy"] != null
            ? UserModel.fromJson(json?["createdBy"])
            : null,
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
        "test": test?.toJson(),
        "createdBy": createdBy?.toJson(),
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

class UserModel {
  String? id;
  String? name;
  String? email;

  UserModel({
    this.id,
    this.name,
    this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic>? json) => UserModel(
        id: json?["_id"],
        name: json?["name"],
        email: json?["email"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "email": email,
      };
}

class Participant {
  UserModel? student;
  DateTime? joinedAt;
  String? id;

  Participant({
    this.student,
    this.joinedAt,
    this.id,
  });

  factory Participant.fromJson(Map<String, dynamic>? json) =>
      Participant(
        student: json?["student"] != null
            ? UserModel.fromJson(json?["student"])
            : null,
        joinedAt: json?["joinedAt"] != null
            ? DateTime.tryParse(json!["joinedAt"])
            : null,
        id: json?["_id"],
      );

  Map<String, dynamic> toJson() => {
        "student": student?.toJson(),
        "joinedAt": joinedAt?.toIso8601String(),
        "_id": id,
      };
}

class TestModel {
  String? id;
  String? title;
  String? questionBank;
  int? durationMinutes;

  TestModel({
    this.id,
    this.title,
    this.questionBank,
    this.durationMinutes,
  });

  factory TestModel.fromJson(Map<String, dynamic>? json) => TestModel(
        id: json?["_id"],
        title: json?["title"],
        questionBank: json?["questionBank"],
        durationMinutes: json?["durationMinutes"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "questionBank": questionBank,
        "durationMinutes": durationMinutes,
      };
}

class Meta {
  int? page;
  int? limit;
  int? total;
  int? pages;

  Meta({
    this.page,
    this.limit,
    this.total,
    this.pages,
  });

  factory Meta.fromJson(Map<String, dynamic>? json) => Meta(
        page: json?["page"] ?? 0,
        limit: json?["limit"] ?? 0,
        total: json?["total"] ?? 0,
        pages: json?["pages"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "limit": limit,
        "total": total,
        "pages": pages,
      };
}