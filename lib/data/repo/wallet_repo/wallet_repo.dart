// ══════════════════════════════════════════════════════════════════════════════
// WALLET REPOSITORY
// File: lib/data/repo/wallet/wallet_repository.dart
// ══════════════════════════════════════════════════════════════════════════════

import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/wallet_models/wallet_models.dart';

class WalletRepository {
  final ApiClient _apiClient;
  WalletRepository(this._apiClient);

  // ── 1. GET /user/wallet ───────────────────────────────────────────────────
  Future<WalletBalance> getBalance() async {
    try {
      final res = await _apiClient.get('${ApiEndpoint.appBaseUrl}/wallet');
      _checkSuccess(res.data);
      final data = (res.data as Map<String, dynamic>?)?['data'];
      return WalletBalance.fromJson(data as Map<String, dynamic>?);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to fetch wallet balance.');
    }
  }

  // ── 2. POST /user/wallet/recharge/initiate ────────────────────────────────
  Future<RazorpayOrder> initiateRecharge(int amount) async {
    try {
      final res = await _apiClient.post(
        '${ApiEndpoint.appBaseUrl}/wallet/recharge/initiate',
        data: {'amount': amount},
      );
      _checkSuccess(res.data);
      final data = (res.data as Map<String, dynamic>?)?['data'];
      return RazorpayOrder.fromJson(data as Map<String, dynamic>?);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to initiate recharge.');
    }
  }

  // ── 3. POST /user/wallet/recharge ─────────────────────────────────────────
  Future<RechargeResult> confirmRecharge({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final res = await _apiClient.post(
        '${ApiEndpoint.appBaseUrl}/wallet/recharge',
        data: {
          'razorpayOrderId': razorpayOrderId,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpaySignature': razorpaySignature,
        },
      );
      _checkSuccess(res.data);
      final data = (res.data as Map<String, dynamic>?)?['data'];
      return RechargeResult.fromJson(data as Map<String, dynamic>?);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to confirm recharge.');
    }
  }

  // ── 4. GET /user/wallet/points-history ────────────────────────────────────
  Future<PointsHistoryResponse> getPointsHistory({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final res = await _apiClient.get(
        '${ApiEndpoint.appBaseUrl}/wallet/points-history',
        queryParameters: {'page': page, 'limit': limit},
      );
      _checkSuccess(res.data);
      print("POINT HISTORY API RESPONSE: ${res.data}");
      return PointsHistoryResponse.fromJson(res.data as Map<String, dynamic>?);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to fetch points history.');
    }
  }

  // ── 5. POST /user/wallet/convert-points ───────────────────────────────────
  Future<ConvertPointsResult> convertPoints(int pointsToConvert) async {
    try {
      final res = await _apiClient.post(
        '${ApiEndpoint.appBaseUrl}/wallet/convert-points',
        data: {'pointsToConvert': pointsToConvert},
      );
      _checkSuccess(res.data);
      final data = (res.data as Map<String, dynamic>?)?['data'];
      return ConvertPointsResult.fromJson(data as Map<String, dynamic>?);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to convert points.');
    }
  }

  // ─── Helper ───────────────────────────────────────────────────────────────
  void _checkSuccess(dynamic data) {
    final map = data as Map<String, dynamic>?;
    if (map?['success'] != true) {
      throw AppException(
        (map?['message']?.toString().isNotEmpty == true)
            ? map!['message']
            : 'Something went wrong.',
      );
    }
  }
}
