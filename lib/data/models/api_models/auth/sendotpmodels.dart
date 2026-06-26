class SendOtpModel {
  final bool success;
  final String message;

  SendOtpModel({required this.success, required this.message});

  factory SendOtpModel.fromJson(Map<String, dynamic> json) {
    return SendOtpModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}