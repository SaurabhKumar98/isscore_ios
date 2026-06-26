import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/halloffamemodels/halloffame_models.dart';

class HallOfFameRepositories {
  final ApiClient _apiClient;

  HallOfFameRepositories(this._apiClient);

 Future<HallOfFameModels> getHallOfFame({
  int page = 1,
  int limit = 10,
  String? eventType, // ✅ ADD
}) async {
  try {
    final res = await _apiClient.get(
      '${ApiEndpoint.appBaseUrl}/hall-of-fame',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (eventType != null && eventType.isNotEmpty)
          'eventType': eventType, // ✅ FILTER
      },
    );

    return HallOfFameModels.fromJson(res.data as Map<String, dynamic>);
  } catch (e) {
    throw AppException('Failed to fetch hall of fame data.');
  }
}
}
