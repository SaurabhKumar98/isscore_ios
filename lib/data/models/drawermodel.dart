import 'package:flutter/material.dart';

class DrawerItemModel {
  final String title;
  final IconData icon;
  final String? route; // 👈 nullable
  final bool hasArrow;
  final List<DrawerSubItem>? subItems;

  DrawerItemModel({
    required this.title,
    required this.icon,
    this.route, // 👈 nullable
    this.hasArrow = false,
    this.subItems,
  });
}

class DrawerSubItem {
  final String title;
  final IconData icon;
  final String route; // 👈 NOT nullable
   final dynamic arguments;

  DrawerSubItem({
    required this.title,
    required this.icon,
    required this.route,
     this.arguments,
  });
}
