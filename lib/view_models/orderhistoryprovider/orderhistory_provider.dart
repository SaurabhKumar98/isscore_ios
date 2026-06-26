import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/orderhistorymodels/orderhistory_models.dart';
import 'package:firstedu/data/repo/orderhistory/orderhistory_repo.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

class OrderhistoryProvider extends ChangeNotifier {
  final OrderhistoryRepo _orderhistoryRepo;

  OrderhistoryProvider(this._orderhistoryRepo);

  // ─────────────────── LOADING STATE ───────────────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPaginationLoading = false;
  bool get isPaginationLoading => _isPaginationLoading;

  // ─────────────────── DATA STATE ──────────────────────

  List<OrderHistoryItem> _orders = [];
  List<OrderHistoryItem> get orders => _orders;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // ─────────────────── ACTIVE FILTERS ──────────────────
  // Kept here so loadMore can repeat the same query.

  String? _activeType;       // null → All
  String? _activeCategoryId; // null → no filter
  String? _activeFrom;
  String? _activeTo;

  // ─────────────────── PAGINATION STATE ────────────────

  int _currentPage = 1;
  int get currentPage => _currentPage;

  int _totalPages = 1;
  int get totalPages => _totalPages;

  int _totalItems = 0;
  int get totalItems => _totalItems;

  bool get hasMore => _currentPage < _totalPages;

  // ─────────────────── HELPERS ─────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setPaginationLoading(bool value) {
    _isPaginationLoading = value;
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

  // ─────────────────── FETCH ORDERS ────────────────────

  /// [type] — single API type value or null for All.
  /// [categoryId] — MongoDB ObjectId string or null.
  Future<void> fetchOrders(
    BuildContext context, {
    String? type,
    String? categoryId,
    String? from,
    String? to,
  }) async {
    // Persist active filters so loadMore can reuse them.
    _activeType = type;
    _activeCategoryId = categoryId;
    _activeFrom = from;
    _activeTo = to;

    try {
      _setLoading(true);
      clearError();

      _currentPage = 1;
      _orders = [];

      final model = await _orderhistoryRepo.getOrderHistory(
        page: _currentPage,
        limit: 10,
        type: _activeType,
        categoryId: _activeCategoryId,
        from: _activeFrom,
        to: _activeTo,
      );

      _orders = model.data ?? [];
      _totalPages = model.meta?.pages ?? 1;
      _totalItems = model.meta?.total ?? 0;
    } on AppException catch (e) {
      _setError(e.message);
      if (context.mounted) {
        AppToast.error(context, title: "Failed to Load", message: e.message);
      }
    } catch (e, stack) {
      debugPrint("❌ ORDER HISTORY FETCH ERROR: $e\n$stack");
      const msg = "Something went wrong. Please try again.";
      _setError(msg);
      if (context.mounted) {
        AppToast.error(context, title: "Error", message: msg);
      }
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────── LOAD MORE ───────────────────────

  Future<void> loadMore(BuildContext context) async {
    if (!hasMore || _isPaginationLoading) return;

    final nextPage = _currentPage + 1;

    try {
      _setPaginationLoading(true);

      final model = await _orderhistoryRepo.getOrderHistory(
        page: nextPage,
        limit: 10,
        type: _activeType,
        categoryId: _activeCategoryId,
        from: _activeFrom,
        to: _activeTo,
      );

      _orders.addAll(model.data ?? []);
      _currentPage = nextPage;
      _totalPages = model.meta?.pages ?? 1;
      _totalItems = model.meta?.total ?? 0;

      notifyListeners();
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(
            context, title: "Failed to Load More", message: e.message);
      }
    } catch (e, stack) {
      debugPrint("❌ ORDER HISTORY LOAD MORE ERROR: $e\n$stack");
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

  // ─────────────────── RESET ───────────────────────────

  void reset() {
    _isLoading = false;
    _isPaginationLoading = false;
    _orders = [];
    _currentPage = 1;
    _totalPages = 1;
    _totalItems = 0;
    _errorMessage = '';
    _activeType = null;
    _activeCategoryId = null;
    _activeFrom = null;
    _activeTo = null;
    notifyListeners();
  }
}