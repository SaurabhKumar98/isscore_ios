import 'dart:convert';

SignupModel signupModelFromJson(String str) =>
    SignupModel.fromJson(json.decode(str));

String signupModelToJson(SignupModel data) => json.encode(data.toJson());

class SignupModel {
  final bool success;
  final SignupUser? user; // ✅ "data" IS the user directly
  final String message;

  SignupModel({
    required this.success,
    this.user,
    required this.message,
  });

  factory SignupModel.fromJson(Map<String, dynamic> json) => SignupModel(
        success: json["success"] ?? false,
        user: json["data"] != null ? SignupUser.fromJson(json["data"]) : null,
        message: json["message"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": user?.toJson(),
        "message": message,
      };
}

class SignupUser {
  final String id;
  final String email;
  final String name;
  final String schoolOrCollege;
  final String classOrGrade;
  final String phone;
  final String? profileImage; // ✅ nullable — API returns null
  final String referralCode;
  final String? lastLogin;    // ✅ nullable — API returns null on signup

  SignupUser({
    required this.id,
    required this.email,
    required this.name,
    required this.schoolOrCollege,
    required this.classOrGrade,
    required this.phone,
    this.profileImage,
    required this.referralCode,
    this.lastLogin,
  });

  factory SignupUser.fromJson(Map<String, dynamic> json) => SignupUser(
        id: json["_id"] ?? "",
        email: json["email"] ?? "",
        name: json["name"] ?? "",
        schoolOrCollege: json["schoolOrCollege"] ?? "",
        classOrGrade: json["classOrGrade"] ?? "",
        phone: json["phone"] ?? "",
        profileImage: json["profileImage"],   // ✅ keep null as-is
        referralCode: json["referralCode"] ?? "",
        lastLogin: json["lastLogin"],         // ✅ keep null as-is
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