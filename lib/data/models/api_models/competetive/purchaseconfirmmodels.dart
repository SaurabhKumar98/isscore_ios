import 'dart:convert';

PurchaseconfirmedModels purchaseconfirmedModelsFromJson(String str) =>
    PurchaseconfirmedModels.fromJson(json.decode(str));

String purchaseconfirmedModelsToJson(PurchaseconfirmedModels data) =>
    json.encode(data.toJson());

class PurchaseconfirmedModels {
  final bool? success;
  final String? message;
  final PurchaseConfirmData? data;
  final dynamic meta;

  PurchaseconfirmedModels({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory PurchaseconfirmedModels.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PurchaseconfirmedModels();
    return PurchaseconfirmedModels(
      success: json["success"],
      message: json["message"],
      data: json["data"] != null
          ? PurchaseConfirmData.fromJson(json["data"])
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

class PurchaseConfirmData {
  // ── Shared fields ──────────────────────────────────────────────────────────
  final String? id;
  final int? purchasePrice;
  final String? paymentMethod;
  final String? paymentId;
  final String? paymentStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final dynamic lastUpgradedAt;

  // ── Category purchase fields ───────────────────────────────────────────────
  final String? studentId;       // extracted from student string OR object
  final String? categoryId;
  final String? pillarType;
  final List<String>? unlockedCategoryIds;

  // ── Test purchase fields ───────────────────────────────────────────────────
  final String? studentName;     // from student object
  final String? studentEmail;    // from student object
  final String? testId;          // from test object
  final String? testTitle;       // from test object

  PurchaseConfirmData({
    this.id,
    this.purchasePrice,
    this.paymentMethod,
    this.paymentId,
    this.paymentStatus,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.lastUpgradedAt,
    this.studentId,
    this.categoryId,
    this.pillarType,
    this.unlockedCategoryIds,
    this.studentName,
    this.studentEmail,
    this.testId,
    this.testTitle,
  });

  factory PurchaseConfirmData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PurchaseConfirmData();

    // ── student: can be a String ID or a full object ───────────────────────
    String? studentId;
    String? studentName;
    String? studentEmail;
    final rawStudent = json["student"];
    if (rawStudent is String) {
      studentId = rawStudent;
    } else if (rawStudent is Map<String, dynamic>) {
      studentId = rawStudent["_id"] as String?;
      studentName = rawStudent["name"] as String?;
      studentEmail = rawStudent["email"] as String?;
    }

    // ── test: only present in test purchase response ───────────────────────
    String? testId;
    String? testTitle;
    final rawTest = json["test"];
    if (rawTest is Map<String, dynamic>) {
      testId = rawTest["_id"] as String?;
      testTitle = rawTest["title"] as String?;
    }

    return PurchaseConfirmData(
      id: json["_id"] as String?,
      purchasePrice: json["purchasePrice"] as int?,
      paymentMethod: json["paymentMethod"] as String?,
      paymentId: json["paymentId"] as String?,
      paymentStatus: json["paymentStatus"] as String?,
      lastUpgradedAt: json["lastUpgradedAt"],
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"])
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.tryParse(json["updatedAt"])
          : null,
      v: json["__v"] as int?,
      // category fields
      studentId: studentId,
      categoryId: json["categoryId"] as String?,
      pillarType: json["pillarType"] as String?,
      unlockedCategoryIds: json["unlockedCategoryIds"] != null
          ? List<String>.from(json["unlockedCategoryIds"])
          : [],
      // test fields
      studentName: studentName,
      studentEmail: studentEmail,
      testId: testId,
      testTitle: testTitle,
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "purchasePrice": purchasePrice,
        "paymentMethod": paymentMethod,
        "paymentId": paymentId,
        "paymentStatus": paymentStatus,
        "lastUpgradedAt": lastUpgradedAt,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "student": studentId,
        "categoryId": categoryId,
        "pillarType": pillarType,
        "unlockedCategoryIds": unlockedCategoryIds != null
            ? List<dynamic>.from(unlockedCategoryIds!)
            : [],
        "testId": testId,
        "testTitle": testTitle,
      };
}