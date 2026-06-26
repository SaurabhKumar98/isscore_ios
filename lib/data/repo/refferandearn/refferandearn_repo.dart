import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/refferandearnmodel/refferandearnmodel.dart';

class ReferAndEarnRepo {
  final ApiClient _apiClient;

  ReferAndEarnRepo(this._apiClient);

  Future<ReferAndEarnModel> getReferAndEarnData() async {
    try {
      final res = await _apiClient.get(
        '${ApiEndpoint.appBaseUrl}/refer-earn',
      );

      final data = res.data;

      if (data == null || data is! Map<String, dynamic>) {
        throw AppException('Invalid response format');
      }

      return ReferAndEarnModel.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to fetch refer & earn data.');
    }
  }
}