
import 'dart:convert';

OlympiadCenterResponseModel olympiadCenterResponseModelFromJson(String str) =>
    OlympiadCenterResponseModel.fromJson(json.decode(str));

String olympiadCenterResponseModelToJson(OlympiadCenterResponseModel data) =>
    json.encode(data.toJson());

class OlympiadCenterResponseModel {
  bool? success;
  String? message;
  List<OlympiadData>? data;
  Meta? meta;

  OlympiadCenterResponseModel({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory OlympiadCenterResponseModel.fromJson(Map<String, dynamic> json) {
    return OlympiadCenterResponseModel(
      success: json["success"],
      message: json["message"],
      data: json["data"] == null
          ? []
          : List<OlympiadData>.from(
              json["data"].map((x) => OlympiadData.fromJson(x)),
            ),
      meta: json["meta"] == null
          ? null
          : Meta.fromJson(json["meta"] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
    "meta": meta?.toJson(),
  };
}

class OlympiadData {
  String? id;
  CategoryModel? categoryId;

  String? title;
  String? description;

  TestModel? testId;

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
  int? effectivePrice;
  int? discountAmount;

  String? status;
  bool? isEventLive;
  bool? isRegistrationOpen;

  String? categoryName;
  bool? isRegistered;

  String? testStatus;
  String? testSessionId;

  AppliedOffer? appliedOffer;

  OlympiadData({
    this.id,
    this.categoryId,
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
    this.effectivePrice,
    this.discountAmount,
    this.status,
    this.isEventLive,
    this.isRegistrationOpen,
    this.categoryName,
    this.isRegistered,
    this.testStatus,
    this.testSessionId,
    this.appliedOffer,
  });

  factory OlympiadData.fromJson(Map<String, dynamic>? json) => OlympiadData(
    id: json?["_id"],
    categoryId: json?["categoryId"] == null
        ? null
        : CategoryModel.fromJson(json?["categoryId"]),
    title: json?["title"],
    description: json?["description"],
    testId: json?["testId"] == null
        ? null
        : TestModel.fromJson(json?["testId"]),
    purchaseCount: json?["purchaseCount"],

    registrationStartTime: DateTime.tryParse(
      json?["registrationStartTime"] ?? "",
    ),
    registrationEndTime: DateTime.tryParse(json?["registrationEndTime"] ?? ""),
    startTime: DateTime.tryParse(json?["startTime"] ?? ""),
    endTime: DateTime.tryParse(json?["endTime"] ?? ""),
    resultDeclarationDate: DateTime.tryParse(
      json?["resultDeclarationDate"] ?? "",
    ),

    firstPlacePoints: json?["firstPlacePoints"],
    secondPlacePoints: json?["secondPlacePoints"],
    thirdPlacePoints: json?["thirdPlacePoints"],

    createdAt: DateTime.tryParse(json?["createdAt"] ?? ""),
    updatedAt: DateTime.tryParse(json?["updatedAt"] ?? ""),
    v: json?["__v"],

    price: json?["price"],
    originalPrice: json?["originalPrice"],
    discountedPrice: json?["discountedPrice"],
    effectivePrice: json?["effectivePrice"],
    discountAmount: json?["discountAmount"],

    status: json?["status"],
    isEventLive: json?["isEventLive"],
    isRegistrationOpen: json?["isRegistrationOpen"],

    categoryName: json?["categoryName"],
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
    "title": title,
    "description": description,
    "testId": testId?.toJson(),
    "purchaseCount": purchaseCount,

    "registrationStartTime": registrationStartTime?.toIso8601String(),
    "registrationEndTime": registrationEndTime?.toIso8601String(),
    "startTime": startTime?.toIso8601String(),
    "endTime": endTime?.toIso8601String(),
    "resultDeclarationDate": resultDeclarationDate?.toIso8601String(),

    "firstPlacePoints": firstPlacePoints,
    "secondPlacePoints": secondPlacePoints,
    "thirdPlacePoints": thirdPlacePoints,

    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,

    "price": price,
    "originalPrice": originalPrice,
    "discountedPrice": discountedPrice,
    "effectivePrice": effectivePrice,
    "discountAmount": discountAmount,

    "status": status,
    "isEventLive": isEventLive,
    "isRegistrationOpen": isRegistrationOpen,

    "categoryName": categoryName,
    "isRegistered": isRegistered,

    "testStatus": testStatus,
    "testSessionId": testSessionId,

    "appliedOffer": appliedOffer?.toJson(),
  };
}

class CategoryModel {
  String? id;
  String? name;
  ParentCategory? parent;
  String? kind;

  CategoryModel({this.id, this.name, this.parent, this.kind});

  factory CategoryModel.fromJson(Map<String, dynamic>? json) => CategoryModel(
    id: json?["_id"],
    name: json?["name"],
    kind: json?["kind"],
    parent: json?["parent"] == null
        ? null
        : ParentCategory.fromJson(json?["parent"]),
  );
  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "kind": kind,
    "parent": parent?.toJson(),
  };
}

class ParentCategory {
  String? id;
  String? name;

  ParentCategory({this.id, this.name});

  factory ParentCategory.fromJson(Map<String, dynamic>? json) =>
      ParentCategory(id: json?["_id"], name: json?["name"]);
  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

class CreatedBy {
  String? id;
  String? name;
  String? email;

  CreatedBy({this.id, this.name, this.email});

  factory CreatedBy.fromJson(Map<String, dynamic>? json) =>
      CreatedBy(id: json?["_id"], name: json?["name"], email: json?["email"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name, "email": email};
}

class TestModel {
  String? id;
  String? title;
  int? durationMinutes;
  String? sessionId; // ← from API: test.sessionId
  String?
  testStatus; // ← from API: test.testStatus ("not_started" | "completed" | ...)

  TestModel({
    this.id,
    this.title,
    this.durationMinutes,
    this.sessionId,
    this.testStatus,
  });

  factory TestModel.fromJson(Map<String, dynamic>? json) => TestModel(
    id: json?["_id"],
    title: json?["title"],
    durationMinutes: json?["durationMinutes"],
    sessionId: json?["sessionId"],
    testStatus: json?["testStatus"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "durationMinutes": durationMinutes,
    "sessionId": sessionId,
    "testStatus": testStatus,
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

  factory AppliedOffer.fromJson(Map<String, dynamic>? json) => AppliedOffer(
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

class Meta {
  int? page;
  int? limit;
  int? total;
  int? pages;

  Meta({this.page, this.limit, this.total, this.pages});

  factory Meta.fromJson(Map<String, dynamic>? json) => Meta(
    page: json?["page"],
    limit: json?["limit"],
    total: json?["total"],
    pages: json?["pages"],
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "limit": limit,
    "total": total,
    "pages": pages,
  };
}
