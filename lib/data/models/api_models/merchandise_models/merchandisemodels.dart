import 'dart:convert';

MerchandiseModels merchandiseModelsFromJson(String str) =>
    MerchandiseModels.fromJson(json.decode(str) ?? {});

String merchandiseModelsToJson(MerchandiseModels data) =>
    json.encode(data.toJson());

class MerchandiseModels {
  final bool success;
  final String message;
  final List<MerchandiseItem> data;
  final MerchandiseMeta meta;

  MerchandiseModels({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory MerchandiseModels.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return MerchandiseModels(
        success: false,
        message: '',
        data: [],
        meta: MerchandiseMeta.empty(),
      );
    }
    return MerchandiseModels(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
              ?.map((x) => MerchandiseItem.fromJson(x))
              .toList() ??
          [],
      meta: MerchandiseMeta.fromJson(json['meta']),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data.map((x) => x.toJson()).toList(),
        'meta': meta.toJson(),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// MerchandiseItem
// ─────────────────────────────────────────────────────────────────────────────
class MerchandiseItem {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int pointsRequired;
  final int price;         // original / MRP price
  final int discountedPrice; // ✅ NEW — effective price after discount
  final int originalPrice;   // ✅ NEW — same as price but explicit
  final String category;
  final bool isPhysical;
  final bool isActive;
  final int stockQuantity;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MerchandiseItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.pointsRequired,
    required this.price,
    required this.discountedPrice,
    required this.originalPrice,
    required this.category,
    required this.isPhysical,
    required this.isActive,
    required this.stockQuantity,
    this.createdAt,
    this.updatedAt,
  });

  /// The price actually paid — discountedPrice if set and lower, else price
  int get effectivePrice =>
      (discountedPrice > 0 && discountedPrice < price) ? discountedPrice : price;

  /// True when a discount is active
  bool get hasDiscount => effectivePrice < price && price > 0;

  factory MerchandiseItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MerchandiseItem.empty();
    final rawPrice = (json['price'] ?? 0).toInt();
    final rawDiscounted = (json['discountedPrice'] ?? 0).toInt();
    final rawOriginal = (json['originalPrice'] ?? rawPrice).toInt();
    return MerchandiseItem(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      pointsRequired: (json['pointsRequired'] ?? 0).toInt(),
      price: rawPrice,
      discountedPrice: rawDiscounted,
      originalPrice: rawOriginal,
      category: json['category'] ?? '',
      isPhysical: json['isPhysical'] ?? false,
      isActive: json['isActive'] ?? true,
      stockQuantity: (json['stockQuantity'] ?? 0).toInt(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? ''),
    );
  }

  factory MerchandiseItem.empty() => MerchandiseItem(
        id: '',
        name: '',
        description: '',
        imageUrl: '',
        pointsRequired: 0,
        price: 0,
        discountedPrice: 0,
        originalPrice: 0,
        category: '',
        isPhysical: false,
        isActive: false,
        stockQuantity: 0,
      );

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
}

// ─────────────────────────────────────────────────────────────────────────────
// MerchandiseMeta
// ─────────────────────────────────────────────────────────────────────────────
class MerchandiseMeta {
  final int page;
  final int limit;
  final int total;
  final int pages;
  final int totalPoints;
  final double monetaryBalance;

  MerchandiseMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
    required this.totalPoints,
    required this.monetaryBalance,
  });

  factory MerchandiseMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MerchandiseMeta.empty();
    return MerchandiseMeta(
      page: (json['page'] ?? 1).toInt(),
      limit: (json['limit'] ?? 10).toInt(),
      total: (json['total'] ?? 0).toInt(),
      pages: (json['pages'] ?? 1).toInt(),
      totalPoints: (json['totalPoints'] ?? 0).toInt(),
      monetaryBalance: (json['monetaryBalance'] ?? 0.0).toDouble(),
    );
  }

  factory MerchandiseMeta.empty() => MerchandiseMeta(
        page: 1,
        limit: 10,
        total: 0,
        pages: 1,
        totalPoints: 0,
        monetaryBalance: 0,
      );

  Map<String, dynamic> toJson() => {
        'page': page,
        'limit': limit,
        'total': total,
        'pages': pages,
        'totalPoints': totalPoints,
        'monetaryBalance': monetaryBalance,
      };
}