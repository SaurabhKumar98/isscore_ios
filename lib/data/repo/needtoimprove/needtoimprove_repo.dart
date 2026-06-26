import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/needtoimprove/needtoimprove_models.dart';

class NeedToImproveRepo {
  final ApiClient _apiClient;

  NeedToImproveRepo(this._apiClient);

  Future<NeedToImproveModel> getNeedToImproveData() async {
    try {
      final res = await _apiClient.get(
        '${ApiEndpoint.appBaseUrl}/need-to-improve',
      );

      final data = res.data;

      if (data == null || data is! Map<String, dynamic>) {
        throw AppException('Invalid response format');
      }

      return NeedToImproveModel.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to fetch need to improve data.');
    }
  }
}