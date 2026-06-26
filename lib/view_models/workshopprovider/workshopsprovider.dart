import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/competetive/applycoupanmodels.dart';
import 'package:firstedu/data/models/api_models/workshops_models/workshopmodels.dart';
import 'package:firstedu/data/models/api_models/workshops_models/workshopsbyidmodels.dart';
import 'package:firstedu/data/repo/workshops/paymentmodels.dart';
import 'package:firstedu/data/repo/workshops/workshops_repositories.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

class WorkshopProvider extends ChangeNotifier {
  final WorkshopRepository _repo;
  WorkshopProvider(this._repo);

  // ── LIST ──────────────────────────────────────────────────────────────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPaginationLoading = false;
  bool get isPaginationLoading => _isPaginationLoading;

  List<Workshop> _workshops = [];
  List<Workshop> get workshops => _workshops;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String _selectedFilter = 'All';
  int _selectedFilterIndex = 0;
  int get selectedFilterIndex => _selectedFilterIndex;

  int _currentPage = 1;
  int _totalPages = 1;
  bool get hasMore => _currentPage < _totalPages;

  // ── DETAIL ────────────────────────────────────────────────────────────────

  bool _isDetailLoading = false;
  bool get isDetailLoading => _isDetailLoading;

  WorkshopDetails? _selectedWorkshop;
  WorkshopDetails? get selectedWorkshop => _selectedWorkshop;

  String _detailError = '';
  String get detailError => _detailError;

  // ── PAYMENT ───────────────────────────────────────────────────────────────

  bool _isPaymentLoading = false;
  bool get isPaymentLoading => _isPaymentLoading;

  InitiatePaymentData? _pendingRazorpayOrder;
  InitiatePaymentData? get pendingRazorpayOrder => _pendingRazorpayOrder;

  // ── COUPON ────────────────────────────────────────────────────────────────

  bool _isCouponLoading = false;
  bool get isCouponLoading => _isCouponLoading;

  String? _couponError;
  String? get couponError => _couponError;

  CouponData? _appliedCoupon;
  CouponData? get appliedCoupon => _appliedCoupon;

  // ── HELPERS ───────────────────────────────────────────────────────────────

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
  void _setPagLoading(bool v) { _isPaginationLoading = v; notifyListeners(); }

  void clearError() { _errorMessage = ''; notifyListeners(); }

  // ── FETCH WORKSHOPS ───────────────────────────────────────────────────────

