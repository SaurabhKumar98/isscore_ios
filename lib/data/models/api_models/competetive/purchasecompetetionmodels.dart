import 'dart:convert';

PurchaseCompetetionModels purchaseCompetetionModelsFromJson(String str) =>
    PurchaseCompetetionModels.fromJson(json.decode(str));

String purchaseCompetetionModelsToJson(PurchaseCompetetionModels data) =>
    json.encode(data.toJson());

class PurchaseCompetetionModels {
  final bool? success;
  final String? message;
  final PurchaseData? data;
  final dynamic meta;

  PurchaseCompetetionModels({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory PurchaseCompetetionModels.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PurchaseCompetetionModels();

    return PurchaseCompetetionModels(
      success: json["success"],
      message: json["message"],
      data: json["data"] != null
          ? PurchaseData.fromJson(json["data"])
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

class PurchaseData {
  final bool? completed;
  final String? orderId;
  final int? amount;
  final String? currency;
  final String? key;
  final String? categoryId;
  final String? title;

  final AppliedOffer? appliedOffer;
  final dynamic appliedCoupon;

  final int? originalPrice;
  final int? discountedPrice;

  PurchaseData({
    this.completed,
    this.orderId,
    this.amount,
    this.currency,
    this.key,
    this.categoryId,
    this.title,
    this.appliedOffer,
    this.appliedCoupon,
    this.originalPrice,
    this.discountedPrice,
  });

  factory PurchaseData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PurchaseData();

    return PurchaseData(
      completed: json["completed"],
      orderId: json["orderId"],
      amount: json["amount"],
      currency: json["currency"],
      key: json["key"],
      categoryId: json["categoryId"],
      title: json["title"],
      appliedOffer: json["appliedOffer"] != null
          ? AppliedOffer.fromJson(json["appliedOffer"])
          : null,
      appliedCoupon: json["appliedCoupon"],
      originalPrice: json["originalPrice"],
      discountedPrice: json["discountedPrice"],
    );
  }

  Map<String, dynamic> toJson() => {
        "completed": completed,
        "orderId": orderId,
        "amount": amount,
        "currency": currency,
        "key": key,
        "categoryId": categoryId,
        "title": title,
        "appliedOffer": appliedOffer?.toJson(),
        "appliedCoupon": appliedCoupon,
        "originalPrice": originalPrice,
        "discountedPrice": discountedPrice,
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
      id: json["_id"],
      offerName: json["offerName"],
      applicableOn: json["applicableOn"],
      discountType: json["discountType"],
      discountValue: json["discountValue"],
      description: json["description"],
      validTill: json["validTill"] != null
          ? DateTime.tryParse(json["validTill"])
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