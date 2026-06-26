class AgoraTokenModel {
  final bool success;
  final String message;
  final AgoraTokenData data;

  AgoraTokenModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AgoraTokenModel.fromJson(Map<String, dynamic> json) {
    return AgoraTokenModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: AgoraTokenData.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class AgoraTokenData {
  final String appId;
  final String channelName;
  final String token;
  final int uid;
  final String role;
  final int expiresInSeconds;

  AgoraTokenData({
    required this.appId,
    required this.channelName,
    required this.token,
    required this.uid,
    required this.role,
    required this.expiresInSeconds,
  });

  factory AgoraTokenData.fromJson(Map<String, dynamic> json) {
    return AgoraTokenData(
      appId: json['appId'] as String? ?? '',
      channelName: json['channelName'] as String? ?? '',
      token: json['token'] as String? ?? '',
      uid: json['uid'] as int? ?? 0,
      role: json['role'] as String? ?? 'student',
      expiresInSeconds: json['expiresInSeconds'] as int? ?? 3600,
    );
  }
}