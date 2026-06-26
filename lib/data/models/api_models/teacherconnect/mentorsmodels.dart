import 'dart:convert';

MentorResponse mentorResponseFromJson(String str) =>
    MentorResponse.fromJson(json.decode(str));

String mentorResponseToJson(MentorResponse data) =>
    json.encode(data.toJson());

/// ─────────────────────────────────────────────────────────────────────────────
/// Root Response
/// ─────────────────────────────────────────────────────────────────────────────
class MentorResponse {
  final bool success;
  final String message;
  final MentorData data;
  final PaginationMeta meta;

  MentorResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory MentorResponse.fromJson(Map<String, dynamic> json) {
    return MentorResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: MentorData.fromJson(json['data'] ?? {}),
      meta: PaginationMeta.fromJson(json['meta'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data.toJson(),
        'meta': meta.toJson(),
      };
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Data Wrapper
/// ─────────────────────────────────────────────────────────────────────────────
class MentorData {
  final List<Mentor> mentors;
  final int totalMentors;
  final int totalOnline;

  MentorData({
    required this.mentors,
    required this.totalMentors,
    required this.totalOnline,
  });

  factory MentorData.fromJson(Map<String, dynamic> json) {
    return MentorData(
      mentors: (json['teachers'] as List?)
              ?.map((e) => Mentor.fromJson(e))
              .toList() ??
          [],
      totalMentors: json['totalTeachers'] ?? 0,
      totalOnline: json['totalOnline'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'teachers': mentors.map((e) => e.toJson()).toList(),
        'totalTeachers': totalMentors,
        'totalOnline': totalOnline,
      };
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Mentor Model
/// ─────────────────────────────────────────────────────────────────────────────
class Mentor {
  final double averageRating; // ← was int, API sends 3.5 (double)
  final int ratingCount;
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String gender;
  final String about;
  final String experience;
  final String language;
  final String hiringFor;
  final List<String> skills;
  final String status;
  final int perMinuteRate;
  final bool isLive;
  final String profileImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int version;
  final bool isOnline;

  Mentor({
    required this.averageRating,
    required this.ratingCount,
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.gender,
    required this.about,
    required this.experience,
    required this.language,
    required this.hiringFor,
    required this.skills,
    required this.status,
    required this.perMinuteRate,
    required this.isLive,
    required this.profileImage,
    this.createdAt,
    this.updatedAt,
    required this.version,
    required this.isOnline,
  });

factory Mentor.fromJson(Map<String, dynamic> json) {
  return Mentor(
    averageRating:
        (json['averageRating'] as num?)?.toDouble() ?? 0.0,

    ratingCount:
        (json['ratingCount'] as num?)?.toInt() ?? 0,

    id: json['_id']?.toString() ?? '',

    name: json['name']?.toString() ?? '',

    email: json['email']?.toString() ?? '',

    phone: json['phone']?.toString(),

    gender: json['gender']?.toString() ?? '',

    about: json['about']?.toString() ?? '',

    experience: json['experience']?.toString() ?? '',

    language: json['language']?.toString() ?? '',

    hiringFor: json['hiringFor']?.toString() ?? '',

    skills: (json['skills'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [],

    status: json['status']?.toString() ?? '',

    perMinuteRate:
        (json['perMinuteRate'] as num?)?.toInt() ?? 0,

    isLive: json['isLive'] ?? false,

    profileImage:
        json['profileImage']?.toString() ?? '',

    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'])
        : null,

    updatedAt: json['updatedAt'] != null
        ? DateTime.tryParse(json['updatedAt'])
        : null,

    version:
        (json['__v'] as num?)?.toInt() ?? 0,

    isOnline: json['isOnline'] ?? false,
  );
}
  Map<String, dynamic> toJson() => {
        'averageRating': averageRating,
        'ratingCount': ratingCount,
        '_id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'gender': gender,
        'about': about,
        'experience': experience,
        'language': language,
        'hiringFor': hiringFor,
        'skills': skills,
        'status': status,
        'perMinuteRate': perMinuteRate,
        'isLive': isLive,
        'profileImage': profileImage,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        '__v': version,
        'isOnline': isOnline,
      };
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Pagination Meta
/// ─────────────────────────────────────────────────────────────────────────────
class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int pages;

  PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      pages: json['pages'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'page': page,
        'limit': limit,
        'total': total,
        'pages': pages,
      };
}