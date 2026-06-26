import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/coursedownload/purchasecourse.dart';

class DownloadCourseRepositories {
  final ApiClient _apiClient;
  DownloadCourseRepositories(this._apiClient);

  /// General or Certification courses
  /// GET /user/my-courses?page=1&limit=10&isCertification=false/true
  Future<PurchasedChourseModels> getCourseDownloads({
    required bool isCertification,
    String? type,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'isCertification': isCertification,
        if (type != null) 'contentType': type.toLowerCase(),
      };

      final response = await _apiClient.get(
        ApiEndpoint.myCourses, // → /user/my-courses
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw AppException('Server returned empty response');
      }

      final model = PurchasedChourseModels.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (model.success != true) {
        throw AppException(
            model.message ?? 'Failed to load courses');
      }

      return model;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Something went wrong while loading courses');
    }
  }

  /// Free Materials
  /// GET /user/my-courses?isFreeMaterial=true&fetchSubcategories=true&pillarName=School
  Future<PurchasedChourseModels> getFreeMaterials({
    String? pillarName,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'isFreeMaterial': true,
        'fetchSubcategories': true,
        'page': page,
        'limit': limit,
        if (pillarName != null && pillarName.isNotEmpty)
          'pillarName': pillarName,
      };

      final response = await _apiClient.get(
        ApiEndpoint.myCourses, // → /user/my-courses
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw AppException('Server returned empty response');
      }

      final model = PurchasedChourseModels.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (model.success != true) {
        throw AppException(
            model.message ?? 'Failed to load free materials');
      }

      return model;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
          'Something went wrong while loading free materials');
    }
  }
}