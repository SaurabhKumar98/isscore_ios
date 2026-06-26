import 'package:firstedu/data/models/api_models/competetive/applycoupanmodels.dart';
import 'package:firstedu/data/models/api_models/resourcestore/Categorymodels.dart';
import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/resourcestore/storemodels.dart';
import 'package:firstedu/data/models/api_models/resourcestore/storepaymentmodels.dart';
import 'package:firstedu/data/repo/resourcestore/store_repositories.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

class StoreProvider extends ChangeNotifier {
  final StoreRepository _storeRepository;

  StoreProvider(this._storeRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPaginationLoading = false;
  bool get isPaginationLoading => _isPaginationLoading;

  List<Item> _items = [];
  List<Item> get items => _items;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String _selectedType = 'both';
  String get selectedType => _selectedType;

  String _search = '';
  String get search => _search;

  String? _categoryId;
  String? get selectedCategoryId => _categoryId;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  int _totalPages = 1;
  int get totalPages => _totalPages;

  int _totalItems = 0;
  int get totalItems => _totalItems;

  bool get hasMore => _currentPage < _totalPages;

  bool _isCategoryLoading = false;
  bool get isCategoryLoading => _isCategoryLoading;

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  CategoryModel? _selectedCategory;
  CategoryModel? get selectedCategory => _selectedCategory;

  bool _isCouponLoading = false;
  bool get isCouponLoading => _isCouponLoading;

  String? _couponError;
  String? get couponError => _couponError;

  CouponData? _appliedCoupon;
  CouponData? get appliedCoupon => _appliedCoupon;

  bool _isPaymentLoading = false;
  bool get isPaymentLoading => _isPaymentLoading;

  StoreRazorpayOrder? _pendingRazorpayOrder;
  StoreRazorpayOrder? get pendingRazorpayOrder => _pendingRazorpayOrder;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setPaginationLoading(bool value) {
    _isPaginationLoading = value;
    notifyListeners();
  }

  void _setPaymentLoading(bool value) {
    _isPaymentLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────
  //  FETCH ITEMS
  // ─────────────────────────────────────────────────────────────────

  Future<void> fetchItems(BuildContext context) async {
    try {
      _setLoading(true);
      clearError();

      _currentPage = 1;
      _items = [];

      final model = await _storeRepository.getTestsAndBundles(
        type: _selectedType,
        page: _currentPage,
        search: _search,
        category: _categoryId,
      );

      _items = model.data?.items ?? [];
      _totalPages = model.meta?.pages ?? 1;
      _totalItems = model.meta?.total ?? 0;

      debugPrint("✅ STORE FETCH: ${_items.length} items");
    } on AppException catch (e) {
      _setError(e.message);
      if (context.mounted) {
        AppToast.error(context, title: "Failed to Load", message: e.message);
      }
    } catch (e, stack) {
      debugPrint("❌ STORE FETCH ERROR: $e\n$stack");
      const msg = "Something went wrong. Please try again.";
      _setError(msg);
      if (context.mounted) {
        AppToast.error(context, title: "Error", message: msg);
      }
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  LOAD MORE
  // ─────────────────────────────────────────────────────────────────

  Future<void> loadMore(BuildContext context) async {
    if (!hasMore || _isPaginationLoading) return;

    final nextPage = _currentPage + 1;

    try {
      _setPaginationLoading(true);

      final model = await _storeRepository.getTestsAndBundles(
        type: _selectedType,
        page: nextPage,
        search: _search,
        category: _categoryId,
      );

      _items.addAll(model.data?.items ?? []);
      _currentPage = nextPage;
      _totalPages = model.meta?.pages ?? _totalPages;
      _totalItems = model.meta?.total ?? _totalItems;
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(
          context,
          title: "Failed to Load More",
          message: e.message,
        );
      }
    } catch (e, stack) {
      debugPrint("❌ STORE LOAD MORE ERROR: $e\n$stack");
      if (context.mounted) {
        AppToast.error(
          context,
          title: "Error",
          message: "Something went wrong. Please try again.",
        );
      }
    } finally {
      _setPaginationLoading(false);
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  FETCH CATEGORIES  ✅ Fixed: all types mapped correctly
  // ─────────────────────────────────────────────────────────────────

 Future<void> fetchCategories() async {
  try {
    _isCategoryLoading = true;
    notifyListeners();

    final response = await _storeRepository.getCategories();
    _categories = response.data;
    debugPrint("📂 CATEGORIES LOADED: ${_categories.length}");
  } on AppException catch (e) {
    debugPrint("❌ CATEGORY FETCH ERROR: ${e.message}");
    _categories = [];
  } catch (e, stack) {
    debugPrint("❌ CATEGORY FETCH ERROR: $e\n$stack");
    _categories = [];
  } finally {
    _isCategoryLoading = false;
    notifyListeners();
  }
}
  // ─────────────────────────────────────────────────────────────────
  //  COUPON
  // ─────────────────────────────────────────────────────────────────

Future<void> applyCoupon(
  BuildContext context, {
  required String code,
  required int amount,
  required String module,   // ✅ renamed from itemType
}) async {
  try {
    _isCouponLoading = true;
    _couponError = null;
    _appliedCoupon = null;
    notifyListeners();

    final res = await _storeRepository.applyCoupon(
      code: code,
      amount: amount,
      module: module,   // ✅ pass as module
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
 
 
  void clearCoupon() {
    _appliedCoupon = null;
    _couponError = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────
  //  PAYMENT
  // ─────────────────────────────────────────────────────────────────

  Future<String> initiatePayment(
    BuildContext context, {
    required String itemId,
    required String itemType,
    required StorePaymentMethod method,
    String? couponCode,
  }) async {
    try {
      _setPaymentLoading(true);
      _pendingRazorpayOrder = null;

      final methodStr = switch (method) {
        StorePaymentMethod.free => 'free',
        StorePaymentMethod.wallet => 'wallet',
        StorePaymentMethod.razorpay => 'razorpay',
      };

      final response = await _storeRepository.initiatePayment(
        itemId: itemId,
        paymentMethod: methodStr,
        itemType: itemType,
        couponCode: couponCode,
      );

      debugPrint("Payment response: ${response.data}");

      if (methodStr == 'free' || methodStr == 'wallet') {
        if (context.mounted) {
          AppToast.success(
            context,
            title: "Purchase Successful 🎉",
            message: response.message ?? "Purchase completed.",
          );
        }
        return "success";
      }

      final data = response.data;

      if (data?.orderId != null) {
        _pendingRazorpayOrder = StoreRazorpayOrder(
          key: data?.key,
          amount: data?.amount,
          currency: data?.currency,
          orderId: data?.orderId,
          eventTitle: data?.testTitle,
        );

        notifyListeners();
        return "razorpay";
      }

      throw AppException("Unexpected payment response");
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(context, title: "Payment Failed", message: e.message);
      }
      return "error";
    } catch (e, stack) {
      debugPrint("STORE PAYMENT ERROR: $e\n$stack");
      if (context.mounted) {
        AppToast.error(
          context,
          title: "Error",
          message: "Something went wrong. Please try again.",
        );
      }
      return "error";
    } finally {
      _setPaymentLoading(false);
    }
  }

  Future<void> completeRazorpayPurchase(
    BuildContext context, {
    required String itemId,
    required String itemType,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      _setPaymentLoading(true);

      await _storeRepository.completeRazorpayPurchase(
        itemId: itemId,
        itemType: itemType,
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );

      _pendingRazorpayOrder = null;
      notifyListeners();

      if (context.mounted) {
        AppToast.success(
          context,
          title: "Purchase Successful 🎉",
          message: "Test bundle purchased successfully",
        );
      }
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(
          context,
          title: "Verification Failed",
          message: e.message,
        );
      }
    } catch (e, stack) {
      debugPrint("❌ STORE COMPLETE PAYMENT ERROR: $e\n$stack");
      if (context.mounted) {
        AppToast.error(
          context,
          title: "Error",
          message: "Payment verification failed. Please contact support.",
        );
      }
    } finally {
      _setPaymentLoading(false);
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  FILTER CONTROLS  ✅ Fixed: type set BEFORE fetching
  // ─────────────────────────────────────────────────────────────────

  Future<void> setType(BuildContext context, String type) async {
    if (_selectedType == type) return;

    // ✅ Set type FIRST so fetchCategories reads the correct value
    _selectedType = type;
    _selectedCategory = null;
    _categoryId = null;
    notifyListeners();

    await Future.wait([fetchCategories(), fetchItems(context)]);
  }

  Future<void> setSearch(BuildContext context, String search) async {
    _search = search;
    await fetchItems(context);
  }

  Future<void> setCategory(BuildContext context, String? categoryId) async {
    _categoryId = categoryId;
    if (categoryId == null) _selectedCategory = null;
    notifyListeners();
    await fetchItems(context);
  }

  void selectCategory(BuildContext context, CategoryModel? category) {
    _selectedCategory = category;
    _categoryId = category?.id;
    notifyListeners();
    fetchItems(context);
  }

  void clearCategory(BuildContext context) {
    _selectedCategory = null;
    _categoryId = null;
    notifyListeners();
    fetchItems(context);
  }


  void reset() {
    _isLoading = false;
    _isPaginationLoading = false;
    _isCategoryLoading = false;
    _isPaymentLoading = false;
    _items = [];
    _categories = [];
    _selectedType = 'both';
    _search = '';
    _categoryId = null;
    _selectedCategory = null;
    _currentPage = 1;
    _totalPages = 1;
    _totalItems = 0;
    _errorMessage = '';
    _pendingRazorpayOrder = null;
    notifyListeners();
  }
}