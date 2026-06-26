import 'dart:convert';

LoginModel loginModelFromJson(String str) =>
    LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  final bool success;
  final LoginPayload? loginPayload;
  final String message;

  LoginModel({
    required this.success,
    this.loginPayload,
    required this.message,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
        success: json["success"] as bool? ?? false,
        loginPayload: json["data"] != null
            ? LoginPayload.fromJson(json["data"] as Map<String, dynamic>)
            : null,
        message: json["message"] as String? ?? "Unknown error",
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": loginPayload?.toJson(),
        "message": message,
      };
}

class LoginPayload {
  final UserModel? user;
  final String? accessToken;
  final String? refreshToken;

  /// 🔥 ADD THESE
  final bool alreadyLoggedInElsewhere;
  final String? message;

  LoginPayload({
    this.user,
    this.accessToken,
    this.refreshToken,
    this.alreadyLoggedInElsewhere = false,
    this.message,
  });

  factory LoginPayload.fromJson(Map<String, dynamic> json) => LoginPayload(
        user: json["user"] != null
            ? UserModel.fromJson(json["user"] as Map<String, dynamic>)
            : null,
        accessToken: json["accessToken"] as String?,
        refreshToken: json["refreshToken"] as String?,

        // 🔥 SAFE PARSING
        alreadyLoggedInElsewhere:
            json["alreadyLoggedInElsewhere"] == true,
        message: json["message"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "user": user?.toJson(),
        "accessToken": accessToken,
        "refreshToken": refreshToken,
        "alreadyLoggedInElsewhere": alreadyLoggedInElsewhere,
        "message": message,
      };
}

class UserModel {
  final String? id;
  final String? email;
  final String? name;
  final String? schoolOrCollege;
  final String? classOrGrade;
  final String? phone;
  final String? profileImage;
  final String? referralCode;
  final String? lastLogin;

  UserModel({
    this.id,
    this.email,
    this.name,
    this.schoolOrCollege,
    this.classOrGrade,
    this.phone,
    this.profileImage,
    this.referralCode,
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["_id"] as String?,
        email: json["email"] as String?,
        name: json["name"] as String?,
        schoolOrCollege: json["schoolOrCollege"] as String?,
        classOrGrade: json["classOrGrade"] as String?,
        phone: json["phone"] as String?,
        profileImage: json["profileImage"] as String?,
        referralCode: json["referralCode"] as String?,
        lastLogin: json["lastLogin"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "email": email,
        "name": name,
        "schoolOrCollege": schoolOrCollege,
        "classOrGrade": classOrGrade,
        "phone": phone,
        "profileImage": profileImage,
        "referralCode": referralCode,
        "lastLogin": lastLogin,
      };
}