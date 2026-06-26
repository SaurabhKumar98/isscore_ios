import 'package:flutter/material.dart';

enum EventType { written, video }

class EventModel {
  final String title;
  final String description;
  final String participants;
  final String date;
  final String status;
  final String category; // 👈 Writing / Music / Quiz etc
  final EventType type;
  final IconData icon;
  final Color iconBg;

  EventModel({
    required this.title,
    required this.description,
    required this.participants,
    required this.date,
    required this.status,
    required this.category,
    required this.type,
    required this.icon,
    required this.iconBg,
  });
}
