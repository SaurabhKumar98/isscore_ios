
import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/leaderboard/leaderboard_models.dart';

class LeaderboardRepository {
  final ApiClient _apiClient;

  LeaderboardRepository(this._apiClient);

  // ── GET list of events (olympiad or tournament) ───────────────────

  /// GET /student/leaderboard?type=olympiad&page=1&limit=5
Future<LeaderboardListResponse> getLeaderboardList({
  required String type,
  int page = 1,
  int limit = 10,
  String? categoryId,          // ← single nullable ID
}) async {
  try {
    final queryParams = <String, dynamic>{
      'type': type,
      'page': page,
      'limit': limit,
    };

    if (categoryId != null) {
      queryParams['category'] = categoryId;   // ← key name matches API
    }

    final response = await _apiClient.get(
      ApiEndpoint.leaderboard,
      queryParameters: queryParams,
    );

    if (response.data == null) throw AppException("Empty response from server");

    final model = LeaderboardListResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    if (!model.success) {
      throw AppException(model.message ?? "Failed to load leaderboard");
    }

    return model;
  } on AppException {
    rethrow;
  } catch (_) {
    throw AppException("Something went wrong");
  }
}
  // ── GET single event leaderboard by eventId ───────────────────────

  /// GET /student/leaderboard?type=olympiad&eventId=xxx
  Future<SingleLeaderboardResponse> getSingleLeaderboard({
    required String type,    // "olympiad" | "tournament"
    required String eventId,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoint.leaderboard,
        queryParameters: {
          'type': type,
          'eventId': eventId,
        },
      );

      if (response.data == null) {
        throw AppException("Empty response from server");
      }

      final model = SingleLeaderboardResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!model.success) {
        throw AppException(model.message ?? "Failed to load leaderboard");
      }

      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException("Something went wrong");
    }
  }
Future<CategoriesResponse> getCategories() async {
  try {
    final response = await _apiClient.get(
      '${ApiEndpoint.appBaseUrl}/categories',
    );

    if (response.data == null) {
      throw AppException("Empty response from server");
    }

    final model = CategoriesResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    if (!model.success) {
      throw AppException(model.message ?? "Failed to fetch categories");
    }

    return model;
  } on AppException {
    rethrow;
  } catch (_) {
    throw AppException("Failed to fetch categories");
  }
}

}