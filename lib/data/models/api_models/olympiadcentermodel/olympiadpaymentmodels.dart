// Mirrors firstedu/data/repo/workshops/paymentmodels.dart
// Used by OlympiadCenterRepositories + OlympiadProvider

enum OlympiadPaymentMethod { free, wallet, razorpay }

extension OlympiadPaymentMethodX on OlympiadPaymentMethod {
  String get value {
    switch (this) {
      case OlympiadPaymentMethod.free:
        return 'free';
      case OlympiadPaymentMethod.wallet:
        return 'wallet';
      case OlympiadPaymentMethod.razorpay:
        return 'razorpay';
    }
  }
}

// ── POST /olympiads/:id/initiate-payment ─────────────────────────────────────

class OlympiadInitiatePaymentResponse {
  bool? success;
  String? message;
  OlympiadInitiatePaymentData? data;

  OlympiadInitiatePaymentResponse(
      {this.success, this.message, this.data});

  factory OlympiadInitiatePaymentResponse.fromJson(
          Map<String, dynamic> json) =>
      OlympiadInitiatePaymentResponse(
        success: json['success'],
        message: json['message'],
        data: json['data'] == null
            ? null
            : OlympiadInitiatePaymentData.fromJson(
                json['data'] as Map<String, dynamic>),
      );
}

class OlympiadInitiatePaymentData {
  /// true  → free/wallet, already registered (no Razorpay needed)
  /// false → Razorpay order created, open checkout
  bool? completed;

  // Razorpay order fields (completed = false)
  String? orderId;
  int? amount;   // paise
  String? currency;
  String? key;   // Razorpay key_id sent from backend

  // Optional label for checkout title
  String? eventTitle;

  // Registration fields (completed = true)
  String? id;
  String? eventType;
  String? eventId;
  String? paymentStatus;
  String? paymentMethod;

  OlympiadInitiatePaymentData({
    this.completed,
    this.orderId,
    this.amount,
    this.currency,
    this.key,
    this.eventTitle,
    this.id,
    this.eventType,
    this.eventId,
    this.paymentStatus,
    this.paymentMethod,
  });

  factory OlympiadInitiatePaymentData.fromJson(
          Map<String, dynamic> json) =>
      OlympiadInitiatePaymentData(
        completed: json['completed'],
        orderId: json['orderId'],
        amount: json['amount'],
        currency: json['currency'],
        key: json['key'],
        eventTitle: json['eventTitle'],
        id: json['_id'],
        eventType: json['eventType'],
        eventId: json['eventId'],
        paymentStatus: json['paymentStatus'],
        paymentMethod: json['paymentMethod'],
      );
}