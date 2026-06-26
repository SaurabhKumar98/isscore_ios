import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/competetive/applycoupanmodels.dart';
import 'package:firstedu/data/models/api_models/olympiadcentermodel/olympiadcategory_models.dart';
import 'package:firstedu/data/models/api_models/olympiadcentermodel/olympiadcentermodels.dart';
import 'package:firstedu/data/models/api_models/olympiadcentermodel/olympiaddetailsmodels.dart';
import 'package:firstedu/data/models/api_models/olympiadcentermodel/olympiadpaymentmodels.dart';

class OlympiadCenterRepositories {
  final ApiClient _apiClient;

  OlympiadCenterRepositories(this._apiClient);

  // ── GET /user/categories?rootType=Olympiads&format=tree ──────────────────

  Future<OlympiadCategoryResponseModel> getCategories() async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoint.appBaseUrl}/categories',
        queryParameters: {
          'rootType': 'Olympiads',
          'format': 'tree',
        },
      );

      if (response.data == null) throw AppException('Empty response from server');

      final model = OlympiadCategoryResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (model.success != true) {
        throw AppException(
          model.message?.isNotEmpty == true
              ? model.message!
              : 'Failed to load categories',
        );
      }

      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Something went wrong. Please try again.');
    }
  }

  // ── GET /olympiads ────────────────────────────────────────────────────────

  Future<OlympiadCenterResponseModel> getOlympiad({
    int page = 1,
    int limit = 10,
    String? status,
    String? categoryId,
    String? search,
    bool registeredOnly = false,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoint.olympiad,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
          if (categoryId != null) 'categoryId': categoryId,
          if (search != null && search.isNotEmpty) 'search': search,
          if (registeredOnly) 'registeredOnly': 'true',
        },
      );

      if (response.data == null) throw AppException('Empty response from server');

      final model = OlympiadCenterResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (model.success != true) {
        throw AppException(
          model.message?.isNotEmpty == true
              ? model.message!
              : 'Failed to load olympiads',
        );
      }

      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Something went wrong. Please try again.');
    }
  }


  Future<OlympiadDetailsModels> getOlympiadDetail(String olympiadId) async {
    try {
      final response =
          await _apiClient.get('${ApiEndpoint.olympiad}/$olympiadId');

      if (response.data == null) throw AppException('Empty response from server');

      final model = OlympiadDetailsModels.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (model.success != true) {
        throw AppException(
          model.message?.isNotEmpty == true
              ? model.message!
              : 'Failed to load olympiad details',
        );
      }

      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Something went wrong. Please try again.');
    }
  }

  // ── POST /olympiads/:id/initiate-payment ──────────────────────────────────

  Future<OlympiadInitiatePaymentResponse> initiatePayment({
    required String olympiadId,
    required String method,
    String? couponCode,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoint.olympiad}/$olympiadId/initiate-payment',
        data: {
          'paymentMethod': method,
          if (couponCode != null && couponCode.isNotEmpty)
            'couponCode': couponCode,
        },
      );

      if (response.data == null) throw AppException('Empty response from server');

      final model = OlympiadInitiatePaymentResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (model.success != true) {
        throw AppException(
          model.message?.isNotEmpty == true
              ? model.message!
              : 'Failed to initiate payment',
        );
      }

      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Something went wrong. Please try again.');
    }
  }

  // ── POST /olympiads/:id/register ──────────────────────────────────────────

  Future<void> completeRazorpayRegistration({
    required String olympiadId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoint.olympiad}/$olympiadId/register',
        data: {
          'razorpayOrderId': razorpayOrderId,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpaySignature': razorpaySignature,
        },
      );

      if (response.data == null) throw AppException('Empty response from server');

      final json = response.data as Map<String, dynamic>;
      if (json['success'] != true) {
        throw AppException(
          (json['message'] as String?)?.isNotEmpty == true
              ? json['message']
              : 'Registration failed',
        );
      }
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Something went wrong. Please try again.');
    }
  }

  // ── POST /coupons/apply ───────────────────────────────────────────────────

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
}