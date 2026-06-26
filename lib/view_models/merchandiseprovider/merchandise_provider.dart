import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/merchandise_models/merchandisedetailsmodels.dart';
import 'package:firstedu/data/models/api_models/merchandise_models/merchandisefetchclaimedmodels.dart';
import 'package:firstedu/data/models/api_models/merchandise_models/merchandisemodels.dart';
import 'package:firstedu/data/repo/merchandise/merchandise_repo.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

class MerchandiseProvider extends ChangeNotifier {
  final MerchandiseRepository _repo;

  MerchandiseProvider(this._repo);

  // ───────── LIST ─────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPaginationLoading = false;
  bool get isPaginationLoading => _isPaginationLoading;

  List<MerchandiseItem> _items = [];
  List<MerchandiseItem> get items => _items;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  int _currentPage = 1;
  int _totalPages = 1;
  bool get hasMore => _currentPage < _totalPages;

  String _selectedCategory = '';
  String get selectedCategory => _selectedCategory;

  // User balances (from meta)
  int _totalPoints = 0;
  int get totalPoints => _totalPoints;

  double _monetaryBalance = 0;
  double get monetaryBalance => _monetaryBalance;

  // ───────── DETAIL ─────────
  bool _isDetailLoading = false;
  bool get isDetailLoading => _isDetailLoading;

  MerchandiseDetail? _detail;
  MerchandiseDetail? get detail => _detail;

  // ───────── CLAIM (points) ─────────
  bool _isClaiming = false;
  bool get isClaiming => _isClaiming;

  // ───────── PAYMENT (wallet / razorpay / free) ─────────
  bool _isPaymentLoading = false;
  bool get isPaymentLoading => _isPaymentLoading;

  MerchandisePaymentData? _pendingPaymentData; // razorpay gateway data
  MerchandisePaymentData? get pendingPaymentData => _pendingPaymentData;

  bool _isConfirmingPayment = false;
  bool get isConfirmingPayment => _isConfirmingPayment;

  // ───────── COUPON ─────────
  bool _isCouponLoading = false;
  bool get isCouponLoading => _isCouponLoading;

  MerchandiseCouponData? _appliedCoupon;
  MerchandiseCouponData? get appliedCoupon => _appliedCoupon;

  String? _couponError;
  String? get couponError => _couponError;

  // ───────── MY CLAIMS ─────────
  bool _isClaimsLoading = false;
  bool get isClaimsLoading => _isClaimsLoading;

  bool _isClaimsPaginationLoading = false;
  bool get isClaimsPaginationLoading => _isClaimsPaginationLoading;

  List<ClaimItem> _myClaims = [];
  List<ClaimItem> get myClaims => _myClaims;

  String _claimsError = '';
  String get claimsError => _claimsError;

  int _claimsPage = 1;
  int _claimsTotalPages = 1;
  bool get hasMoreClaims => _claimsPage < _claimsTotalPages;

  // ═══════════════════════════════════════════════════════════════
  // LIST
  // ═══════════════════════════════════════════════════════════════

  Future<void> fetchMerchandise(BuildContext context) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      _currentPage = 1;
      _items = [];
      notifyListeners();

      final model = await _repo.getMerchandise(
        page: _currentPage,
        category: _selectedCategory,
      );

