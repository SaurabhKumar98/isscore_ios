import 'dart:convert';

EveryDayChallengesModels everyDayChallengesModelsFromJson(String str) =>
    EveryDayChallengesModels.fromJson(json.decode(str));

String everyDayChallengesModelsToJson(EveryDayChallengesModels data) =>
    json.encode(data.toJson());

class EveryDayChallengesModels {
  bool? success;
  String? message;
  ChallengeData? data;
  dynamic meta;

  EveryDayChallengesModels({this.success, this.message, this.data, this.meta});

  factory EveryDayChallengesModels.fromJson(Map<String, dynamic> json) =>
      EveryDayChallengesModels(
        success: json["success"],
        message: json["message"],
        data: json["data"] != null
            ? ChallengeData.fromJson(json["data"])
            : null,
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
    "meta": meta,
  };
}

// ─────────────────────────────────────────────
// Challenge Data (Renamed from Data)
// ─────────────────────────────────────────────

class ChallengeData {
  Challenge? challenge;
  int? streakDays;
  bool? completedToday;
  int? nextPoints;
  int? nextStreakDay;
  List<StreakCycle>? streakCycle;

  ChallengeData({
    this.challenge,
    this.streakDays,
    this.completedToday,
    this.nextPoints,
    this.nextStreakDay,
    this.streakCycle,
  });

  factory ChallengeData.fromJson(Map<String, dynamic> json) => ChallengeData(
    challenge: json["challenge"] != null
        ? Challenge.fromJson(json["challenge"])
        : null,
    streakDays: json["streakDays"],
    completedToday: json["completedToday"],
    nextPoints: json["nextPoints"],
    nextStreakDay: json["nextStreakDay"],
    streakCycle: json["streakCycle"] != null
        ? List<StreakCycle>.from(
            json["streakCycle"].map((x) => StreakCycle.fromJson(x)),
          )
        : [],
  );

  Map<String, dynamic> toJson() => {
    "challenge": challenge?.toJson(),
    "streakDays": streakDays,
    "completedToday": completedToday,
    "nextPoints": nextPoints,
    "nextStreakDay": nextStreakDay,
    "streakCycle": streakCycle != null
        ? List<dynamic>.from(streakCycle!.map((x) => x.toJson()))
        : [],
  };
}

// ─────────────────────────────────────────────
// Challenge
// ─────────────────────────────────────────────

class Challenge {
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
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Challenge({
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
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
    id: json["_id"],
    title: json["title"],
    description: json["description"],
    imageUrl: json["imageUrl"],
    questionBank: json["questionBank"] != null
        ? QuestionBank.fromJson(json["questionBank"])
        : null,
    proctoringInstructions: json["proctoringInstructions"],
    price: json["price"],
    applicableFor: json["applicableFor"],
    durationMinutes: json["durationMinutes"],
    isPublished: json["isPublished"],
    createdAt: json["createdAt"] != null
        ? DateTime.tryParse(json["createdAt"])
        : null,
    updatedAt: json["updatedAt"] != null
        ? DateTime.tryParse(json["updatedAt"])
        : null,
    v: json["__v"],
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
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

// ─────────────────────────────────────────────
// QuestionBank
// ─────────────────────────────────────────────

class QuestionBank {
  String? id;
  String? name;
  List<Category>? categories;
  String? overallDifficulty;

  QuestionBank({this.id, this.name, this.categories, this.overallDifficulty});

  factory QuestionBank.fromJson(Map<String, dynamic> json) => QuestionBank(
    id: json["_id"],
    name: json["name"],
    categories: json["categories"] != null
        ? List<Category>.from(
            json["categories"].map((x) => Category.fromJson(x)),
          )
        : [],
    overallDifficulty: json["overallDifficulty"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "categories": categories != null
        ? List<dynamic>.from(categories!.map((x) => x.toJson()))
        : [],
    "overallDifficulty": overallDifficulty,
  };
}

// ─────────────────────────────────────────────
// Category
// ─────────────────────────────────────────────

class Category {
  String? id;
  String? name;

  Category({this.id, this.name});

  factory Category.fromJson(Map<String, dynamic> json) =>
      Category(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

// ─────────────────────────────────────────────
// StreakCycle
// ─────────────────────────────────────────────

class StreakCycle {
  int? day;
  int? points;
  bool? completed;

  StreakCycle({this.day, this.points, this.completed});

  factory StreakCycle.fromJson(Map<String, dynamic> json) => StreakCycle(
    day: json["day"],
    points: json["points"],
    completed: json["completed"],
  );

  Map<String, dynamic> toJson() => {
    "day": day,
    "points": points,
    "completed": completed,
  };
}
