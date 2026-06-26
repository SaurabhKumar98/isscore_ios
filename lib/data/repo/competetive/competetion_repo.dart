// ── competetion_repo.dart (updated getAvailableTests) ───────────────────────
// Only adds `search` to the query when the rootType supports it on the
// student route.  Currently: Competitive ✅  |  School ❌ (admin-only)

import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/competetive/applycoupanmodels.dart';
import 'package:firstedu/data/models/api_models/competetive/avilabletestcompetetionmodels.dart';
import 'package:firstedu/data/models/api_models/competetive/competetionbyid_models.dart';
import 'package:firstedu/data/models/api_models/competetive/competetionsingleidby_models.dart';
import 'package:firstedu/data/models/api_models/competetive/purchasecompetetionmodels.dart';
import 'package:firstedu/data/models/api_models/competetive/purchaseconfirmmodels.dart';
import 'package:firstedu/data/models/api_models/competetive/subcategorydetilsmodels.dart';
import 'package:firstedu/data/models/api_models/olympiadcentermodel/olympiadcategory_models.dart';
import 'package:flutter/material.dart';

class CompetitionRepository {
  final ApiClient _apiClient;

  CompetitionRepository(this._apiClient);

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER — does this rootType support `search` on the STUDENT route?
  // School → NO  (search only works on admin route for school tests)
  // Everything else (Competitive, Olympiad, Skill Development…) → YES
  // ══════════════════════════════════════════════════════════════════════════
  static bool _supportsSearch(String? rootType) {
    return (rootType ?? '').toLowerCase() != 'school';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ALL COMPETITIONS
  // ══════════════════════════════════════════════════════════════════════════

  Future<CompetationDetailModels> getAllCompetitions({
    required String rootType,
    int page = 1,
    int limit = 10,
    String? categoryId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        "path": "",
        "rootType": rootType,
        "page": page,
        "limit": limit,
      };
      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams["categoryId"] = categoryId;
      }

      final response = await _apiClient.get(
        '${ApiEndpoint.competitions}/resolve-path',
        queryParameters: queryParams,
      );

      debugPrint("🌐 getAllCompetitions → rootType=$rootType, categoryId=$categoryId");
      debugPrint("🌐 Query params: $queryParams");

      if (response.data == null) throw AppException('Empty response');

      final model = CompetationDetailModels.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (model.success != true) throw AppException(model.message ?? "Failed");

      return model;
    } catch (e) {
      debugPrint("❌ ERROR: $e");
      throw AppException(e.toString());
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CATEGORY TREE
  // ══════════════════════════════════════════════════════════════════════════

  Future<OlympiadCategoryResponseModel> getCategoryTree(String rootType) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoint.appBaseUrl}/categories',
        queryParameters: {"rootType": rootType, "format": "tree"},
      );
      if (response.data == null) throw AppException('Empty response');
      return OlympiadCategoryResponseModel.fromJson(
          response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint("❌ CATEGORY TREE ERROR: $e");
      throw AppException(e.toString());
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // COMPETITION BY PATH
  // ══════════════════════════════════════════════════════════════════════════

  Future<CompetationDetailModels> getCompetitionByPath(
    String path,
    String rootType, {
    String? categoryId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        "path": path.toLowerCase(),
        "rootType": rootType,
      };
      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams["categoryId"] = categoryId;
      }

      final response = await _apiClient.get(
        '${ApiEndpoint.competitions}/resolve-path',
        queryParameters: queryParams,
      );

      if (response.data == null) throw AppException('Empty response from server.');

      final model = CompetationDetailModels.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (model.success != true) {
        throw AppException(
          (model.message?.isNotEmpty ?? false)
              ? model.message!
              : 'Failed to load competition details.',
        );
      }

      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Something went wrong. Please try again.');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CATEGORY DETAIL
  // ══════════════════════════════════════════════════════════════════════════

  Future<CompetitionSubDetailModel> getCategoryDetail(String id) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoint.competitions}/$id/detail',
      );
      if (response.data == null) throw AppException('Empty response');
      final model = CompetitionSubDetailModel.fromJson(
          response.data as Map<String, dynamic>);
      if (model.success != true) throw AppException(model.message ?? "Failed");
      return model;
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // AVAILABLE TESTS
  // ── KEY CHANGE: `search` is only appended when _supportsSearch(rootType)
  //   is true, i.e. everything EXCEPT School on the student route.
  // ══════════════════════════════════════════════════════════════════════════

  Future<AvailableTestsModel> getAvailableTests({
    required String categoryId,
    String? rootType,
    String? search,          // ← NEW param
    int page = 1,
    int limit = 100,
  }) async {
    String endpoint;
    switch ((rootType ?? '').toLowerCase()) {
      case "school":
        endpoint = "/school-tests";
        break;
      case "skill development":
      case "skill":
        endpoint = "/skill-tests";
        break;
      default:
        endpoint = "/competitive-tests";
    }

    // Build query params
    final queryParams = <String, dynamic>{
      "categoryId": categoryId,
      "page": page,
      "limit": limit,
    };

    // ── CONDITIONAL SEARCH ─────────────────────────────────────────────────
    // School student route does NOT support ?search — skip it entirely.
    // All other routes (Competitive, Olympiad, Skill…) DO support it.
    if (_supportsSearch(rootType) &&
        search != null &&
        search.trim().isNotEmpty) {
      queryParams["search"] = search.trim();
    }
    // ───────────────────────────────────────────────────────────────────────

    debugPrint("🚀 getAvailableTests → $endpoint | rootType=$rootType | search=$search | supportsSearch=${_supportsSearch(rootType)}");
    debugPrint("🚀 Query: $queryParams");

    final response = await _apiClient.get(
      "${ApiEndpoint.appBaseUrl}$endpoint",
      queryParameters: queryParams,
    );

    return AvailableTestsModel.fromJson(response.data);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SINGLE COMPETITION
  // ══════════════════════════════════════════════════════════════════════════

  Future<CompetitionSingleIdByModels> getSingleCompetition(
    String competitionId,
  ) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoint.competitions}/single/$competitionId',
      );
      if (response.data == null) throw AppException('Empty response from server.');
      final model = CompetitionSingleIdByModels.fromJson(
          response.data as Map<String, dynamic>);
      if (!model.success) {
        throw AppException(
          model.message.isNotEmpty ? model.message : 'Failed to load competition.',
        );
      }
      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Something went wrong. Please try again.');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // APPLY COUPON
  // ══════════════════════════════════════════════════════════════════════════

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
      if (response.data == null) throw AppException('Empty response from server.');
      final model = ApplyCouponModels.fromJson(response.data as Map<String, dynamic>);
      if (model.success != true) {
        throw AppException(
          (model.message?.isNotEmpty ?? false) ? model.message! : 'Invalid coupon code.',
        );
      }
      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Failed to apply coupon. Please try again.');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // INITIATE CATEGORY PAYMENT
  // ══════════════════════════════════════════════════════════════════════════

  Future<PurchaseCompetetionModels> initiateCategoryPayment({
    required String categoryId,
    required String paymentMethod,
    String? couponCode,
  }) async {
    try {
      final body = <String, dynamic>{
        'categoryId': categoryId,
        'paymentMethod': paymentMethod,
      };
      if (couponCode != null && couponCode.trim().isNotEmpty) {
        body['couponCode'] = couponCode.trim();
      }
      final response = await _apiClient.post(
        '${ApiEndpoint.competitions}/$categoryId/initiate-payment',
        data: body,
      );
      if (response.data == null) throw AppException('Empty response from server.');
      final model = PurchaseCompetetionModels.fromJson(response.data as Map<String, dynamic>);
      if (model.success != true) {
        throw AppException(
          (model.message?.isNotEmpty ?? false) ? model.message! : 'Payment initiation failed.',
        );
      }
      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Something went wrong. Please try again.');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // COMPLETE CATEGORY RAZORPAY PAYMENT
  // ══════════════════════════════════════════════════════════════════════════

  Future<PurchaseconfirmedModels> completeCategoryRazorpayPayment({
    required String categoryId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoint.competitions}/$categoryId/confirm-payment',
        data: {
          'categoryId': categoryId,
          'razorpayOrderId': razorpayOrderId,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpaySignature': razorpaySignature,
        },
      );
      if (response.data == null) throw AppException('Empty response from server.');
      final model = PurchaseconfirmedModels.fromJson(response.data as Map<String, dynamic>);
      if (model.success != true) {
        throw AppException(
          (model.message?.isNotEmpty ?? false) ? model.message! : 'Payment verification failed.',
        );
      }
      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Payment verification failed. Contact support.');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // INITIATE / CONFIRM UPGRADE
  // ══════════════════════════════════════════════════════════════════════════

  Future<PurchaseCompetetionModels> initiateUpgrade({
    required String categoryId,
    required String paymentMethod,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoint.competitions}/$categoryId/checkout-upgrade',
        data: {'paymentMethod': paymentMethod},
      );
      if (response.data == null) throw AppException('Empty response from server.');
      final model = PurchaseCompetetionModels.fromJson(response.data as Map<String, dynamic>);
      if (model.success != true) {
        throw AppException(
          (model.message?.isNotEmpty ?? false) ? model.message! : 'Upgrade initiation failed.',
        );
      }
      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Something went wrong. Please try again.');
    }
  }

  Future<PurchaseconfirmedModels> confirmUpgrade({
    required String categoryId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoint.competitions}/$categoryId/confirm-upgrade',
        data: {
          'categoryId': categoryId,
          'razorpayOrderId': razorpayOrderId,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpaySignature': razorpaySignature,
        },
      );
      if (response.data == null) throw AppException('Empty response from server.');
      final model = PurchaseconfirmedModels.fromJson(response.data as Map<String, dynamic>);
      if (model.success != true) {
        throw AppException(
          (model.message?.isNotEmpty ?? false) ? model.message! : 'Upgrade confirmation failed.',
        );
      }
      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Upgrade confirmation failed. Contact support.');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // INITIATE / COMPLETE TEST PAYMENT
  // ══════════════════════════════════════════════════════════════════════════

  Future<PurchaseCompetetionModels> initiateTestPayment({
    required String testId,
    required String paymentMethod,
    String? couponCode,
  }) async {
    try {
      final body = <String, dynamic>{'paymentMethod': paymentMethod};
      if (couponCode != null && couponCode.trim().isNotEmpty) {
        body['couponCode'] = couponCode.trim();
      }
      final response = await _apiClient.post(
        '${ApiEndpoint.appBaseUrl}/tests/$testId/initiate-payment',
        data: body,
      );
      if (response.data == null) throw AppException('Empty response from server.');
      final model = PurchaseCompetetionModels.fromJson(response.data as Map<String, dynamic>);
      if (model.success != true) {
        throw AppException(
          (model.message?.isNotEmpty ?? false) ? model.message! : 'Payment initiation failed.',
        );
      }
      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Something went wrong. Please try again.');
    }
  }

