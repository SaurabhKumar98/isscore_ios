import 'dart:convert';

CompetitionModel competitionModelFromJson(String str) =>
    CompetitionModel.fromJson(json.decode(str));

String competitionModelToJson(CompetitionModel data) =>
    json.encode(data.toJson());

class CompetitionModel {
  bool? success;
  String? message;
  List<CompetitionData>? competitionList;
  dynamic meta;

  CompetitionModel({
    this.success,
    this.message,
    this.competitionList,
    this.meta,
  });

  factory CompetitionModel.fromJson(Map<String, dynamic>? json) =>
      CompetitionModel(
        success: json?["success"],
        message: json?["message"],
        competitionList: json?["data"] == null
            ? []
            : List<CompetitionData>.from(
                json?["data"].map((x) => CompetitionData.fromJson(x))),
        meta: json?["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": competitionList?.map((x) => x.toJson()).toList(),
        "meta": meta,
      };
}

// ─────────────────────────────────────────────────────────────────────────────

class CompetitionData {
  String? id;
  String? name;
  dynamic parent;
  int? order;
  bool? isActive;
  String? createdBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  bool? isPredefined;
  String? rootType;
  List<CompetitionChild>? children;

  CompetitionData({
    this.id,
    this.name,
    this.parent,
    this.order,
    this.isActive,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.isPredefined,
    this.rootType,
    this.children,
  });

