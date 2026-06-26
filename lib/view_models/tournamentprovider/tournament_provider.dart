// lib/view_models/tournamentprovider/tournament_provider.dart

import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/tournament/tournament_models.dart';
import 'package:firstedu/data/models/api_models/tournament/tournamentdetailsbyid_models.dart';
import 'package:firstedu/data/models/api_models/tournament/tournamentpayment_models.dart';
import 'package:firstedu/data/repo/tournament/tournament_repo.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

class TournamentProvider extends ChangeNotifier {
  final TournamentRepository _repo;

  TournamentProvider(this._repo);


  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPaginationLoading = false;
  bool get isPaginationLoading => _isPaginationLoading;

  bool _isPaymentLoading = false;
  bool get isPaymentLoading => _isPaymentLoading;

  List<Tournament> _tournaments = [];
  List<Tournament> get tournaments => _tournaments;

  Data? _tournament;
  Data? get tournament => _tournament;

  TournamentInitiatePaymentData? _pendingRazorpayOrder;
  TournamentInitiatePaymentData? get pendingRazorpayOrder =>
      _pendingRazorpayOrder;

  String? _selectedStatus;
  String? get selectedStatus => _selectedStatus;

  int _page = 1;
  int _totalPages = 1;
  bool get hasMore => _page < _totalPages;


  Future<void> fetchTournaments(BuildContext context) async {
    try {
      _isLoading = true;
      _page = 1;
      _tournaments = [];
      notifyListeners();

      final res = await _repo.getTournaments(
        page: _page,
        status: _selectedStatus,
      );

      _tournaments = res.data;
      _totalPages = res.meta.pages;
    } on AppException catch (e) {
      print("Error fetching tournaments: ${e.message}");
      if (context.mounted) {
        AppToast.error(context, title: "Error", message: e.message);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Data?> fetchTournamentById(BuildContext context, String id) async {
    try {
      final res = await _repo.getTournamentById(id);
      return res.data;
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(context, title: "Error", message: e.message);
      }
      return null;
    }
  } 

  
  // ── LOAD MORE ───────────────────────────────────────────────────────────────

  Future<void> loadMore(BuildContext context) async {
    if (!hasMore || _isPaginationLoading) return;

    try {
      _isPaginationLoading = true;
      notifyListeners();

      final nextPage = _page + 1;
      final res = await _repo.getTournaments(
        page: nextPage,
        status: _selectedStatus,
      );

      _tournaments.addAll(res.data);
      _page = nextPage;
      _totalPages = res.meta.pages;
    } catch (_) {
    } finally {
      _isPaginationLoading = false;
      notifyListeners();
    }
  }

  // ── FILTER ──────────────────────────────────────────────────────────────────

  Future<void> setStatus(BuildContext context, String? status) async {
    if (_selectedStatus == status) return;
    _selectedStatus = status;
    await fetchTournaments(context);
  }

  // ── GET DETAIL ──────────────────────────────────────────────────

  Future<void> fetchTournament(BuildContext context, String id) async {
    try {
      _isLoading = true;
      _tournament = null;
      notifyListeners();

      final res = await _repo.getTournamentById(id);
      _tournament = res.data;
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(context, title: "Error", message: e.message);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── INITIATE PAYMENT ────────────────────────────────────────────────────────

  /// Returns: 'success' | 'razorpay' | 'error'
  Future<String?> initiatePayment(
    BuildContext context, {
    required String tournamentId,
    required TournamentPaymentMethod method,
    String? couponCode,
  }) async {
    try {
      _isPaymentLoading = true;
      notifyListeners();

      final res = await _repo.initiatePayment(
        tournamentId: tournamentId,
        method: method,
        couponCode: couponCode,
      );

      final data = res.data;
      if (data == null) return null;

      // Free or wallet → completed immediately
      if (data.isCompleted) {
        // Refresh detail so isRegistered flips to true
        await fetchTournament(context, tournamentId);
        if (context.mounted) {
          AppToast.success(
            context,
            title: "Success",
            message: res.message ?? "Registered successfully!",
          );
        }
        return 'success';
      }

      // Razorpay → order pending
      _pendingRazorpayOrder = data;
      return 'razorpay';
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(context, title: "Error", message: e.message);
      }
      return 'error';
    } finally {
      _isPaymentLoading = false;
      notifyListeners();
    }
  }

  // ── COMPLETE RAZORPAY REGISTRATION ──────────────────────────────────────────

  Future<void> completeRazorpayRegistration(
    BuildContext context, {
    required String tournamentId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      _isPaymentLoading = true;
      notifyListeners();

      final res = await _repo.completeRegistration(
        tournamentId: tournamentId,
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );

      _pendingRazorpayOrder = null;

      // Refresh detail so UI reflects isRegistered: true
      await fetchTournament(context, tournamentId);

      if (context.mounted) {
        AppToast.success(
          context,
          title: "Success",
          message: res.message ?? "Registered successfully!",
        );
      }
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(context, title: "Payment Failed", message: e.message);
      }
    } finally {
      _isPaymentLoading = false;
      notifyListeners();
    }
  }

  // ── RESET ───────────────────────────────────────────────────────────────────

  void reset() {
    _isLoading = false;
    _isPaginationLoading = false;
    _isPaymentLoading = false;
    _tournaments = [];
    _selectedStatus = null;
    _page = 1;
    _totalPages = 1;
    _tournament = null;
    _pendingRazorpayOrder = null;
    notifyListeners();
  }
}
