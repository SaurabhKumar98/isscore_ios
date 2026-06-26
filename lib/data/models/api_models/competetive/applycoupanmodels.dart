import 'dart:convert';

ApplyCouponModels applyCouponModelsFromJson(String str) =>
    ApplyCouponModels.fromJson(json.decode(str));

String applyCouponModelsToJson(ApplyCouponModels data) =>
    json.encode(data.toJson());

class ApplyCouponModels {
  final bool? success;
  final String? message;
  final CouponData? data;
  final dynamic meta;

  ApplyCouponModels({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory ApplyCouponModels.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ApplyCouponModels();

    return ApplyCouponModels(
      success: json["success"],
      message: json["message"],
      data: json["data"] != null
          ? CouponData.fromJson(json["data"])
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

class CouponData {
  final Coupon? coupon;
  final num? originalPrice;
  final num? discount;
  final num? discountedPrice;

  CouponData({
    this.coupon,
    this.originalPrice,
    this.discount,
    this.discountedPrice,
  });

  factory CouponData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CouponData();

    return CouponData(
      coupon:
          json["coupon"] != null ? Coupon.fromJson(json["coupon"]) : null,
      originalPrice: json["originalPrice"] as num?,
      discount: json["discount"] as num?,
      discountedPrice: json["discountedPrice"] as num?,
    );
  }

  Map<String, dynamic> toJson() => {
        "coupon": coupon?.toJson(),
        "originalPrice": originalPrice,
        "discount": discount,
        "discountedPrice": discountedPrice,
      };
}
class Coupon {
  final String? id;
  final String? code;
  final String? description;
  final String? discountType;
  final int? discountValue;
  final String? applicableTo;
  final DateTime? validFrom;
  final DateTime? validUntil;

  Coupon({
    this.id,
    this.code,
    this.description,
    this.discountType,
    this.discountValue,
    this.applicableTo,
    this.validFrom,
    this.validUntil,
  });

  factory Coupon.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Coupon();

    return Coupon(
      id: json["_id"],
      code: json["code"],
      description: json["description"],
      discountType: json["discountType"],
      discountValue: json["discountValue"],
      applicableTo: json["applicableTo"],
      validFrom: json["validFrom"] != null
          ? DateTime.tryParse(json["validFrom"])
          : null,
      validUntil: json["validUntil"] != null
          ? DateTime.tryParse(json["validUntil"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "code": code,
        "description": description,
        "discountType": discountType,
        "discountValue": discountValue,
        "applicableTo": applicableTo,
        "validFrom": validFrom?.toIso8601String(),
        "validUntil": validUntil?.toIso8601String(),
      };
}