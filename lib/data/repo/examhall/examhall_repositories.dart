import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/examhall/examhall_models.dart';
import 'package:firstedu/data/models/api_models/resourcestore/Categorymodels.dart';

class ExamHallRepository {
  final ApiClient _apiClient;

  ExamHallRepository(this._apiClient);

  // ─── Exam Hall Items ───────────────────────────────────────────────
  Future<ExamHallModels> getExamHall({
    String? type,
    String? categoryId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoint.examhall,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (type != null && type.isNotEmpty) 'type': type,
          if (categoryId != null && categoryId.isNotEmpty)
            'category': categoryId,
        },
      );

      if (response.data == null) {
        throw AppException('Empty response from server');
      }

      final model = ExamHallModels.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (model.success != true) {
        throw AppException(
          model.message?.isNotEmpty == true
              ? model.message!
              : 'Failed to load exam hall',
        );
      }

      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Something went wrong. Please try again.');
    }
  }

  // ─── Categories ────────────────────────────────────────────────────
  /// [linkedTo] — value expected by the backend, e.g. 'both' | 'test' | 'testBundle'
// ✅ Remove linkedTo entirely — same as store repo
Future<CategoryResponse> getCategories() async {
  try {
    final response = await _apiClient.get(
      ApiEndpoint.categories,
      // ✅ No queryParameters at all
    );

    if (response.data == null) {
      throw AppException('Empty response from server');
    }

    return CategoryResponse.fromJson(response.data as Map<String, dynamic>);
  } on AppException {
    rethrow;
  } catch (_) {
    throw AppException('Failed to load categories. Please try again.');
  }
}

}

// ─── Category Models ─────────────────────────────────────────────────────────

// class CategoryResponse {
//   final bool success;
//   final String message;
//   final List<CategoryModel> data;

//   CategoryResponse({
//     required this.success,
//     required this.message,
//     required this.data,
//   });

//   factory CategoryResponse.fromJson(Map<String, dynamic>? json) {
//     return CategoryResponse(
//       success: json?['success'] ?? false,
//       message: json?['message'] ?? '',
//       data:
//           (json?['data'] as List<dynamic>?)
//               ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           [],
//     );
//   }
// }

// class CategoryModel {
//   final String id;
//   final String name;
//   final int order;
//   final bool isActive;
//   final List<CategoryModel> children;

//   CategoryModel({
//     required this.id,
//     required this.name,
//     required this.order,
//     required this.isActive,
//     required this.children,
//   });

//   bool get hasChildren => children.isNotEmpty;

//   factory CategoryModel.fromJson(Map<String, dynamic>? json) {
//     return CategoryModel(
//       id: json?['_id'] ?? '',
//       name: json?['name'] ?? '',
//       order: json?['order'] ?? 0,
//       isActive: json?['isActive'] ?? true,
//       children:
//           (json?['children'] as List<dynamic>?)
//               ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           [],
//     );
//   }
// }
