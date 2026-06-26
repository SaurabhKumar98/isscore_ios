import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/competetive/applycoupanmodels.dart';
import 'package:firstedu/data/models/api_models/workshops_models/workshopmodels.dart';
import 'package:firstedu/data/models/api_models/workshops_models/workshopsbyidmodels.dart';
import 'package:firstedu/data/repo/workshops/paymentmodels.dart';

class WorkshopRepository {
  final ApiClient _apiClient;
  WorkshopRepository(this._apiClient);

  Future<WorkshopResponse> getWorkshops({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (status != null && status.toLowerCase() != 'all')
          'status': status.toLowerCase(),
      };
      final response = await _apiClient.get(
        ApiEndpoint.workshop,
        queryParameters: params,
      );
      if (response.data == null) throw AppException('Empty response.');
      final model =
          WorkshopResponse.fromJson(response.data as Map<String, dynamic>);
      if (!model.success) {
        throw AppException(
            model.message.isNotEmpty ? model.message : 'Failed to load workshops.');
      }
      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Something went wrong. Please try again.');
    }
  }

  Future<WorkshopDetailsResponse> getWorkshopDetails(String id) async {
    try {
      final response = await _apiClient.get('${ApiEndpoint.workshop}/$id');
      if (response.data == null) throw AppException('Empty response.');
      final model = WorkshopDetailsResponse.fromJson(
          response.data as Map<String, dynamic>);
      if (!model.success) {
        throw AppException(model.message.isNotEmpty
            ? model.message
            : 'Failed to load workshop details.');
      }
      return model;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Something went wrong: $e');
    }
  }

  // ── POST initiate-payment — now accepts optional couponCode ──────────────

  Future<InitiatePaymentResponse> initiatePayment({
    required String workshopId,
    required PaymentMethod method,
    String? couponCode, // ← added
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoint.workshop}/$workshopId/initiate-payment',
        data: {
          'paymentMethod': method.value,
          if (couponCode != null && couponCode.isNotEmpty)
            'couponCode': couponCode,
        },
      );
      if (response.data == null) throw AppException('Empty response.');
      final model = InitiatePaymentResponse.fromJson(
          response.data as Map<String, dynamic>);
      if (!model.success) {
        throw AppException(
            model.message.isNotEmpty ? model.message : 'Payment initiation failed.');
      }
      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Something went wrong. Please try again.');
    }
  }

  Future<CompleteRegistrationResponse> completeRegistration({
    required String workshopId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoint.workshop}/$workshopId/register',
        data: {
          'razorpayOrderId': razorpayOrderId,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpaySignature': razorpaySignature,
        },
      );
      if (response.data == null) throw AppException('Empty response.');
      final model = CompleteRegistrationResponse.fromJson(
          response.data as Map<String, dynamic>);
      if (!model.success) {
        throw AppException(
            model.message.isNotEmpty ? model.message : 'Registration failed.');
      }
      return model;
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
 
 

}