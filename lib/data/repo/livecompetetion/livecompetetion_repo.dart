import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/livecompetetion/livecompetetion_models.dart';

class LiveCompetitionDrawerRepository {
  final ApiClient _apiClient;

  // ✅ IMPORTANT: Pass SAME ApiClient instance
  LiveCompetitionDrawerRepository(this._apiClient);

  // ─────────────────────────────────────────────────────────────
  // GET ALL LIVE COMPETITION CATEGORIES
  // ─────────────────────────────────────────────────────────────
  Future<LiveCompetetionDrawerModels> getAllLiveCompetitions() async {
    try {
      final response = await _apiClient.get(
        "${ApiEndpoint.appBaseUrl}/live-competition-categories",
      );

      /// ✅ Safety check
      if (response.data == null) {
        throw AppException("Empty response from server");
      }

      /// ✅ Parse response
      final model = LiveCompetetionDrawerModels.fromJson(
        response.data as Map<String, dynamic>,
      );

      /// ✅ Handle API failure
      if (model.success != true) {
        throw AppException(
          model.message ?? "Failed to load live competitions",
        );
      }

      return model;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        "Something went wrong while fetching live competitions",
      );
    }
  }
}