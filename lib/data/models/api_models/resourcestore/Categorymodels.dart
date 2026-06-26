import 'package:flutter/material.dart';

class CategoryResponse {
  final bool success;
  final String message;
  final List<CategoryModel> data;

  CategoryResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic>? json) {
    final rawList = json?['data'] as List<dynamic>? ?? [];

    // ✅ Parse each item individually — one bad item won't kill the whole list
    final parsed = <CategoryModel>[];
    for (final e in rawList) {
      try {
        parsed.add(CategoryModel.fromJson(e as Map<String, dynamic>));
      } catch (err) {
        debugPrint('⚠️ CategoryModel parse error: $err\nItem: $e');
      }
    }

    return CategoryResponse(
      success: json?['success'] ?? false,
      message: json?['message'] ?? '',
      data: parsed,
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final int order;
  final bool isActive;
  final String? rootType;   // ✅ Added
  final String? kind;       // ✅ Added — some nodes have this
  final List<CategoryModel> children;

  CategoryModel({
    required this.id,
    required this.name,
    required this.order,
    required this.isActive,
    this.rootType,
    this.kind,
    required this.children,
  });

  bool get hasChildren => children.isNotEmpty;

  /// e.g. "Olympiads", "School", "Competitive", "Skill Development", "custom"
  bool get isPredefined => rootType != null && rootType != 'custom';

  factory CategoryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) throw ArgumentError('CategoryModel.fromJson: null json');

    // ✅ Parse children individually so one bad child doesn't kill the parent
    final rawChildren = json['children'] as List<dynamic>? ?? [];
    final children = <CategoryModel>[];
    for (final e in rawChildren) {
      try {
        children.add(CategoryModel.fromJson(e as Map<String, dynamic>));
      } catch (err) {
        debugPrint('⚠️ Child CategoryModel parse error: $err');
      }
    }

    return CategoryModel(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      rootType: json['rootType'] as String?,
      kind: json['kind'] as String?,
      children: children,
    );
  }
}