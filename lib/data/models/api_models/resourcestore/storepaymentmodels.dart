import 'dart:convert';

enum StorePaymentMethod {
  free,
  wallet,
  razorpay,
}
StorePaymentResponse storePaymentResponseFromJson(String str) =>
    StorePaymentResponse.fromJson(json.decode(str));

class StorePaymentResponse {
  bool? success;
  String? message;
  StorePaymentData? data;

  StorePaymentResponse({
    this.success,
    this.message,
    this.data,
  });

  factory StorePaymentResponse.fromJson(Map<String, dynamic>? json) {
    return StorePaymentResponse(
      success: json?["success"],
      message: json?["message"],
      data: json?["data"] != null
          ? StorePaymentData.fromJson(json?["data"])
          : null,
    );
  }
}

class StorePaymentData {
  bool? completed;
  String? orderId;
  int? amount;
  String? currency;
  String? key;
  String? testId;
  String? testTitle;

  StorePaymentData({
    this.completed,
    this.orderId,
    this.amount,
    this.currency,
    this.key,
    this.testId,
    this.testTitle,
  });

  factory StorePaymentData.fromJson(Map<String, dynamic>? json) {
    return StorePaymentData(
      completed: json?["completed"],
      orderId: json?["orderId"],
      amount: json?["amount"],
      currency: json?["currency"],
      key: json?["key"],
      testId: json?["testId"],
      testTitle: json?["testTitle"],
    );
  }
}
class StorePurchaseResponse {
  bool? success;
  String? message;
  PurchaseData? data;

  StorePurchaseResponse({
    this.success,
    this.message,
    this.data,
  });

  factory StorePurchaseResponse.fromJson(Map<String, dynamic>? json) {
    return StorePurchaseResponse(
      success: json?["success"],
      message: json?["message"],
      data: json?["data"] != null
          ? PurchaseData.fromJson(json?["data"])
          : null,
    );
  }
}

class PurchaseData {
  String? id;
  Student? student;
  Test? test;
  dynamic testBundle;
  int? purchasePrice;
  DateTime? purchaseDate;
  String? paymentId;
  String? paymentStatus;
  DateTime? createdAt;

  PurchaseData({
    this.id,
    this.student,
    this.test,
    this.testBundle,
    this.purchasePrice,
    this.purchaseDate,
    this.paymentId,
    this.paymentStatus,
    this.createdAt,
  });

  factory PurchaseData.fromJson(Map<String, dynamic>? json) {
    return PurchaseData(
      id: json?["_id"],
      student: json?["student"] != null
          ? Student.fromJson(json?["student"])
          : null,
      test: json?["test"] != null
          ? Test.fromJson(json?["test"])
          : null,
      testBundle: json?["testBundle"],
      purchasePrice: json?["purchasePrice"],
      purchaseDate: json?["purchaseDate"] != null
          ? DateTime.tryParse(json?["purchaseDate"])
          : null,
      paymentId: json?["paymentId"],
      paymentStatus: json?["paymentStatus"],
      createdAt: json?["createdAt"] != null
          ? DateTime.tryParse(json?["createdAt"])
          : null,
    );
  }
}

class Student {
  String? id;
  String? name;
  String? email;

  Student({
    this.id,
    this.name,
    this.email,
  });

  factory Student.fromJson(Map<String, dynamic>? json) {
    return Student(
      id: json?["_id"],
      name: json?["name"],
      email: json?["email"],
    );
  }
}

class Test {
  String? id;
  String? title;
  String? description;
  int? durationMinutes;
  String? questionBank;

  Test({
    this.id,
    this.title,
    this.description,
    this.durationMinutes,
    this.questionBank,
  });

  factory Test.fromJson(Map<String, dynamic>? json) {
    return Test(
      id: json?["_id"],
      title: json?["title"],
      description: json?["description"],
      durationMinutes: json?["durationMinutes"],
      questionBank: json?["questionBank"],
    );
  }
}

class StoreRazorpayOrder {
  String? key;
  int? amount;
  String? currency;
  String? orderId;
  String? eventTitle;

  StoreRazorpayOrder({
    this.key,
    this.amount,
    this.currency,
    this.orderId,
    this.eventTitle,
  });

  factory StoreRazorpayOrder.fromPaymentData(StorePaymentData? data) {
    return StoreRazorpayOrder(
      key: data?.key,
      amount: data?.amount,
      currency: data?.currency,
      orderId: data?.orderId,
      eventTitle: data?.testTitle,
    );
  }
}