import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/wallet_models/wallet_models.dart';
import 'package:firstedu/data/repo/wallet_repo/wallet_repo.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view_models/razropaymanger/razorpayservices.dart';
import 'package:flutter/widgets.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

enum WalletStatus { idle, loading, success, error }

class WalletProvider extends ChangeNotifier {
  final WalletRepository _repo;
  WalletProvider(this._repo);

  WalletStatus _status = WalletStatus.idle;
  WalletStatus get status => _status;
  bool get isLoading => _status == WalletStatus.loading;

  WalletBalance? _balance;
  WalletBalance? get balance => _balance;

  // ✅ Screen reads this for the success dialog
  int _lastRechargedAmount = 0;
  int get lastRechargedAmount => _lastRechargedAmount;

  PointsHistoryResponse? _pointsHistory;
  PointsHistoryResponse? get pointsHistory => _pointsHistory;
  bool _isHistoryLoading = false;
  bool get isHistoryLoading => _isHistoryLoading;
  bool _isPaginationLoading = false;
  bool get isPaginationLoading => _isPaginationLoading;
  bool get hasMoreHistory =>
      (_pointsHistory?.page ?? 0) < (_pointsHistory?.pages ?? 0);

  bool _isRechargePending = false;
  bool get isRechargePending => _isRechargePending;

  bool _isConverting = false;
  bool get isConverting => _isConverting;

  String _error = '';
  String get errorMessage => _error;

  RazorpayOrder? _pendingOrder;

  int _totalPoints = 0;
int get totalPoints => _totalPoints;

  // ✅ Prevents Razorpay firing onSuccess multiple times
  bool _confirmInProgress = false;

  // ── 1. Fetch Balance ──────────────────────────────────────────────────────
  Future<void> fetchBalance() async {
    _setStatus(WalletStatus.loading);
    try {
      _balance = await _repo.getBalance();
      _setStatus(WalletStatus.success);
    } on AppException catch (e) {
      _error = e.message;
      _setStatus(WalletStatus.error);
    }
  }

  // ── 2 + 3. Initiate → Razorpay → Confirm ─────────────────────────────────
  // ✅ No BuildContext — uses AppToast.showGlobal (navigatorKey) instead
  Future<void> initiateRecharge({
    required int amount,
    String? contact,
    String? email,
    required void Function() onSuccess, // ✅ no message param needed
  }) async {
    if (_isRechargePending) return;
    _isRechargePending = true;
    _confirmInProgress = false;
    _lastRechargedAmount = amount;
    _error = '';
    notifyListeners();

    try {
      final order = await _repo.initiateRecharge(amount);
      _pendingOrder = order;

      RazorpayManager.instance.init(
        onSuccess: (res) => _onPaymentSuccess(res, onSuccess),
        onError: (res) {
          _isRechargePending = false;
          _confirmInProgress = false;
          notifyListeners();
          // ✅ No context needed — works even after screen is popped
          AppToast.errorGlobal(
            title: 'Payment Failed',
            message: res.message ?? 'Payment failed or cancelled',
          );
        },
      );

      RazorpayManager.instance.openCheckout(
        key: order.key,
        amount: order.amount,
        orderId: order.orderId,
        title: 'Wallet Recharge',
        description: 'Add ₹$amount to your wallet',
        contact: contact,
        email: email,
      );
    } on AppException catch (e) {
      _error = e.message;
      _isRechargePending = false;
      notifyListeners();
      AppToast.errorGlobal(title: 'Recharge Failed', message: e.message);
    }
  }

  Future<void> _onPaymentSuccess(
    PaymentSuccessResponse res,
    void Function() onSuccess,
  ) async {
    // ✅ Guard — Razorpay fires onSuccess multiple times
    if (_confirmInProgress) return;
    _confirmInProgress = true;

    try {
      final result = await _repo.confirmRecharge(
        razorpayOrderId: res.orderId ?? _pendingOrder?.orderId ?? '',
        razorpayPaymentId: res.paymentId ?? '',
        razorpaySignature: res.signature ?? '',
      );

      _balance = WalletBalance(
        monetaryBalance: result.balance,
        rewardPoints: _balance?.rewardPoints ?? 0,
      );
      _pendingOrder = null;
      _isRechargePending = false;
      notifyListeners();

      fetchPointsHistory(refresh: true);

      // ✅ Screen shows its own success dialog via onSuccess()
      // Provider also shows a global toast as backup
      onSuccess();
    } on AppException catch (e) {
      _isRechargePending = false;
      _confirmInProgress = false;
      notifyListeners();
      AppToast.errorGlobal(title: 'Recharge Failed', message: e.message);
    }
  }

  // ── 4. Points History ─────────────────────────────────────────────────────
  Future<void> fetchPointsHistory({bool refresh = false}) async {
    if (refresh) {
  _pointsHistory = null;
  _isHistoryLoading = true;
  notifyListeners();

  try {
    _pointsHistory = await _repo.getPointsHistory(page: 1);
    _totalPoints = _pointsHistory?.total ?? 0; // ✅ FIX
  } on AppException catch (e) {
    _error = e.message;
  } finally {
    _isHistoryLoading = false;
    notifyListeners();
  }
  return;
}

    if (!hasMoreHistory || _isPaginationLoading) return;
    _isPaginationLoading = true;
    notifyListeners();

    try {
      final nextPage = (_pointsHistory?.page ?? 0) + 1;
      final res = await _repo.getPointsHistory(page: nextPage);
      _totalPoints = _pointsHistory?.total ?? 0; 
      _pointsHistory = PointsHistoryResponse(
        items: [...(_pointsHistory?.items ?? []), ...res.items],
        page: res.page,
        limit: res.limit,
        total: res.total,
        pages: res.pages,
      );
      _totalPoints = res.total;
      print("TOTAL POINTS: ${_pointsHistory?.total}");
    } on AppException catch (e) {
      _error = e.message;
    } finally {
      _isPaginationLoading = false;
      notifyListeners();
    }
  }

  // ── 5. Convert Points ─────────────────────────────────────────────────────
  Future<void> convertPoints({
    required int points,
    required void Function(String) onSuccess,
  }) async {
    _isConverting = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _repo.convertPoints(points);
      _balance = WalletBalance(
        monetaryBalance: result.monetaryBalance,
        rewardPoints: result.rewardPoints,
      );
      fetchPointsHistory(refresh: true);
      _isConverting = false;
      notifyListeners();
      onSuccess(
        'Converted $points XP → ₹${(points / 100 * 10).toStringAsFixed(0)}',
      );
    } on AppException catch (e) {
      _error = e.message;
      _isConverting = false;
      notifyListeners();
      // ✅ Global toast — no context needed
      AppToast.errorGlobal(title: 'Conversion Failed', message: e.message);
    }
  }

  // ── Cleanup ───────────────────────────────────────────────────────────────
  void cleanup() {
    RazorpayManager.instance.clear();
  }

  void _setStatus(WalletStatus s) {
    _status = s;
    notifyListeners();
  }
}
