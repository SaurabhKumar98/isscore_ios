import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Global Razorpay Manager (Singleton)
class RazorpayManager {
  RazorpayManager._internal();
  static final RazorpayManager instance = RazorpayManager._internal();

  Razorpay? _razorpay;

  void init({
    // ✅ context removed — was causing "deactivated widget" crash
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
  }) {
    // ✅ ALWAYS clear + recreate — the old code used ??= which kept the
    //    same instance and stacked listeners on every payment,
    //    causing POST /wallet/recharge to fire 5 times
    _razorpay?.clear();
    _razorpay = Razorpay();

    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, (res) => onSuccess(res));
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, (res) => onError(res));
  }

  void openCheckout({
    required String key,
    required int amount, // paise
    required String orderId,
    String currency = 'INR',
    String title = 'Payment',
    String description = '',
    String? contact,
    String? email,
    String themeColor = '#162556',
  }) {
    final options = {
      'key': key,
      'amount': amount,
      'currency': currency,
      'name': title,
      'description': description,
      'order_id': orderId,
      'prefill': {'contact': contact ?? '', 'email': email ?? ''},
      'theme': {'color': themeColor},
    };

    try {
      _razorpay?.open(options);
    } catch (e) {
      debugPrint('Razorpay open error: $e');
    }
  }

  /// Call on screen dispose / app logout
  void clear() {
    _razorpay?.clear();
    _razorpay = null;
  }
}
