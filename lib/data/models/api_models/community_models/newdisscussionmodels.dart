import 'dart:convert';

PostModels postModelsFromJson(String str) =>
    PostModels.fromJson(json.decode(str));

String postModelsToJson(PostModels data) => json.encode(data.toJson());

class PostModels {
  final bool success;
  final String? message;
  final PostData? data;
  final dynamic meta;

  PostModels({
    required this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory PostModels.fromJson(Map<String, dynamic> json) {
    return PostModels(
      success: json["success"] ?? false,
      message: json["message"],
      data: json["data"] != null ? PostData.fromJson(json["data"]) : null,
      meta: json["meta"],
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
        "meta": meta,
      };
}

class PostData {
  final String? id;
  final String? title;
  final String? description;
  final List<String> tags;
  final String? topic;
  final String? attachment;
  final String? createdBy;
  final List<dynamic> likes;
  final List<dynamic> comments;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;

  PostData({
    this.id,
    this.title,
    this.description,
    required this.tags,
    this.topic,
    this.attachment,
    this.createdBy,
    required this.likes,
    required this.comments,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  factory PostData.fromJson(Map<String, dynamic> json) {
    return PostData(
      id: json["_id"],
      title: json["title"],
      description: json["description"],
      tags: (json["tags"] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      topic: json["topic"],
      attachment: json["attachment"],
      createdBy: json["createdBy"],
      likes: (json["likes"] as List?) ?? [],
      comments: (json["comments"] as List?) ?? [],
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"])
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.tryParse(json["updatedAt"])
          : null,
      version: json["__v"],
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "description": description,
        "tags": tags,
        "topic": topic,
        "attachment": attachment,
        "createdBy": createdBy,
        "likes": likes,
        "comments": comments,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": version,
      };
}