// lib/view_models/livecompetetionprovider/livecompetetiondetailsprovider.dart

import 'dart:io';
import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/competetive/applycoupanmodels.dart';
import 'package:firstedu/data/models/api_models/livecompetetion/livecompetionmodels.dart';
import 'package:firstedu/data/repo/livecompetetion/livecompetetionrepository.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

/// Round name constants — always use these instead of raw strings.
class LiveRound {
  static const String megaAudition = 'MEGA_AUDITION';
  static const String grandFinale = 'GRAND_FINALE';
}

class LiveCompetitionProvider extends ChangeNotifier {
  final LiveCompetitionRepository _repo;
  LiveCompetitionProvider(this._repo);

  // ── Coupon ────────────────────────────────────────────────────────────────
  bool _isCouponLoading = false;
  bool get isCouponLoading => _isCouponLoading;
  String? _couponError;
  String? get couponError => _couponError;
  CouponData? _appliedCoupon;
  CouponData? get appliedCoupon => _appliedCoupon;

  Future<void> applyCoupon(
    BuildContext context, {
    required String code,
    required int amount,
    required String itemType,
  }) async {
    try {
      _isCouponLoading = true;
      _couponError = null;
      _appliedCoupon = null;
      notifyListeners();
      final res =
          await _repo.applyCoupon(code: code, amount: amount, itemType: itemType);
      _appliedCoupon = res.data;
    } on AppException catch (e) {
      _couponError = e.message;
      if (context.mounted)
        AppToast.error(context, title: 'Coupon Error', message: e.message);
    } finally {
      _isCouponLoading = false;
      notifyListeners();
    }
  }

  void clearCoupon() {
    _appliedCoupon = null;
    _couponError = null;
    notifyListeners();
  }

  // ── List ──────────────────────────────────────────────────────────────────
  List<LiveCompetition> _liveList = [];
  bool _isLoading = false;
  String? _error;
  List<LiveCompetition> get liveList => _liveList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Single ────────────────────────────────────────────────────────────────
  LiveCompetition? _selectedCompetition;
  bool _isSingleLoading = false;
  String? _singleError;
  LiveCompetition? get selectedCompetition => _selectedCompetition;
  bool get isSingleLoading => _isSingleLoading;
  String? get singleError => _singleError;

  // ── Payment ───────────────────────────────────────────────────────────────
  LivePaymentOrder? _pendingOrder;
  bool _isPaymentLoading = false;
  String? _paymentError;
  LivePaymentOrder? get pendingOrder => _pendingOrder;
  bool get isPaymentLoading => _isPaymentLoading;
  String? get paymentError => _paymentError;

  // ── Root context (for post-navigation snacks) ──────────────────────────
  BuildContext? rootContext;
  void setRootContext(BuildContext ctx) => rootContext = ctx;

  // ── FETCH ALL ──────────────────────────────────────────────────────────────
  Future<void> fetchLiveCompetitions(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _repo.getAllLiveCompetitions();
      _liveList = result.data ?? [];
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── FETCH SINGLE ───────────────────────────────────────────────────────────
  Future<void> fetchSingleLiveCompetition(
      BuildContext context, String id) async {
    _isSingleLoading = true;
    _singleError = null;
    notifyListeners();
    try {
      final result = await _repo.getSingleLiveCompetition(id);
      _selectedCompetition = result.data;
    } catch (e) {
      _singleError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isSingleLoading = false;
      notifyListeners();
    }
  }

  void setSelectedCompetition(LiveCompetition competition) {
    _selectedCompetition = competition;
    _singleError = null;
    notifyListeners();
  }

  // ── INITIATE PAYMENT ───────────────────────────────────────────────────────
  Future<String> initiatePayment(
    BuildContext context, {
    required String competitionId,
    required String paymentMethod,
    String? couponCode,
  }) async {
    _isPaymentLoading = true;
    _paymentError = null;
    _pendingOrder = null;
    notifyListeners();
    try {
      final result = await _repo.initiatePayment(
        id: competitionId,
        paymentMethod: paymentMethod,
        couponCode: couponCode,
      );
      final order = result.data;
      if (order?.completed == true) {
        await fetchLiveCompetitions(context);
        await fetchSingleLiveCompetition(context, competitionId);
        return 'success';
      }
      if (paymentMethod == 'razorpay' && order != null) {
        _pendingOrder = order;
        return 'razorpay';
      }
      await fetchLiveCompetitions(context);
      await fetchSingleLiveCompetition(context, competitionId);
      return 'success';
    } catch (e) {
      _paymentError = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _isPaymentLoading = false;
      notifyListeners();
    }
  }

  // ── COMPLETE RAZORPAY PAYMENT ──────────────────────────────────────────────
  Future<bool> completeRazorpayPayment(
    BuildContext context, {
    required String competitionId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      await _repo.completePayment(
        id: competitionId,
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );
      await fetchLiveCompetitions(context);
      await fetchSingleLiveCompetition(context, competitionId);
      return true;
    } catch (e) {
      _paymentError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ── START COMPETITION ──────────────────────────────────────────────────────
  // Calls the start API to set startedAt and returns participation data.
  Future<LiveParticipationData?> startCompetition(
    BuildContext context,
    String id, {
    required String round,
  }) async {
    try {
      final result = await _repo.startCompetition(id, round: round);
      return result.data;
    } catch (e) {
      _singleError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  // ── SAVE DRAFT ─────────────────────────────────────────────────────────────
  Future<bool> saveDraft({
    required String competitionId,
    required String textContent,
    required String round,
  }) async {
    try {
      await _repo.saveDraft(
          id: competitionId, textContent: textContent, round: round);
      return true;
    } catch (e) {
      debugPrint('Draft save failed: $e');
      return false;
    }
  }

  // ── SUBMIT WORK ────────────────────────────────────────────────────────────
  Future<bool> submitWork(
    BuildContext context, {
    required String competitionId,
    required String round,
    String? textContent,
    List<File>? fileList,
  }) async {
    try {
      await _repo.submitWork(
        id: competitionId,
        round: round,
        textContent: textContent,
        fileList: fileList,
      );
      await fetchSingleLiveCompetition(context, competitionId);
      notifyListeners();
      return true;
    } catch (e) {
      _singleError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}