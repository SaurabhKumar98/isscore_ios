// ── competetionprovider.dart (fixed: auto-refresh after payment) ─────────────

import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/competetive/applycoupanmodels.dart';
import 'package:firstedu/data/models/api_models/competetive/avilabletestcompetetionmodels.dart';
import 'package:firstedu/data/models/api_models/competetive/competetionbyid_models.dart';
import 'package:firstedu/data/models/api_models/competetive/competetionsingleidby_models.dart';
import 'package:firstedu/data/models/api_models/competetive/purchasecompetetionmodels.dart';
import 'package:firstedu/data/models/api_models/competetive/purchaseconfirmmodels.dart';
import 'package:firstedu/data/models/api_models/competetive/subcategorydetilsmodels.dart';
import 'package:firstedu/data/models/api_models/olympiadcentermodel/olympiadcategory_models.dart';
import 'package:firstedu/data/repo/competetive/competetion_repo.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

class CompetitionProvider extends ChangeNotifier {
  final CompetitionRepository _repo;

  CompetitionProvider(this._repo);

  // ── Razorpay root-context ──────────────────────────────────────────────────
  BuildContext? rootContext;
  void setRootContext(BuildContext ctx) => rootContext = ctx;

  // ══════════════════════════════════════════════════════════════════════════
  // CATEGORY TREE (for filter sheet)
  // ══════════════════════════════════════════════════════════════════════════

  List<OlympiadCategoryData> _categoryTree = [];
  List<OlympiadCategoryData> get categoryTree => _categoryTree;

  bool _isCategoryTreeLoading = false;
  bool get isCategoryTreeLoading => _isCategoryTreeLoading;

  String? _selectedFilterCategoryId;
  String? get selectedFilterCategoryId => _selectedFilterCategoryId;

  // ══════════════════════════════════════════════════════════════════════════
  // CATEGORY LIST
  // ══════════════════════════════════════════════════════════════════════════

  List<Child> _allCategories = [];
  List<Child> _categories = [];
  List<Child> get categories => _categories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPaginationLoading = false;
  bool get isPaginationLoading => _isPaginationLoading;

  int _page = 1;
  int _totalPages = 1;
  bool get hasMore => _page < _totalPages;

  String currentRootType = "Competitive";

  // ══════════════════════════════════════════════════════════════════════════
  // CATEGORY DETAIL (resolve-path)
  // ══════════════════════════════════════════════════════════════════════════

  CompetationDetailData? _detail;
  CompetationDetailData? get detail => _detail;

  String? _error;
  String? get error => _error;

  // ══════════════════════════════════════════════════════════════════════════
  // CATEGORY SUB-DETAIL (:id/detail)
  // ══════════════════════════════════════════════════════════════════════════

  CompetitionSubDetailData? _categoryDetail;
  CompetitionSubDetailData? get categoryDetail => _categoryDetail;

  // ══════════════════════════════════════════════════════════════════════════
  // AVAILABLE TESTS + SEARCH STATE
  // ══════════════════════════════════════════════════════════════════════════

  List<TestData> _tests = [];
  List<TestData> get tests => _tests;

  Meta? _testMeta;
  Meta? get testMeta => _testMeta;

  bool get supportsSearch =>
      currentRootType.toLowerCase() != 'school';

  String _testSearchQuery = '';
  String get testSearchQuery => _testSearchQuery;

  bool _isTestSearchLoading = false;
  bool get isTestSearchLoading => _isTestSearchLoading;

  String? _lastFetchedSearch;
  String? _lastFetchedCategoryId;

  // ══════════════════════════════════════════════════════════════════════════
  // SINGLE COMPETITION BUNDLE
  // ══════════════════════════════════════════════════════════════════════════

  CompetitionDetail? _singleCompetition;
  CompetitionDetail? get singleCompetition => _singleCompetition;

  bool _isSingleLoading = false;
  bool get isSingleLoading => _isSingleLoading;

  String? _singleError;
  String? get singleError => _singleError;

  // ══════════════════════════════════════════════════════════════════════════
  // COUPON STATE
  // ══════════════════════════════════════════════════════════════════════════

  bool _isCouponLoading = false;
  bool get isCouponLoading => _isCouponLoading;

  String? _couponError;
  String? get couponError => _couponError;

  CouponData? _appliedCoupon;
  CouponData? get appliedCoupon => _appliedCoupon;

  // ══════════════════════════════════════════════════════════════════════════
  // CATEGORY PAYMENT STATE
  // ══════════════════════════════════════════════════════════════════════════

