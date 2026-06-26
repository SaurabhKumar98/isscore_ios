import 'dart:convert';

StoreModels storeModelsFromJson(String str) =>
    StoreModels.fromJson(json.decode(str));

String storeModelsToJson(StoreModels data) => json.encode(data.toJson());

/// Helper to safely parse a field that might be a String or a Map
String? safeString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is Map) return value['name']?.toString() ?? value.toString();
  return value.toString();
}

class StoreModels {
  bool? success;
  String? message;
  Data? data;
  Meta? meta;

  StoreModels({this.success, this.message, this.data, this.meta});

  factory StoreModels.fromJson(Map<String, dynamic>? json) => StoreModels(
        success: json?["success"],
        message: json?["message"],
        data: json?["data"] != null ? Data.fromJson(json?["data"]) : null,
        meta: json?["meta"] != null ? Meta.fromJson(json?["meta"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
        "meta": meta?.toJson(),
      };
}

class Data {
  List<Item>? items;

  Data({this.items});

  factory Data.fromJson(Map<String, dynamic>? json) => Data(
        items: json?["items"] == null
            ? []
            : List<Item>.from(
                json?["items"].map((x) => Item.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
        "items": items?.map((x) => x.toJson()).toList(),
      };
}

class Item {
  String? id;
  String? name;
  String? description;
  dynamic imageUrl;
  List<Test>? tests;
  int? price;
  bool? isActive;
  String? createdBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  int? originalPrice;
  double? discountedPrice;
  double? effectivePrice;
  String? itemType;
  String? category;
  String? categoryPath;
  String? title;
  QuestionBank? questionBank;
  String? categoryId;
  String? proctoringInstructions;
  String? applicableFor;
  int? durationMinutes;
  bool? isPublished;
  bool? purchased;
  bool? requiresPurchase;
  String? purchaseMessage;
    int? rewardPoints; 

  Item({
    this.id,
    this.name,
    this.description,
    this.imageUrl,
    this.tests,
    this.price,
    this.isActive,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.originalPrice,
    this.discountedPrice,
    this.effectivePrice,
    this.itemType,
    this.category,
    this.categoryPath,
    this.title,
    this.questionBank,
    this.categoryId,
    this.proctoringInstructions,
    this.applicableFor,
    this.durationMinutes,
    this.isPublished,
    this.purchased,
    this.requiresPurchase,
    this.purchaseMessage,
    this.rewardPoints,
  });

  factory Item.fromJson(Map<String, dynamic>? json) => Item(
        id: json?["_id"],
        name: safeString(json?["name"]),
        description: safeString(json?["description"]),
        imageUrl: json?["imageUrl"],
        tests: json?["tests"] == null
            ? []
            : List<Test>.from(
                json?["tests"].map((x) => Test.fromJson(x)),
              ),
        price: json?["price"],
        isActive: json?["isActive"],
        createdBy: safeString(json?["createdBy"]),
        createdAt: json?["createdAt"] != null
            ? DateTime.tryParse(json?["createdAt"])
            : null,
        updatedAt: json?["updatedAt"] != null
            ? DateTime.tryParse(json?["updatedAt"])
            : null,
        v: json?["__v"],
        originalPrice: json?["originalPrice"],
        discountedPrice: (json?["discountedPrice"] as num?)?.toDouble(),
        effectivePrice: (json?["effectivePrice"] as num?)?.toDouble(),
        itemType: safeString(json?["itemType"]),
        category: safeString(json?["category"]),
        categoryPath: safeString(json?["categoryPath"]),
        title: safeString(json?["title"]),
        questionBank: json?["questionBank"] != null
            ? QuestionBank.fromJson(json?["questionBank"])
            : null,
        categoryId: safeString(json?["categoryId"]),
        proctoringInstructions: safeString(json?["proctoringInstructions"]),
        applicableFor: safeString(json?["applicableFor"]),
        durationMinutes: json?["durationMinutes"],
        isPublished: json?["isPublished"],
        purchased: json?["purchased"],
        requiresPurchase: json?["requiresPurchase"],
        purchaseMessage: safeString(json?["purchaseMessage"]),
        rewardPoints: json?["rewardPoints"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "description": description,
        "imageUrl": imageUrl,
        "tests": tests?.map((x) => x.toJson()).toList(),
        "price": price,
        "isActive": isActive,
        "createdBy": createdBy,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "originalPrice": originalPrice,
        "discountedPrice": discountedPrice,
        "effectivePrice": effectivePrice,
        "itemType": itemType,
        "category": category,
        "categoryPath": categoryPath,
        "title": title,
        "questionBank": questionBank?.toJson(),
        "categoryId": categoryId,
        "proctoringInstructions": proctoringInstructions,
        "applicableFor": applicableFor,
        "durationMinutes": durationMinutes,
        "isPublished": isPublished,
        "purchased": purchased,
        "requiresPurchase": requiresPurchase,
        "purchaseMessage": purchaseMessage,
        "rewardPoints": rewardPoints,
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
        name: safeString(json?["name"]),
        categories: json?["categories"] == null
            ? []
            : List<Category>.from(
                json?["categories"].map((x) => Category.fromJson(x)),
              ),
        overallDifficulty: safeString(json?["overallDifficulty"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "categories": categories?.map((x) => x.toJson()).toList(),
        "overallDifficulty": overallDifficulty,
      };
}

class Category {
  String? id;
  String? name;
  String? kind;
  bool? hasPurchase;
  String? categoryId;

  Category({this.id, this.name, this.kind, this.hasPurchase, this.categoryId});

  factory Category.fromJson(Map<String, dynamic>? json) => Category(
        id: json?["_id"],
        name: safeString(json?["name"]),
        kind: safeString(json?["kind"]),
        hasPurchase: json?["hasPurchase"],
        categoryId: safeString(json?["id"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "kind": kind,
        "hasPurchase": hasPurchase,
        "id": categoryId,
      };
}

class Test {
  String? id;
  String? title;
  QuestionBank? questionBank;
  int? durationMinutes;
  String? categoryId;
  String? category;
  String? categoryPath;

  Test({
    this.id,
    this.title,
    this.questionBank,
    this.durationMinutes,
    this.categoryId,
    this.category,
    this.categoryPath,
  });

  factory Test.fromJson(Map<String, dynamic>? json) => Test(
        id: json?["_id"],
        title: safeString(json?["title"]),
        questionBank: json?["questionBank"] != null
            ? QuestionBank.fromJson(json?["questionBank"])
            : null,
        durationMinutes: json?["durationMinutes"],
        categoryId: safeString(json?["categoryId"]),
        category: safeString(json?["category"]),
        categoryPath: safeString(json?["categoryPath"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "questionBank": questionBank?.toJson(),
        "durationMinutes": durationMinutes,
        "categoryId": categoryId,
        "category": category,
        "categoryPath": categoryPath,
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