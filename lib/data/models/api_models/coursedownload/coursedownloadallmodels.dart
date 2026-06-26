import 'dart:convert';

DownloadCourseResponse downloadCourseResponseFromJson(String str) =>
    DownloadCourseResponse.fromJson(json.decode(str));

String downloadCourseResponseToJson(DownloadCourseResponse data) =>
    json.encode(data.toJson());

/// ---------- MAIN RESPONSE ----------
class DownloadCourseResponse {
  final bool success;
  final String? message;
  final List<CourseData> data;
  final Meta? meta;

  DownloadCourseResponse({
    required this.success,
    this.message,
    required this.data,
    this.meta,
  });

  factory DownloadCourseResponse.fromJson(Map<String, dynamic> json) =>
      DownloadCourseResponse(
        success: json["success"] ?? false,
        message: json["message"],
        data: (json["data"] as List?)?.map((e) => CourseData.fromJson(e)).toList() ?? [],
        meta: json["meta"] != null ? Meta.fromJson(json["meta"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data.map((e) => e.toJson()).toList(),
        "meta": meta?.toJson(),
      };
}

/// ---------- COURSE DATA ----------
class CourseData {
  final String? id;
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? contentType;
  final String? contentUrl;

  final num? price;
  final num? originalPrice;
  final num? discountedPrice;
  final num? effectivePrice;

  final bool? isPublished;
  final bool? isCertification;

  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;

  final List<String> syllabus;
  final List<String> categoryPath;
  final List<CategoryId> categoryIds;

  final int? contentsCount;
  final int? certificationTestCount;
   final bool? isPurchased;

  CourseData({
    this.id,
    this.title,
    this.description,
    this.imageUrl,
    this.contentType,
    this.contentUrl,
    this.price,
    this.originalPrice,
    this.discountedPrice,
    this.effectivePrice,
    this.isPublished,
    this.isCertification,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.version,
    this.syllabus = const [],
    this.categoryPath = const [],
    this.categoryIds = const [],
    this.contentsCount,
    this.certificationTestCount,
    this.isPurchased,
  });

  factory CourseData.fromJson(Map<String, dynamic> json) => CourseData(
        id: json["_id"],
        title: json["title"],
        description: json["description"],
        imageUrl: json["imageUrl"],
        contentType: json["contentType"],
        contentUrl: json["contentUrl"],
        price: json["price"],
        originalPrice: json["originalPrice"],
        discountedPrice: json["discountedPrice"],
        effectivePrice: json["effectivePrice"],
        isPublished: json["isPublished"],
        isCertification: json["isCertification"],
        createdBy: json["createdBy"],
        createdAt: json["createdAt"] != null ? DateTime.tryParse(json["createdAt"]) : null,
        updatedAt: json["updatedAt"] != null ? DateTime.tryParse(json["updatedAt"]) : null,
        version: json["__v"],
        syllabus: List<String>.from(json["syllabus"] ?? []),
        categoryPath: List<String>.from(json["categoryPath"] ?? []),
        categoryIds: (json["categoryIds"] as List?)
                ?.map((e) => CategoryId.fromJson(e))
                .toList() ??
            [],
        contentsCount: json["contentsCount"],
        certificationTestCount: json["certificationTestCount"],
              isPurchased: json["isPurchased"], 
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "description": description,
        "imageUrl": imageUrl,
        "contentType": contentType,
        "contentUrl": contentUrl,
        "price": price,
        "originalPrice": originalPrice,
        "discountedPrice": discountedPrice,
        "effectivePrice": effectivePrice,
        "isPublished": isPublished,
        "isCertification": isCertification,
        "createdBy": createdBy,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": version,
        "syllabus": syllabus,
        "categoryPath": categoryPath,
        "categoryIds": categoryIds.map((e) => e.toJson()).toList(),
        "contentsCount": contentsCount,
        "certificationTestCount": certificationTestCount,
         "isPurchased": isPurchased,
      };
}

/// ---------- CATEGORY ID ----------
class CategoryId {
  final String? id;
  final String? name;
  final String? parent;
  final String? kind;
  final bool? hasPurchase;

  CategoryId({this.id, this.name, this.parent, this.kind, this.hasPurchase});

  factory CategoryId.fromJson(Map<String, dynamic> json) => CategoryId(
        id: json["_id"],
        name: json["name"],
        parent: json["parent"],
        kind: json["kind"],
        hasPurchase: json["hasPurchase"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "parent": parent,
        "kind": kind,
        "hasPurchase": hasPurchase,
      };
}

/// ---------- META ----------
class Meta {
  final int? page;
  final int? limit;
  final int? total;
  final int? pages;

  Meta({this.page, this.limit, this.total, this.pages});

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        page: json["page"],
        limit: json["limit"],
        total: json["total"],
        pages: json["pages"],
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "limit": limit,
        "total": total,
        "pages": pages,
      };
}