  bool _isCategoryPaymentLoading = false;
  bool get isCategoryPaymentLoading => _isCategoryPaymentLoading;

  String? _categoryPaymentError;
  String? get categoryPaymentError => _categoryPaymentError;

  PurchaseData? _pendingCategoryOrder;
  PurchaseData? get pendingCategoryOrder => _pendingCategoryOrder;

  PurchaseConfirmData? _confirmedCategoryPurchase;
  PurchaseConfirmData? get confirmedCategoryPurchase =>
      _confirmedCategoryPurchase;

  // ══════════════════════════════════════════════════════════════════════════
  // UPGRADE STATE
  // ══════════════════════════════════════════════════════════════════════════

  bool _isUpgradeLoading = false;
  bool get isUpgradeLoading => _isUpgradeLoading;

  String? _upgradeError;
  String? get upgradeError => _upgradeError;

  PurchaseData? _pendingUpgradeOrder;
  PurchaseData? get pendingUpgradeOrder => _pendingUpgradeOrder;

  PurchaseConfirmData? _confirmedUpgrade;
  PurchaseConfirmData? get confirmedUpgrade => _confirmedUpgrade;

  // ══════════════════════════════════════════════════════════════════════════
  // PAYMENT SUCCESS LISTENERS
  // ══════════════════════════════════════════════════════════════════════════

  final List<VoidCallback> _paymentSuccessListeners = [];

  void addPaymentSuccessListener(VoidCallback cb) =>
      _paymentSuccessListeners.add(cb);

  void removePaymentSuccessListener(VoidCallback cb) =>
      _paymentSuccessListeners.remove(cb);

