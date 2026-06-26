import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/tournament/tournament_models.dart';
import 'package:firstedu/data/models/api_models/tournament/tournamentdetailsbyid_models.dart';
import 'package:firstedu/data/models/api_models/tournament/tournamentpayment_models.dart';
import 'package:flutter/foundation.dart';

class TournamentRepository {
  final ApiClient _apiClient;

  TournamentRepository(this._apiClient);

  Future<TournamentModels> getTournaments({
    int page = 1,
    int limit = 10,
    String? status,
    String? search,
    bool registeredOnly = false,
    String? category,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (status != null && status != 'all') 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        if (registeredOnly) 'registeredOnly': 'true',
        if (category != null) 'category': category,
      };

      final response = await _apiClient.get(
        ApiEndpoint.tournament,
        queryParameters: query,
      );

      print("Raw tournament response: ${response.data}"); // Debug log

      if (response.data == null) {
        throw AppException("Empty response from server");
      }

      final model = TournamentModels.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!model.success) {
        throw AppException(
          model.message.isNotEmpty
              ? model.message
              : "Failed to load tournaments",
        );
      }

      return model;
    } on AppException {
      print("Error in getTournaments ");
      rethrow;
    } catch (e, stack) {
      // ✅ Log the REAL error so you can debug it
      print('❌ getTournaments error: $e');
      debugPrint('Stack: $stack');
      throw AppException("Parse error: $e");
    }
  }

  // ── GET /tournaments/:id ────────────────────────────────────────────────────

  Future<TournamentDetailsByIdModels> getTournamentById(String id) async {
    try {
      final response = await _apiClient.get('${ApiEndpoint.tournament}/$id');

      if (response.data == null) {
        throw AppException("Empty response from server");
      }

      final model = TournamentDetailsByIdModels.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (model.success == false) {
        throw AppException(
          (model.message?.isNotEmpty ?? false)
              ? model.message!
              : "Failed to load tournament details",
        );
      }

      return model;
    } on AppException {
      rethrow;
    } catch (e, stack) {
      debugPrint('❌ getTournamentById error: $e');
      debugPrint('Stack: $stack');
      throw AppException("Parse error: $e");
    }
  }

  // ── POST /tournaments/:id/initiate-payment ──────────────────────────────────

  Future<TournamentInitiatePaymentResponse> initiatePayment({
    required String tournamentId,
    required TournamentPaymentMethod method,
    String? couponCode,
  }) async {
    try {
      final body = TournamentInitiatePaymentRequest(
        paymentMethod: method.value,
        couponCode: couponCode,
      ).toJson();

      final response = await _apiClient.post(
        '${ApiEndpoint.tournament}/$tournamentId/initiate-payment',
        data: body,
      );

      if (response.data == null) {
        throw AppException("Empty response from server");
      }

      final model = TournamentInitiatePaymentResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!model.success) {
        throw AppException(model.message ?? "Failed to initiate payment");
      }

      return model;
    } on AppException {
      rethrow;
    } catch (e, stack) {
      debugPrint('❌ initiatePayment error: $e');
      debugPrint('Stack: $stack');
      throw AppException("Something went wrong");
    }
  }

  // ── POST /tournaments/:id/register ─────────────────────────────────────────

  Future<TournamentRegisterResponse> completeRegistration({
    required String tournamentId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final body = TournamentRegisterRequest(
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      ).toJson();

      final response = await _apiClient.post(
        '${ApiEndpoint.tournament}/$tournamentId/register',
        data: body,
      );

      if (response.data == null) {
        throw AppException("Empty response from server");
      }

      final model = TournamentRegisterResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!model.success) {
        throw AppException(model.message ?? "Registration failed");
      }

      return model;
    } on AppException {
      rethrow;
    } catch (e, stack) {
      debugPrint('❌ completeRegistration error: $e');
      debugPrint('Stack: $stack');
      throw AppException("Something went wrong");
    }
  }
}
