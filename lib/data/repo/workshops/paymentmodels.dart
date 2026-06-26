import 'dart:convert';

// ─────────────────────────────────────────────────────────────────────────────
// INITIATE PAYMENT RESPONSE
// ─────────────────────────────────────────────────────────────────────────────

InitiatePaymentResponse initiatePaymentResponseFromJson(String str) =>
    InitiatePaymentResponse.fromJson(json.decode(str));

class InitiatePaymentResponse {
  final bool success;
  final String message;
  final InitiatePaymentData? data;

  InitiatePaymentResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory InitiatePaymentResponse.fromJson(Map<String, dynamic> json) {
    return InitiatePaymentResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? InitiatePaymentData.fromJson(json['data'])
          : null,
    );
  }
}

class InitiatePaymentData {
  /// true  → free / wallet → already registered, no further action needed
  /// false → razorpay → need to open checkout then call /register
  final bool completed;

  // ── Only present when completed = false (razorpay flow) ──
  final String? orderId;
  final int? amount;       // in paise
  final String? currency;
  final String? key;       // Razorpay key
  final String? eventType;
  final String? eventId;
  final String? eventTitle;

  // ── Only present when completed = true (free / wallet) ──
  final String? registrationId;
  final String? student;
  final String? status;
  final String? paymentStatus;
  final DateTime? registeredAt;

  InitiatePaymentData({
    required this.completed,
    this.orderId,
    this.amount,
    this.currency,
    this.key,
    this.eventType,
    this.eventId,
    this.eventTitle,
    this.registrationId,
    this.student,
    this.status,
    this.paymentStatus,
    this.registeredAt,
  });

  factory InitiatePaymentData.fromJson(Map<String, dynamic> json) {
    return InitiatePaymentData(
      completed: json['completed'] ?? true,
      orderId: json['orderId'],
      amount: json['amount'],
      currency: json['currency'],
      key: json['key'],
      eventType: json['eventType'],
      eventId: json['eventId'],
      eventTitle: json['eventTitle'],
      registrationId: json['_id'],
      student: json['student'],
      status: json['status'],
      paymentStatus: json['paymentStatus'],
      registeredAt: json['registeredAt'] != null
          ? DateTime.tryParse(json['registeredAt'])
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPLETE REGISTRATION (after Razorpay) RESPONSE
// ─────────────────────────────────────────────────────────────────────────────

CompleteRegistrationResponse completeRegistrationResponseFromJson(
        String str) =>
    CompleteRegistrationResponse.fromJson(json.decode(str));

class CompleteRegistrationResponse {
  final bool success;
  final String message;
  final CompleteRegistrationData? data;

  CompleteRegistrationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CompleteRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return CompleteRegistrationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? CompleteRegistrationData.fromJson(json['data'])
          : null,
    );
  }
}

class CompleteRegistrationData {
  final String id;
  final String student;
  final String eventType;
  final String eventId;
  final String status;
  final String paymentStatus;
  final DateTime? registeredAt;

  CompleteRegistrationData({
    required this.id,
    required this.student,
    required this.eventType,
    required this.eventId,
    required this.status,
    required this.paymentStatus,
    this.registeredAt,
  });

  factory CompleteRegistrationData.fromJson(Map<String, dynamic> json) {
    return CompleteRegistrationData(
      id: json['_id'] ?? '',
      student: json['student'] ?? '',
      eventType: json['eventType'] ?? '',
      eventId: json['eventId'] ?? '',
      status: json['status'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      registeredAt: json['registeredAt'] != null
          ? DateTime.tryParse(json['registeredAt'])
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAYMENT METHOD ENUM
// ─────────────────────────────────────────────────────────────────────────────

enum PaymentMethod { free, wallet, razorpay }

extension PaymentMethodX on PaymentMethod {
  String get value {
    switch (this) {
      case PaymentMethod.free:
        return 'free';
      case PaymentMethod.wallet:
        return 'wallet';
      case PaymentMethod.razorpay:
        return 'razorpay';
    }
  }
}