  // ─────────────────────────────────────────────────────────────────────────
  //  FIX: _notifyPaymentSuccess now does a SYNCHRONOUS re-fetch so the card
  //  hasAccess state is updated immediately, no race condition.
  //  Previously it used addPostFrameCallback which could be missed if the
  //  widget rebuilt before the callback fired.
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _notifyPaymentSuccess() async {
    final ctx = rootContext;

    // Re-fetch all competitions so hasAccess flags are fresh from server
    if (ctx != null && ctx.mounted) {
      await fetchCompetitions(ctx, currentRootType);

      // Also refresh the detail path if we have one open
      if (_detail != null && ctx.mounted) {
        final path = (_detail?.node?.name ?? '')
            .toLowerCase()
            .trim()
            .replaceAll(RegExp(r'\s+'), '-');
        if (path.isNotEmpty) await fetchByPath(ctx, path);
      }
    }

    // Notify all registered screen-level listeners (e.g. CompetitionScreen)
    for (final cb in List.of(_paymentSuccessListeners)) {
      cb();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TEST PAYMENT STATE
  // ══════════════════════════════════════════════════════════════════════════

  bool _isPaymentLoading = false;
  bool get isPaymentLoading => _isPaymentLoading;

  String? _paymentError;
  String? get paymentError => _paymentError;

  PurchaseData? _pendingTestOrder;
  PurchaseData? get pendingTestOrder => _pendingTestOrder;

  PurchaseConfirmData? _confirmedTestPurchase;
  PurchaseConfirmData? get confirmedTestPurchase => _confirmedTestPurchase;

  // ══════════════════════════════════════════════════════════════════════════
  // RESET FOR ROOT TYPE
  // ══════════════════════════════════════════════════════════════════════════

  void resetForRootType(String newRootType) {
    if (currentRootType == newRootType) return;
    currentRootType = newRootType;
    _selectedFilterCategoryId = null;
    _categoryTree = [];
    _allCategories = [];
    _categories = [];
    _page = 1;
    _totalPages = 1;
    _testSearchQuery = '';
    _lastFetchedSearch = null;
    _lastFetchedCategoryId = null;
    // No notifyListeners() — called during build phase from initState
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FETCH CATEGORY TREE
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> fetchCategoryTree(String rootType) async {
    try {
      _isCategoryTreeLoading = true;
      notifyListeners();
      final res = await _repo.getCategoryTree(rootType);
      _categoryTree = res.data ?? [];
    } catch (e) {
      debugPrint("❌ CATEGORY TREE ERROR: $e");
      _categoryTree = [];
    } finally {
      _isCategoryTreeLoading = false;
      notifyListeners();
    }
  }

  List<OlympiadCategoryData> get flatCategoryList {
    final flat = <OlympiadCategoryData>[];
    for (final node in _categoryTree) {
      flat.addAll(node.flatten());
    }
    return flat;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CLIENT-SIDE FILTER
  // ══════════════════════════════════════════════════════════════════════════

  void _applyLocalFilter() {
    if (_selectedFilterCategoryId == null) {
      _categories = List.from(_allCategories);
      return;
    }
    final direct =
        _allCategories.where((c) => c.id == _selectedFilterCategoryId).toList();
    if (direct.isNotEmpty) {
      _categories = direct;
      return;
    }
    final topLevelId = _findTopLevelAncestorId(_selectedFilterCategoryId!);
    if (topLevelId != null) {
      _categories = _allCategories.where((c) => c.id == topLevelId).toList();
    } else {
      _categories = List.from(_allCategories);
    }
  }

  String? _findTopLevelAncestorId(String targetId) {
    for (final rootNode in _categoryTree) {
      for (final topChild in rootNode.children ?? []) {
        if (topChild.id == targetId) return topChild.id;
        if (_isDescendant(topChild, targetId)) return topChild.id;
      }
    }
    return null;
  }

  bool _isDescendant(OlympiadCategoryData node, String targetId) {
    for (final child in node.children ?? []) {
      if (child.id == targetId) return true;
      if (_isDescendant(child, targetId)) return true;
    }
    return false;
  }

  void setFilterCategory(
    BuildContext context,
    String? categoryId,
    String rootType,
  ) {
    if (currentRootType != rootType) return;
    _selectedFilterCategoryId = categoryId;
    _page = 1;
    _applyLocalFilter();
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FETCH COMPETITIONS
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _fetchCompetitionsWithFilter(
    BuildContext context,
    String rootType,
    String? categoryId,
  ) async {
    try {
      _isLoading = true;
      currentRootType = rootType;
      notifyListeners();

      final res = await _repo.getAllCompetitions(
        rootType: rootType,
      );

      _allCategories = res.data?.children ?? [];
      _applyLocalFilter();
      debugPrint(
        "📦 ALL: ${_allCategories.length}, "
        "FILTERED: ${_categories.length}, "
        "activeFilter=$categoryId",
      );
    } catch (e) {
      debugPrint("❌ PROVIDER ERROR: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCompetitions(BuildContext context, String rootType) async {
    await _fetchCompetitionsWithFilter(
        context, rootType, _selectedFilterCategoryId);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOAD MORE (pagination)
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> loadMore(BuildContext context) async {
    if (!hasMore || _isPaginationLoading) return;
    try {
      _isPaginationLoading = true;
      notifyListeners();
      final nextPage = _page + 1;
      final res = await _repo.getAllCompetitions(
        rootType: currentRootType,
        page: nextPage,
      );
      _allCategories = [..._allCategories, ...?(res.data?.children)];
      _applyLocalFilter();
      _page = nextPage;
      _totalPages = (res.meta?['pages'] as int?) ?? _totalPages;
    } finally {
      _isPaginationLoading = false;
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOCAL FETCH (used by CompetitionDetailScreen)
  // ══════════════════════════════════════════════════════════════════════════

  Future<CompetationDetailData?> fetchByPathLocal(
    BuildContext context,
    String path, {
    String? categoryId,
  }) async {
    final res = await _repo.getCompetitionByPath(
      path,
      currentRootType,
      categoryId: categoryId,
    );
    return res.data;
  }

  Future<List<OlympiadCategoryData>> fetchCategoryTreeLocal(
      String rootType) async {
    try {
      final res = await _repo.getCategoryTree(rootType);
      return res.data ?? [];
    } catch (_) {
      return [];
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FETCH BY PATH
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> fetchByPath(BuildContext context, String path) async {
    try {
      _isLoading = true;
      _error = null;
      _detail = null;
      notifyListeners();
      final res = await _repo.getCompetitionByPath(path, currentRootType);
      _detail = res.data;
    } on AppException catch (e) {
      _error = e.message;
      if (context.mounted) {
        AppToast.error(context, title: 'Error', message: e.message);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FETCH CATEGORY DETAIL
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> fetchCategoryDetail(BuildContext context, String id) async {
    try {
      _isLoading = true;
      notifyListeners();
      final res = await _repo.getCategoryDetail(id);
      _categoryDetail = res.data;
    } catch (e) {
      debugPrint("❌ DETAIL ERROR: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FETCH TESTS — with optional search
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> fetchTests(
    BuildContext context,
    String categoryId,
    String? rootType, {
    String? search,
    bool isSearchTrigger = false,
  }) async {
    final normalised = (search ?? '').trim().isEmpty ? null : search!.trim();

    if (_lastFetchedCategoryId == categoryId &&
        _lastFetchedSearch == normalised) {
      return;
    }

    try {
      if (isSearchTrigger) {
        _isTestSearchLoading = true;
      } else {
        _isLoading = true;
      }
      notifyListeners();

      final res = await _repo.getAvailableTests(
        categoryId: categoryId,
        rootType: rootType,
        search: normalised,
      );

      _tests = res.data ?? [];
      _testMeta = res.meta;
      _lastFetchedCategoryId = categoryId;
      _lastFetchedSearch = normalised;

      debugPrint(
        "📦 fetchTests → rootType=$rootType | supportsSearch=$supportsSearch "
        "| search=$normalised | count=${_tests.length}",
      );
    } catch (e) {
      debugPrint("❌ TEST ERROR: $e");
    } finally {
      _isLoading = false;
      _isTestSearchLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTestSearch(
    BuildContext context,
    String categoryId,
    String? rootType,
    String query,
  ) async {
    _testSearchQuery = query;
    notifyListeners();

    await fetchTests(
      context,
      categoryId,
      rootType,
      search: query,
      isSearchTrigger: true,
    );
  }

  Future<void> clearTestSearch(
    BuildContext context,
    String categoryId,
    String? rootType,
  ) async {
    _testSearchQuery = '';
    await fetchTests(context, categoryId, rootType);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FETCH SINGLE COMPETITION
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> fetchSingleCompetition(
    BuildContext context,
    String competitionId,
  ) async {
    try {
      _isSingleLoading = true;
      _singleError = null;
      _singleCompetition = null;
      notifyListeners();
      final res = await _repo.getSingleCompetition(competitionId);
      _singleCompetition = res.data;
    } on AppException catch (e) {
      _singleError = e.message;
      if (context.mounted) {
        AppToast.error(context, title: 'Error', message: e.message);
      }
    } finally {
      _isSingleLoading = false;
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // COUPON
  // ══════════════════════════════════════════════════════════════════════════

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
      final res = await _repo.applyCoupon(
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

  void clearCoupon() {
    _appliedCoupon = null;
    _couponError = null;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CATEGORY PAYMENT
  // ══════════════════════════════════════════════════════════════════════════

  Future<String?> initiateCategoryPayment(
    BuildContext context, {
    required String categoryId,
    required String paymentMethod,
    String? couponCode,
  }) async {
    try {
      _isCategoryPaymentLoading = true;
      _categoryPaymentError = null;
      _pendingCategoryOrder = null;
      notifyListeners();

      final res = await _repo.initiateCategoryPayment(
        categoryId: categoryId,
        paymentMethod: paymentMethod,
        couponCode: couponCode,
      );

      if (paymentMethod == 'wallet' || paymentMethod == 'free') return 'success';

      final orderData = res.data;
      if (orderData?.completed == true || orderData?.orderId == null) {
        return 'success';
      }

      _pendingCategoryOrder = orderData;
      return 'razorpay';
    } on AppException catch (e) {
      _categoryPaymentError = e.message;
      if (context.mounted) {
        AppToast.error(context, title: 'Payment Error', message: e.message);
      }
      return null;
    } catch (_) {
      _categoryPaymentError = 'Something went wrong.';
      return null;
    } finally {
      _isCategoryPaymentLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  FIX: completeCategoryRazorpayPayment
  //  Removed addPostFrameCallback race condition.
  //  Now awaits re-fetch directly and returns true/false.
  //  The snackbar + onPurchaseSuccess callback is handled by the sheet.
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> completeCategoryRazorpayPayment(
    BuildContext context, {
    required String categoryId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final res = await _repo.completeCategoryRazorpayPayment(
        categoryId: categoryId,
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );
      _confirmedCategoryPurchase = res.data;
      _pendingCategoryOrder = null;
      notifyListeners();

      // ✅ FIX: await the refresh directly — no postFrameCallback race
      await _notifyPaymentSuccess();

      return true;
    } on AppException catch (e) {
      final ctx = rootContext;
      if (ctx != null && ctx.mounted) {
        AppToast.error(ctx, title: 'Verification Failed', message: e.message);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UPGRADE
  // ══════════════════════════════════════════════════════════════════════════

  Future<String?> initiateUpgrade(
    BuildContext context, {
    required String categoryId,
    required String paymentMethod,
  }) async {
    try {
      _isUpgradeLoading = true;
      _upgradeError = null;
      _pendingUpgradeOrder = null;
      notifyListeners();

      final res = await _repo.initiateUpgrade(
        categoryId: categoryId,
        paymentMethod: paymentMethod,
      );

      if (paymentMethod == 'wallet' || paymentMethod == 'free') return 'success';

      final orderData = res.data;
      if (orderData?.completed == true || orderData?.orderId == null) {
        return 'success';
      }

      _pendingUpgradeOrder = orderData;
      return 'razorpay';
    } on AppException catch (e) {
      _upgradeError = e.message;
      if (context.mounted) {
        AppToast.error(context, title: 'Upgrade Error', message: e.message);
      }
      return null;
    } catch (_) {
      _upgradeError = 'Something went wrong.';
      return null;
    } finally {
      _isUpgradeLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  FIX: confirmUpgrade — same fix as completeCategoryRazorpayPayment
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> confirmUpgrade(
    BuildContext context, {
    required String categoryId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final res = await _repo.confirmUpgrade(
        categoryId: categoryId,
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );
      _confirmedUpgrade = res.data;
      _pendingUpgradeOrder = null;
      notifyListeners();

      // ✅ FIX: await the refresh directly
      await _notifyPaymentSuccess();

      return true;
    } on AppException catch (e) {
      final ctx = rootContext;
      if (ctx != null && ctx.mounted) {
        AppToast.error(ctx, title: 'Upgrade Failed', message: e.message);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TEST PAYMENT
  // ══════════════════════════════════════════════════════════════════════════

  Future<String?> initiateTestPayment(
    BuildContext context, {
    required String testId,
    required String paymentMethod,
    String? couponCode,
  }) async {
    try {
      _isPaymentLoading = true;
      _paymentError = null;
      _pendingTestOrder = null;
      notifyListeners();

      final res = await _repo.initiateTestPayment(
        testId: testId,
        paymentMethod: paymentMethod,
        couponCode: couponCode,
      );

      if (paymentMethod == 'free' || paymentMethod == 'wallet') return 'success';

      final orderData = res.data;
      if (orderData?.completed == true || orderData?.orderId == null) {
        return 'success';
      }

      _pendingTestOrder = orderData;
      return 'razorpay';
    } on AppException catch (e) {
      _paymentError = e.message;
      if (context.mounted) {
        AppToast.error(context, title: 'Payment Error', message: e.message);
      }
      return null;
    } catch (_) {
      _paymentError = 'Something went wrong.';
      return null;
    } finally {
      _isPaymentLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  FIX: completeTestRazorpayPayment
  //  Now awaits _notifyPaymentSuccess so tests list also refreshes.
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> completeTestRazorpayPayment(
    BuildContext context, {
    required String testId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final res = await _repo.completeTestRazorpayPayment(
        testId: testId,
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );
      _confirmedTestPurchase = res.data;
      _pendingTestOrder = null;
      notifyListeners();

      // ✅ FIX: refresh competitions list so hasAccess is updated
      await _notifyPaymentSuccess();

      return true;
    } on AppException catch (e) {
      debugPrint("❌ Provider completeTestRazorpayPayment: ${e.message}");
      final ctx = context.mounted ? context : rootContext;
      if (ctx != null && ctx.mounted) {
        AppToast.error(ctx, title: 'Verification Failed', message: e.message);
      }
      return false;
    } catch (e) {
      debugPrint("❌ Provider completeTestRazorpayPayment unknown: $e");
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FULL RESET
  // ══════════════════════════════════════════════════════════════════════════

  void reset() {
    _allCategories = [];
    _categories = [];
    _isLoading = false;
    _isPaginationLoading = false;
    _page = 1;
    _totalPages = 1;
    _detail = null;
    _error = null;
    _categoryDetail = null;
    _tests = [];
    _testMeta = null;
    _singleCompetition = null;
    _isSingleLoading = false;
    _singleError = null;
    _categoryTree = [];
    _isCategoryTreeLoading = false;
    _selectedFilterCategoryId = null;
    _isCouponLoading = false;
    _couponError = null;
    _appliedCoupon = null;
    _isCategoryPaymentLoading = false;
    _categoryPaymentError = null;
    _pendingCategoryOrder = null;
    _confirmedCategoryPurchase = null;
    _isUpgradeLoading = false;
    _upgradeError = null;
    _pendingUpgradeOrder = null;
    _confirmedUpgrade = null;
    _isPaymentLoading = false;
    _paymentError = null;
    _pendingTestOrder = null;
    _confirmedTestPurchase = null;
    _testSearchQuery = '';
    _lastFetchedSearch = null;
    _lastFetchedCategoryId = null;
    notifyListeners();
  }
}