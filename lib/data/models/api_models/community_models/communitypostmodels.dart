// To parse this JSON data, do
//
// final communityModels = communityModelsFromJson(jsonString);

import 'dart:convert';

CommunityModels communityModelsFromJson(String str) =>
    CommunityModels.fromJson(json.decode(str));

String communityModelsToJson(CommunityModels data) =>
    json.encode(data.toJson());

class CommunityModels {
  final bool success;
  final String message;
  final List<CommunityPost> data;
  final Meta? meta;

  CommunityModels({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory CommunityModels.fromJson(Map<String, dynamic> json) {
    return CommunityModels(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
              ?.map((e) => CommunityPost.fromJson(e))
              .toList() ??
          [],
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data.map((e) => e.toJson()).toList(),
        'meta': meta?.toJson(),
      };
}

/// ───────────────── POST MODEL ─────────────────

class CommunityPost {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final String topic;
  final String? attachment;
  final CreatedBy? createdBy;
  final List<dynamic> likes;
  final List<dynamic> comments;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int v;

  CommunityPost({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.topic,
    required this.attachment,
    required this.createdBy,
    required this.likes,
    required this.comments,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      tags: (json['tags'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      topic: json['topic'] ?? '',
      attachment: json['attachment'],
      createdBy: json['createdBy'] != null
          ? CreatedBy.fromJson(json['createdBy'])
          : null,
      likes: json['likes'] as List? ?? [],
      comments: json['comments'] as List? ?? [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'description': description,
        'tags': tags,
        'topic': topic,
        'attachment': attachment,
        'createdBy': createdBy?.toJson(),
        'likes': likes,
        'comments': comments,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        '__v': v,
      };
}

/// ───────────────── USER MODEL ─────────────────

class CreatedBy {
  final String id;
  final String name;
  final String email;

  CreatedBy({
    required this.id,
    required this.name,
    required this.email,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    return CreatedBy(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'email': email,
      };
}

/// ───────────────── META ─────────────────

class Meta {
  final int page;
  final int limit;
  final int total;
  final int pages;

  Meta({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
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