import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/competetive/applycoupanmodels.dart';
import 'package:firstedu/data/models/api_models/coursedownload/coursedetailsbyidmodels.dart';
import 'package:firstedu/data/models/api_models/coursedownload/coursedownloadallmodels.dart';
import 'package:firstedu/data/models/api_models/coursedownload/coursepaymentmodels.dart';
import 'package:firstedu/data/models/api_models/resourcestore/Categorymodels.dart';
import 'package:firstedu/data/repo/coursedownload/coursedownload_repositores.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

class CourseDownloadProvider extends ChangeNotifier {
  final CourseDownloadRepository _repository;

  CourseDownloadProvider(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPaginationLoading = false;
  bool get isPaginationLoading => _isPaginationLoading;

  bool? _isCertification;
  bool? get isCertification => _isCertification;

  CourseDetailsData? _courseDetails;
  CourseDetailsData? get courseDetails => _courseDetails;

  bool _isLoadingDetails = false;
  bool get isLoadingDetails => _isLoadingDetails;

  List<CourseData> _items = [];
  List<CourseData> get items => _items;

  String? _selectedType; 
  String _selectedAccess = 'both'; 

  String? get selectedType => _selectedType;
  String get selectedAccess => _selectedAccess;
  bool _isPaymentLoading = false;
  bool get isPaymentLoading => _isPaymentLoading;

  CourseInitiatePaymentData? _pendingRazorpayOrder;
  CourseInitiatePaymentData? get pendingRazorpayOrder => _pendingRazorpayOrder;
  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  bool _isCategoryLoading = false;
  bool get isCategoryLoading => _isCategoryLoading;

  CategoryModel? _selectedCategory;
  CategoryModel? get selectedCategory => _selectedCategory;

  String? _categoryId;
  String? get selectedCategoryId => _categoryId;

  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;
CouponData? _appliedCoupon;
CouponData? get appliedCoupon => _appliedCoupon;
String? _couponError;
String? get couponError => _couponError;
bool _isCouponLoading = false;
bool get isCouponLoading => _isCouponLoading;

  Future<void> fetchDownloads(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      _currentPage = 1;
      _items = [];

      final model = await _repository.getCourseDownloads(
        type: _selectedType,
        access: _selectedAccess,
        isCertification: _isCertification,
        category: _categoryId,
        page: _currentPage,
      );

      _items = model.data;
      _totalPages = model.meta?.pages ?? 1;
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(context, title: "Error", message: e.message);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCourseDetails(BuildContext context, String courseId) async {
    try {
      _isLoadingDetails = true;
      notifyListeners();

      final res = await _repository.getCourseDetails(courseId);

      _courseDetails = res.data;
    } on AppException catch (e) {
      AppToast.error(context, title: "Error", message: e.message);
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategories({bool? isCertification}) async {
    try {
      _isCategoryLoading = true;
      notifyListeners();
      final response = await _repository.getCourseCategories(
        isCertification: isCertification,
      );
      _categories = response.data;
    } catch (e) {
      _categories = [];
      debugPrint("❌ COURSE CATEGORY ERROR: $e");
    } finally {
      _isCategoryLoading = false;
      notifyListeners();
    }
  }
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

    final res = await _repository.applyCoupon(
      code: code,
      amount: amount,
      module: 'course',   // ← fixed for course sheet
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

  void selectCategory(BuildContext context, CategoryModel? cat) {
    _selectedCategory = cat;
    _categoryId = cat?.id;
    notifyListeners();
    fetchDownloads(context);
  }

  void clearCategory(BuildContext context) {
    _selectedCategory = null;
    _categoryId = null;
    notifyListeners();
    fetchDownloads(context);
  }

  Future<void> setCertification(BuildContext context, bool? value) async {
    _isCertification = value ?? false;
    print("CERTIFICATION VALUE => $_isCertification");

    await fetchDownloads(context);
  }

  Future<void> loadMore(BuildContext context) async {
    if (!hasMore || _isPaginationLoading) return;

    try {
      _isPaginationLoading = true;
      notifyListeners();

      final nextPage = _currentPage + 1;

      final model = await _repository.getCourseDownloads(
        type: _selectedType,
        access: _selectedAccess,
        page: nextPage,
      );

      _items.addAll(model.data);
      _currentPage = nextPage;
      _totalPages = model.meta?.pages ?? _totalPages;
    } finally {
      _isPaginationLoading = false;
      notifyListeners();
    }
  }

  Future<void> setType(BuildContext context, String? type) async {
    if (_selectedType == type) return;
    _selectedType = type;
    await fetchDownloads(context);
  }

  Future<void> setAccess(BuildContext context, String access) async {
    if (_selectedAccess == access) return;
    _selectedAccess = access;
    await fetchDownloads(context);
  }

  Future<String?> initiatePayment(
    BuildContext context, {
    required String courseId,
    required CoursePaymentMethod method,
    String? couponCode,
  }) async {
    try {
      _isPaymentLoading = true;
      notifyListeners();

      final result = await _repository.initiatePayment(
        courseId: courseId,
        method: method,
        couponCode: couponCode,
      );

      final data = result.data;
      if (data == null) return null;

      // Free or wallet — completed immediately
      if (data.isCompleted) {
        if (context.mounted) {
          AppToast.success(
            context,
            title: "Success",
            message: result.message ?? "Course purchased!",
          );
        }
        return 'success';
      }

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

  Future<void> completeRazorpayPurchase(
    BuildContext context, {
    required String courseId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      _isPaymentLoading = true;
      notifyListeners();

      final result = await _repository.completePurchase(
        courseId: courseId,
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );

      _pendingRazorpayOrder = null;

      if (context.mounted) {
        AppToast.success(
          context,
          title: "Success",
          message: result.message ?? "Course purchased!",
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

  void reset() {
    _isLoading = false;
    _isPaginationLoading = false;
    _items = [];
    _selectedType = null;
    _selectedAccess = 'both';
    _currentPage = 1;
    _totalPages = 1;
    notifyListeners();
  }
}