  Future<void> fetchWorkshops(BuildContext context) async {
    try {
      _setLoading(true);
      clearError();
      _currentPage = 1;
      _workshops = [];

      final model = await _repo.getWorkshops(
        page: _currentPage,
        status: _selectedFilter,
      );
      _workshops = model.workshops;
      _totalPages = model.meta?.totalPages ?? 1;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      if (context.mounted)
        AppToast.error(context, title: 'Failed', message: e.message);
    } catch (_) {
      _errorMessage = 'Something went wrong.';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // ── LOAD MORE ─────────────────────────────────────────────────────────────

  Future<void> loadMore(BuildContext context) async {
    if (!hasMore || _isPaginationLoading) return;
    final next = _currentPage + 1;
    try {
      _setPagLoading(true);
      final model = await _repo.getWorkshops(page: next, status: _selectedFilter);
      _workshops.addAll(model.workshops);
      _currentPage = next;
      _totalPages = model.meta?.totalPages ?? 1;
    } on AppException catch (e) {
      if (context.mounted)
        AppToast.error(context, title: 'Error', message: e.message);
    } catch (_) {
    } finally {
      _setPagLoading(false);
    }
  }

  // ── FILTER ────────────────────────────────────────────────────────────────

  Future<void> setFilter(BuildContext context, int index, String label) async {
    if (_selectedFilterIndex == index) return;
    _selectedFilterIndex = index;
    _selectedFilter = label;
    notifyListeners();
    await fetchWorkshops(context);
  }

  // ── DETAIL ────────────────────────────────────────────────────────────────

  Future<void> fetchWorkshopDetail(BuildContext context, String id) async {
    try {
      _isDetailLoading = true;
      _detailError = '';
      _selectedWorkshop = null;
      notifyListeners();
      final model = await _repo.getWorkshopDetails(id);
      _selectedWorkshop = model.data;
    } on AppException catch (e) {
      _detailError = e.message;
      if (context.mounted)
        AppToast.error(context, title: 'Error', message: e.message);
    } catch (_) {
      _detailError = 'Something went wrong.';
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  void clearDetail() {
    _selectedWorkshop = null;
    _detailError = '';
    _isDetailLoading = false;
    _pendingRazorpayOrder = null;
    // also clear coupon when leaving detail
    _appliedCoupon = null;
    _couponError = null;
    notifyListeners();
  }

  // ── APPLY COUPON ──────────────────────────────────────────────────────────

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

    final res = await _repo.applyCoupon(
      code: code,
      amount: amount,
      module: module,   // ✅ pass as module
    );
print("Coupon Response: ${res.data}");
    _appliedCoupon = res.data;
  } on AppException catch (e) {
    _couponError = e.message;
      print("COUPON ERROR => $e");

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
    required String workshopId,
    required PaymentMethod method,
    String? couponCode, // ← added
  }) async {
    try {
      _isPaymentLoading = true;
      _pendingRazorpayOrder = null;
      notifyListeners();

      final res = await _repo.initiatePayment(
        workshopId: workshopId,
        method: method,
        couponCode: couponCode, // ← passed through
      );

      if (res.data?.completed == true) {
        _refreshWorkshopAsRegistered(workshopId);
        if (context.mounted) {
          AppToast.success(
            context,
            title: 'Registered!',
            message: res.message.isNotEmpty
                ? res.message
                : 'Successfully registered for workshop.',
          );
        }
        return 'success';
      } else {
        _pendingRazorpayOrder = res.data;
        notifyListeners();
        return 'razorpay';
      }
    } on AppException catch (e) {
      if (context.mounted)
        AppToast.error(context, title: 'Payment Failed', message: e.message);
      return 'error';
    } catch (_) {
      if (context.mounted) {
        AppToast.error(context, title: 'Error', message: 'Something went wrong.');
      }
      return 'error';
    } finally {
      _isPaymentLoading = false;
      notifyListeners();
    }
  }

  // ── COMPLETE REGISTRATION ─────────────────────────────────────────────────

  Future<bool> completeRazorpayRegistration(
    BuildContext context, {
    required String workshopId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      _isPaymentLoading = true;
      notifyListeners();

      final res = await _repo.completeRegistration(
        workshopId: workshopId,
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );

      _refreshWorkshopAsRegistered(workshopId);
      _pendingRazorpayOrder = null;

      if (context.mounted) {
        AppToast.success(
          context,
          title: 'Registered!',
          message: res.message.isNotEmpty
              ? res.message
              : 'Payment successful. You are registered!',
        );
      }
      return true;
    } on AppException catch (e) {
      if (context.mounted)
        AppToast.error(context, title: 'Registration Failed', message: e.message);
      return false;
    } catch (_) {
      if (context.mounted) {
        AppToast.error(context, title: 'Error', message: 'Something went wrong.');
      }
      return false;
    } finally {
      _isPaymentLoading = false;
      notifyListeners();
    }
  }

  void _refreshWorkshopAsRegistered(String workshopId) {
    final idx = _workshops.indexWhere((w) => w.workshopId == workshopId);
    if (idx != -1) {
      final old = _workshops[idx];
      _workshops[idx] = Workshop(
        workshopId: old.workshopId,
        title: old.title,
        description: old.description,
        startTime: old.startTime,
        endTime: old.endTime,
        price: old.price,
        maxParticipants: old.maxParticipants,
        eventType: old.eventType,
        status: old.status,
        isRegistered: true,
      );
    }
    if (_selectedWorkshop?.id == workshopId) {
      final d = _selectedWorkshop!;
      _selectedWorkshop = WorkshopDetails(
        id: d.id,
        title: d.title,
        description: d.description,
        imageUrl: d.imageUrl,
        teacher: d.teacher,
        startTime: d.startTime,
        endTime: d.endTime,
        meetingLink: d.meetingLink,
        meetingPassword: d.meetingPassword,
        price: d.price,
        maxParticipants: d.maxParticipants,
        registrationStartTime: d.registrationStartTime,
        registrationEndTime: d.registrationEndTime,
        eventType: d.eventType,
        status: d.status,
        isPublished: d.isPublished,
        isRegistrationOpen: d.isRegistrationOpen,
        isEventLive: d.isEventLive,
        canJoin: d.canJoin,
        isRegistered: true,
        createdAt: d.createdAt,
        updatedAt: d.updatedAt,
      );
    }
    notifyListeners();
  }

  // ── RESET ─────────────────────────────────────────────────────────────────

  void reset() {
    _isLoading = false;
    _isPaginationLoading = false;
    _workshops = [];
    _selectedFilter = 'All';
    _selectedFilterIndex = 0;
    _currentPage = 1;
    _totalPages = 1;
    _errorMessage = '';
    _isDetailLoading = false;
    _selectedWorkshop = null;
    _detailError = '';
    _isPaymentLoading = false;
    _pendingRazorpayOrder = null;
    _isCouponLoading = false;
    _appliedCoupon = null;
    _couponError = null;
    notifyListeners();
  }
}