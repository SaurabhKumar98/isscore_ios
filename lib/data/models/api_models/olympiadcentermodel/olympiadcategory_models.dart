/// Model for GET /user/categories?rootType=Olympiads&format=tree

class OlympiadCategoryResponseModel {
  final bool? success;
  final String? message;
  final List<OlympiadCategoryData>? data;

  OlympiadCategoryResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory OlympiadCategoryResponseModel.fromJson(Map<String, dynamic> json) {
    return OlympiadCategoryResponseModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) =>
              OlympiadCategoryData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OlympiadCategoryData {
  final String? id;
  final String? name;
  final String? kind;
  final List<OlympiadCategoryData>? children;

  OlympiadCategoryData({
    this.id,
    this.name,
    this.kind,
    this.children,
  });

  factory OlympiadCategoryData.fromJson(Map<String, dynamic> json) {
    return OlympiadCategoryData(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      kind: json['kind'] as String?,
      children: (json['children'] as List<dynamic>?)
          ?.map((e) =>
              OlympiadCategoryData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Flatten this node + all descendants into a flat list.
  List<OlympiadCategoryData> flatten() {
    final result = <OlympiadCategoryData>[this];
    for (final child in children ?? []) {
      result.addAll(child.flatten());
    }
    return result;
  }
}