  factory CompetitionData.fromJson(Map<String, dynamic>? json) =>
      CompetitionData(
        id: json?["_id"],
        name: json?["name"],
        parent: json?["parent"],
        order: json?["order"],
        isActive: json?["isActive"],
        createdBy: json?["createdBy"],
        createdAt: DateTime.tryParse(json?["createdAt"] ?? ""),
        updatedAt: DateTime.tryParse(json?["updatedAt"] ?? ""),
        v: json?["__v"],
        isPredefined: json?["isPredefined"],
        rootType: json?["rootType"],
        children: json?["children"] == null
            ? []
            : List<CompetitionChild>.from(
                json?["children"].map((x) => CompetitionChild.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "parent": parent,
        "order": order,
        "isActive": isActive,
        "createdBy": createdBy,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "isPredefined": isPredefined,
        "rootType": rootType,
        "children": children?.map((x) => x.toJson()).toList(),
      };
}

// ─────────────────────────────────────────────────────────────────────────────

class CompetitionChild {
  // ── Core identity ──────────────────────────────────────────────────────────
  String? id;
  String? name;
  String? slug;
  String? kind;
  String? rootType;
  String? status;
  bool? isActive;
  bool? isPredefined;
  int? order;
  String? createdBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  // ── Relations ──────────────────────────────────────────────────────────────
  CompetitionParent? parent;
  List<CompetitionChild>? children;

  // ── Content ────────────────────────────────────────────────────────────────
  String? bannerImg;
  String? description;
  String? about;
  String? syllabus;
  String? markingScheme;
  String? rankingCriteria;
  String? examDatesAndDetails;
  String? awards;
  String? rules;

  // ── Meta ───────────────────────────────────────────────────────────────────
  List<dynamic>? subjects;
  List<dynamic>? tags;
  dynamic capacity;
  int? purchaseCount;
  int? childCount;
  bool? isLeaf;
  bool? isSecondSubcategory;

  // ── Policies ───────────────────────────────────────────────────────────────
  String? offerPolicy;
  String? couponPolicy;
  String? offerOverrideId;

  // ── Pricing ────────────────────────────────────────────────────────────────
  int? price;
  int? discountedPrice;
  bool? isFree;
  int? originalPrice;
  int? effectivePrice;
  int? discountAmount;
  int? currentPrice;       // current price at time of API call
  CompetitionOffer? appliedOffer;

  // ── Access & Purchase state ────────────────────────────────────────────────
  bool? hasAccess;         // true = already purchased
  CompetitionPurchase? purchase;
  int? paidSoFar;          // total amount paid so far
  String? purchaseDate;    // ISO date string of original purchase

  // ── Upgrade state ──────────────────────────────────────────────────────────
  bool? upgradable;        // true = new sub-categories added, upgrade available
  int? upgradeCost;        // amount to pay for upgrade (0 if isFreeUpgrade)
  bool? isFreeUpgrade;     // true = upgrade is free
  List<dynamic>? newCategoryIds; // IDs of newly added categories on upgrade

  CompetitionChild({
    this.id,
    this.name,
    this.slug,
    this.kind,
    this.rootType,
    this.status,
    this.isActive,
    this.isPredefined,
    this.order,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.parent,
    this.children,
    this.bannerImg,
    this.description,
    this.about,
    this.syllabus,
    this.markingScheme,
    this.rankingCriteria,
    this.examDatesAndDetails,
    this.awards,
    this.rules,
    this.subjects,
    this.tags,
    this.capacity,
    this.purchaseCount,
    this.childCount,
    this.isLeaf,
    this.isSecondSubcategory,
    this.offerPolicy,
    this.couponPolicy,
    this.offerOverrideId,
    this.price,
    this.discountedPrice,
    this.isFree,
    this.originalPrice,
    this.effectivePrice,
    this.discountAmount,
    this.currentPrice,
    this.appliedOffer,
    this.hasAccess,
    this.purchase,
    this.paidSoFar,
    this.purchaseDate,
    this.upgradable,
    this.upgradeCost,
    this.isFreeUpgrade,
    this.newCategoryIds,
  });

  factory CompetitionChild.fromJson(Map<String, dynamic>? json) =>
      CompetitionChild(
        // Core identity
        id: json?["_id"],
        name: json?["name"],
        slug: json?["slug"],
        kind: json?["kind"],
        rootType: json?["rootType"],
        status: json?["status"],
        isActive: json?["isActive"],
        isPredefined: json?["isPredefined"],
        order: json?["order"],
        createdBy: json?["createdBy"],
        createdAt: DateTime.tryParse(json?["createdAt"] ?? ""),
        updatedAt: DateTime.tryParse(json?["updatedAt"] ?? ""),
        v: json?["__v"],

        // Relations
        parent: json?["parent"] == null
            ? null
            : CompetitionParent.fromJson(json?["parent"]),
        children: json?["children"] == null
            ? []
            : List<CompetitionChild>.from(
                json?["children"].map((x) => CompetitionChild.fromJson(x))),

        // Content
        bannerImg: json?["bannerImg"],
        description: json?["description"],
        about: json?["about"],
        syllabus: json?["syllabus"],
        markingScheme: json?["markingScheme"],
        rankingCriteria: json?["rankingCriteria"],
        examDatesAndDetails: json?["examDatesAndDetails"],
        awards: json?["awards"],
        rules: json?["rules"],

        // Meta
        subjects: json?["subjects"] == null
            ? []
            : List<dynamic>.from(json?["subjects"]),
        tags: json?["tags"] == null
            ? []
            : List<dynamic>.from(json?["tags"]),
        capacity: json?["capacity"],
        purchaseCount: json?["purchaseCount"],
        childCount: json?["childCount"],
        isLeaf: json?["isLeaf"],
        isSecondSubcategory: json?["isSecondSubcategory"],

        // Policies
        offerPolicy: json?["offerPolicy"],
        couponPolicy: json?["couponPolicy"],
        offerOverrideId: json?["offerOverrideId"],

        // Pricing
        price: json?["price"],
        discountedPrice: json?["discountedPrice"],
        isFree: json?["isFree"],
        originalPrice: json?["originalPrice"],
        effectivePrice: json?["effectivePrice"],
        discountAmount: json?["discountAmount"],
        currentPrice: json?["currentPrice"],
        appliedOffer: json?["appliedOffer"] == null
            ? null
            : CompetitionOffer.fromJson(json?["appliedOffer"]),

        // Access & Purchase state
        hasAccess: json?["hasAccess"],
        purchase: json?["purchase"] == null
            ? null
            : CompetitionPurchase.fromJson(json?["purchase"]),
        paidSoFar: json?["paidSoFar"],
        purchaseDate: json?["purchaseDate"],

        // Upgrade state
        upgradable: json?["upgradable"],
        upgradeCost: json?["upgradeCost"],
        isFreeUpgrade: json?["isFreeUpgrade"],
        newCategoryIds: json?["newCategoryIds"] == null
            ? []
            : List<dynamic>.from(json?["newCategoryIds"]),
      );

  Map<String, dynamic> toJson() => {
        // Core identity
        "_id": id,
        "name": name,
        "slug": slug,
        "kind": kind,
        "rootType": rootType,
        "status": status,
        "isActive": isActive,
        "isPredefined": isPredefined,
        "order": order,
        "createdBy": createdBy,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,

        // Relations
        "parent": parent?.toJson(),
        "children": children?.map((x) => x.toJson()).toList(),

        // Content
        "bannerImg": bannerImg,
        "description": description,
        "about": about,
        "syllabus": syllabus,
        "markingScheme": markingScheme,
        "rankingCriteria": rankingCriteria,
        "examDatesAndDetails": examDatesAndDetails,
        "awards": awards,
        "rules": rules,

        // Meta
        "subjects": subjects,
        "tags": tags,
        "capacity": capacity,
        "purchaseCount": purchaseCount,
        "childCount": childCount,
        "isLeaf": isLeaf,
        "isSecondSubcategory": isSecondSubcategory,

        // Policies
        "offerPolicy": offerPolicy,
        "couponPolicy": couponPolicy,
        "offerOverrideId": offerOverrideId,

        // Pricing
        "price": price,
        "discountedPrice": discountedPrice,
        "isFree": isFree,
        "originalPrice": originalPrice,
        "effectivePrice": effectivePrice,
        "discountAmount": discountAmount,
        "currentPrice": currentPrice,
        "appliedOffer": appliedOffer?.toJson(),

        // Access & Purchase state
        "hasAccess": hasAccess,
        "purchase": purchase?.toJson(),
        "paidSoFar": paidSoFar,
        "purchaseDate": purchaseDate,

        // Upgrade state
        "upgradable": upgradable,
        "upgradeCost": upgradeCost,
        "isFreeUpgrade": isFreeUpgrade,
        "newCategoryIds": newCategoryIds,
      };
}

// ─────────────────────────────────────────────────────────────────────────────

class CompetitionOffer {
  String? id;
  String? offerName;
  String? applicableOn;
  String? discountType;
  int? discountValue;
  String? description;
  DateTime? validTill;

  CompetitionOffer({
    this.id,
    this.offerName,
    this.applicableOn,
    this.discountType,
    this.discountValue,
    this.description,
    this.validTill,
  });

  factory CompetitionOffer.fromJson(Map<String, dynamic>? json) =>
      CompetitionOffer(
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

// ─────────────────────────────────────────────────────────────────────────────

class CompetitionPurchase {
  String? id;
  String? student;
  String? categoryId;
  String? pillarType;
  List<dynamic>? unlockedCategoryIds;
  int? purchasePrice;
  String? paymentMethod;
  String? paymentId;
  String? paymentStatus;
  DateTime? lastUpgradedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  CompetitionPurchase({
    this.id,
    this.student,
    this.categoryId,
    this.pillarType,
    this.unlockedCategoryIds,
    this.purchasePrice,
    this.paymentMethod,
    this.paymentId,
    this.paymentStatus,
    this.lastUpgradedAt,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory CompetitionPurchase.fromJson(Map<String, dynamic>? json) =>
      CompetitionPurchase(
        id: json?["_id"],
        student: json?["student"],
        categoryId: json?["categoryId"],
        pillarType: json?["pillarType"],
        unlockedCategoryIds: json?["unlockedCategoryIds"] == null
            ? []
            : List<dynamic>.from(json?["unlockedCategoryIds"]),
        purchasePrice: json?["purchasePrice"],
        paymentMethod: json?["paymentMethod"],
        paymentId: json?["paymentId"],
        paymentStatus: json?["paymentStatus"],
        lastUpgradedAt: DateTime.tryParse(json?["lastUpgradedAt"] ?? ""),
        createdAt: DateTime.tryParse(json?["createdAt"] ?? ""),
        updatedAt: DateTime.tryParse(json?["updatedAt"] ?? ""),
        v: json?["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "student": student,
        "categoryId": categoryId,
        "pillarType": pillarType,
        "unlockedCategoryIds": unlockedCategoryIds,
        "purchasePrice": purchasePrice,
        "paymentMethod": paymentMethod,
        "paymentId": paymentId,
        "paymentStatus": paymentStatus,
        "lastUpgradedAt": lastUpgradedAt?.toIso8601String(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

// ─────────────────────────────────────────────────────────────────────────────

class CompetitionParent {
  String? id;
  String? name;
  int? order;
  String? kind;

  CompetitionParent({
    this.id,
    this.name,
    this.order,
    this.kind,
  });

  factory CompetitionParent.fromJson(Map<String, dynamic>? json) =>
      CompetitionParent(
        id: json?["_id"],
        name: json?["name"],
        order: json?["order"],
        kind: json?["kind"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "order": order,
        "kind": kind,
      };
}