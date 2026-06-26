import 'dart:convert';

MerchandiseClaimedFetchModels merchandiseClaimedFetchModelsFromJson(
  String str,
) => MerchandiseClaimedFetchModels.fromJson(json.decode(str) ?? {});

String merchandiseClaimedFetchModelsToJson(
  MerchandiseClaimedFetchModels data,
) => json.encode(data.toJson());

class MerchandiseClaimedFetchModels {
  final bool success;
  final String message;
  final List<ClaimItem> data;
  final ClaimListMeta meta;

  MerchandiseClaimedFetchModels({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory MerchandiseClaimedFetchModels.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return MerchandiseClaimedFetchModels(
        success: false,
        message: '',
        data: [],
        meta: ClaimListMeta.fromJson({}),
      );
    }

    return MerchandiseClaimedFetchModels(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List?)?.map((x) => ClaimItem.fromJson(x)).toList() ??
          [],
      meta: ClaimListMeta.fromJson(json['meta']),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data.map((x) => x.toJson()).toList(),
    'meta': meta.toJson(),
  };
}

class ClaimItem {
  final String id;
  final ClaimItemStudent? student;
  final ClaimItemMerchandise? merchandise;
  final int pointsSpent;
  final String status;
  final ClaimItemAddress? deliveryAddress;
  final DateTime? claimedAt;
  final dynamic shippedAt;
  final dynamic deliveredAt;
  final dynamic trackingNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ClaimItem({
    required this.id,
    this.student,
    this.merchandise,
    required this.pointsSpent,
    required this.status,
    this.deliveryAddress,
    this.claimedAt,
    this.shippedAt,
    this.deliveredAt,
    this.trackingNumber,
    this.createdAt,
    this.updatedAt,
  });

  factory ClaimItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClaimItem(id: '', pointsSpent: 0, status: '');
    }

    return ClaimItem(
      id: json['_id'] ?? '',
      student: json['student'] != null
          ? ClaimItemStudent.fromJson(json['student'])
          : null,
      merchandise: json['merchandise'] != null
          ? ClaimItemMerchandise.fromJson(json['merchandise'])
          : null,
      pointsSpent: (json['pointsSpent'] ?? 0).toInt(),
      status: json['status'] ?? '',
      deliveryAddress: json['deliveryAddress'] != null
          ? ClaimItemAddress.fromJson(json['deliveryAddress'])
          : null,
      claimedAt: DateTime.tryParse(json['claimedAt'] ?? ''),
      shippedAt: json['shippedAt'],
      deliveredAt: json['deliveredAt'],
      trackingNumber: json['trackingNumber'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'student': student?.toJson(),
    'merchandise': merchandise?.toJson(),
    'pointsSpent': pointsSpent,
    'status': status,
    'deliveryAddress': deliveryAddress?.toJson(),
    'claimedAt': claimedAt?.toIso8601String(),
    'shippedAt': shippedAt,
    'deliveredAt': deliveredAt,
    'trackingNumber': trackingNumber,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}

class ClaimItemAddress {
  final String fullName;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  ClaimItemAddress({
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  factory ClaimItemAddress.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClaimItemAddress(
        fullName: '',
        phone: '',
        addressLine1: '',
        addressLine2: '',
        city: '',
        state: '',
        postalCode: '',
        country: '',
      );
    }

    return ClaimItemAddress(
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postalCode'] ?? '',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'phone': phone,
    'addressLine1': addressLine1,
    'addressLine2': addressLine2,
    'city': city,
    'state': state,
    'postalCode': postalCode,
    'country': country,
  };
}

class ClaimItemMerchandise {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int pointsRequired;
  final bool isPhysical;

  ClaimItemMerchandise({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.pointsRequired,
    required this.isPhysical,
  });

  factory ClaimItemMerchandise.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClaimItemMerchandise(
        id: '',
        name: '',
        description: '',
        imageUrl: '',
        pointsRequired: 0,
        isPhysical: false,
      );
    }

    return ClaimItemMerchandise(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      pointsRequired: (json['pointsRequired'] ?? 0).toInt(),
      isPhysical: json['isPhysical'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'pointsRequired': pointsRequired,
    'isPhysical': isPhysical,
  };
}

class ClaimItemStudent {
  final String id;
  final String name;
  final String email;
  final String phone;

  ClaimItemStudent({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory ClaimItemStudent.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClaimItemStudent(id: '', name: '', email: '', phone: '');
    }

    return ClaimItemStudent(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'email': email,
    'phone': phone,
  };
}

class ClaimListMeta {
  final int page;
  final int limit;
  final int total;
  final int pages;

  ClaimListMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory ClaimListMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClaimListMeta(page: 1, limit: 10, total: 0, pages: 1);
    }

    return ClaimListMeta(
      page: (json['page'] ?? 1).toInt(),
      limit: (json['limit'] ?? 10).toInt(),
      total: (json['total'] ?? 0).toInt(),
      pages: (json['pages'] ?? 1).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'page': page,
    'limit': limit,
    'total': total,
    'pages': pages,
  };
}
