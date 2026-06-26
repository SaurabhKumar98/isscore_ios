import 'dart:convert';

CourseDetailsModel courseDetailsModelFromJson(String str) =>
    CourseDetailsModel.fromJson(json.decode(str));

String courseDetailsModelToJson(CourseDetailsModel data) =>
    json.encode(data.toJson());

class CourseDetailsModel {
  final bool success;
  final String message;
  final CourseDetailsData? data;
  final dynamic meta;

  CourseDetailsModel({
    required this.success,
    required this.message,
    this.data,
    this.meta,
  });

  factory CourseDetailsModel.fromJson(Map<String, dynamic> json) =>
      CourseDetailsModel(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] != null
            ? CourseDetailsData.fromJson(json["data"])
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

class CourseDetailsData {
  final String id;
  final String title;
  final String description;
  final List<dynamic> syllabus;
  final String? imageUrl;
  final List<Content> contents;
  final List<Module> modules;
  final int price;
  final bool isPublished;
  final String createdBy;
  final List<CategoryId> categoryIds;
  final bool isCertification;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int v;
  final int originalPrice;
  final int discountedPrice;
  final int effectivePrice;
  final bool isPurchased;
  final List<String> categoryPath;
  final int certificationTestCount;
  final List<CertificationTest> certificationTests;

  CourseDetailsData({
    required this.id,
    required this.title,
    required this.description,
    required this.syllabus,
    this.imageUrl,
    required this.contents,
    required this.modules,
    required this.price,
    required this.isPublished,
    required this.createdBy,
    required this.categoryIds,
    required this.isCertification,
    this.createdAt,
    this.updatedAt,
    required this.v,
    required this.originalPrice,
    required this.discountedPrice,
    required this.effectivePrice,
    required this.isPurchased,
    required this.categoryPath,
    required this.certificationTestCount,
    required this.certificationTests,
  });

