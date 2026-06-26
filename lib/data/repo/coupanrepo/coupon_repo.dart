// lib/data/repo/coupon/coupon_repo.dart

import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/competetive/applycoupanmodels.dart';


class CouponRepo {
  final ApiClient _apiClient;

  CouponRepo(this._apiClient);

  Future<ApplyCouponModels> applyCoupon({
    required String code,
    required int amount,
    required String itemType,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoint.appBaseUrl}/coupons/apply',
        data: {
          'code': code.trim().toUpperCase(),
          'amount': amount,
          'itemType': itemType,
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