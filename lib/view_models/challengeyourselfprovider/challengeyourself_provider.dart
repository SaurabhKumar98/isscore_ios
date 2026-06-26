import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/challengeyourself/challengeyourself_models.dart';
import 'package:firstedu/data/models/api_models/competetive/applycoupanmodels.dart';
import 'package:firstedu/data/repo/challengeyourself/challengeyourself_repo.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

class ChallengeYourselfProvider extends ChangeNotifier {
  final ChallengeYourselfRepository _repo;
  ChallengeYourselfProvider(this._repo);

  // ── categories ────────────────────────────────────────────────────────────
  List<CategoryNode> _categories = [];
  List<CategoryNode> get categories => _categories;

  // ── parent selection (class chip) ─────────────────────────────────────────
  String? _selectedParentCategoryId;
  String? get selectedParentCategoryId => _selectedParentCategoryId;

  CategoryNode? get selectedParentCategory => _selectedParentCategoryId == null
      ? null
      : _findById(_categories, _selectedParentCategoryId!);

  // ── leaf / subject selection ──────────────────────────────────────────────
  String? _selectedCategoryId;
  String? get selectedCategoryId => _selectedCategoryId;

  CategoryNode? get selectedCategory => _selectedCategoryId == null
      ? null
      : _findById(_categories, _selectedCategoryId!);

  // ── stages ────────────────────────────────────────────────────────────────
  List<Stage> _stages = [];
  List<Stage> get stages => _stages;

  int _selectedStageIndex = 0;
  int get selectedStageIndex => _selectedStageIndex;

  Stage? get selectedStage =>
      _stages.isNotEmpty ? _stages[_selectedStageIndex] : null;

  // ── loading / error ───────────────────────────────────────────────────────
  bool _isCategoryLoading = false;
  bool get isCategoryLoading => _isCategoryLoading;

  bool _isStageLoading = false;
  bool get isStageLoading => _isStageLoading;

  bool get isLoading => _isCategoryLoading || _isStageLoading;

  String? _error;
  String? get error => _error;

  // ── coupon ────────────────────────────────────────────────────────────────
  CouponData? _appliedCoupon;
  CouponData? get appliedCoupon => _appliedCoupon;

  bool _isCouponLoading = false;
  bool get isCouponLoading => _isCouponLoading;

  String? _couponError;
  String? get couponError => _couponError;

 Future<void> fetchCategories(BuildContext context) async {
  try {
    _isCategoryLoading = true;
    _error = null;
    notifyListeners();

    final res = await _repo.getChallengeYourself();
    _categories = res.data?.categories ?? [];

    final stagesFromResponse = res.data?.stages ?? [];
    if (stagesFromResponse.isNotEmpty && _stages.isEmpty) {
      _stages = stagesFromResponse;
      _selectedStageIndex = _resolveActiveStageIndex(_stages);
    }
  } on AppException catch (e) {
    _error = e.message;
    if (context.mounted) {
      AppToast.error(context, title: 'Error', message: e.message);
    }
  } finally {
    _isCategoryLoading = false;
    notifyListeners();
  }
}

// ── Helper: find which stage the user is currently active in ──────────────
int _resolveActiveStageIndex(List<Stage> stages) {
  if (stages.isEmpty) return 0;

  for (int i = 0; i < stages.length; i++) {
    final stage = stages[i];
    final levels = stage.levels;

    // Check if this stage has ANY unlocked level
    final hasUnlocked = levels.any((l) => l.unlocked == true);
    if (!hasUnlocked) continue;

    // Check if this stage is fully completed (all levels have full marks)
    final totalLevels = stage.totalLevels ?? levels.length;
    final completedCount =
        levels.where((l) => l.completedWithFullMarks == true).length;
    final isFullyCompleted = completedCount >= totalLevels;

    // If not fully completed → this is the active stage
    if (!isFullyCompleted) return i;
  }

  // All stages completed → show the last one
  return stages.length - 1;
}
  // ─────────────────────────────────────────────────────────────────────────
  // FETCH STAGES for a selected leaf category
  // ─────────────────────────────────────────────────────────────────────────

Future<void> fetchStages(BuildContext context) async {
  if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) return;

  try {
    _isStageLoading = true;
    _error = null;
    notifyListeners();

    final res = await _repo.getChallengeYourself(
      categoryId: _selectedCategoryId,
    );

    if ((res.data?.categories ?? []).isNotEmpty) {
      _categories = res.data!.categories;
    }

    _stages = res.data?.stages ?? [];

    // ── Auto-select the current active stage ──────────────────────────
    // Logic:
    // 1. Find first stage where user has an unlocked level but hasn't
    //    completed ALL levels with full marks → that's the active stage
    // 2. If all stages fully completed → stay on last stage
    // 3. Otherwise default to 0 (Bronze)
    _selectedStageIndex = _resolveActiveStageIndex(_stages);

  } on AppException catch (e) {
    _error = e.message;
    if (context.mounted) {
      AppToast.error(context, title: 'Error', message: e.message);
    }
  } finally {
    _isStageLoading = false;
    notifyListeners();
  }
}
  // ─────────────────────────────────────────────────────────────────────────
  // SELECT PARENT (class chip tapped)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> selectParentCategory(
    BuildContext context,
    String parentId,
  ) async {
    if (_selectedParentCategoryId == parentId) return;
    _selectedParentCategoryId = parentId;
    _selectedCategoryId = null;
    _stages = [];
    _selectedStageIndex = 0;
    notifyListeners();

    final parent = _findById(_categories, parentId);
    if (parent != null && parent.children.isEmpty) {
      await _setLeafAndFetch(context, parentId);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SELECT PARENT + CHILD together
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> selectParentAndChild(
    BuildContext context,
    String parentId,
    String childId,
  ) async {
    _selectedParentCategoryId = parentId;
    _stages = [];
    _selectedStageIndex = 0;
    notifyListeners();
    await _setLeafAndFetch(context, childId);
  }

  Future<void> _setLeafAndFetch(BuildContext context, String id) async {
    _selectedCategoryId = id;
    _stages = [];
    _selectedStageIndex = 0;
    notifyListeners();
    await fetchStages(context);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SELECT STAGE TAB
  // ─────────────────────────────────────────────────────────────────────────

  void selectStage(int index) {
    if (_selectedStageIndex == index) return;
    _selectedStageIndex = index;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REFRESH
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> refresh(BuildContext context) async {
    if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty) {
      await fetchStages(context);
    } else {
      await fetchCategories(context);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // COUPON
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> applyCoupon(
    BuildContext context, {
    required String code,
    required int amount,
    required String module,
  }) async {
    try {
      _isCouponLoading = true;
      _couponError = null;
      _appliedCoupon = null;
      notifyListeners();

      final res = await _repo.applyCoupon(
        code: code,
        amount: amount,
        module: module,
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
    _isCouponLoading = false;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // RESET
  // ─────────────────────────────────────────────────────────────────────────

  void reset() {
    _categories = [];
    _stages = [];
    _selectedParentCategoryId = null;
    _selectedCategoryId = null;
    _selectedStageIndex = 0;
    _isCategoryLoading = false;
    _isStageLoading = false;
    _error = null;
    clearCoupon();
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  CategoryNode? _findById(List<CategoryNode> nodes, String id) {
    for (final node in nodes) {
      if (node.id == id) return node;
      final found = _findById(node.children, id);
      if (found != null) return found;
    }
    return null;
  }
}
