import 'dart:convert';

CompetitionSubDetailModel competitionSubDetailModelFromJson(String str) =>
    CompetitionSubDetailModel.fromJson(json.decode(str));

String competitionSubDetailModelToJson(CompetitionSubDetailModel data) =>
    json.encode(data.toJson());

class CompetitionSubDetailModel {
  final bool? success;
  final String? message;
  final CompetitionSubDetailData? data;
  final dynamic meta;

  CompetitionSubDetailModel({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory CompetitionSubDetailModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CompetitionSubDetailModel();

    return CompetitionSubDetailModel(
      success: json["success"],
      message: json["message"],
      data: json["data"] != null
          ? CompetitionSubDetailData.fromJson(json["data"])
          : null,
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

// 🔥 MAIN DATA MODEL
class CompetitionSubDetailData {
  final String? id;
  final String? name;
  final String? description;
  final String? syllabus;
  final String? bannerImg;

  final Parent? parent;

  final int? price;
  final int? discountedPrice;
  final int? originalPrice;
  final int? effectivePrice;
  final int? discountAmount;

  final bool? isActive;
  final bool? isFree;
  final bool? hasAccess;
  final bool? upgradable;
  final bool? isFreeUpgrade;

  final int? upgradeCost;
  final int? newChildrenCount;

  final String? status;
  final String? rootType;

  final bool? isLeaf;
  final bool? isSecondSubcategory;

  final List<dynamic>? subjects;
  final List<dynamic>? tags;
  final List<dynamic>? linkedSubcategories;

  final AppliedOffer? appliedOffer;
  final GlobalOffer? globalOffer;
  final OverrideOffer? overrideOffer;

  final int? purchaseCount;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  CompetitionSubDetailData({
    this.id,
    this.name,
    this.description,
    this.syllabus,
    this.bannerImg,
    this.parent,
    this.price,
    this.discountedPrice,
    this.originalPrice,
    this.effectivePrice,
    this.discountAmount,
    this.isActive,
    this.isFree,
    this.hasAccess,
    this.upgradable,
    this.isFreeUpgrade,
    this.upgradeCost,
    this.newChildrenCount,
    this.status,
    this.rootType,
    this.isLeaf,
    this.isSecondSubcategory,
    this.subjects,
    this.tags,
    this.linkedSubcategories,
    this.appliedOffer,
    this.globalOffer,
    this.overrideOffer,
    this.purchaseCount,
    this.createdAt,
    this.updatedAt,
  });

  factory CompetitionSubDetailData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CompetitionSubDetailData();

    return CompetitionSubDetailData(
      id: json["_id"],
      name: json["name"],
      description: json["description"],
      syllabus: json["syllabus"],
      bannerImg: json["bannerImg"],
      parent:
          json["parent"] != null ? Parent.fromJson(json["parent"]) : null,
      price: json["price"],
      discountedPrice: json["discountedPrice"],
      originalPrice: json["originalPrice"],
      effectivePrice: json["effectivePrice"],
      discountAmount: json["discountAmount"],
      isActive: json["isActive"],
      isFree: json["isFree"],
      hasAccess: json["hasAccess"],
      upgradable: json["upgradable"],
      isFreeUpgrade: json["isFreeUpgrade"],
      upgradeCost: json["upgradeCost"],
      newChildrenCount: json["newChildrenCount"],
      status: json["status"],
      rootType: json["rootType"],
      isLeaf: json["isLeaf"],
      isSecondSubcategory: json["isSecondSubcategory"],
      subjects: json["subjects"],
      tags: json["tags"],
      linkedSubcategories: json["linkedSubcategories"],
      appliedOffer: json["appliedOffer"] != null
          ? AppliedOffer.fromJson(json["appliedOffer"])
          : null,
      globalOffer: json["globalOffer"] != null
          ? GlobalOffer.fromJson(json["globalOffer"])
          : null,
      overrideOffer: json["overrideOffer"] != null
          ? OverrideOffer.fromJson(json["overrideOffer"])
          : null,
      purchaseCount: json["purchaseCount"],
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.parse(json["updatedAt"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "description": description,
        "syllabus": syllabus,
        "bannerImg": bannerImg,
        "parent": parent?.toJson(),
        "price": price,
        "discountedPrice": discountedPrice,
        "originalPrice": originalPrice,
        "effectivePrice": effectivePrice,
        "discountAmount": discountAmount,
        "isActive": isActive,
        "isFree": isFree,
        "hasAccess": hasAccess,
        "upgradable": upgradable,
        "isFreeUpgrade": isFreeUpgrade,
        "upgradeCost": upgradeCost,
        "newChildrenCount": newChildrenCount,
        "status": status,
        "rootType": rootType,
        "isLeaf": isLeaf,
        "isSecondSubcategory": isSecondSubcategory,
        "subjects": subjects,
        "tags": tags,
        "linkedSubcategories": linkedSubcategories,
        "appliedOffer": appliedOffer?.toJson(),
        "globalOffer": globalOffer?.toJson(),
        "overrideOffer": overrideOffer?.toJson(),
        "purchaseCount": purchaseCount,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

// 🔹 Parent
class Parent {
  final String? id;
  final String? name;
  final int? order;
  final String? kind;
  final bool? hasPurchase;

  Parent({
    this.id,
    this.name,
    this.order,
    this.kind,
    this.hasPurchase,
  });

  factory Parent.fromJson(Map<String, dynamic>? json) {
    return Parent(
      id: json?["_id"],
      name: json?["name"],
      order: json?["order"],
      kind: json?["kind"],
      hasPurchase: json?["hasPurchase"],
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "order": order,
        "kind": kind,
        "hasPurchase": hasPurchase,
      };
}

// 🔹 Applied Offer
class AppliedOffer {
  final String? id;
  final String? offerName;
  final String? discountType;
  final int? discountValue;
  final String? description;
  final DateTime? validTill;

  AppliedOffer({
    this.id,
    this.offerName,
    this.discountType,
    this.discountValue,
    this.description,
    this.validTill,
  });

  factory AppliedOffer.fromJson(Map<String, dynamic>? json) {
    return AppliedOffer(
      id: json?["_id"],
      offerName: json?["offerName"],
      discountType: json?["discountType"],
      discountValue: json?["discountValue"],
      description: json?["description"],
      validTill: json?["validTill"] != null
          ? DateTime.parse(json!["validTill"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "offerName": offerName,
        "discountType": discountType,
        "discountValue": discountValue,
        "description": description,
        "validTill": validTill?.toIso8601String(),
      };
}

// 🔹 Global Offer
class GlobalOffer {
  final String? id;
  final String? offerName;
  final int? discountValue;

  GlobalOffer({
    this.id,
    this.offerName,
    this.discountValue,
  });

  factory GlobalOffer.fromJson(Map<String, dynamic>? json) {
    return GlobalOffer(
      id: json?["_id"],
      offerName: json?["offerName"],
      discountValue: json?["discountValue"],
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "offerName": offerName,
        "discountValue": discountValue,
      };
}

// 🔹 Override Offer
class OverrideOffer {
  final String? id;
  final String? offerName;
  final String? applicableOn;
  final String? entityId;
  final String? entityModel;
  final String? discountType;
  final int? discountValue;
  final String? status;
  final DateTime? validTill;
  final String? description;

  OverrideOffer({
    this.id,
    this.offerName,
    this.applicableOn,
    this.entityId,
    this.entityModel,
    this.discountType,
    this.discountValue,
    this.status,
    this.validTill,
    this.description,
  });

  factory OverrideOffer.fromJson(Map<String, dynamic>? json) {
    if (json == null) return OverrideOffer();

    return OverrideOffer(
      id: json["_id"],
      offerName: json["offerName"],
      applicableOn: json["applicableOn"],
      entityId: json["entityId"],
      entityModel: json["entityModel"],
      discountType: json["discountType"],
      discountValue: json["discountValue"],
      status: json["status"],
      validTill: json["validTill"] != null
          ? DateTime.parse(json["validTill"])
          : null,
      description: json["description"],
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "offerName": offerName,
        "applicableOn": applicableOn,
        "entityId": entityId,
        "entityModel": entityModel,
        "discountType": discountType,
        "discountValue": discountValue,
        "status": status,
        "validTill": validTill?.toIso8601String(),
        "description": description,
      };
}