  factory CourseDetailsData.fromJson(Map<String, dynamic> json) =>
      CourseDetailsData(
        id: json["_id"] ?? "",
        title: json["title"] ?? "",
        description: json["description"] ?? "",
        syllabus: json["syllabus"] != null
            ? List<dynamic>.from(json["syllabus"])
            : [],
        imageUrl: json["imageUrl"],
        contents: json["contents"] != null
            ? List<Content>.from(
                json["contents"].map((x) => Content.fromJson(x)))
            : [],
        modules: json["modules"] != null
            ? List<Module>.from(
                json["modules"].map((x) => Module.fromJson(x)))
            : [],
        price: json["price"] ?? 0,
        isPublished: json["isPublished"] ?? false,
        createdBy: json["createdBy"] ?? "",
        categoryIds: json["categoryIds"] != null
            ? List<CategoryId>.from(
                json["categoryIds"].map((x) => CategoryId.fromJson(x)))
            : [],
        isCertification: json["isCertification"] ?? false,
        createdAt: json["createdAt"] != null
            ? DateTime.tryParse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.tryParse(json["updatedAt"])
            : null,
        v: json["__v"] ?? 0,
        originalPrice: json["originalPrice"] ?? 0,
        discountedPrice: json["discountedPrice"] ?? 0,
        effectivePrice: json["effectivePrice"] ?? 0,
        isPurchased: json["isPurchased"] ?? false,
        categoryPath: json["categoryPath"] != null
            ? List<String>.from(json["categoryPath"])
            : [],
        certificationTestCount: json["certificationTestCount"] ?? 0,
        certificationTests: json["certificationTests"] != null
            ? List<CertificationTest>.from(json["certificationTests"]
                .map((x) => CertificationTest.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "description": description,
        "syllabus": syllabus,
        "imageUrl": imageUrl,
        "contents": contents.map((x) => x.toJson()).toList(),
        "modules": modules.map((x) => x.toJson()).toList(),
        "price": price,
        "isPublished": isPublished,
        "createdBy": createdBy,
        "categoryIds": categoryIds.map((x) => x.toJson()).toList(),
        "isCertification": isCertification,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "originalPrice": originalPrice,
        "discountedPrice": discountedPrice,
        "effectivePrice": effectivePrice,
        "isPurchased": isPurchased,
        "categoryPath": categoryPath,
        "certificationTestCount": certificationTestCount,
        "certificationTests":
            certificationTests.map((x) => x.toJson()).toList(),
      };
}

class Module {
  final String id;
  final String title;
  final String description;
  final List<Content> contents;
  final Test? test;
  final int order;
  final bool testCompleted;

  final String testStatus;
  final String? sessionId;

  Module({
    required this.id,
    required this.title,
    required this.description,
    required this.contents,
    this.test,
    required this.order,
    required this.testCompleted,
    required this.testStatus,
    this.sessionId,
  });

  factory Module.fromJson(Map<String, dynamic> json) => Module(
        id: json["_id"] ?? "",
        title: json["title"] ?? "",
        description: json["description"] ?? "",
        contents: json["contents"] != null
            ? List<Content>.from(
                json["contents"].map((x) => Content.fromJson(x)))
            : [],
        test: json["test"] != null ? Test.fromJson(json["test"]) : null,
        order: json["order"] ?? 0,
        testCompleted: json["testCompleted"] ?? false,
        testStatus: json["testStatus"] ?? "not_started",
        sessionId: json["sessionId"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "description": description,
        "contents": contents.map((x) => x.toJson()).toList(),
        "test": test?.toJson(),
        "order": order,
        "testCompleted": testCompleted,
        "testStatus": testStatus,
        "sessionId": sessionId,
      };
}

class Test {
  final String id;
  final String title;
  final String description;
  final int durationMinutes;
  final dynamic questionBank;

  // ✅ NEW FIELD
  final int passingPercentage;

  Test({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    this.questionBank,
    required this.passingPercentage,
  });

  factory Test.fromJson(Map<String, dynamic> json) => Test(
        id: json["_id"] ?? "",
        title: json["title"] ?? "",
        description: json["description"] ?? "",
        durationMinutes: json["durationMinutes"] ?? 0,
        questionBank: json["questionBank"],
        passingPercentage: json["passingPercentage"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "description": description,
        "durationMinutes": durationMinutes,
        "questionBank": questionBank,
        "passingPercentage": passingPercentage,
      };
}

class CertificationTest {
  final String id;
  final String title;
  final String description;
  final int durationMinutes;

  // ✅ NEW FIELDS
  final int passingPercentage;
  final String status;
  final String? sessionId;

  CertificationTest({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.passingPercentage,
    required this.status,
    this.sessionId,
  });

  factory CertificationTest.fromJson(Map<String, dynamic> json) =>
      CertificationTest(
        id: json["_id"] ?? "",
        title: json["title"] ?? "",
        description: json["description"] ?? "",
        durationMinutes: json["durationMinutes"] ?? 0,
        passingPercentage: json["passingPercentage"] ?? 0,
        status: json["status"] ?? "not_started",
        sessionId: json["sessionId"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "description": description,
        "durationMinutes": durationMinutes,
        "passingPercentage": passingPercentage,
        "status": status,
        "sessionId": sessionId,
      };
}

class CategoryId {
  final String id;
  final String name;
  final String parent;
  final String kind;
  final bool hasPurchase;
  final String categoryIdId;

  CategoryId({
    required this.id,
    required this.name,
    required this.parent,
    required this.kind,
    required this.hasPurchase,
    required this.categoryIdId,
  });

  factory CategoryId.fromJson(Map<String, dynamic> json) => CategoryId(
        id: json["_id"] ?? "",
        name: json["name"] ?? "",
        parent: json["parent"] ?? "",
        kind: json["kind"] ?? "",
        hasPurchase: json["hasPurchase"] ?? false,
        categoryIdId: json["id"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "parent": parent,
        "kind": kind,
        "hasPurchase": hasPurchase,
        "id": categoryIdId,
      };
}

class Content {
  final String type;
  final String originalName;
  final String? url;
  final String id;

  Content({
    required this.type,
    required this.originalName,
    this.url,
    required this.id,
  });

  factory Content.fromJson(Map<String, dynamic> json) => Content(
        type: json["type"] ?? "",
        originalName: json["originalName"] ?? "",
        url: json["url"],
        id: json["_id"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "originalName": originalName,
        "url": url,
        "_id": id,
      };
}