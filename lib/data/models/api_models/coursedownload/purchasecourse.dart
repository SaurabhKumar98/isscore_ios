import 'dart:convert';

PurchasedChourseModels purchasedChourseModelsFromJson(String str) =>
    PurchasedChourseModels.fromJson(json.decode(str));

String purchasedChourseModelsToJson(PurchasedChourseModels data) =>
    json.encode(data.toJson());

class PurchasedChourseModels {
  bool? success;
  String? message;
  List<PurchasedCourse>? data;
  Meta? meta;

  PurchasedChourseModels({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory PurchasedChourseModels.fromJson(Map<String, dynamic> json) {
    return PurchasedChourseModels(
      success: json["success"],
      message: json["message"],
      data: json["data"] == null
          ? []
          : List<PurchasedCourse>.from(
              json["data"].map((x) => PurchasedCourse.fromJson(x)),
            ),
      meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.map((e) => e.toJson()).toList(),
        "meta": meta?.toJson(),
      };
}

class PurchasedCourse {
  String? id;
  Student? student;
  CourseInfo? course;
  double? purchasePrice;
  String? paymentId;
  String? paymentStatus;
  DateTime? purchaseDate;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? version;

  double? originalPrice;
  double? discountedPrice;
  double? effectivePrice;
  double? discountAmount;
  AppliedOffer? appliedOffer;

  PurchasedCourse({
    this.id,
    this.student,
    this.course,
    this.purchasePrice,
    this.paymentId,
    this.paymentStatus,
    this.purchaseDate,
    this.createdAt,
    this.updatedAt,
    this.version,
    this.originalPrice,
    this.discountedPrice,
    this.effectivePrice,
    this.discountAmount,
    this.appliedOffer,
  });

  factory PurchasedCourse.fromJson(Map<String, dynamic> json) {
    return PurchasedCourse(
      id: json["_id"],
      student: json["student"] == null
          ? null
          : Student.fromJson(json["student"]),
      course: json["course"] == null
          ? null
          : CourseInfo.fromJson(json["course"]),
      purchasePrice: (json["purchasePrice"] as num?)?.toDouble(),
      paymentId: json["paymentId"],
      paymentStatus: json["paymentStatus"],
      purchaseDate: json["purchaseDate"] != null
          ? DateTime.tryParse(json["purchaseDate"])
          : null,
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"])
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.tryParse(json["updatedAt"])
          : null,
      version: json["__v"],
      originalPrice: (json["originalPrice"] as num?)?.toDouble(),
      discountedPrice: (json["discountedPrice"] as num?)?.toDouble(),
      effectivePrice: (json["effectivePrice"] as num?)?.toDouble(),
      discountAmount: (json["discountAmount"] as num?)?.toDouble(),
      appliedOffer: json["appliedOffer"] != null
          ? AppliedOffer.fromJson(json["appliedOffer"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "student": student?.toJson(),
        "course": course?.toJson(),
        "purchasePrice": purchasePrice,
        "paymentId": paymentId,
        "paymentStatus": paymentStatus,
        "purchaseDate": purchaseDate?.toIso8601String(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": version,
      };
}

class Student {
  String? id;
  String? name;
  String? email;

  Student({
    this.id,
    this.name,
    this.email,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json["_id"],
      name: json["name"],
      email: json["email"],
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "email": email,
      };
}

class AppliedOffer {
  String? id;
  String? offerName;
  String? discountType;
  int? discountValue;

  AppliedOffer({
    this.id,
    this.offerName,
    this.discountType,
    this.discountValue,
  });

  factory AppliedOffer.fromJson(Map<String, dynamic> json) {
    return AppliedOffer(
      id: json["_id"],
      offerName: json["offerName"],
      discountType: json["discountType"],
      discountValue: json["discountValue"],
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "offerName": offerName,
        "discountType": discountType,
        "discountValue": discountValue,
      };
}

class CourseInfo {
  String? id;
  String? title;
  String? description;
  String? contentType;
  int? price;
  String? imageUrl;

  List<String> syllabus;
  List<String> categoryIds;
  List<dynamic> modules;
  List<CourseContent> contents;

  CourseInfo({
    this.id,
    this.title,
    this.description,
    this.contentType,
    this.price,
    this.imageUrl,
    this.syllabus = const [],
    this.categoryIds = const [],
    this.modules = const [],
    this.contents = const [],
  });

  String? get contentUrl =>
      contents.isNotEmpty ? contents.first.url : null;

  String? get resolvedType =>
      contentType ??
      (contents.isNotEmpty ? contents.first.type : null);

  factory CourseInfo.fromJson(Map<String, dynamic> json) {
    return CourseInfo(
      id: json["_id"],
      title: json["title"],
      description: json["description"],
      contentType: json["contentType"],
      price: json["price"],
      imageUrl: json["imageUrl"],
      syllabus: json["syllabus"] == null
          ? []
          : List<String>.from(json["syllabus"]),
      categoryIds: json["categoryIds"] == null
          ? []
          : List<String>.from(json["categoryIds"]),
      modules: json["modules"] ?? [],
      contents: (json["contents"] as List?)
              ?.map((e) => CourseContent.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "description": description,
        "contentType": contentType,
        "price": price,
        "imageUrl": imageUrl,
        "syllabus": syllabus,
        "categoryIds": categoryIds,
        "modules": modules,
        "contents": contents.map((e) => e.toJson()).toList(),
      };
}

class CourseContent {
  String? url;
  String? type;
  String? originalName;
  String? id;

  CourseContent({
    this.url,
    this.type,
    this.originalName,
    this.id,
  });

  factory CourseContent.fromJson(Map<String, dynamic> json) {
    return CourseContent(
      url: json["url"],
      type: json["type"],
      originalName: json["originalName"],
      id: json["_id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "url": url,
        "type": type,
        "originalName": originalName,
        "_id": id,
      };
}

class Meta {
  int? page;
  int? limit;
  int? total;
  int? pages;

  Meta({
    this.page,
    this.limit,
    this.total,
    this.pages,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      page: json["page"],
      limit: json["limit"],
      total: json["total"],
      pages: json["pages"],
    );
  }

  Map<String, dynamic> toJson() => {
        "page": page,
        "limit": limit,
        "total": total,
        "pages": pages,
      };
}