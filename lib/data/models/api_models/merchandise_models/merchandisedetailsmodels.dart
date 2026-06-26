import 'dart:convert';
import 'package:firstedu/data/models/api_models/merchandise_models/merchandisemodels.dart';

MerchandiseDetailsModels merchandiseDetailsModelsFromJson(String str) =>
    MerchandiseDetailsModels.fromJson(json.decode(str) ?? {});

String merchandiseDetailsModelsToJson(MerchandiseDetailsModels data) =>
    json.encode(data.toJson());

class MerchandiseDetailsModels {
  final bool success;
  final String message;
  final MerchandiseDetail? data;
  final dynamic meta;

  MerchandiseDetailsModels({
    required this.success,
    required this.message,
    this.data,
    this.meta,
  });

  factory MerchandiseDetailsModels.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return MerchandiseDetailsModels(success: false, message: '', data: null);
    }
    return MerchandiseDetailsModels(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? MerchandiseDetail.fromJson(json['data'])
          : null,
      meta: json['meta'],
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.toJson(),
        'meta': meta,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// MerchandiseDetail  — identical fields to MerchandiseItem (same API shape)
// ─────────────────────────────────────────────────────────────────────────────
class MerchandiseDetail {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int pointsRequired;
  final int price;
  final int discountedPrice; // ← ADD
  final int originalPrice;   // ← ADD
  final String category;
  final bool isPhysical;
  final bool isActive;
  final int stockQuantity;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MerchandiseDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.pointsRequired,
    required this.price,
    required this.discountedPrice, // ← ADD
    required this.originalPrice,   // ← ADD
    required this.category,
    required this.isPhysical,
    required this.isActive,
    required this.stockQuantity,
    this.createdAt,
    this.updatedAt,
  });

factory MerchandiseDetail.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return MerchandiseDetail(
        id: '', name: '', description: '', imageUrl: '',
        pointsRequired: 0, price: 0,
        discountedPrice: 0, // ← ADD
        originalPrice: 0,   // ← ADD
        category: '', isPhysical: false, isActive: false, stockQuantity: 0,
      );
    }
    final rawPrice = (json['price'] ?? 0).toInt();
    return MerchandiseDetail(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      pointsRequired: (json['pointsRequired'] ?? 0).toInt(),
      price: rawPrice,
      discountedPrice: (json['discountedPrice'] ?? 0).toInt(), // ← ADD
      originalPrice: (json['originalPrice'] ?? rawPrice).toInt(), // ← ADD
      category: json['category'] ?? '',
      isPhysical: json['isPhysical'] ?? false,
      isActive: json['isActive'] ?? true,
      stockQuantity: (json['stockQuantity'] ?? 0).toInt(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? ''),
    );
  }
Map<String, dynamic> toJson() => {
  '_id': id,
  'name': name,
  'description': description,
  'imageUrl': imageUrl,
  'pointsRequired': pointsRequired,
  'price': price,
  'discountedPrice': discountedPrice,
  'originalPrice': originalPrice,
  'category': category,
  'isPhysical': isPhysical,
  'isActive': isActive,
  'stockQuantity': stockQuantity,
  'createdAt': createdAt?.toIso8601String(),
  'updatedAt': updatedAt?.toIso8601String(),
};
  // Helper: convert to lightweight MerchandiseItem for card/list display
 MerchandiseItem toItem() => MerchandiseItem(
        id: id,
        name: name,
        description: description,
        imageUrl: imageUrl,
        pointsRequired: pointsRequired,
        price: price,
        discountedPrice: discountedPrice, // ← ADD
        originalPrice: originalPrice,     // ← ADD
        category: category,
        isPhysical: isPhysical,
        isActive: isActive,
        stockQuantity: stockQuantity,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Initiate-payment response  (wallet / razorpay / free)
// ─────────────────────────────────────────────────────────────────────────────
class MerchandiseInitiatePaymentModels {
  final bool success;
  final String message;
  final MerchandisePaymentData? data;

  MerchandiseInitiatePaymentModels({
    required this.success,
    required this.message,
    this.data,
  });

  factory MerchandiseInitiatePaymentModels.fromJson(
      Map<String, dynamic>? json) {
    if (json == null) {
      return MerchandiseInitiatePaymentModels(
          success: false, message: '', data: null);
    }
    return MerchandiseInitiatePaymentModels(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? MerchandisePaymentData.fromJson(json['data'])
          : null,
    );
  }
}

class MerchandisePaymentData {
  /// true  → payment is done (wallet/free); no gateway step needed
  final bool completed;

  // Razorpay fields (only present when completed == false)
  final String? orderId;
  final int? amount; // in paise
  final String? currency;
  final String? key;
  final String? itemId;
  final String? title;
  final int? originalPrice;
  final int? discountedPrice;

  MerchandisePaymentData({
    required this.completed,
    this.orderId,
    this.amount,
    this.currency,
    this.key,
    this.itemId,
    this.title,
    this.originalPrice,
    this.discountedPrice,
  });

  factory MerchandisePaymentData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MerchandisePaymentData(completed: true);
    return MerchandisePaymentData(
      completed: json['completed'] ?? true,
      orderId: json['orderId'],
      amount: json['amount'] != null ? (json['amount'] as num).toInt() : null,
      currency: json['currency'],
      key: json['key'],
      itemId: json['itemId'],
      title: json['title'],
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice'] as num).toInt()
          : null,
      discountedPrice: json['discountedPrice'] != null
          ? (json['discountedPrice'] as num).toInt()
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Coupon apply response
// ─────────────────────────────────────────────────────────────────────────────
class MerchandiseApplyCouponModels {
  final bool success;
  final String message;
  final MerchandiseCouponData? data;

  MerchandiseApplyCouponModels({
    required this.success,
    required this.message,
    this.data,
  });

  factory MerchandiseApplyCouponModels.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return MerchandiseApplyCouponModels(
          success: false, message: '', data: null);
    }
    return MerchandiseApplyCouponModels(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? MerchandiseCouponData.fromJson(json['data'])
          : null,
    );
  }
}

// REPLACE the entire MerchandiseCouponData class:
class MerchandiseCouponData {
  final String couponCode;
  final int discountValue;
  final String discountType;
  final int originalAmount;
  final int discountAmount;
  final int finalAmount;

  MerchandiseCouponData({
    required this.couponCode,
    required this.discountValue,
    required this.discountType,
    required this.originalAmount,
    required this.discountAmount,
    required this.finalAmount,
  });

  factory MerchandiseCouponData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return MerchandiseCouponData(
        couponCode: '', discountValue: 0, discountType: '',
        originalAmount: 0, discountAmount: 0, finalAmount: 0,
      );
    }

    // API wraps data under a 'coupon' key:
    // { coupon: { code, discountType, discountValue }, 
    //   originalPrice, discount, discountedPrice }
    final couponObj = json['coupon'] as Map<String, dynamic>? ?? {};

    return MerchandiseCouponData(
      couponCode:    couponObj['code']          ?? json['couponCode']     ?? '',
      discountValue: (couponObj['discountValue'] ?? json['discountValue'] ?? 0).toInt(),
      discountType:  couponObj['discountType']   ?? json['discountType']  ?? '',
      originalAmount:(json['originalPrice']      ?? json['originalAmount']?? 0).toInt(),
      discountAmount:(json['discount']           ?? json['discountAmount']?? 0).toInt(),
      finalAmount:   (json['discountedPrice']    ?? json['finalAmount']   ?? 0).toInt(),
    );
  }
}