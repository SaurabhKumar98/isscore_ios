import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/community_models/communitypostmodels.dart';

class CommunityRepository {
  final ApiClient _apiClient;

  CommunityRepository(this._apiClient);

  Future<CommunityModels> getCommunityPosts({
    int page = 1,
    int limit = 10,
    String? topic,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (topic != null && topic.isNotEmpty) 'topic': topic,
      };

      final response = await _apiClient.get(
        ApiEndpoint.userForums, // e.g. /user/forums
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw AppException(
          "Server returned empty response. Please try again.",
        );
      }

      final model = CommunityModels.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!model.success) {
        throw AppException(
          model.message.isNotEmpty
              ? model.message
              : "Failed to load community posts.",
        );
      }

      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException("Something went wrong. Please try again.");
    }
  }
}