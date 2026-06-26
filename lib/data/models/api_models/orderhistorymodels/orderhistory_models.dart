import 'dart:convert';

OrderHistoryModels orderHistoryModelsFromJson(String str) =>
    OrderHistoryModels.fromJson(json.decode(str));

String orderHistoryModelsToJson(OrderHistoryModels data) =>
    json.encode(data.toJson());

class OrderHistoryModels {
  bool? success;
  String? message;
  List<OrderHistoryItem>? data;
  Meta? meta;

  OrderHistoryModels({this.success, this.message, this.data, this.meta});

  factory OrderHistoryModels.fromJson(Map<String, dynamic> json) =>
      OrderHistoryModels(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<OrderHistoryItem>.from(
                json["data"].map((x) => OrderHistoryItem.fromJson(x))),
        meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "meta": meta?.toJson(),
      };
}

class OrderHistoryItem {
  String? id;
  String? type;
  DateTime? date;
  String? title;
  String? itemName;
  int? amount;
  // null → fiat (INR), "points" → points currency
  String? amountUnit;
  String? paymentMethod;
  String? status;
  OrderData? data;

  OrderHistoryItem({
    this.id,
    this.type,
    this.date,
    this.title,
    this.itemName,
    this.amount,
    this.amountUnit,
    this.paymentMethod,
    this.status,
    this.data,
  });

  /// True when this transaction was settled in points, not money.
  bool get isPaidWithPoints => amountUnit == 'points';

  /// True when the item was free (amount == 0 OR paymentMethod == "free").
  bool get isFree =>
      (amount ?? 0) == 0 || paymentMethod?.toLowerCase() == 'free';

  factory OrderHistoryItem.fromJson(Map<String, dynamic> json) =>
      OrderHistoryItem(
        id: json["id"],
        type: json["type"],
        date: json["date"] != null ? DateTime.parse(json["date"]) : null,
        title: json["title"],
        itemName: json["itemName"],
        amount: (json["amount"] as num?)?.toInt(),
        amountUnit: json["amountUnit"],
        paymentMethod: json["paymentMethod"],
        status: json["status"],
        data: json["data"] != null ? OrderData.fromJson(json["data"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "date": date?.toIso8601String(),
        "title": title,
        "itemName": itemName,
        "amount": amount,
        "amountUnit": amountUnit,
        "paymentMethod": paymentMethod,
        "status": status,
        "data": data?.toJson(),
      };
}

class OrderData {
  String? id;

  OrderData({this.id});

  factory OrderData.fromJson(Map<String, dynamic> json) =>
      OrderData(id: json["_id"]);

  Map<String, dynamic> toJson() => {"_id": id};
}

class Meta {
  int? page;
  int? limit;
  int? total;
  int? pages;

  Meta({this.page, this.limit, this.total, this.pages});

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        page: json["page"],
        limit: json["limit"],
        total: json["total"],
        pages: json["pages"],
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "limit": limit,
        "total": total,
        "pages": pages,
      };
}