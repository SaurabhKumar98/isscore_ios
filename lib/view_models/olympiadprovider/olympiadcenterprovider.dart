import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/competetive/applycoupanmodels.dart';
import 'package:firstedu/data/models/api_models/olympiadcentermodel/olympiadcategory_models.dart';
import 'package:firstedu/data/models/api_models/olympiadcentermodel/olympiadcentermodels.dart';
import 'package:firstedu/data/models/api_models/olympiadcentermodel/olympiaddetailsmodels.dart';
import 'package:firstedu/data/models/api_models/olympiadcentermodel/olympiadpaymentmodels.dart';
import 'package:firstedu/data/repo/olympiad/olympiadcenter_repositories.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

class OlympiadProvider extends ChangeNotifier {
  final OlympiadCenterRepositories _repository;

  OlympiadProvider(this._repository);

  // ── LIST STATE ────────────────────────────────────────────────────────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPaginationLoading = false;
  bool get isPaginationLoading => _isPaginationLoading;

  List<OlympiadData> _items = [];
  List<OlympiadData> get items => _items;

  int _currentPage = 1;
  int _totalPages = 1;
  bool get hasMore => _currentPage < _totalPages;

  String? _selectedStatus;
  String? get selectedStatus => _selectedStatus;

  // ── CATEGORY FILTER STATE ─────────────────────────────────────────────────

  bool _isCategoryLoading = false;
  bool get isCategoryLoading => _isCategoryLoading;

  /// Flat list of subcategories (children of the root "Olympiads" node)
  List<OlympiadCategoryData> _categories = [];
  List<OlympiadCategoryData> get categories => _categories;

  String? _selectedCategoryId;
  String? get selectedCategoryId => _selectedCategoryId;

  // ── DETAIL STATE ──────────────────────────────────────────────────────────

  bool _isDetailLoading = false;
  bool get isDetailLoading => _isDetailLoading;

  OlympiadDetailsData? _detail;
  OlympiadDetailsData? get detail => _detail;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── PAYMENT STATE ─────────────────────────────────────────────────────────

  bool _isPaymentLoading = false;
  bool get isPaymentLoading => _isPaymentLoading;

  OlympiadInitiatePaymentData? _pendingRazorpayOrder;
  OlympiadInitiatePaymentData? get pendingRazorpayOrder => _pendingRazorpayOrder;

  // ── COUPON STATE ──────────────────────────────────────────────────────────

  bool _isCouponLoading = false;
  bool get isCouponLoading => _isCouponLoading;

  String? _couponError;
  String? get couponError => _couponError;

  CouponData? _appliedCoupon;
  CouponData? get appliedCoupon => _appliedCoupon;


 Future<void> fetchCategories(BuildContext context) async {
  // Remove: if (_categories.isNotEmpty) return;
  try {
    _isCategoryLoading = true;
    notifyListeners();

    final model = await _repository.getCategories();
    final root = model.data?.isNotEmpty == true ? model.data!.first : null;
    _categories = root?.children ?? [];
  } on AppException catch (e) {
    debugPrint('OlympiadProvider.fetchCategories: ${e.message}');
  } finally {
    _isCategoryLoading = false;
    notifyListeners();
  }
}
  // ── FETCH LIST ────────────────────────────────────────────────────────────

  Future<void> fetchOlympiads(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      _currentPage = 1;
      _items = [];

      final model = await _repository.getOlympiad(
        page: _currentPage,
        status: _selectedStatus,
        categoryId: _selectedCategoryId,
      );

      _items = model.data ?? [];
      _totalPages = model.meta?.pages ?? 1;
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(context, title: 'Error', message: e.message);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── LOAD MORE ─────────────────────────────────────────────────────────────

  Future<void> loadMore(BuildContext context) async {
    if (!hasMore || _isPaginationLoading) return;

    try {
      _isPaginationLoading = true;
      notifyListeners();

      final nextPage = _currentPage + 1;
      final model = await _repository.getOlympiad(
        page: nextPage,
        status: _selectedStatus,
        categoryId: _selectedCategoryId,
      );

      _items.addAll(model.data ?? []);
      _currentPage = nextPage;
      _totalPages = model.meta?.pages ?? _totalPages;
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(context, title: 'Error', message: e.message);
      }
    } finally {
      _isPaginationLoading = false;
      notifyListeners();
    }
  }

