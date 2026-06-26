
import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/challengeyourself/challengeyourself_models.dart';
import 'package:firstedu/data/models/api_models/competetive/applycoupanmodels.dart';

class ChallengeYourselfRepository {
  final ApiClient _apiClient;

  ChallengeYourselfRepository(this._apiClient);

  Future<ChallengeYourselfModel> getChallengeYourself({
    String? categoryId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams['categoryId'] = categoryId;
      }

      final response = await _apiClient.get(
        ApiEndpoint.challengeYourself,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.data == null) {
        throw AppException('Server returned an empty response.');
      }

      final model = ChallengeYourselfModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (model.success != true) {
        throw AppException(
          (model.message != null && model.message!.isNotEmpty)
              ? model.message!
              : 'Failed to load challenge data.',
        );
      }

      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Something went wrong. Please try again.');
    }
  }


  Future<ApplyCouponModels> applyCoupon({
    required String code,
    required int amount,
    required String module,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoint.appBaseUrl}/coupons/apply',
        data: {
          'code': code.trim().toUpperCase(),
          'amount': amount,
          'module': module,
        },
      );

      if (response.data == null) {
        throw AppException('Empty response from server.');
      }

      final model = ApplyCouponModels.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (model.success != true) {
        throw AppException(
          (model.message?.isNotEmpty ?? false)
              ? model.message!
              : 'Invalid coupon code.',
        );
      }

      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Failed to apply coupon. Please try again.');
    }
  }
}