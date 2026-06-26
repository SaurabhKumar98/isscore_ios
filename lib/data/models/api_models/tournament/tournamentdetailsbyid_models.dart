import 'dart:convert';

TournamentDetailsByIdModels tournamentDetailsByIdModelsFromJson(String str) =>
    TournamentDetailsByIdModels.fromJson(json.decode(str));

String tournamentDetailsByIdModelsToJson(TournamentDetailsByIdModels data) =>
    json.encode(data.toJson());

class TournamentDetailsByIdModels {
  bool? success;
  String? message;
  Data? data;
  dynamic meta;

  TournamentDetailsByIdModels({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory TournamentDetailsByIdModels.fromJson(Map<String, dynamic> json) {
    return TournamentDetailsByIdModels(
      success: json["success"],
      message: json["message"],
      data: json["data"] != null ? Data.fromJson(json["data"]) : null,
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

class Data {
  String? id;
  String? title;
  dynamic imageUrl;
  List<Stage>? stages;
  DateTime? registrationStartTime;
  DateTime? registrationEndTime;
  int? price;
  int? firstPlacePoints;
  int? secondPlacePoints;
  int? thirdPlacePoints;
  bool? isPublished;
  CreatedBy? createdBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  AppliedOffer? appliedOffer;
  int? originalPrice;
  double? discountedPrice;
  double? discountAmount;
  double? effectivePrice;
  String? status;
  bool? isRegistrationOpen;
  bool? isEventLive;
  bool? canJoin;
  dynamic goesLiveAt;
  bool? isRegistered;
  dynamic currentStage;
  List<dynamic>? qualifiedStages;
    DateTime? resultDeclaredAt;

  Data({
    this.id,
    this.title,
    this.imageUrl,
    this.stages,
    this.registrationStartTime,
    this.registrationEndTime,
    this.price,
    this.firstPlacePoints,
    this.secondPlacePoints,
    this.thirdPlacePoints,
    this.isPublished,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.appliedOffer,
    this.originalPrice,
    this.discountedPrice,
    this.discountAmount,
    this.effectivePrice,
    this.status,
    this.isRegistrationOpen,
    this.isEventLive,
    this.canJoin,
    this.goesLiveAt,
    this.isRegistered,
    this.currentStage,
    this.qualifiedStages,
        this.resultDeclaredAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json["_id"],
      title: json["title"],
      imageUrl: json["imageUrl"],
      stages: json["stages"] != null
          ? List<Stage>.from(json["stages"].map((x) => Stage.fromJson(x)))
          : [],
      registrationStartTime: json["registrationStartTime"] != null
          ? DateTime.parse(json["registrationStartTime"])
          : null,
      registrationEndTime: json["registrationEndTime"] != null
          ? DateTime.parse(json["registrationEndTime"])
          : null,
      price: (json["price"] as num?)?.toInt(),
      firstPlacePoints: (json["firstPlacePoints"] as num?)?.toInt(),
      secondPlacePoints: (json["secondPlacePoints"] as num?)?.toInt(),
      thirdPlacePoints: (json["thirdPlacePoints"] as num?)?.toInt(),
      isPublished: json["isPublished"],
      createdBy: json["createdBy"] != null
          ? CreatedBy.fromJson(json["createdBy"])
          : null,
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.parse(json["updatedAt"])
          : null,
      v: (json["__v"] as num?)?.toInt(),
      appliedOffer: json["appliedOffer"] != null
          ? AppliedOffer.fromJson(json["appliedOffer"])
          : null,
      originalPrice: (json["originalPrice"] as num?)?.toInt(),
      discountedPrice: json["discountedPrice"]?.toDouble(),
      discountAmount: json["discountAmount"]?.toDouble(),
      effectivePrice: json["effectivePrice"]?.toDouble(),
      status: json["status"],
      isRegistrationOpen: json["isRegistrationOpen"],
      isEventLive: json["isEventLive"],
      canJoin: json["canJoin"],
      goesLiveAt: json["goesLiveAt"],
      isRegistered: json["isRegistered"],
      currentStage: json["currentStage"],
      qualifiedStages: json["qualifiedStages"] != null
          ? List<dynamic>.from(json["qualifiedStages"])
          : [],
           resultDeclaredAt: json["resultDeclaredAt"] != null
          ? DateTime.parse(json["resultDeclaredAt"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "imageUrl": imageUrl,
    "stages": stages?.map((x) => x.toJson()).toList(),
    "registrationStartTime": registrationStartTime?.toIso8601String(),
    "registrationEndTime": registrationEndTime?.toIso8601String(),
    "price": price,
    "firstPlacePoints": firstPlacePoints,
    "secondPlacePoints": secondPlacePoints,
    "thirdPlacePoints": thirdPlacePoints,
    "isPublished": isPublished,
    "createdBy": createdBy?.toJson(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "appliedOffer": appliedOffer?.toJson(),
    "originalPrice": originalPrice,
    "discountedPrice": discountedPrice,
    "discountAmount": discountAmount,
    "effectivePrice": effectivePrice,
    "status": status,
    "isRegistrationOpen": isRegistrationOpen,
    "isEventLive": isEventLive,
    "canJoin": canJoin,
    "goesLiveAt": goesLiveAt,
    "isRegistered": isRegistered,
    "currentStage": currentStage,
    "qualifiedStages": qualifiedStages,
  };
}

class AppliedOffer {
  String? id;
  String? offerName;
  String? applicableOn;
  String? discountType;
  int? discountValue;
  String? description;
  DateTime? validTill;

  AppliedOffer({
    this.id,
    this.offerName,
    this.applicableOn,
    this.discountType,
    this.discountValue,
    this.description,
    this.validTill,
  });

  factory AppliedOffer.fromJson(Map<String, dynamic> json) {
    return AppliedOffer(
      id: json["_id"],
      offerName: json["offerName"],
      applicableOn: json["applicableOn"],
      discountType: json["discountType"],
      discountValue: (json["discountValue"] as num?)?.toInt(),
      description: json["description"],
      validTill: json["validTill"] != null
          ? DateTime.parse(json["validTill"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "offerName": offerName,
    "applicableOn": applicableOn,
    "discountType": discountType,
    "discountValue": discountValue,
    "description": description,
    "validTill": validTill?.toIso8601String(),
  };
}

class CreatedBy {
  String? id;
  String? name;
  String? email;

  CreatedBy({this.id, this.name, this.email});

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    return CreatedBy(id: json["_id"], name: json["name"], email: json["email"]);
  }

  Map<String, dynamic> toJson() => {"_id": id, "name": name, "email": email};
}

class Stage {
  String? name;
  Test? test;
  DateTime? startTime;
  DateTime? endTime;
  int? minimumPercentageToQualify;
  int? maxParticipants;
  int? order;
  String? id;
  String? status;
  bool? isEventLive;
  bool? canJoin;
  String? joinBlockReason;
  bool? eligibleForStage;
  PreviousStageQualification? previousStageQualification;
  dynamic goesLiveAt;

  Stage({
    this.name,
    this.test,
    this.startTime,
    this.endTime,
    this.minimumPercentageToQualify,
    this.maxParticipants,
    this.order,
    this.id,
    this.status,
    this.isEventLive,
    this.canJoin,
    this.joinBlockReason,
    this.eligibleForStage,
    this.previousStageQualification,
    this.goesLiveAt,
  });

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      name: json["name"],
      test: json["test"] != null ? Test.fromJson(json["test"]) : null,
      startTime: json["startTime"] != null
          ? DateTime.parse(json["startTime"])
          : null,
      endTime: json["endTime"] != null ? DateTime.parse(json["endTime"]) : null,
      minimumPercentageToQualify: (json["minimumPercentageToQualify"] as num?)
          ?.toInt(),
      maxParticipants: (json["maxParticipants"] as num?)?.toInt(),
      order: (json["order"] as num?)?.toInt(),
      id: json["_id"],
      status: json["status"],
      isEventLive: json["isEventLive"],
      canJoin: json["canJoin"],
      joinBlockReason: json["joinBlockReason"],
      eligibleForStage: json["eligibleForStage"],
      previousStageQualification: json["previousStageQualification"] != null
          ? PreviousStageQualification.fromJson(
              json["previousStageQualification"],
            )
          : null,
      goesLiveAt: json["goesLiveAt"],
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "test": test?.toJson(),
    "startTime": startTime?.toIso8601String(),
    "endTime": endTime?.toIso8601String(),
    "minimumPercentageToQualify": minimumPercentageToQualify,
    "maxParticipants": maxParticipants,
    "order": order,
    "_id": id,
    "status": status,
    "isEventLive": isEventLive,
    "canJoin": canJoin,
    "joinBlockReason": joinBlockReason,
    "eligibleForStage": eligibleForStage,
    "previousStageQualification": previousStageQualification?.toJson(),
    "goesLiveAt": goesLiveAt,
  };
}

class PreviousStageQualification {
  bool? meetsScoreThreshold;
  bool? previousRoundEnded;
  bool? canAdvanceToThisStage;

  PreviousStageQualification({
    this.meetsScoreThreshold,
    this.previousRoundEnded,
    this.canAdvanceToThisStage,
  });

  factory PreviousStageQualification.fromJson(Map<String, dynamic> json) {
    return PreviousStageQualification(
      meetsScoreThreshold: json["meetsScoreThreshold"],
      previousRoundEnded: json["previousRoundEnded"],
      canAdvanceToThisStage: json["canAdvanceToThisStage"],
    );
  }

  Map<String, dynamic> toJson() => {
    "meetsScoreThreshold": meetsScoreThreshold,
    "previousRoundEnded": previousRoundEnded,
    "canAdvanceToThisStage": canAdvanceToThisStage,
  };
}

class Test {
  String? id;
  String? title;
  QuestionBank? questionBank;
  int? durationMinutes;
  dynamic sessionId;
  String? testStatus;

  Test({
    this.id,
    this.title,
    this.questionBank,
    this.durationMinutes,
    this.sessionId,
    this.testStatus,
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json["_id"],
      title: json["title"],
      questionBank: json["questionBank"] != null
          ? QuestionBank.fromJson(json["questionBank"])
          : null,
      durationMinutes: (json["durationMinutes"] as num?)?.toInt(),
      sessionId: json["sessionId"],
      testStatus: json["testStatus"],
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "questionBank": questionBank?.toJson(),
    "durationMinutes": durationMinutes,
    "sessionId": sessionId,
    "testStatus": testStatus,
  };
}

class QuestionBank {
  String? id;
  String? name;
  List<dynamic>? categories;

  QuestionBank({this.id, this.name, this.categories});

  factory QuestionBank.fromJson(Map<String, dynamic> json) {
    return QuestionBank(
      id: json["_id"],
      name: json["name"],
      categories: json["categories"] != null
          ? List<dynamic>.from(json["categories"])
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "categories": categories,
  };
}