  // ── FETCH DETAIL ──────────────────────────────────────────────────────────

  Future<void> fetchDetail(BuildContext context, String olympiadId) async {
    try {
      _isDetailLoading = true;
      _errorMessage = null;
      _detail = null;
      notifyListeners();

      final model = await _repository.getOlympiadDetail(olympiadId);
      _detail = model.data;
    } on AppException catch (e) {
      _errorMessage = e.message;
      if (context.mounted) {
        AppToast.error(context, title: 'Error', message: e.message);
      }
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  // ── APPLY COUPON ──────────────────────────────────────────────────────────

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

      final res = await _repository.applyCoupon(
        code: code,
        amount: amount,
        itemType: itemType,
      );

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

  // ── CLEAR COUPON ──────────────────────────────────────────────────────────

  void clearCoupon() {
    _appliedCoupon = null;
    _couponError = null;
    notifyListeners();
  }

  // ── INITIATE PAYMENT ──────────────────────────────────────────────────────

  Future<String> initiatePayment(
    BuildContext context, {
    required String olympiadId,
    required OlympiadPaymentMethod method,
    String? couponCode,
  }) async {
    try {
      _isPaymentLoading = true;
      _pendingRazorpayOrder = null;
      notifyListeners();

      final response = await _repository.initiatePayment(
        olympiadId: olympiadId,
        method: method.value,
        couponCode: couponCode,
      );

      final data = response.data;

      if (data?.completed == true) {
        await fetchDetail(context, olympiadId);
        return 'success';
      }

      if (data?.orderId != null) {
        _pendingRazorpayOrder = data;
        notifyListeners();
        return 'razorpay';
      }

      return 'error';
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(context, title: 'Payment Error', message: e.message);
      }
      return 'error';
    } finally {
      _isPaymentLoading = false;
      notifyListeners();
    }
  }

  // ── COMPLETE RAZORPAY ─────────────────────────────────────────────────────

  Future<void> completeRazorpayRegistration(
    BuildContext context, {
    required String olympiadId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      _isPaymentLoading = true;
      notifyListeners();

      await _repository.completeRazorpayRegistration(
        olympiadId: olympiadId,
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );

      if (context.mounted) {
        await fetchDetail(context, olympiadId);
        AppToast.success(
          context,
          title: 'Registered!',
          message: "You're successfully registered for this olympiad.",
        );
      }
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(
            context, title: 'Registration Failed', message: e.message);
      }
    } finally {
      _isPaymentLoading = false;
      _pendingRazorpayOrder = null;
      notifyListeners();
    }
  }

  // ── STATUS FILTER ─────────────────────────────────────────────────────────

  Future<void> setStatus(BuildContext context, String? status) async {
    if (_selectedStatus == status) return;
    _selectedStatus = status;
    await fetchOlympiads(context);
  }

  // ── CATEGORY FILTER ───────────────────────────────────────────────────────

  Future<void> setCategory(BuildContext context, String? categoryId) async {
    if (_selectedCategoryId == categoryId) return;
    _selectedCategoryId = categoryId;
    await fetchOlympiads(context);
  }

  // ── CLEAR / RESET ─────────────────────────────────────────────────────────

  void clearDetail() {
    _detail = null;
    _errorMessage = null;
    _isDetailLoading = false;
    _pendingRazorpayOrder = null;
    _appliedCoupon = null;
    _couponError = null;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _isPaginationLoading = false;
    _isDetailLoading = false;
    _isPaymentLoading = false;
    _isCouponLoading = false;
    _isCategoryLoading = false;
    _items = [];
    _currentPage = 1;
    _totalPages = 1;
    _selectedStatus = null;
    _selectedCategoryId = null;
    _categories = [];
    _detail = null;
    _errorMessage = null;
    _pendingRazorpayOrder = null;
    _appliedCoupon = null;
    _couponError = null;
    notifyListeners();
  }
}