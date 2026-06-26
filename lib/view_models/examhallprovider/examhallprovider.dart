import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/examhall/examhall_models.dart';
import 'package:firstedu/data/models/api_models/resourcestore/Categorymodels.dart';
import 'package:firstedu/data/repo/examhall/examhall_repositories.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

class ExamHallProvider extends ChangeNotifier {
  final ExamHallRepository _repository;

  ExamHallProvider(this._repository);

  // ─── Loading ───────────────────────────────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPaginationLoading = false;
  bool get isPaginationLoading => _isPaginationLoading;

  bool _isCategoryLoading = false;
  bool get isCategoryLoading => _isCategoryLoading;
  List<CategoryModel> _visibleCategories = [];
  List<CategoryModel> get visibleCategories => _visibleCategories;

  // ─── Items ─────────────────────────────────────────────────────────
  List<ExamHallItem> _items = [];
  List<ExamHallItem> get items => _items;

  // ─── Pagination ────────────────────────────────────────────────────
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  int get totalItems => _totalItems;
  bool get hasMore => _currentPage < _totalPages;

  // ─── Type filter (Row 1) ───────────────────────────────────────────
  // 'all' | 'test' | 'testBundle'
  String _selectedType = 'all';
  String get selectedType => _selectedType;

  // ─── Category filter (Row 2) ───────────────────────────────────────
  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  CategoryModel? _selectedCategory;
  CategoryModel? get selectedCategory => _selectedCategory;

  // ─── Error ─────────────────────────────────────────────────────────
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // ─── Helpers ───────────────────────────────────────────────────────
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setPaginationLoading(bool v) {
    _isPaginationLoading = v;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // ─── Fetch items ───────────────────────────────────────────────────
Future<void> fetchItems(BuildContext context) async {
  try {
    _isLoading = true;
    _errorMessage = '';
    _items = [];
    _currentPage = 1;
    notifyListeners();

    final model = await _repository.getExamHall(
      type: _selectedType == 'all' ? null : _selectedType,
      categoryId: _selectedCategory?.id,
      page: 1,
    );

    _items = model.data ?? [];
    _totalPages = model.pagination?.pages ?? 1;   // ✅ pagination, not meta
    _totalItems = model.pagination?.total ?? 0;   // ✅ pagination, not meta
    _currentPage = 1;
  } on AppException catch (e) {
    _errorMessage = e.message;
    if (context.mounted) {
      AppToast.error(context, title: "Failed to Load", message: e.message);
    }
  } catch (e, stack) {
    debugPrint("❌ EXAM HALL FETCH ERROR: $e\n$stack");
    const msg = "Something went wrong. Please try again.";
    _errorMessage = msg;
    if (context.mounted) {
      AppToast.error(context, title: "Error", message: msg);
    }
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
  // ─── Pagination ────────────────────────────────────────────────────
  Future<void> loadMore(BuildContext context) async {
    if (!hasMore || _isPaginationLoading) return;
    final nextPage = _currentPage + 1;
    try {
      _setPaginationLoading(true);
      final model = await _repository.getExamHall(
        type: _selectedType == 'all' ? null : _selectedType,
        categoryId: _selectedCategory?.id,
        page: nextPage,
      );
      _items.addAll(model.data ?? []);
      _currentPage = nextPage;
      _totalPages = model.pagination?.pages ?? _totalPages;
      _totalItems = model.pagination?.total ?? _totalItems;
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(
          context,
          title: "Failed to Load More",
          message: e.message,
        );
      }
    } catch (e, stack) {
      debugPrint("❌ EXAM HALL LOAD MORE ERROR: $e\n$stack");
      if (context.mounted) {
        AppToast.error(
          context,
          title: "Error",
          message: "Something went wrong.",
        );
      }
    } finally {
      _setPaginationLoading(false);
    }
  }

  // ─── Fetch categories for current type ────────────────────────────
  // Called whenever type changes. linkedTo maps:
  //   all        → 'both'
  //   test       → 'test'
  //   testBundle → 'testBundle'
Future<void> fetchCategories() async {
  try {
    _isCategoryLoading = true;
    notifyListeners();

    final response = await _repository.getCategories();  // ✅ no linkedTo
    _categories = response.data;
  } on AppException catch (e) {
    debugPrint('❌ CATEGORY ERROR: ${e.message}');
    _categories = [];
  } catch (e) {
    debugPrint('❌ CATEGORY ERROR: $e');
    _categories = [];
  } finally {
    _isCategoryLoading = false;
    notifyListeners();
  }
}
  // ─── Row 1: Type chip tapped ───────────────────────────────────────
  // Changes type → resets category → fetches new categories + items
  Future<void> setType(BuildContext context, String type) async {
    if (_selectedType == type) return;
    _selectedType = type;
    _selectedCategory = null; // reset category when type changes
    notifyListeners();
    await Future.wait([fetchCategories(), fetchItems(context)]);
  }

  // ─── Row 2: Category chip tapped ──────────────────────────────────
  // Tapping same category deselects it (shows all for current type)
  void selectCategory(BuildContext context, CategoryModel category) {
    if (_selectedCategory?.id == category.id) {
      _selectedCategory = null;
    } else {
      _selectedCategory = category;
    }

    // ❌ DO NOT TOUCH visibleCategories HERE
    // UI handled by bottom sheet only

    notifyListeners();
    fetchItems(context);
  }

  // ─── Init ──────────────────────────────────────────────────────────
  Future<void> init(BuildContext context) async {
  await Future.wait([
    fetchCategories(),   // ✅ no arguments
    fetchItems(context),
  ]);
}
void clearItems() {
  _items = [];
  _currentPage = 1;
  _totalPages = 1;
  _errorMessage = '';
  notifyListeners();
}
  // ─── Reset ─────────────────────────────────────────────────────────
  void reset() {
    _isLoading = false;
    _isPaginationLoading = false;
    _isCategoryLoading = false;
    _items = [];
    _categories = [];
    _selectedType = 'all';
    _selectedCategory = null;
    _currentPage = 1;
    _totalPages = 1;
    _totalItems = 0;
    _errorMessage = '';
    notifyListeners();
  }
}
