// otpverifymodel.dart
import 'dart:convert';

OtpVerifyModel otpVerifyModelFromJson(String str) =>
    OtpVerifyModel.fromJson(json.decode(str));

class OtpVerifyModel {
  final bool success;
  final String message;

  OtpVerifyModel({
    required this.success,
    required this.message,
  });

  factory OtpVerifyModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return OtpVerifyModel(success: false, message: '');
    return OtpVerifyModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }
}