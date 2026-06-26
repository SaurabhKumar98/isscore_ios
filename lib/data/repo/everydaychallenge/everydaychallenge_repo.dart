import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/everydaychallenge/everydaychallenge_models.dart';

class EverydaychallengeRepo {
  final ApiClient _apiClient;
  EverydaychallengeRepo(this._apiClient);

  Future<EveryDayChallengesModels> getEveryDayChallenge({
    int page = 1, int limit = 10
  }) async {
    try{
      final res = await _apiClient.get(
        '${ApiEndpoint.appBaseUrl}/everyday-challenges',
        queryParameters: {'page': page, 'limit': limit},
      );
      return EveryDayChallengesModels.fromJson(res.data as Map<String, dynamic>);
    }on AppException {
      rethrow;
    }catch(e){
       throw AppException('Failed to fetch EveryDayChallenge.');
    }
  }
}