      _items = model.data;
      _totalPages = model.meta.pages;
      _totalPoints = model.meta.totalPoints;
      _monetaryBalance = model.meta.monetaryBalance;
    } on AppException catch (e) {
      _errorMessage = e.message;
      if (context.mounted) {
        AppToast.error(context, title: 'Error', message: e.message);
      }
    } catch (e) {
      _errorMessage = 'Something went wrong.';
      if (context.mounted) {
        AppToast.error(context,
            title: 'Error', message: 'Unexpected error occurred');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore(BuildContext context) async {
    if (!hasMore || _isPaginationLoading) return;
    final nextPage = _currentPage + 1;
    try {
      _isPaginationLoading = true;
      notifyListeners();

      final model = await _repo.getMerchandise(
          page: nextPage, category: _selectedCategory);

      _items.addAll(model.data);
      _currentPage = nextPage;
      _totalPages = model.meta.pages;
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(context, title: 'Error', message: e.message);
      }
    } finally {
      _isPaginationLoading = false;
      notifyListeners();
    }
  }

  Future<void> setCategory(BuildContext context, String category) async {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
    await fetchMerchandise(context);
  }

  // ═══════════════════════════════════════════════════════════════
  // DETAIL
  // ═══════════════════════════════════════════════════════════════

  Future<void> fetchDetail(BuildContext context, String id) async {
    try {
      _isDetailLoading = true;
      _detail = null;
      notifyListeners();

      final model = await _repo.getMerchandiseById(id);
      _detail = model.data;
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(context, title: 'Error', message: e.message);
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context,
            title: 'Error', message: 'Unexpected error occurred');
      }
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // CLAIM VIA POINTS
  // ═══════════════════════════════════════════════════════════════

  Future<bool> claimMerchandise(
    BuildContext context, {
    required String merchandiseId,
    Map<String, dynamic>? deliveryAddress,
  }) async {
    try {
      _isClaiming = true;
      notifyListeners();

      final model = await _repo.claimMerchandise(
        merchandiseId: merchandiseId,
        deliveryAddress: deliveryAddress,
      );

      if (model.success && context.mounted) {
        AppToast.success(context,
            title: 'Claimed!', message: 'Merchandise claimed with points.');
      }

      return model.success;
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(context, title: 'Claim Failed', message: e.message);
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context,
            title: 'Error', message: 'Something went wrong.');
      }
      return false;
    } finally {
      _isClaiming = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // INITIATE PAYMENT  (wallet / razorpay / free)
  // Returns:
  //   true  → payment completed (wallet/free), caller can pop screen
  //   false → error
  //   null  → razorpay gateway needed; pendingPaymentData is set
  // ═══════════════════════════════════════════════════════════════

  Future<bool?> initiatePayment(
    BuildContext context, {
    required String merchandiseId,
    required String paymentMethod, // 'wallet' | 'razorpay' | 'free'
    String? couponCode,
    Map<String, dynamic>? deliveryAddress, // required for wallet/free+physical
  }) async {
    try {
      _isPaymentLoading = true;
      _pendingPaymentData = null;
      notifyListeners();

      // For wallet/free we send deliveryAddress in the initiate call.
      // For razorpay we must NOT send it here (backend rule).
      final model = await _repo.initiatePayment(
        merchandiseId: merchandiseId,
        paymentMethod: paymentMethod,
        couponCode: couponCode,
      );

      if (!model.success) return false;

      final pd = model.data;

      if (pd == null || pd.completed) {
        // Wallet / free — done in one step
        if (context.mounted) {
          AppToast.success(context,
              title: 'Success!', message: 'Merchandise purchased successfully.');
        }
        return true;
      } else {
        // Razorpay — caller must open the gateway
        _pendingPaymentData = pd;
        notifyListeners();
        return null;
      }
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(context, title: 'Payment Failed', message: e.message);
      }
      return false;
    } finally {
      _isPaymentLoading = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // CONFIRM RAZORPAY PAYMENT
  // ═══════════════════════════════════════════════════════════════

  Future<bool> confirmPayment(
    BuildContext context, {
    required String merchandiseId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
    Map<String, dynamic>? deliveryAddress,
  }) async {
    try {
      _isConfirmingPayment = true;
      notifyListeners();

      final model = await _repo.confirmPayment(
        merchandiseId: merchandiseId,
        razorpayPaymentId: razorpayPaymentId,
        razorpayOrderId: razorpayOrderId,
        razorpaySignature: razorpaySignature,
        deliveryAddress: deliveryAddress,
      );

      if (model.success && context.mounted) {
        AppToast.success(context,
            title: 'Payment Confirmed!',
            message: 'Your order has been placed.');
      }

      return model.success;
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(
            context, title: 'Confirmation Failed', message: e.message);
      }
      return false;
    } finally {
      _isConfirmingPayment = false;
      _pendingPaymentData = null;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // COUPON
  // ═══════════════════════════════════════════════════════════════

  Future<void> applyCoupon(
    BuildContext context, {
    required String code,
    required int amount,
  }) async {
    try {
      _isCouponLoading = true;
      _couponError = null;
      _appliedCoupon = null;
      notifyListeners();

      final res = await _repo.applyCoupon(code: code, amount: amount);
      _appliedCoupon = res.data;
    } on AppException catch (e) {
      _couponError = e.message;
      if (context.mounted) {
        AppToast.error(context, title: 'Coupon Error', message: e.message);
      }
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

  // ═══════════════════════════════════════════════════════════════
  // MY CLAIMS
  // ═══════════════════════════════════════════════════════════════

  Future<void> fetchMyClaims(BuildContext context) async {
    try {
      _isClaimsLoading = true;
      _claimsError = '';
      _claimsPage = 1;
      _myClaims = [];
      notifyListeners();

      final model = await _repo.getMyClaims(page: _claimsPage);
      _myClaims = model.data ?? [];
      _claimsTotalPages = model.meta?.pages ?? 1;
    } on AppException catch (e) {
      _claimsError = e.message;
      if (context.mounted) {
        AppToast.error(context, title: 'Error', message: e.message);
      }
    } catch (e) {
      _claimsError = 'Something went wrong.';
    } finally {
      _isClaimsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreClaims(BuildContext context) async {
    if (!hasMoreClaims || _isClaimsPaginationLoading) return;
    final nextPage = _claimsPage + 1;
    try {
      _isClaimsPaginationLoading = true;
      notifyListeners();

      final model = await _repo.getMyClaims(page: nextPage);
      _myClaims.addAll(model.data ?? []);
      _claimsPage = nextPage;
      _claimsTotalPages = model.meta?.pages ?? _claimsTotalPages;
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(context, title: 'Error', message: e.message);
      }
    } finally {
      _isClaimsPaginationLoading = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // RESET
  // ═══════════════════════════════════════════════════════════════

  void reset() {
    _isLoading = false;
    _isPaginationLoading = false;
    _isDetailLoading = false;
    _isClaiming = false;
    _isPaymentLoading = false;
    _isConfirmingPayment = false;
    _isCouponLoading = false;
    _isClaimsLoading = false;
    _isClaimsPaginationLoading = false;

    _items = [];
    _detail = null;
    _myClaims = [];
    _pendingPaymentData = null;
    _appliedCoupon = null;

    _selectedCategory = '';
    _errorMessage = '';
    _claimsError = '';
    _couponError = null;

    _currentPage = 1;
    _totalPages = 1;
    _claimsPage = 1;
    _claimsTotalPages = 1;
    _totalPoints = 0;
    _monetaryBalance = 0;

    notifyListeners();
  }
}