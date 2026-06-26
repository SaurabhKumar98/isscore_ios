import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/teacherconnect/agoratoken_models.dart';

class CallRepository {
  final ApiClient _apiClient;
  CallRepository(this._apiClient);

  /// POST /user/teacher-sessions/:sessionId/agora-token
  /// No body required. Auth via JWT header (handled by ApiClient).
  Future<AgoraTokenData> getAgoraToken(String sessionId) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoint.appBaseUrl}/teacher-sessions/$sessionId/agora-token',
      );

      if (response.data == null) {
        throw AppException('Empty response from server while fetching Agora token.');
      }

      final model = AgoraTokenModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!model.success) {
        throw AppException(
          model.message.isNotEmpty
              ? model.message
              : 'Failed to fetch Agora token.',
        );
      }

      return model.data;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Something went wrong while fetching call token.');
    }
  }
}