// resetpasswordmodel.dart
import 'dart:convert';

ResetPasswordModel resetPasswordModelFromJson(String str) =>
    ResetPasswordModel.fromJson(json.decode(str));

class ResetPasswordModel {
  final bool success;
  final String message;

  ResetPasswordModel({
    required this.success,
    required this.message,
  });

  factory ResetPasswordModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ResetPasswordModel(success: false, message: '');
    return ResetPasswordModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }
}