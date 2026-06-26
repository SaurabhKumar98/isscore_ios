import 'dart:convert';

TournamentModels tournamentModelsFromJson(String str) =>
    TournamentModels.fromJson(json.decode(str));

String tournamentModelsToJson(TournamentModels data) =>
    json.encode(data.toJson());

// ── Helper ──────────────────────────────────────────────────────────────────
/// Safely converts a JSON numeric value (int OR double) to int.
/// Dio parses JSON numbers as double when the value has a decimal,
/// so `json["price"] ?? 0` crashes with "type 'double' is not a subtype of type 'int'".
int _toInt(dynamic v, [int fallback = 0]) =>
    v == null ? fallback : (v as num).toInt();

class TournamentModels {
  bool success;
  String message;
  List<Tournament> data;
  Meta meta;

  TournamentModels({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory TournamentModels.fromJson(Map<String, dynamic> json) =>
      TournamentModels(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] == null
            ? []
            : List<Tournament>.from(
                json["data"].map((x) => Tournament.fromJson(x)),
              ),
        meta: json["meta"] == null
            ? Meta(page: 0, limit: 0, total: 0, pages: 0)
            : Meta.fromJson(json["meta"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data.map((x) => x.toJson()).toList(),
    "meta": meta.toJson(),
  };
}

class Tournament {
  String id;
  String title;
  String description;
  String? imageUrl;
  List<Stage> stages;

  DateTime registrationStartTime;
  DateTime registrationEndTime;

  int price;
  int firstPlacePoints;
  int secondPlacePoints;
  int thirdPlacePoints;

  bool isPublished;
  CreatedBy? createdBy;

  DateTime createdAt;
  DateTime updatedAt;

  int version;
  dynamic appliedOffer;

  int originalPrice;
  int discountedPrice;

  String status;
  bool isRegistrationOpen;
  bool isEventLive;
  bool canJoin;

  dynamic goesLiveAt;
  bool isRegistered;
  int discountAmount; // ← ADD
  int effectivePrice;

  Tournament({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.stages,
    required this.registrationStartTime,
    required this.registrationEndTime,
    required this.price,
    required this.firstPlacePoints,
    required this.secondPlacePoints,
    required this.thirdPlacePoints,
    required this.isPublished,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    this.appliedOffer,
    required this.originalPrice,
    required this.discountedPrice,
    required this.status,
    required this.isRegistrationOpen,
    required this.isEventLive,
    required this.canJoin,
    this.goesLiveAt,
    required this.isRegistered,
    required this.discountAmount, // ← ADD
    required this.effectivePrice,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) => Tournament(
    id: json["_id"] ?? "",
    title: json["title"] ?? "",
    description: json["description"] ?? "",
    imageUrl: json["imageUrl"],

    stages: json["stages"] == null
        ? []
        : (json["stages"] as List)
              .map((x) {
                try {
                  return Stage.fromJson(x as Map<String, dynamic>);
                } catch (_) {
                  return null;
                }
              })
              .whereType<Stage>()
              .toList(),

    registrationStartTime: json["registrationStartTime"] == null
        ? DateTime.now()
        : DateTime.tryParse(json["registrationStartTime"]) ?? DateTime.now(),

    registrationEndTime: json["registrationEndTime"] == null
        ? DateTime.now()
        : DateTime.tryParse(json["registrationEndTime"]) ?? DateTime.now(),

    // ✅ All numeric fields use _toInt() — handles double/int from Dio
    price: _toInt(json["price"]),
    firstPlacePoints: _toInt(json["firstPlacePoints"]),
    secondPlacePoints: _toInt(json["secondPlacePoints"]),
    thirdPlacePoints: _toInt(json["thirdPlacePoints"]),

    isPublished: json["isPublished"] ?? false,

    createdBy: json["createdBy"] == null
        ? null
        : CreatedBy.fromJson(json["createdBy"]),

    createdAt: json["createdAt"] == null
        ? DateTime.now()
        : DateTime.tryParse(json["createdAt"]) ?? DateTime.now(),

    updatedAt: json["updatedAt"] == null
        ? DateTime.now()
        : DateTime.tryParse(json["updatedAt"]) ?? DateTime.now(),

    version: _toInt(json["__v"]),
    appliedOffer: json["appliedOffer"],

    originalPrice: _toInt(json["originalPrice"]),
    discountedPrice: _toInt(json["discountedPrice"]),

    status: json["status"] ?? "",
    isRegistrationOpen: json["isRegistrationOpen"] ?? false,
    isEventLive: json["isEventLive"] ?? false,
    canJoin: json["canJoin"] ?? false,

    goesLiveAt: json["goesLiveAt"],
    isRegistered: json["isRegistered"] ?? false,
    discountAmount: _toInt(json["discountAmount"]), // ← ADD
    effectivePrice: _toInt(json["effectivePrice"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "description": description,
    "imageUrl": imageUrl,
    "stages": stages.map((x) => x.toJson()).toList(),
    "registrationStartTime": registrationStartTime.toIso8601String(),
    "registrationEndTime": registrationEndTime.toIso8601String(),
    "price": price,
    "firstPlacePoints": firstPlacePoints,
    "secondPlacePoints": secondPlacePoints,
    "thirdPlacePoints": thirdPlacePoints,
    "isPublished": isPublished,
    "createdBy": createdBy?.toJson(),
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "__v": version,
    "appliedOffer": appliedOffer,
    "originalPrice": originalPrice,
    "discountedPrice": discountedPrice,
    "status": status,
    "isRegistrationOpen": isRegistrationOpen,
    "isEventLive": isEventLive,
    "canJoin": canJoin,
    "goesLiveAt": goesLiveAt,
    "isRegistered": isRegistered,
    "discountAmount": discountAmount, // ← ADD
    "effectivePrice": effectivePrice,
  };
}

class CreatedBy {
  String id;
  String name;
  String email;

  CreatedBy({required this.id, required this.name, required this.email});

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
    id: json["_id"] ?? "",
    name: json["name"] ?? "",
    email: json["email"] ?? "",
  );

  Map<String, dynamic> toJson() => {"_id": id, "name": name, "email": email};
}

class Stage {
  String name;
  Test? test;
  String subject;
  DateTime startTime;
  DateTime endTime;
  int minimumMarksToQualify;
  int? maxParticipants;
  int order;
  String id;

  Stage({
    required this.name,
    this.test,
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.minimumMarksToQualify,
    this.maxParticipants,
    required this.order,
    required this.id,
  });

  factory Stage.fromJson(Map<String, dynamic> json) => Stage(
    name: json["name"] ?? "",
    test: json["test"] == null
        ? null
        : (() {
            try {
              return Test.fromJson(json["test"] as Map<String, dynamic>);
            } catch (_) {
              return null;
            }
          })(),
    subject: json["subject"] ?? "",
    startTime: json["startTime"] == null
        ? DateTime.now()
        : DateTime.tryParse(json["startTime"]) ?? DateTime.now(),
    endTime: json["endTime"] == null
        ? DateTime.now()
        : DateTime.tryParse(json["endTime"]) ?? DateTime.now(),
    minimumMarksToQualify: _toInt(json["minimumMarksToQualify"]),
    maxParticipants: json["maxParticipants"] == null
        ? null
        : _toInt(json["maxParticipants"]),
    order: _toInt(json["order"]),
    id: json["_id"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "test": test?.toJson(),
    "subject": subject,
    "startTime": startTime.toIso8601String(),
    "endTime": endTime.toIso8601String(),
    "minimumMarksToQualify": minimumMarksToQualify,
    "maxParticipants": maxParticipants,
    "order": order,
    "_id": id,
  };
}

class Test {
  String id;
  String title;
  QuestionBank questionBank;
  int durationMinutes;
  String? sessionId;
  String testStatus;

  Test({
    required this.id,
    required this.title,
    required this.questionBank,
    required this.durationMinutes,
    this.sessionId,
    required this.testStatus,
  });

  factory Test.fromJson(Map<String, dynamic> json) => Test(
    id: json["_id"] ?? "",
    title: json["title"] ?? "",
    questionBank: json["questionBank"] == null
        ? QuestionBank(id: "", name: "", categories: [])
        : QuestionBank.fromJson(json["questionBank"] as Map<String, dynamic>),
    durationMinutes: _toInt(json["durationMinutes"]),
    sessionId: json["sessionId"],
    testStatus: json["testStatus"] ?? "not_started",
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "questionBank": questionBank.toJson(),
    "durationMinutes": durationMinutes,
    "sessionId": sessionId,
    "testStatus": testStatus,
  };
}

class QuestionBank {
  String id;
  String name;
  List<Category> categories;

  QuestionBank({
    required this.id,
    required this.name,
    required this.categories,
  });

  factory QuestionBank.fromJson(Map<String, dynamic> json) => QuestionBank(
    id: json["_id"] ?? "",
    name: json["name"] ?? "",
    categories: json["categories"] == null
        ? []
        : List<Category>.from(
            json["categories"].map((x) => Category.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "categories": categories.map((x) => x.toJson()).toList(),
  };
}

class Category {
  String id;
  String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) =>
      Category(id: json["_id"] ?? "", name: json["name"] ?? "");

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

class Meta {
  int page;
  int limit;
  int total;
  int pages;

  Meta({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    page: _toInt(json["page"]),
    limit: _toInt(json["limit"]),
    total: _toInt(json["total"]),
    pages: _toInt(json["pages"]),
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "limit": limit,
    "total": total,
    "pages": pages,
  };
}
