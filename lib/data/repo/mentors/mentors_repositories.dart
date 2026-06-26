import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/teacherconnect/mentorsmodels.dart';

class MentorsRepositories {
  final ApiClient _apiClient;
  MentorsRepositories(this._apiClient);

  Future<MentorResponse> getMentors({
    int page = 1,
    int limit = 10,
    String filter = 'all',
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (filter == 'online') 'presence': 'online',
if (filter == 'offline') 'presence': 'offline',
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _apiClient.get(
        ApiEndpoint.mentors,
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw AppException(
          "Server returned an empty response. Please try again.",
        );
      }

      final model = MentorResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!model.success) {
        throw AppException(
          model.message.isNotEmpty
              ? model.message
              : "Failed to load mentors. Please try again.",
        );
      }

      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException("Something went wrong. Please try again.");
    }
  }

  // ─────────────────── SUBMIT RATING ───────────────────
  //
  // POST /students/teachers/:teacherId/rate
  // Authorization: Bearer <student_jwt>
  // Body: { "rating": 5 }

  Future<bool> submitRating({
    required String teacherId,
    required int rating,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoint.mentors}/$teacherId/rate',
        data: <String, dynamic>{'rating': rating},
      );

      if (response.data == null) {
        throw AppException("Failed to submit rating. Please try again.");
      }

      final json = response.data as Map<String, dynamic>;
      return json['success'] == true;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException("Something went wrong. Please try again.");
    }
  }
}
