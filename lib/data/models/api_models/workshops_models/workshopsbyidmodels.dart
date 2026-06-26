import 'dart:convert';

WorkshopDetailsResponse workshopDetailsResponseFromJson(String str) =>
    WorkshopDetailsResponse.fromJson(json.decode(str));

String workshopDetailsResponseToJson(WorkshopDetailsResponse data) =>
    json.encode(data.toJson());

class WorkshopDetailsResponse {
  final bool success;
  final String message;
  final WorkshopDetails? data;

  WorkshopDetailsResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory WorkshopDetailsResponse.fromJson(Map<String, dynamic> json) {
    return WorkshopDetailsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          json['data'] != null ? WorkshopDetails.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.toJson(),
      };
}

class WorkshopDetails {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? teacher;

  final DateTime? startTime;
  final DateTime? endTime;

  final String? meetingLink;
  final String? meetingPassword;

  final int price;
  final int? maxParticipants;

  final DateTime? registrationStartTime;
  final DateTime? registrationEndTime;

  final String? eventType;
  final String status;

  final bool isPublished;
  final bool isRegistrationOpen;
  final bool isEventLive;
  final bool canJoin;
  final bool isRegistered;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  WorkshopDetails({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.teacher,
    this.startTime,
    this.endTime,
    this.meetingLink,
    this.meetingPassword,
    required this.price,
    this.maxParticipants,
    this.registrationStartTime,
    this.registrationEndTime,
    this.eventType,
    required this.status,
    required this.isPublished,
    required this.isRegistrationOpen,
    required this.isEventLive,
    required this.canJoin,
    required this.isRegistered,
    this.createdAt,
    this.updatedAt,
  });

  factory WorkshopDetails.fromJson(Map<String, dynamic> json) {
    return WorkshopDetails(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      teacher: json['teacher'] != null ? json['teacher']['name'] : null,
      startTime:
          json['startTime'] != null ? DateTime.tryParse(json['startTime']) : null,
      endTime:
          json['endTime'] != null ? DateTime.tryParse(json['endTime']) : null,
      meetingLink: json['meetingLink'],
      meetingPassword: json['meetingPassword'],
      price: json['price'] ?? 0,
      maxParticipants: json['maxParticipants'],
      registrationStartTime: json['registrationStartTime'] != null
          ? DateTime.tryParse(json['registrationStartTime'])
          : null,
      registrationEndTime: json['registrationEndTime'] != null
          ? DateTime.tryParse(json['registrationEndTime'])
          : null,
      eventType: json['eventType'],
      status: json['status'] ?? '',
      isPublished: json['isPublished'] ?? false,
      isRegistrationOpen: json['isRegistrationOpen'] ?? false,
      isEventLive: json['isEventLive'] ?? false,
      canJoin: json['canJoin'] ?? false,
      isRegistered: json['isRegistered'] ?? false,
      createdAt:
          json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'teacher': teacher,
        'startTime': startTime?.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'meetingLink': meetingLink,
        'meetingPassword': meetingPassword,
        'price': price,
        'maxParticipants': maxParticipants,
        'registrationStartTime': registrationStartTime?.toIso8601String(),
        'registrationEndTime': registrationEndTime?.toIso8601String(),
        'eventType': eventType,
        'status': status,
        'isPublished': isPublished,
        'isRegistrationOpen': isRegistrationOpen,
        'isEventLive': isEventLive,
        'canJoin': canJoin,
        'isRegistered': isRegistered,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}