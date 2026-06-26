import 'dart:convert';

AvailableTestsModel availableTestsModelFromJson(String str) =>
    AvailableTestsModel.fromJson(json.decode(str));

String availableTestsModelToJson(AvailableTestsModel data) =>
    json.encode(data.toJson());

class AvailableTestsModel {
  final bool? success;
  final String? message;
  final List<TestData>? data;
  final Meta? meta;

  AvailableTestsModel({this.success, this.message, this.data, this.meta});

  factory AvailableTestsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return AvailableTestsModel();

    return AvailableTestsModel(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List?)?.map((e) => TestData.fromJson(e)).toList(),
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.map((e) => e.toJson()).toList(),
    "meta": meta?.toJson(),
  };
}

class TestData {
  final String? id;
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? questionBank;
  final String? categoryId;
  final String? proctoringInstructions;

  final int? price;
  final int? originalPrice;
  final int? discountedPrice;
  final int? effectivePrice;
  final int? discountAmount;

  final String? applicableFor;
  final int? durationMinutes;
  final bool? isPublished;

  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final AppliedOffer? appliedOffer;

  final dynamic testStatus;
  final dynamic testSessionId;

  final bool? isNewLocked;
  final bool? isPurchased;

  TestData({
    this.id,
    this.title,
    this.description,
    this.imageUrl,
    this.questionBank,
    this.categoryId,
    this.proctoringInstructions,
    this.price,
    this.originalPrice,
    this.discountedPrice,
    this.effectivePrice,
    this.discountAmount,
    this.applicableFor,
    this.durationMinutes,
    this.isPublished,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.appliedOffer,
    this.testStatus,
    this.testSessionId,
    this.isNewLocked,
    this.isPurchased,
  });

  factory TestData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return TestData();

    return TestData(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      questionBank: json['questionBank'],
      categoryId: json['categoryId'],
      proctoringInstructions: json['proctoringInstructions'],
      price: json['price'],
      originalPrice: json['originalPrice'],
      discountedPrice: json['discountedPrice'],
      effectivePrice: json['effectivePrice'],
      discountAmount: json['discountAmount'],
      applicableFor: json['applicableFor'],
      durationMinutes: json['durationMinutes'],
      isPublished: json['isPublished'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      appliedOffer: json['appliedOffer'] != null
          ? AppliedOffer.fromJson(json['appliedOffer'])
          : null,
      testStatus: json['testStatus'],
      testSessionId: json['testSessionId'],
      isNewLocked: json['isNewLocked'],
      isPurchased: json['isPurchased'],
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "description": description,
    "imageUrl": imageUrl,
    "questionBank": questionBank,
    "categoryId": categoryId,
    "proctoringInstructions": proctoringInstructions,
    "price": price,
    "originalPrice": originalPrice,
    "discountedPrice": discountedPrice,
    "effectivePrice": effectivePrice,
    "discountAmount": discountAmount,
    "applicableFor": applicableFor,
    "durationMinutes": durationMinutes,
    "isPublished": isPublished,
    "createdBy": createdBy,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "appliedOffer": appliedOffer?.toJson(),
    "testStatus": testStatus,
    "testSessionId": testSessionId,
    "isNewLocked": isNewLocked,
    "isPurchased": isPurchased,
  };
}

class AppliedOffer {
  final String? id;
  final String? offerName;
  final String? applicableOn;
  final String? discountType;
  final int? discountValue;
  final String? description;
  final DateTime? validTill;

  AppliedOffer({
    this.id,
    this.offerName,
    this.applicableOn,
    this.discountType,
    this.discountValue,
    this.description,
    this.validTill,
  });

  factory AppliedOffer.fromJson(Map<String, dynamic>? json) {
    if (json == null) return AppliedOffer();

    return AppliedOffer(
      id: json['_id'],
      offerName: json['offerName'],
      applicableOn: json['applicableOn'],
      discountType: json['discountType'],
      discountValue: json['discountValue'],
      description: json['description'],
      validTill: json['validTill'] != null
          ? DateTime.tryParse(json['validTill'])
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

class Meta {
  final int? page;
  final int? limit;
  final int? total;
  final int? pages;
  final bool? hasAccess;
  final bool? upgradable;
  final int? upgradeCost;
  final bool? isFreeUpgrade;
  final bool? hasNewContent;

  Meta({
    this.page,
    this.limit,
    this.total,
    this.pages,
    this.hasAccess,
    this.upgradable,
    this.upgradeCost,
    this.isFreeUpgrade,
    this.hasNewContent,
  });

  factory Meta.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Meta();

    return Meta(
      page: json['page'],
      limit: json['limit'],
      total: json['total'],
      pages: json['pages'],
      hasAccess: json['hasAccess'],
      upgradable: json['upgradable'],
      upgradeCost: json['upgradeCost'],
      isFreeUpgrade: json['isFreeUpgrade'],
      hasNewContent: json['hasNewContent'],
    );
  }

  Map<String, dynamic> toJson() => {
    "page": page,
    "limit": limit,
    "total": total,
    "pages": pages,
    "hasAccess": hasAccess,
    "upgradable": upgradable,
    "upgradeCost": upgradeCost,
    "isFreeUpgrade": isFreeUpgrade,
    "hasNewContent": hasNewContent,
  };
}
