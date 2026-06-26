import 'dart:convert';

OlympiadDetailsModels olympiadDetailsModelsFromJson(String str) =>
    OlympiadDetailsModels.fromJson(json.decode(str));

String olympiadDetailsModelsToJson(OlympiadDetailsModels data) =>
    json.encode(data.toJson());

class OlympiadDetailsModels {
  bool? success;
  String? message;
  OlympiadDetailsData? data;
  dynamic meta;

  OlympiadDetailsModels({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory OlympiadDetailsModels.fromJson(Map<String, dynamic>? json) =>
      OlympiadDetailsModels(
        success: json?["success"],
        message: json?["message"],
        data: json?["data"] == null
            ? null
            : OlympiadDetailsData.fromJson(json?["data"]),
        meta: json?["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
        "meta": meta,
      };
}

class OlympiadDetailsData {
  String? id;
  CategoryId? categoryId;
  String? categoryName;

  String? title;
  String? description;

  TestId? testId;

  int? purchaseCount;

  DateTime? registrationStartTime;
  DateTime? registrationEndTime;
  DateTime? startTime;
  DateTime? endTime;
  DateTime? resultDeclarationDate;

  int? firstPlacePoints;
  int? secondPlacePoints;
  int? thirdPlacePoints;

  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  int? price;
  int? originalPrice;
  int? discountedPrice;
  int? discountAmount;
  int? effectivePrice;

  String? status;
  bool? isEventLive;
  bool? isRegistrationOpen;
  bool? isRegistered;

  String? testStatus;
  String? testSessionId;

  AppliedOffer? appliedOffer;
  

  OlympiadDetailsData({
    this.id,
    this.categoryId,
    this.categoryName,
    this.title,
    this.description,
    this.testId,
    this.purchaseCount,
    this.registrationStartTime,
    this.registrationEndTime,
    this.startTime,
    this.endTime,
    this.resultDeclarationDate,
    this.firstPlacePoints,
    this.secondPlacePoints,
    this.thirdPlacePoints,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.price,
    this.originalPrice,
    this.discountedPrice,
    this.discountAmount,
    this.effectivePrice,
    this.status,
    this.isEventLive,
    this.isRegistrationOpen,
    this.isRegistered,
    this.testStatus,
    this.testSessionId,
    this.appliedOffer,
  });

  factory OlympiadDetailsData.fromJson(Map<String, dynamic>? json) =>
      OlympiadDetailsData(
        id: json?["_id"],
        categoryId: json?["categoryId"] == null
            ? null
            : CategoryId.fromJson(json?["categoryId"]),
        categoryName: json?["categoryName"],
        title: json?["title"],
        description: json?["description"],
        testId: json?["testId"] == null
            ? null
            : TestId.fromJson(json?["testId"]),
        purchaseCount: json?["purchaseCount"],

        registrationStartTime:
            DateTime.tryParse(json?["registrationStartTime"] ?? ""),
        registrationEndTime:
            DateTime.tryParse(json?["registrationEndTime"] ?? ""),
        startTime: DateTime.tryParse(json?["startTime"] ?? ""),
        endTime: DateTime.tryParse(json?["endTime"] ?? ""),
        resultDeclarationDate:
            DateTime.tryParse(json?["resultDeclarationDate"] ?? ""),

        firstPlacePoints: json?["firstPlacePoints"],
        secondPlacePoints: json?["secondPlacePoints"],
        thirdPlacePoints: json?["thirdPlacePoints"],

        createdAt: DateTime.tryParse(json?["createdAt"] ?? ""),
        updatedAt: DateTime.tryParse(json?["updatedAt"] ?? ""),
        v: json?["__v"],

        price: json?["price"],
        originalPrice: json?["originalPrice"],
        discountedPrice: json?["discountedPrice"],
        discountAmount: json?["discountAmount"],
        effectivePrice: json?["effectivePrice"],

        status: json?["status"],
        isEventLive: json?["isEventLive"],
        isRegistrationOpen: json?["isRegistrationOpen"],
        isRegistered: json?["isRegistered"],

        testStatus: json?["testStatus"],
        testSessionId: json?["testSessionId"],

        appliedOffer: json?["appliedOffer"] == null
            ? null
            : AppliedOffer.fromJson(json?["appliedOffer"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "categoryId": categoryId?.toJson(),
        "categoryName": categoryName,
        "title": title,
        "description": description,
        "testId": testId?.toJson(),
        "purchaseCount": purchaseCount,
        "registrationStartTime": registrationStartTime?.toIso8601String(),
        "registrationEndTime": registrationEndTime?.toIso8601String(),
        "startTime": startTime?.toIso8601String(),
        "endTime": endTime?.toIso8601String(),
        "resultDeclarationDate":
            resultDeclarationDate?.toIso8601String(),
        "firstPlacePoints": firstPlacePoints,
        "secondPlacePoints": secondPlacePoints,
        "thirdPlacePoints": thirdPlacePoints,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "price": price,
        "originalPrice": originalPrice,
        "discountedPrice": discountedPrice,
        "discountAmount": discountAmount,
        "effectivePrice": effectivePrice,
        "status": status,
        "isEventLive": isEventLive,
        "isRegistrationOpen": isRegistrationOpen,
        "isRegistered": isRegistered,
        "testStatus": testStatus,
        "testSessionId": testSessionId,
        "appliedOffer": appliedOffer?.toJson(),
      };
}

class CategoryId {
  String? id;
  String? name;
  Parent? parent;
  String? kind;

  CategoryId({this.id, this.name, this.parent, this.kind});

  factory CategoryId.fromJson(Map<String, dynamic>? json) => CategoryId(
        id: json?["_id"],
        name: json?["name"],
        kind: json?["kind"],
        parent: json?["parent"] == null
            ? null
            : Parent.fromJson(json?["parent"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "kind": kind,
        "parent": parent?.toJson(),
      };
}

class Parent {
  String? id;
  String? name;

  Parent({this.id, this.name});

  factory Parent.fromJson(Map<String, dynamic>? json) => Parent(
        id: json?["_id"],
        name: json?["name"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
      };
}

class TestId {
  String? id;
  String? title;
  dynamic imageUrl;
  int? price;
  int? durationMinutes;
  bool? isPublished;

  TestId({
    this.id,
    this.title,
    this.imageUrl,
    this.price,
    this.durationMinutes,
    this.isPublished,
  });

  factory TestId.fromJson(Map<String, dynamic>? json) => TestId(
        id: json?["_id"],
        title: json?["title"],
        imageUrl: json?["imageUrl"],
        price: json?["price"],
        durationMinutes: json?["durationMinutes"],
        isPublished: json?["isPublished"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "imageUrl": imageUrl,
        "price": price,
        "durationMinutes": durationMinutes,
        "isPublished": isPublished,
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

  factory AppliedOffer.fromJson(Map<String, dynamic>? json) =>
      AppliedOffer(
        id: json?["_id"],
        offerName: json?["offerName"],
        applicableOn: json?["applicableOn"],
        discountType: json?["discountType"],
        discountValue: json?["discountValue"],
        description: json?["description"],
        validTill: DateTime.tryParse(json?["validTill"] ?? ""),
      );

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