import 'package:firstedu/data/models/api_models/challengeyourself/challengeyourself_models.dart';

export 'package:firstedu/data/models/api_models/challengeyourself/challengeyourself_models.dart'
    show CategoryNode;

class CategoriesModel {
  final bool success;
  final String message;
  final List<CategoryNode> data;

  CategoriesModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CategoriesModel.fromJson(Map<String, dynamic> json) {
    return CategoriesModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<CategoryNode>.from(
              (json['data'] as List).map((x) => CategoryNode.fromJson(x)))
          : [],
    );
  }
}