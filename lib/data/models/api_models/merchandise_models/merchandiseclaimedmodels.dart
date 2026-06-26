import 'dart:convert';

MerchandiseClaimedModels merchandiseClaimedModelsFromJson(String str) =>
    MerchandiseClaimedModels.fromJson(json.decode(str) ?? {});

String merchandiseClaimedModelsToJson(MerchandiseClaimedModels data) =>
    json.encode(data.toJson());

class MerchandiseClaimedModels {
  final bool success;
  final String message;
  final ClaimResult? data;
  final dynamic meta;

  MerchandiseClaimedModels({
    required this.success,
    required this.message,
    this.data,
    this.meta,
  });

  factory MerchandiseClaimedModels.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return MerchandiseClaimedModels(success: false, message: '', data: null);
    }

    return MerchandiseClaimedModels(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ClaimResult.fromJson(json['data']) : null,
      meta: json['meta'],
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data?.toJson(),
    'meta': meta,
  };
}

class ClaimResult {
  final String id;
  final ClaimStudent? student;
  final ClaimedMerchandise? merchandise;
  final int pointsSpent;
  final String status;
  final ClaimDeliveryAddress? deliveryAddress;
  final DateTime? claimedAt;
  final dynamic shippedAt;
  final dynamic deliveredAt;
  final dynamic trackingNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ClaimResult({
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

  factory ClaimResult.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClaimResult(id: '', pointsSpent: 0, status: '');
    }

    return ClaimResult(
      id: json['_id'] ?? '',
      student: json['student'] != null
          ? ClaimStudent.fromJson(json['student'])
          : null,
      merchandise: json['merchandise'] != null
          ? ClaimedMerchandise.fromJson(json['merchandise'])
          : null,
      pointsSpent: (json['pointsSpent'] ?? 0).toInt(),
      status: json['status'] ?? '',
      deliveryAddress: json['deliveryAddress'] != null
          ? ClaimDeliveryAddress.fromJson(json['deliveryAddress'])
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

class ClaimDeliveryAddress {
  final String fullName;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  ClaimDeliveryAddress({
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  factory ClaimDeliveryAddress.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClaimDeliveryAddress(
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

    return ClaimDeliveryAddress(
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

class ClaimedMerchandise {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int pointsRequired;
  final bool isPhysical;

  ClaimedMerchandise({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.pointsRequired,
    required this.isPhysical,
  });

  factory ClaimedMerchandise.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClaimedMerchandise(
        id: '',
        name: '',
        description: '',
        imageUrl: '',
        pointsRequired: 0,
        isPhysical: false,
      );
    }

    return ClaimedMerchandise(
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

class ClaimStudent {
  final String id;
  final String name;
  final String email;
  final String phone;

  ClaimStudent({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory ClaimStudent.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClaimStudent(id: '', name: '', email: '', phone: '');
    }

    return ClaimStudent(
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
