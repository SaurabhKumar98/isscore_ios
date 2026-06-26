import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/halloffamemodels/halloffame_models.dart';
import 'package:firstedu/data/repo/halloffame/halloffame_repo.dart';
import 'package:flutter/material.dart';

enum HallOfFameStatus { idle, loading, success, error }

class HallOfFameProvider extends ChangeNotifier {
  final HallOfFameRepositories _repo;

  HallOfFameProvider(this._repo);

  HallOfFameStatus _status = HallOfFameStatus.idle;
  HallOfFameStatus get status => _status;

  bool get isLoading => _status == HallOfFameStatus.loading;

  HallOfFameModels? _hallOfFame;
  HallOfFameModels? get hallOfFame => _hallOfFame;

  String _selectedFilter = 'all';
  String get selectedFilter => _selectedFilter;

  bool _isPaginationLoading = false;
  bool get isPaginationLoading => _isPaginationLoading;

  String _error = '';
  String get errorMessage => _error;

  bool get hasMore =>
      (_hallOfFame?.meta?.page ?? 0) < (_hallOfFame?.meta?.pages ?? 0);

  // ── Fetch Hall Of Fame ─────────────────────────────
  Future<void> fetchHallOfFame({bool refresh = false}) async {
    if (refresh) {
      _hallOfFame = null;
      _setStatus(HallOfFameStatus.loading);

      try {
        _hallOfFame = await _repo.getHallOfFame(
          page: 1,
          eventType: _selectedFilter == 'all' ? null : _selectedFilter,
        );
        _setStatus(HallOfFameStatus.success); // ✅ FIXED
      } on AppException catch (e) {
        _error = e.message;
        _setStatus(HallOfFameStatus.error);
      } catch (e) {
        _error = e.toString();
        _setStatus(HallOfFameStatus.error);
      }
      return;
    }

    if (!hasMore || _isPaginationLoading) return;

    _isPaginationLoading = true;
    notifyListeners();

    try {
      final nextPage = (_hallOfFame?.meta?.page ?? 0) + 1;

      final res = await _repo.getHallOfFame(
        page: nextPage,
        eventType: _selectedFilter == 'all' ? null : _selectedFilter,
      );

      _hallOfFame = HallOfFameModels(
        success: res.success,
        message: res.message,
        data: [...(_hallOfFame?.data ?? []), ...(res.data ?? [])],
        meta: res.meta,
      );
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isPaginationLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String type) {
    if (_selectedFilter == type) return;
    _selectedFilter = type;
    fetchHallOfFame(refresh: true);
  }

  // ── Helper ───────────────────────────────────────
  void _setStatus(HallOfFameStatus status) {
    _status = status;
    notifyListeners();
  }
}