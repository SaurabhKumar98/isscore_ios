import 'dart:convert';

OtpRequestModel otpRequestModelFromJson(String str) =>
    OtpRequestModel.fromJson(json.decode(str));

String otpRequestModelToJson(OtpRequestModel data) =>
    json.encode(data.toJson());

class OtpRequestModel {
  final bool success;
  final OtpData? otpData;
  final String message;

  OtpRequestModel({
    required this.success,
    this.otpData,
    required this.message,
  });

  factory OtpRequestModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return OtpRequestModel(
        success: false,
        otpData: null,
        message: '',
      );
    }

    return OtpRequestModel(
      success: json['success'] ?? false,
      otpData: json['data'] != null
          ? OtpData.fromJson(json['data'])
          : null,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'data': otpData?.toJson(),
        'message': message,
      };
}

class OtpData {
  OtpData();

  factory OtpData.fromJson(Map<String, dynamic>? json) {
    return OtpData();
  }

  Map<String, dynamic> toJson() => {};
}