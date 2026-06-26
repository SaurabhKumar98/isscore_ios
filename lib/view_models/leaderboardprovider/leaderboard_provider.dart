// lib/view_models/leaderboardprovider/leaderboard_provider.dart

import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/leaderboard/leaderboard_models.dart';
import 'package:firstedu/data/repo/leaderboard/laderboard_repo.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

class LeaderboardProvider extends ChangeNotifier {
  final LeaderboardRepository _repo;

  LeaderboardProvider(this._repo);

  // ── State ──────────────────────────────────────────────────────────

  bool _isListLoading = false;
  bool get isListLoading => _isListLoading;

  bool _isDetailLoading = false;
  bool get isDetailLoading => _isDetailLoading;

  String _selectedType = 'olympiad';
  String get selectedType => _selectedType;

  List<LeaderboardEvent> _events = [];
  List<LeaderboardEvent> get events => _events;

  LeaderboardEvent? _selectedEvent;
  LeaderboardEvent? get selectedEvent => _selectedEvent;

  List<LeaderboardEntry> _entries = [];
  List<LeaderboardEntry> get entries => _entries;

  List<CategoryNode> _categories = [];
  List<CategoryNode> get categories => _categories;

  CategoryNode? _selectedCategory;
  CategoryNode? get selectedCategory => _selectedCategory;

  bool _isCategoryLoading = false;
  bool get isCategoryLoading => _isCategoryLoading;

  int _page = 1;
  int _totalPages = 1;
  bool get hasMore => _page < _totalPages;

  // ── FETCH CATEGORIES ───────────────────────────────────────────────

  Future<void> fetchCategories(BuildContext context) async {
    try {
      _isCategoryLoading = true;
      notifyListeners();

      final res = await _repo.getCategories();
      if (res.success) {
        _categories = res.data;
      }
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(context, title: "Error", message: e.message);
      }
    } finally {
      _isCategoryLoading = false;
      notifyListeners();
    }
  }

  // ── FETCH EVENT LIST ───────────────────────────────────────────────

  Future<void> fetchEvents(BuildContext context, {bool reset = true}) async {
    try {
      if (reset) {
        _page = 1;
        _events = [];
        // Reset selected event/entries when filter changes
        _selectedEvent = null;
        _entries = [];
      }

      _isListLoading = true;
      notifyListeners();

      final res = await _repo.getLeaderboardList(
        type: _selectedType,
        page: _page,
        categoryId: _selectedCategory?.id, // ← single ID, correct param name
      );

      final items = res.data?.items ?? [];
      _events.addAll(items);
      _totalPages = res.data?.pagination?.pages ?? 1;

      // Auto-select first event if none selected
      if (_events.isNotEmpty && _selectedEvent == null) {
        _selectedEvent = _events.first;
        _entries = _selectedEvent!.leaderboard;
      }
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(context, title: "Error", message: e.message);
      }
    } finally {
      _isListLoading = false;
      notifyListeners();
    }
  }

  // ── CATEGORY FILTER ────────────────────────────────────────────────

  void selectCategory(BuildContext context, CategoryNode? node) {
    _selectedCategory = node;
    _selectedEvent = null;
    _entries = [];
    notifyListeners();
    fetchEvents(context);
  }

  void clearCategoryFilter(BuildContext context) {
    _selectedCategory = null;
    _selectedEvent = null;
    _entries = [];
    notifyListeners();
    fetchEvents(context);
  }

  // ── SWITCH TAB ─────────────────────────────────────────────────────

  Future<void> setType(BuildContext context, String type) async {
    if (_selectedType == type) return;
    _selectedType = type;
    _selectedEvent = null;
    _selectedCategory = null;
    _entries = [];
    await fetchEvents(context);
  }

  // ── SELECT EVENT FROM BOTTOM SHEET ────────────────────────────────

  Future<void> selectEvent(BuildContext context, LeaderboardEvent event) async {
    _selectedEvent = event;
    _entries = event.leaderboard;
    notifyListeners();
  }

  // ── LOAD MORE (pagination) ─────────────────────────────────────────

  Future<void> loadMore(BuildContext context) async {
    if (!hasMore || _isListLoading) return;
    _page++;
    await fetchEvents(context, reset: false);
  }

  // ── RESET ──────────────────────────────────────────────────────────

  void reset() {
    _isListLoading = false;
    _isDetailLoading = false;
    _isCategoryLoading = false;
    _selectedType = 'olympiad';
    _events = [];
    _selectedEvent = null;
    _entries = [];
    _categories = [];
    _selectedCategory = null;
    _page = 1;
    _totalPages = 1;
    notifyListeners();
  }
}