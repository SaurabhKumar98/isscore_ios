import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/examhall/examinstractionmodel.dart';

class ExaminstractionRepo {
  final ApiClient _apiClient = ApiClient();

  Future<Examinstructionsmodel> examintractionrepo(String testid) async {
    try {
      final result = await _apiClient.get(
        "${ApiEndpoint.appBaseUrl}/tests/$testid/exam-instructions",
      );
      return Examinstructionsmodel.fromJson(result as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
