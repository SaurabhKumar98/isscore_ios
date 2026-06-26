import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/needtoimprove/needtoimprove_models.dart';
import 'package:firstedu/data/repo/needtoimprove/needtoimprove_repo.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

class NeedToImproveProvider extends ChangeNotifier {
  final NeedToImproveRepo _repo;

  NeedToImproveProvider(this._repo);

  // ── STATE ──────────────────────────────────────────────────────────────

  ImproveData? _data;
  ImproveData? get data => _data;

  // currently selected weak category index
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  WeakCategory? get selectedCategory =>
      (_data?.weakCategories?.isNotEmpty == true)
          ? _data!.weakCategories![_selectedIndex]
          : null;

  List<WeakCategory> get weakCategories =>
      _data?.weakCategories ?? [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ── FETCH ──────────────────────────────────────────────────────────────

  Future<void> fetchData(BuildContext context) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final res = await _repo.getNeedToImproveData();

      if (res.success == true) {
        _data = res.data;
        _selectedIndex = 0;
      } else {
        _error = res.message ?? "Failed to load data.";
        if (context.mounted) {
          AppToast.error(context, title: "Error", message: _error!);
        }
      }
    } on AppException catch (e) {
      _error = e.message;
      if (context.mounted) {
        AppToast.error(context, title: "Error", message: e.message);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── SELECT CATEGORY (tab/chip switch) ─────────────────────────────────

  void selectCategory(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }

  // ── RESET ──────────────────────────────────────────────────────────────

  void reset() {
    _data = null;
    _isLoading = false;
    _error = null;
    _selectedIndex = 0;
    notifyListeners();
  }
}