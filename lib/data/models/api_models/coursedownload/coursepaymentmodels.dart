// lib/data/models/api_models/coursedownload/coursepaymentmodels.dart

class CourseInitiatePaymentRequest {
  final String paymentMethod; // "free" | "wallet" | "razorpay"
  final String? couponCode;

  CourseInitiatePaymentRequest({
    required this.paymentMethod,
    this.couponCode,
  });

  Map<String, dynamic> toJson() => {
        'paymentMethod': paymentMethod,
        if (couponCode != null && couponCode!.isNotEmpty)
          'couponCode': couponCode,
      };
}

// ── Initiate Payment Response ──────────────────────────────────────────────

class CourseInitiatePaymentResponse {
  final bool success;
  final String? message;
  final CourseInitiatePaymentData? data;

  CourseInitiatePaymentResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory CourseInitiatePaymentResponse.fromJson(Map<String, dynamic> json) =>
      CourseInitiatePaymentResponse(
        success: json['success'] ?? false,
        message: json['message'],
        data: json['data'] != null
            ? CourseInitiatePaymentData.fromJson(
                json['data'] as Map<String, dynamic>)
            : null,
      );
}

class CourseInitiatePaymentData {
  // ── Completed purchase (free / wallet) ────────────
  final String? id;
  final String? paymentStatus;
  final String? paymentId;
  final int? purchasePrice;

  // ── Razorpay pending ──────────────────────────────
  final bool? completed; // false = razorpay pending
  final String? orderId;
  final int? amount; // paise
  final String? currency;
  final String? key;
  final String? courseId;
  final String? courseTitle;
  final int? originalPrice;
  final int? discountedPrice;
  final AppliedCoupon? appliedCoupon;

  CourseInitiatePaymentData({
    this.id,
    this.paymentStatus,
    this.paymentId,
    this.purchasePrice,
    this.completed,
    this.orderId,
    this.amount,
    this.currency,
    this.key,
    this.courseId,
    this.courseTitle,
    this.originalPrice,
    this.discountedPrice,
    this.appliedCoupon,
  });

  bool get isCompleted => completed != false && paymentStatus == 'completed';

  factory CourseInitiatePaymentData.fromJson(Map<String, dynamic> json) =>
      CourseInitiatePaymentData(
        id: json['_id'],
        paymentStatus: json['paymentStatus'],
        paymentId: json['paymentId'],
        purchasePrice: json['purchasePrice'],
        completed: json['completed'],
        orderId: json['orderId'],
        amount: json['amount'],
        currency: json['currency'],
        key: json['key'],
        courseId: json['courseId'],
        courseTitle: json['courseTitle'],
        originalPrice: json['originalPrice'],
        discountedPrice: json['discountedPrice'],
        appliedCoupon: json['appliedCoupon'] != null
            ? AppliedCoupon.fromJson(
                json['appliedCoupon'] as Map<String, dynamic>)
            : null,
      );
}

class AppliedCoupon {
  final String? code;
  final int? discount;

  AppliedCoupon({this.code, this.discount});

  factory AppliedCoupon.fromJson(Map<String, dynamic> json) => AppliedCoupon(
        code: json['code'],
        discount: json['discount'],
      );
}

// ── Purchase Response ──────────────────────────────────────────────────────

class CoursePurchaseRequest {
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;

  CoursePurchaseRequest({
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
  });

  Map<String, dynamic> toJson() => {
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
      };
}

class CoursePurchaseResponse {
  final bool success;
  final String? message;

  CoursePurchaseResponse({required this.success, this.message});

  factory CoursePurchaseResponse.fromJson(Map<String, dynamic> json) =>
      CoursePurchaseResponse(
        success: json['success'] ?? false,
        message: json['message'],
      );
}

// ── Payment Method Enum ────────────────────────────────────────────────────

enum CoursePaymentMethod { free, wallet, razorpay }

extension CoursePaymentMethodX on CoursePaymentMethod {
  String get value {
    switch (this) {
      case CoursePaymentMethod.free:
        return 'free';
      case CoursePaymentMethod.wallet:
        return 'wallet';
      case CoursePaymentMethod.razorpay:
        return 'razorpay';
    }
  }
}