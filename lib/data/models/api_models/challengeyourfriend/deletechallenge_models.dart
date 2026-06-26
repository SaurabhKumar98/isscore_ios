import 'dart:convert';

DeleteChallengeModel deleteChallengeModelFromJson(String str) =>
    DeleteChallengeModel.fromJson(json.decode(str));

class DeleteChallengeModel {
  bool? success;
  String? message;
  DeleteData? data;
  dynamic meta;

  DeleteChallengeModel({this.success, this.message, this.data, this.meta});

  factory DeleteChallengeModel.fromJson(Map<String, dynamic>? json) =>
      DeleteChallengeModel(
        success: json?["success"] ?? false,
        message: json?["message"] ?? "",
        data: json?["data"] != null ? DeleteData.fromJson(json!["data"]) : null,
        meta: json?["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
        "meta": meta,
      };
}

class DeleteData {
  String? challengeId;
  bool? deleted;

  DeleteData({this.challengeId, this.deleted});

  factory DeleteData.fromJson(Map<String, dynamic>? json) => DeleteData(
        challengeId: json?["challengeId"],
        deleted: json?["deleted"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "challengeId": challengeId,
        "deleted": deleted,
      };
}