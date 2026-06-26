import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/certificatedownload/certificatedownload_models.dart';

class CertificatedownloadRepo {
  final ApiClient _apiClient;
  CertificatedownloadRepo(this._apiClient);

  Future<CertificateDownloadModels> getCertificate({
    int page = 1, int limit = 10
  }) async {
    try{
       final res = await _apiClient.get(
        '${ApiEndpoint.appBaseUrl}/certificates',
        queryParameters: {'page': page, 'limit': limit},
      );
      return CertificateDownloadModels.fromJson(res.data as Map<String,dynamic>);
    }
    on AppException {
      rethrow;
    }catch(e){
       throw AppException('Failed to Download Certificate.');
    }
  }
}