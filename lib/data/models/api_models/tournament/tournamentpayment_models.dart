// lib/data/models/api_models/tournament/tournament_payment_models.dart

int? _toIntOrNull(dynamic v) => v == null ? null : (v as num).toInt();
int _toInt(dynamic v, [int fallback = 0]) =>
    v == null ? fallback : (v as num).toInt();

class TournamentInitiatePaymentRequest {
  final String paymentMethod;
  final String? couponCode;

  TournamentInitiatePaymentRequest({
    required this.paymentMethod,
    this.couponCode,
  });

  Map<String, dynamic> toJson() => {
    'paymentMethod': paymentMethod,
    if (couponCode != null && couponCode!.isNotEmpty) 'couponCode': couponCode,
  };
}

class TournamentInitiatePaymentResponse {
  final bool success;
  final String? message;
  final TournamentInitiatePaymentData? data;

  TournamentInitiatePaymentResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory TournamentInitiatePaymentResponse.fromJson(
    Map<String, dynamic> json,
  ) => TournamentInitiatePaymentResponse(
    success: json['success'] ?? false,
    message: json['message'],
    data: json['data'] != null
        ? TournamentInitiatePaymentData.fromJson(
            json['data'] as Map<String, dynamic>,
          )
        : null,
  );
}

class TournamentInitiatePaymentData {
  // completed immediately (free / wallet)
  final String? id;
  final String? paymentStatus;
  final String? eventType;
  final String? eventId;

  // razorpay pending
  final bool? completed;
  final String? orderId;
  final int? amount; // paise — can come as double from server
  final String? currency;
  final String? key;
  final String? eventTitle;
  final int? originalPrice; // can come as double (e.g. 99.0)
  final int? discountedPrice; // can come as double (e.g. 89.1)
  final TournamentAppliedCoupon? appliedCoupon;

  TournamentInitiatePaymentData({
    this.id,
    this.paymentStatus,
    this.eventType,
    this.eventId,
    this.completed,
    this.orderId,
    this.amount,
    this.currency,
    this.key,
    this.eventTitle,
    this.originalPrice,
    this.discountedPrice,
    this.appliedCoupon,
  });

  bool get isCompleted => completed != false && paymentStatus == 'completed';

  factory TournamentInitiatePaymentData.fromJson(
    Map<String, dynamic> json,
  ) => TournamentInitiatePaymentData(
    id: json['_id'],
    paymentStatus: json['paymentStatus'],
    eventType: json['eventType'],
    eventId: json['eventId'],
    completed: json['completed'],
    orderId: json['orderId'],
    // ✅ All numeric fields use _toIntOrNull — handles double (e.g. 89.1 → 89)
    amount: _toIntOrNull(json['amount']),
    currency: json['currency'],
    key: json['key'],
    eventTitle: json['eventTitle'],
    originalPrice: _toIntOrNull(json['originalPrice']),
    discountedPrice: _toIntOrNull(json['discountedPrice']),
    appliedCoupon: json['appliedCoupon'] != null
        ? TournamentAppliedCoupon.fromJson(
            json['appliedCoupon'] as Map<String, dynamic>,
          )
        : null,
  );
}

class TournamentAppliedCoupon {
  final String? code;
  final int? discount;

  TournamentAppliedCoupon({this.code, this.discount});

  factory TournamentAppliedCoupon.fromJson(Map<String, dynamic> json) =>
      TournamentAppliedCoupon(
        code: json['code'],
        // ✅ discount can also be a double
        discount: _toIntOrNull(json['discount']),
      );
}

class TournamentRegisterRequest {
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;

  TournamentRegisterRequest({
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

class TournamentRegisterResponse {
  final bool success;
  final String? message;

  TournamentRegisterResponse({required this.success, this.message});

  factory TournamentRegisterResponse.fromJson(Map<String, dynamic> json) =>
      TournamentRegisterResponse(
        success: json['success'] ?? false,
        message: json['message'],
      );
}

enum TournamentPaymentMethod { free, wallet, razorpay }

extension TournamentPaymentMethodX on TournamentPaymentMethod {
  String get value {
    switch (this) {
      case TournamentPaymentMethod.free:
        return 'free';
      case TournamentPaymentMethod.wallet:
        return 'wallet';
      case TournamentPaymentMethod.razorpay:
        return 'razorpay';
    }
  }
}
