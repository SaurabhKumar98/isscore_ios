class PhoneLoginModel {
  final bool success;
  final String message;
  final PhoneLoginPayload? loginPayload;

  PhoneLoginModel({
    required this.success,
    required this.message,
    this.loginPayload,
  });

  factory PhoneLoginModel.fromJson(Map<String, dynamic> json) {
    return PhoneLoginModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      loginPayload: json['data'] != null          // ✅ was 'payload', API returns 'data'
          ? PhoneLoginPayload.fromJson(json['data'])
          : null,
    );
  }
}

class PhoneLoginPayload {
  final String? accessToken;
  final String? refreshToken;
  final PhoneLoginUser? user;

  PhoneLoginPayload({
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory PhoneLoginPayload.fromJson(Map<String, dynamic> json) {
    return PhoneLoginPayload(
      accessToken:  json['accessToken'],
      refreshToken: json['refreshToken'],         // ✅ added — present in API response
      user: json['user'] != null
          ? PhoneLoginUser.fromJson(json['user'])
          : null,
    );
  }
}

class PhoneLoginUser {
  final String? id;
  final String? name;
  final String? phone;
  final String? email;
  final String? profileImage;                     // ✅ added
  final String? schoolOrCollege;                  // ✅ added
  final String? classOrGrade;                     // ✅ added
  final String? referralCode;                     // ✅ added
  final String? status;                           // ✅ added

  PhoneLoginUser({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.profileImage,
    this.schoolOrCollege,
    this.classOrGrade,
    this.referralCode,
    this.status,
  });

  factory PhoneLoginUser.fromJson(Map<String, dynamic> json) {
    return PhoneLoginUser(
      id:            json['_id'] ?? json['id'],
      name:          json['name'],
      phone:         json['phone'],
      email:         json['email'],
      profileImage:  json['profileImage'],        // ✅ added
      schoolOrCollege: json['schoolOrCollege'],   // ✅ added
      classOrGrade:  json['classOrGrade']?.toString(), // ✅ toString() — API returns int (90)
      referralCode:  json['referralCode'],        // ✅ added
      status:        json['status'],              // ✅ added
    );
  }
}