import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/merchandise_models/merchandiseclaimedmodels.dart';
import 'package:firstedu/data/models/api_models/merchandise_models/merchandisedetailsmodels.dart';
import 'package:firstedu/data/models/api_models/merchandise_models/merchandisefetchclaimedmodels.dart';
import 'package:firstedu/data/models/api_models/merchandise_models/merchandisemodels.dart';

class MerchandiseRepository {
  final ApiClient _apiClient;

  MerchandiseRepository(this._apiClient);

  // ──────────────────────────────────────────────────────────────
  // 1. GET /user/merchandise  — list with pagination
  // ──────────────────────────────────────────────────────────────
  Future<MerchandiseModels> getMerchandise({
    int page = 1,
    int limit = 10,
    String? category,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (category != null && category.isNotEmpty) 'category': category,
      };

      final response = await _apiClient.get(
        ApiEndpoint.merchandise,
        queryParameters: query,
      );

      final data = response.data;
      if (data == null) throw AppException('Server returned an empty response.');

      final model =
          MerchandiseModels.fromJson(Map<String, dynamic>.from(data));

      if (!model.success) {
        throw AppException(model.message.isNotEmpty
            ? model.message
            : 'Failed to load merchandise.');
      }

      return model;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  // ──────────────────────────────────────────────────────────────
  // 2. GET /user/merchandise/:id  — single item detail
  // ──────────────────────────────────────────────────────────────
  Future<MerchandiseDetailsModels> getMerchandiseById(String id) async {
    try {
      final response =
          await _apiClient.get('${ApiEndpoint.merchandise}/$id');

      final data = response.data;
      if (data == null) throw AppException('Server returned an empty response.');

      final model = MerchandiseDetailsModels.fromJson(
          Map<String, dynamic>.from(data));

      if (!model.success) {
        throw AppException(model.message.isNotEmpty
            ? model.message
            : 'Failed to load merchandise details.');
      }

      return model;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  // ──────────────────────────────────────────────────────────────
  // 3. POST /user/merchandise/:id/claim  — claim via points
  // ──────────────────────────────────────────────────────────────
  Future<MerchandiseClaimedModels> claimMerchandise({
    required String merchandiseId,
    Map<String, dynamic>? deliveryAddress,
  }) async {
    try {
      final body = <String, dynamic>{
        if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
      };

      final response = await _apiClient.post(
        '${ApiEndpoint.merchandise}/$merchandiseId/claim',
        data: body,
      );

      final data = response.data;
      if (data == null) throw AppException('Server returned an empty response.');

      final model = MerchandiseClaimedModels.fromJson(
          Map<String, dynamic>.from(data));

      if (!model.success) {
        throw AppException(model.message.isNotEmpty
            ? model.message
            : 'Failed to claim merchandise.');
      }

      return model;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  // ──────────────────────────────────────────────────────────────
  // 4. POST /user/merchandise/:id/initiate-payment
  //    paymentMethod: 'wallet' | 'razorpay' | 'free'
  // ──────────────────────────────────────────────────────────────
  Future<MerchandiseInitiatePaymentModels> initiatePayment({
    required String merchandiseId,
    required String paymentMethod,
    String? couponCode,
  }) async {
    try {
      final body = <String, dynamic>{
        'paymentMethod': paymentMethod,
        if (couponCode != null && couponCode.isNotEmpty)
          'couponCode': couponCode,
      };

      final response = await _apiClient.post(
        '${ApiEndpoint.merchandise}/$merchandiseId/initiate-payment',
        data: body,
      );

      final data = response.data;
      if (data == null) throw AppException('Server returned an empty response.');

      final model = MerchandiseInitiatePaymentModels.fromJson(
          Map<String, dynamic>.from(data));

      if (!model.success) {
        throw AppException(model.message.isNotEmpty
            ? model.message
            : 'Payment initiation failed.');
      }

      return model;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  // ──────────────────────────────────────────────────────────────
  // 5. POST /user/merchandise/:id/confirm-payment  — Razorpay only
  // ──────────────────────────────────────────────────────────────
  Future<MerchandiseClaimedModels> confirmPayment({
    required String merchandiseId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
    Map<String, dynamic>? deliveryAddress,
  }) async {
    try {
      final body = <String, dynamic>{
        'razorpayPaymentId': razorpayPaymentId,
        'razorpayOrderId': razorpayOrderId,
        'razorpaySignature': razorpaySignature,
        if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
      };

      final response = await _apiClient.post(
        '${ApiEndpoint.merchandise}/$merchandiseId/confirm-payment',
        data: body,
      );

      final data = response.data;
      if (data == null) throw AppException('Server returned an empty response.');

      final model = MerchandiseClaimedModels.fromJson(
          Map<String, dynamic>.from(data));

      if (!model.success) {
        throw AppException(model.message.isNotEmpty
            ? model.message
            : 'Payment confirmation failed.');
      }

      return model;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  // ──────────────────────────────────────────────────────────────
  // 6. POST /coupons/apply  — validate & apply a coupon code
  // ──────────────────────────────────────────────────────────────
  Future<MerchandiseApplyCouponModels> applyCoupon({
    required String code,
    required int amount,
    String module = 'merchandise',
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

      final data = response.data;
      if (data == null) throw AppException('Empty response from server.');

      final model = MerchandiseApplyCouponModels.fromJson(
          Map<String, dynamic>.from(data));

      if (!model.success) {
        throw AppException(
            model.message.isNotEmpty ? model.message : 'Invalid coupon code.');
      }

      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Failed to apply coupon. Please try again.');
    }
  }

  // ──────────────────────────────────────────────────────────────
  // 7. GET /user/merchandise/my-claims  — paginated claims history
  // ──────────────────────────────────────────────────────────────
  Future<MerchandiseClaimedFetchModels> getMyClaims({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoint.merchandise}/my-claims',
        queryParameters: {'page': page, 'limit': limit},
      );

      final data = response.data;
      if (data == null) throw AppException('Server returned an empty response.');

      final model = MerchandiseClaimedFetchModels.fromJson(
          Map<String, dynamic>.from(data));

      if (!model.success) {
        throw AppException(
            model.message.isNotEmpty ? model.message : 'Failed to load claims.');
      }

      return model;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}