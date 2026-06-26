import 'dart:convert';

StartChallengeModel startChallengeModelFromJson(String str) =>
    StartChallengeModel.fromJson(json.decode(str));

class StartChallengeModel {
  bool? success;
  String? message;
  StartChallengeData? data;
  dynamic meta;

  StartChallengeModel({this.success, this.message, this.data, this.meta});

  factory StartChallengeModel.fromJson(Map<String, dynamic>? json) =>
      StartChallengeModel(
        success: json?["success"] ?? false,
        message: json?["message"] ?? "",
        data: json?["data"] != null
            ? StartChallengeData.fromJson(json!["data"])
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

class StartChallengeData {
  StartedRoom? challenge;
  List<SessionEntry>? sessions;
  String? mySessionId;

  StartChallengeData({this.challenge, this.sessions, this.mySessionId});

  factory StartChallengeData.fromJson(Map<String, dynamic>? json) =>
      StartChallengeData(
        challenge: json?["challenge"] != null
            ? StartedRoom.fromJson(json!["challenge"])
            : null,
        sessions: json?["sessions"] != null
            ? List<SessionEntry>.from(
                json!["sessions"].map((x) => SessionEntry.fromJson(x)))
            : [],
        mySessionId: json?["mySessionId"],
      );

  Map<String, dynamic> toJson() => {
        "challenge": challenge?.toJson(),
        "sessions": sessions?.map((x) => x.toJson()).toList() ?? [],
        "mySessionId": mySessionId,
      };
}

class StartedRoom {
  String? id;
  String? roomStatus;
  DateTime? startedAt;

  StartedRoom({this.id, this.roomStatus, this.startedAt});

  factory StartedRoom.fromJson(Map<String, dynamic>? json) => StartedRoom(
        id: json?["_id"],
        roomStatus: json?["roomStatus"],
        startedAt: json?["startedAt"] != null
            ? DateTime.tryParse(json!["startedAt"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "roomStatus": roomStatus,
        "startedAt": startedAt?.toIso8601String(),
      };
}

class SessionEntry {
  String? studentId;
  String? sessionId;

  SessionEntry({this.studentId, this.sessionId});

  factory SessionEntry.fromJson(Map<String, dynamic>? json) => SessionEntry(
        studentId: json?["studentId"],
        sessionId: json?["sessionId"],
      );

  Map<String, dynamic> toJson() => {
        "studentId": studentId,
        "sessionId": sessionId,
      };
}