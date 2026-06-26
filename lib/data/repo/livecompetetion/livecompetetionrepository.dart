// lib/data/repo/livecompetetion/livecompetetionrepository.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/competetive/applycoupanmodels.dart';
import 'package:firstedu/data/models/api_models/livecompetetion/livecompetionmodels.dart';

class LiveCompetitionRepository {
  final ApiClient _apiClient;
  LiveCompetitionRepository(this._apiClient);

  static const String _base =
      "${ApiEndpoint.appBaseUrl}/live-competitions";

  // ── 1. GET ALL ─────────────────────────────────────────────────────────────
  Future<LiveCompetetionModels> getAllLiveCompetitions() async {
    try {
      final response = await _apiClient.get(_base);
      if (response.data == null) throw AppException("Empty response");
      final model = LiveCompetetionModels.fromJson(
          response.data as Map<String, dynamic>);
      if (model.success != true)
        throw AppException(
            model.message ?? "Failed to load live competitions");
      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException("Something went wrong. Please try again.");
    }
  }

  // ── 2. GET SINGLE ──────────────────────────────────────────────────────────
  Future<SingleLiveCompetitionResponse> getSingleLiveCompetition(
      String id) async {
    try {
      final response = await _apiClient.get("$_base/$id");
      if (response.data == null) throw AppException("Empty response");
      final model = SingleLiveCompetitionResponse.fromJson(
          response.data as Map<String, dynamic>);
      if (model.success != true)
        throw AppException(model.message ?? "Failed to load competition");
      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException("Something went wrong. Please try again.");
    }
  }

  // ── 3. APPLY COUPON ────────────────────────────────────────────────────────
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
      if (response.data == null) throw AppException('Empty response.');
      final model =
          ApplyCouponModels.fromJson(response.data as Map<String, dynamic>);
      if (model.success != true)
        throw AppException((model.message?.isNotEmpty ?? false)
            ? model.message!
            : 'Invalid coupon code.');
      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Failed to apply coupon. Please try again.');
    }
  }

  // ── 4. INITIATE PAYMENT ────────────────────────────────────────────────────
  Future<LivePaymentInitiateResponse> initiatePayment({
    required String id,
    required String paymentMethod,
    String? couponCode,
  }) async {
    try {
      final body = <String, dynamic>{
        'paymentMethod': paymentMethod,
        if (couponCode != null && couponCode.isNotEmpty)
          'couponCode': couponCode,
      };
      final response =
          await _apiClient.post("$_base/$id/initiate-payment", data: body);
      if (response.data == null) throw AppException("Empty response");
      final model = LivePaymentInitiateResponse.fromJson(
          response.data as Map<String, dynamic>);
      if (model.success != true)
        throw AppException(model.message ?? "Payment initiation failed");
      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException("Payment initiation failed. Please try again.");
    }
  }

  // ── 5. COMPLETE PAYMENT ────────────────────────────────────────────────────
  Future<LiveCompetitionParticipation> completePayment({
    required String id,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await _apiClient.post(
        "$_base/$id/complete-payment",
        data: {
          'razorpayOrderId': razorpayOrderId,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpaySignature': razorpaySignature,
        },
      );
      if (response.data == null) throw AppException("Empty response");
      final model = LiveCompetitionParticipation.fromJson(
          response.data as Map<String, dynamic>);
      if (model.success != true)
        throw AppException(model.message ?? "Payment completion failed");
      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException("Could not complete payment. Please try again.");
    }
  }

  // ── 6. START COMPETITION ───────────────────────────────────────────────────
  Future<LiveCompetitionParticipation> startCompetition(
    String id, {
    required String round, // LiveRound.megaAudition | LiveRound.grandFinale
  }) async {
    try {
      final response = await _apiClient.post(
        "$_base/$id/start",
        data: {'round': round},
      );
      if (response.data == null) throw AppException("Empty response");
      final model = LiveCompetitionParticipation.fromJson(
          response.data as Map<String, dynamic>);
      if (model.success != true)
        throw AppException(model.message ?? "Failed to start competition");
      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException("Could not start competition. Please try again.");
    }
  }

  // ── 7. SAVE DRAFT ──────────────────────────────────────────────────────────
  Future<void> saveDraft({
    required String id,
    required String textContent,
    required String round,
  }) async {
    try {
      await _apiClient.patch(
        "$_base/$id/save-draft",
        data: {'text': textContent, 'round': round},
      );
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException("Could not save draft. Please try again.");
    }
  }

  // ── 8. SUBMIT WORK ─────────────────────────────────────────────────────────
  Future<LiveCompetitionParticipation> submitWork({
    required String id,
    required String round,
    String? textContent,
    List<File>? fileList,
  }) async {
    try {
      final formData = FormData.fromMap({
        'round': round,
        if (textContent != null && textContent.isNotEmpty)
          'text': textContent,
        if (fileList != null && fileList.isNotEmpty)
          'files': await Future.wait(
            fileList.map((f) => MultipartFile.fromFile(f.path)),
          ),
      });
      final response =
          await _apiClient.post("$_base/$id/submit", data: formData);
      if (response.data == null) throw AppException("Empty response");
      final model = LiveCompetitionParticipation.fromJson(
          response.data as Map<String, dynamic>);
      if (model.success != true)
        throw AppException(model.message ?? "Submission failed");
      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException("Submission failed. Please try again.");
    }
  }


}