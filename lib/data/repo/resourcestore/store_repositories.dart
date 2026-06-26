// lib/data/repo/resourcestore/store_repositories.dart

import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/competetive/applycoupanmodels.dart';
import 'package:firstedu/data/models/api_models/resourcestore/Categorymodels.dart';
import 'package:firstedu/data/models/api_models/resourcestore/storemodels.dart';
import 'package:firstedu/data/models/api_models/resourcestore/storepaymentmodels.dart';

class StoreRepository {
  final ApiClient _apiClient;

  StoreRepository(this._apiClient);


Future<StoreModels> getTestsAndBundles({
  String type = 'all',          // ← 'all' instead of 'both'
  int page = 1,
  int limit = 9,                // ← matches your API example
  String? search,
  String? category,
  String sortBy = 'createdAt',
  String sortOrder = 'desc',
}) async {
  try {
    final queryParams = <String, dynamic>{
      'type': type,
      'page': page,
      'limit': limit,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
      if (search != null && search.isNotEmpty) 'search': search,
      if (category != null && category.isNotEmpty) 'category': category,
    };
  

      final response = await _apiClient.get(
        ApiEndpoint.testsAndBundles,
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw AppException(
          "Server returned an empty response. Please try again.",
        );
      }

      final model = StoreModels.fromJson(response.data as Map<String, dynamic>);

      if (model.success == false) {
        throw AppException(
          model.message?.isNotEmpty ?? false
              ? model.message!
              : "Failed to load store items. Please try again.",
        );
      }

      return model;
    } on AppException {
      rethrow;
    } catch (e) {
  print("ERROR: $e"); // 🔥 DEBUG
  throw AppException(e.toString());
}
  }

 Future<CategoryResponse> getCategories() async {
  try {
    final response = await _apiClient.get(ApiEndpoint.categories);

    if (response.data == null) {
      throw AppException("Server returned an empty response. Please try again.");
    }

    final model = CategoryResponse.fromJson(response.data as Map<String, dynamic>);

    if (!model.success) {
      throw AppException(
        model.message.isNotEmpty ? model.message : "Failed to load categories. Please try again.",
      );
    }

    return model;
  } on AppException {
    rethrow;
  } catch (_) {
    throw AppException("Something went wrong. Please try again.");
  }
}
Future<ApplyCouponModels> applyCoupon({
  required String code,
  required int amount,
  required String module,   // ✅ renamed from itemType
}) async {
  try {
    final response = await _apiClient.post(
      '${ApiEndpoint.appBaseUrl}/coupons/apply',
      data: {
        'code': code.trim().toUpperCase(),
        'amount': amount,
        'module': module,   // ✅ key is 'module', not 'itemType'
      },
    );

    if (response.data == null)
      throw AppException('Empty response from server.');

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
 
 
  Future<StorePaymentResponse> initiatePayment({
    required String itemId,
    required String itemType, // 'test' or 'testBundle'
    required String paymentMethod,
    String? couponCode,
  }) async {
    try {
      final body = <String, dynamic>{
        'paymentMethod': paymentMethod,
        if (couponCode != null && couponCode.isNotEmpty)
          'couponCode': couponCode,
      };

      // ✅ Route to correct endpoint based on item type
      final String endpoint = itemType == 'testBundle'
          ? '/test-bundles/$itemId/initiate-payment'
          : '/tests/$itemId/initiate-payment';

      final response = await _apiClient.post(
        "${ApiEndpoint.appBaseUrl}$endpoint",
        data: body,
      );

      if (response.data == null) {
        throw AppException(
          "Server returned an empty response. Please try again.",
        );
      }

      final model = StorePaymentResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!(model.success ?? false)) {
        throw AppException(
          (model.message?.isNotEmpty ?? false)
              ? model.message!
              : "Payment initiation failed. Please try again.",
        );
      }

      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException("Something went wrong. Please try again.");
    }
  }

  Future<StorePurchaseResponse> completeRazorpayPurchase({
    required String itemId,
    required String itemType, // 'test' or 'testBundle'
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final body = {
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
      };

      // ✅ Route to correct endpoint based on item type
      final String endpoint = itemType == 'testBundle'
          ? '/test-bundles/$itemId/purchase'
          : '/tests/$itemId/purchase';

      final response = await _apiClient.post(
        "${ApiEndpoint.appBaseUrl}$endpoint",
        data: body,
      );

      if (response.data == null) {
        throw AppException(
          "Server returned an empty response. Please try again.",
        );
      }

      final model = StorePurchaseResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!(model.success ?? false)) {
        throw AppException(
          model.message ??
              "Purchase verification failed. Please contact support.",
        );
      }

      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException("Something went wrong. Please try again.");
    }
  }

}
