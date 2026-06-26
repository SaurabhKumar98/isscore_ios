// lib/data/models/api_models/profile/profile_model.dart

class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? schoolOrCollege;
  final String? classOrGrade;
  final String? profileImage;
  final String? referralCode;
  final String? status;
  final DateTime? createdAt;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.schoolOrCollege,
    this.classOrGrade,
    this.profileImage,
    this.referralCode,
    this.status,
    this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id:             (json['_id']            as String?)  ?? '',
      name:           (json['name']           as String?)  ?? '',
      email:          (json['email']          as String?)  ?? '',
      phone:          json['phone']           as String?,
      schoolOrCollege: json['schoolOrCollege'] as String?,
      classOrGrade:   json['classOrGrade']    as String?,
      profileImage:   json['profileImage']    as String?,
      referralCode:   json['referralCode']    as String?,
      status:         json['status']          as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id':            id,
    'name':           name,
    'email':          email,
    if (phone           != null) 'phone':           phone,
    if (schoolOrCollege != null) 'schoolOrCollege': schoolOrCollege,
    if (classOrGrade    != null) 'classOrGrade':    classOrGrade,
    if (profileImage    != null) 'profileImage':    profileImage,
    if (referralCode    != null) 'referralCode':    referralCode,
    if (status          != null) 'status':          status,
    if (createdAt       != null) 'createdAt':       createdAt!.toIso8601String(),
  };

  ProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? schoolOrCollege,
    String? classOrGrade,
    String? profileImage,
    String? referralCode,
    String? status,
    DateTime? createdAt,
  }) {
    return ProfileModel(
      id:             id             ?? this.id,
      name:           name           ?? this.name,
      email:          email          ?? this.email,
      phone:          phone          ?? this.phone,
      schoolOrCollege: schoolOrCollege ?? this.schoolOrCollege,
      classOrGrade:   classOrGrade   ?? this.classOrGrade,
      profileImage:   profileImage   ?? this.profileImage,
      referralCode:   referralCode   ?? this.referralCode,
      status:         status         ?? this.status,
      createdAt:      createdAt      ?? this.createdAt,
    );
  }
}

// ── Wrapper for GET /user/profile response ─────────────────────────────────
class ProfileResponse {
  final bool success;
  final ProfileModel? data;
  final String message;

  const ProfileResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: (json['success'] as bool?) ?? false,
      data: json['data'] != null
          ? ProfileModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: (json['message'] as String?) ?? '',
    );
  }
}