import 'dart:convert';

ChallengeYourFriendModel challengeYourFriendModelFromJson(String str) =>
    ChallengeYourFriendModel.fromJson(json.decode(str));

String challengeYourFriendModelToJson(ChallengeYourFriendModel data) =>
    json.encode(data.toJson());

class ChallengeYourFriendModel {
  bool? success;
  String? message;
  List<ChallengeItem>? data;
  dynamic meta;

  ChallengeYourFriendModel({this.success, this.message, this.data, this.meta});

  factory ChallengeYourFriendModel.fromJson(Map<String, dynamic>? json) =>
      ChallengeYourFriendModel(
        success: json?["success"] ?? false,
        message: json?["message"] ?? "",
        data: json?["data"] != null
            ? List<ChallengeItem>.from(
                json!["data"].map((x) => ChallengeItem.fromJson(x)),
              )
            : [],
        meta: json?["meta"],
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.map((x) => x.toJson()).toList() ?? [],
    "meta": meta,
  };
}

class ChallengeItem {
  String? id;
  String? title;
  String? description;
  String? imageUrl;
  QuestionBank? questionBank;
  String? proctoringInstructions;
  int? price;
  String? applicableFor;
  int? durationMinutes;
  bool? isPublished;
  String? createdBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  ChallengeItem({
    this.id,
    this.title,
    this.description,
    this.imageUrl,
    this.questionBank,
    this.proctoringInstructions,
    this.price,
    this.applicableFor,
    this.durationMinutes,
    this.isPublished,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory ChallengeItem.fromJson(Map<String, dynamic>? json) => ChallengeItem(
    id: json?["_id"],
    title: json?["title"],
    description: json?["description"],
    imageUrl: json?["imageUrl"],
    questionBank: json?["questionBank"] != null
        ? QuestionBank.fromJson(json?["questionBank"])
        : null,
    proctoringInstructions: json?["proctoringInstructions"],
    price: json?["price"] ?? 0,
    applicableFor: json?["applicableFor"],
    durationMinutes: json?["durationMinutes"] ?? 0,
    isPublished: json?["isPublished"] ?? false,
    createdBy: json?["createdBy"],
    createdAt: json?["createdAt"] != null
        ? DateTime.tryParse(json!["createdAt"])
        : null,
    updatedAt: json?["updatedAt"] != null
        ? DateTime.tryParse(json!["updatedAt"])
        : null,
    v: json?["__v"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "description": description,
    "imageUrl": imageUrl,
    "questionBank": questionBank?.toJson(),
    "proctoringInstructions": proctoringInstructions,
    "price": price,
    "applicableFor": applicableFor,
    "durationMinutes": durationMinutes,
    "isPublished": isPublished,
    "createdBy": createdBy,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class QuestionBank {
  String? id;
  String? name;
  List<Category>? categories;
  String? overallDifficulty;

  QuestionBank({this.id, this.name, this.categories, this.overallDifficulty});

  factory QuestionBank.fromJson(Map<String, dynamic>? json) => QuestionBank(
    id: json?["_id"],
    name: json?["name"],
    categories: json?["categories"] != null
        ? List<Category>.from(
            (json!["categories"] as List).map((x) {
              // ✅ API returns either a String ID or a Map object
              if (x is String) {
                return Category(id: x, name: null);
              } else if (x is Map<String, dynamic>) {
                return Category.fromJson(x);
              }
              return Category();
            }),
          )
        : [],
    overallDifficulty: json?["overallDifficulty"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "categories": categories?.map((x) => x.toJson()).toList() ?? [],
    "overallDifficulty": overallDifficulty,
  };
}

class Category {
  String? id;
  String? name;

  Category({this.id, this.name});

  factory Category.fromJson(Map<String, dynamic>? json) =>
      Category(id: json?["_id"], name: json?["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}