Future<PurchaseconfirmedModels> completeTestRazorpayPayment({
  required String testId,
  required String razorpayOrderId,
  required String razorpayPaymentId,
  required String razorpaySignature,
}) async {
  try {
    final response = await _apiClient.post(
      '${ApiEndpoint.appBaseUrl}/tests/$testId/purchase',
      data: {
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
      },
    );

    debugPrint("🧾 completeTestRazorpayPayment raw response: ${response.data}");

    if (response.data == null) throw AppException('Empty response from server.');

    final model = PurchaseconfirmedModels.fromJson(
      response.data as Map<String, dynamic>,
    );

    // ── KEY FIX: treat 201 Created as success too ─────────────────────────
    // Your API returns 201 for a new purchase record, not 200.
    // If success field is missing or null but statusCode is 2xx, still pass.
    final statusCode = response.statusCode ?? 200;
    final isSuccess = model.success == true || (statusCode >= 200 && statusCode < 300);

    if (!isSuccess) {
      throw AppException(
        (model.message?.isNotEmpty ?? false)
            ? model.message!
            : 'Payment verification failed.',
      );
    }

    return model;
  } on AppException {
    rethrow;
  } catch (e, stack) {
    debugPrint("❌ completeTestRazorpayPayment error: $e");
    debugPrint("❌ Stack: $stack");
    throw AppException('Payment verification failed. Contact support.');
  }
}
}