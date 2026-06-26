import 'dart:convert';

ReferAndEarnModel referAndEarnModelFromJson(String str) =>
    ReferAndEarnModel.fromJson(json.decode(str));

String referAndEarnModelToJson(ReferAndEarnModel data) =>
    json.encode(data.toJson());

class ReferAndEarnModel {
  bool? success;
  String? message;
  ReferralData? data;
  dynamic meta;

  ReferAndEarnModel({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory ReferAndEarnModel.fromJson(Map<String, dynamic>? json) =>
      ReferAndEarnModel(
        success: json?["success"] ?? false,
        message: json?["message"] ?? "",
        data: json?["data"] != null
            ? ReferralData.fromJson(json?["data"])
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

class ReferralData {
  String? referralCode;
  String? shareLink;
  int? pointsPerReferral;
  int? totalReferrals;
  String? message;

  ReferralData({
    this.referralCode,
    this.shareLink,
    this.pointsPerReferral,
    this.totalReferrals,
    this.message,
  });

  factory ReferralData.fromJson(Map<String, dynamic>? json) =>
      ReferralData(
        referralCode: json?["referralCode"],
        shareLink: json?["shareLink"],
        pointsPerReferral: json?["pointsPerReferral"] ?? 0,
        totalReferrals: json?["totalReferrals"] ?? 0,
        message: json?["message"],
      );

  Map<String, dynamic> toJson() => {
        "referralCode": referralCode,
        "shareLink": shareLink,
        "pointsPerReferral": pointsPerReferral,
        "totalReferrals": totalReferrals,
        "message": message,
      };
}