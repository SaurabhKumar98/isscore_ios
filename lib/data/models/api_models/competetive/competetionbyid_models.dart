import 'dart:convert';

CompetationDetailModels competationDetailModelsFromJson(String str) =>
    CompetationDetailModels.fromJson(json.decode(str));

String competationDetailModelsToJson(CompetationDetailModels data) =>
    json.encode(data.toJson());

class CompetationDetailModels {
  bool? success;
  String? message;
  CompetationDetailData? data;
  dynamic meta;

  CompetationDetailModels({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory CompetationDetailModels.fromJson(Map<String, dynamic>? json) =>
      CompetationDetailModels(
        success: json?["success"],
        message: json?["message"],
        data: json?["data"] == null
            ? null
            : CompetationDetailData.fromJson(json?["data"]),
        meta: json?["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
        "meta": meta,
      };
}

// ─────────────────────────────────────────────────────────────
// ROOT DATA
// ─────────────────────────────────────────────────────────────

class CompetationDetailData {
  Node? node;
  List<Child>? children;
  List<Breadcrumb>? breadcrumb;

  CompetationDetailData({
    this.node,
    this.children,
    this.breadcrumb,
  });

  factory CompetationDetailData.fromJson(Map<String, dynamic>? json) =>
      CompetationDetailData(
        node: json?["node"] == null ? null : Node.fromJson(json?["node"]),
        children: json?["children"] == null
            ? []
            : List<Child>.from(
                json?["children"].map((x) => Child.fromJson(x))),
        breadcrumb: json?["breadcrumb"] == null
            ? []
            : List<Breadcrumb>.from(
                json?["breadcrumb"].map((x) => Breadcrumb.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "node": node?.toJson(),
        "children": children?.map((x) => x.toJson()).toList(),
        "breadcrumb": breadcrumb?.map((x) => x.toJson()).toList(),
      };
}

// ─────────────────────────────────────────────────────────────
// BREADCRUMB
// ─────────────────────────────────────────────────────────────

class Breadcrumb {
  String? id;
  String? name;
  String? slug;

  Breadcrumb({this.id, this.name, this.slug});

  factory Breadcrumb.fromJson(Map<String, dynamic>? json) => Breadcrumb(
        id: json?["_id"],
        name: json?["name"],
        slug: json?["slug"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "slug": slug,
      };
}

// ─────────────────────────────────────────────────────────────
// CHILD  (sub-category bundle card)
// ─────────────────────────────────────────────────────────────

class Child {
  // ── Core identity ──────────────────────────────────────────
  final String? id;
  final String? name;
  final String? slug;
  final String? kind;
  final String? rootType;
  final String? status;
  final bool? isActive;
  final bool? isPredefined;
  final int? order;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ── Content ────────────────────────────────────────────────
  final String? bannerImg;
  final String? description;
  final String? about;
  final String? syllabus;
  final String? markingScheme;
  final String? rankingCriteria;
  final String? examDatesAndDetails;
  final String? awards;
  final String? rules;

  // ── Relations ──────────────────────────────────────────────
  final Parent? parent;

  // ── Meta ───────────────────────────────────────────────────
  final List<dynamic>? subjects;
  final List<dynamic>? tags;
  final dynamic capacity;
  final int? purchaseCount;
  final int? childCount;
  final bool? isLeaf;
  final bool? isSecondSubcategory;

  // ── Policies ───────────────────────────────────────────────
  final String? offerPolicy;
  final String? couponPolicy;
  final String? offerOverrideId;

  // ── Pricing ────────────────────────────────────────────────
  final int? price;
  final int? discountedPrice;
  final bool? isFree;
  final int? originalPrice;
  final int? effectivePrice;
  final int? discountAmount;
  final int? currentPrice;
  final AppliedOffer? appliedOffer;

  // ── Access & Purchase ──────────────────────────────────────
  final bool? hasAccess;
  final Purchase? purchase;
  final int? paidSoFar;
  final DateTime? purchaseDate;

  // ── Upgrade ────────────────────────────────────────────────
  final bool? upgradable;
  final int? upgradeCost;
  final bool? isFreeUpgrade;
  final List<dynamic>? newCategoryIds;

  Child({
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
    this.bannerImg,
    this.description,
    this.about,
    this.syllabus,
    this.markingScheme,
    this.rankingCriteria,
    this.examDatesAndDetails,
    this.awards,
    this.rules,
    this.parent,
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

  factory Child.fromJson(Map<String, dynamic>? json) => Child(
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
        bannerImg: json?["bannerImg"],
        description: json?["description"],
        about: json?["about"],
        syllabus: json?["syllabus"],
        markingScheme: json?["markingScheme"],
        rankingCriteria: json?["rankingCriteria"],
        examDatesAndDetails: json?["examDatesAndDetails"],
        awards: json?["awards"],
        rules: json?["rules"],
        parent: json?["parent"] == null
            ? null
            : Parent.fromJson(json?["parent"]),
        subjects: json?["subjects"] == null
            ? []
            : List<dynamic>.from(json?["subjects"]),
        tags: json?["tags"] == null ? [] : List<dynamic>.from(json?["tags"]),
        capacity: json?["capacity"],
        purchaseCount: json?["purchaseCount"],
        childCount: json?["childCount"],
        isLeaf: json?["isLeaf"],
        isSecondSubcategory: json?["isSecondSubcategory"],
        offerPolicy: json?["offerPolicy"],
        couponPolicy: json?["couponPolicy"],
        offerOverrideId: json?["offerOverrideId"],
        price: json?["price"],
        discountedPrice: json?["discountedPrice"],
        isFree: json?["isFree"],
        originalPrice: json?["originalPrice"],
        effectivePrice: json?["effectivePrice"],
        discountAmount: json?["discountAmount"],
        currentPrice: json?["currentPrice"],
        appliedOffer: json?["appliedOffer"] == null
            ? null
            : AppliedOffer.fromJson(json?["appliedOffer"]),
        hasAccess: json?["hasAccess"],
        purchase: json?["purchase"] == null
            ? null
            : Purchase.fromJson(json?["purchase"]),
        paidSoFar: json?["paidSoFar"],
        purchaseDate: json?["purchaseDate"] == null
            ? null
            : DateTime.tryParse(json?["purchaseDate"]),
        upgradable: json?["upgradable"],
        upgradeCost: json?["upgradeCost"],
        isFreeUpgrade: json?["isFreeUpgrade"],
        newCategoryIds: json?["newCategoryIds"] == null
            ? []
            : List<dynamic>.from(json?["newCategoryIds"]),
      );

  Map<String, dynamic> toJson() => {
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
        "bannerImg": bannerImg,
        "description": description,
        "about": about,
        "syllabus": syllabus,
        "markingScheme": markingScheme,
        "rankingCriteria": rankingCriteria,
        "examDatesAndDetails": examDatesAndDetails,
        "awards": awards,
        "rules": rules,
        "parent": parent?.toJson(),
        "subjects": subjects,
        "tags": tags,
        "capacity": capacity,
        "purchaseCount": purchaseCount,
        "childCount": childCount,
        "isLeaf": isLeaf,
        "isSecondSubcategory": isSecondSubcategory,
        "offerPolicy": offerPolicy,
        "couponPolicy": couponPolicy,
        "offerOverrideId": offerOverrideId,
        "price": price,
        "discountedPrice": discountedPrice,
        "isFree": isFree,
        "originalPrice": originalPrice,
        "effectivePrice": effectivePrice,
        "discountAmount": discountAmount,
        "currentPrice": currentPrice,
        "appliedOffer": appliedOffer?.toJson(),
        "hasAccess": hasAccess,
        "purchase": purchase?.toJson(),
        "paidSoFar": paidSoFar,
        "purchaseDate": purchaseDate?.toIso8601String(),
        "upgradable": upgradable,
        "upgradeCost": upgradeCost,
        "isFreeUpgrade": isFreeUpgrade,
        "newCategoryIds": newCategoryIds,
      };
}

// ─────────────────────────────────────────────────────────────
// NODE  (current category header)
// ─────────────────────────────────────────────────────────────

class Node {
  final String? id;
  final String? name;
  final String? slug;
  final String? kind;
  final String? rootType;
  final String? status;
  final bool? isActive;
  final String? bannerImg;
  final String? description;
  final String? syllabus;

  // ── Pricing ────────────────────────────────────────────────
  final int? price;
  final int? originalPrice;
  final int? discountedPrice;
  final int? effectivePrice;
  final int? discountAmount;
  final bool? isFree;

  // ── Access & Purchase ──────────────────────────────────────
  final bool? hasAccess;
  final Purchase? purchase;
  final int? paidSoFar;
  final int? currentPrice;
  final DateTime? purchaseDate;

  // ── Upgrade ────────────────────────────────────────────────
  final bool? upgradable;
  final int? upgradeCost;
  final bool? isFreeUpgrade;
  final List<dynamic>? newCategoryIds;

  // ── Offer ──────────────────────────────────────────────────
  final AppliedOffer? appliedOffer;

  Node({
    this.id,
    this.name,
    this.slug,
    this.kind,
    this.rootType,
    this.status,
    this.isActive,
    this.bannerImg,
    this.description,
    this.syllabus,
    this.price,
    this.originalPrice,
    this.discountedPrice,
    this.effectivePrice,
    this.discountAmount,
    this.isFree,
    this.hasAccess,
    this.purchase,
    this.paidSoFar,
    this.currentPrice,
    this.purchaseDate,
    this.upgradable,
    this.upgradeCost,
    this.isFreeUpgrade,
    this.newCategoryIds,
    this.appliedOffer,
  });

  factory Node.fromJson(Map<String, dynamic>? json) => Node(
        id: json?["_id"],
        name: json?["name"],
        slug: json?["slug"],
        kind: json?["kind"],
        rootType: json?["rootType"],
        status: json?["status"],
        isActive: json?["isActive"],
        bannerImg: json?["bannerImg"],
        description: json?["description"],
        syllabus: json?["syllabus"],
        price: json?["price"],
        originalPrice: json?["originalPrice"],
        discountedPrice: json?["discountedPrice"],
        effectivePrice: json?["effectivePrice"],
        discountAmount: json?["discountAmount"],
        isFree: json?["isFree"],
        hasAccess: json?["hasAccess"],
        purchase: json?["purchase"] == null
            ? null
            : Purchase.fromJson(json?["purchase"]),
        paidSoFar: json?["paidSoFar"],
        currentPrice: json?["currentPrice"],
        purchaseDate: json?["purchaseDate"] == null
            ? null
            : DateTime.tryParse(json?["purchaseDate"]),
        upgradable: json?["upgradable"],
        upgradeCost: json?["upgradeCost"],
        isFreeUpgrade: json?["isFreeUpgrade"],
        newCategoryIds: json?["newCategoryIds"] == null
            ? []
            : List<dynamic>.from(json?["newCategoryIds"]),
        appliedOffer: json?["appliedOffer"] == null
            ? null
            : AppliedOffer.fromJson(json?["appliedOffer"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "slug": slug,
        "kind": kind,
        "rootType": rootType,
        "status": status,
        "isActive": isActive,
        "bannerImg": bannerImg,
        "description": description,
        "syllabus": syllabus,
        "price": price,
        "originalPrice": originalPrice,
        "discountedPrice": discountedPrice,
        "effectivePrice": effectivePrice,
        "discountAmount": discountAmount,
        "isFree": isFree,
        "hasAccess": hasAccess,
        "purchase": purchase?.toJson(),
        "paidSoFar": paidSoFar,
        "currentPrice": currentPrice,
        "purchaseDate": purchaseDate?.toIso8601String(),
        "upgradable": upgradable,
        "upgradeCost": upgradeCost,
        "isFreeUpgrade": isFreeUpgrade,
        "newCategoryIds": newCategoryIds,
        "appliedOffer": appliedOffer?.toJson(),
      };
}

// ─────────────────────────────────────────────────────────────
// PARENT
// ─────────────────────────────────────────────────────────────

class Parent {
  final String? id;
  final String? name;
  final int? order;
  final String? kind;

  Parent({this.id, this.name, this.order, this.kind});

  factory Parent.fromJson(Map<String, dynamic>? json) => Parent(
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

// ─────────────────────────────────────────────────────────────
// APPLIED OFFER
// ─────────────────────────────────────────────────────────────

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

  factory AppliedOffer.fromJson(Map<String, dynamic>? json) => AppliedOffer(
        id: json?["_id"],
        offerName: json?["offerName"],
        applicableOn: json?["applicableOn"],
        discountType: json?["discountType"],
        discountValue: json?["discountValue"],
        description: json?["description"],
        validTill: json?["validTill"] == null
            ? null
            : DateTime.tryParse(json?["validTill"]),
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

// ─────────────────────────────────────────────────────────────
// PURCHASE
// ─────────────────────────────────────────────────────────────

class Purchase {
  final String? id;
  final String? student;
  final String? categoryId;
  final String? pillarType;
  final List<dynamic>? unlockedCategoryIds;
  final int? purchasePrice;
  final String? paymentMethod;
  final String? paymentId;
  final String? paymentStatus;
  final DateTime? lastUpgradedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Purchase({
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
  });

  factory Purchase.fromJson(Map<String, dynamic>? json) => Purchase(
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
        lastUpgradedAt: json?["lastUpgradedAt"] == null
            ? null
            : DateTime.tryParse(json?["lastUpgradedAt"]),
        createdAt: json?["createdAt"] == null
            ? null
            : DateTime.tryParse(json?["createdAt"]),
        updatedAt: json?["updatedAt"] == null
            ? null
            : DateTime.tryParse(json?["updatedAt"]),
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
      };
}