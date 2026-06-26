
import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/teacherconnect/mentorsmodels.dart';
import 'package:firstedu/data/repo/mentors/mentors_repositories.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

class MentorsProvider extends ChangeNotifier {
  final MentorsRepositories _mentorsRepositories;

  MentorsProvider(this._mentorsRepositories);

  // ─────────────────── ITEMS STATE ─────────────────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPaginationLoading = false;
  bool get isPaginationLoading => _isPaginationLoading;

  List<Mentor> _mentors = [];
  List<Mentor> get mentors => _mentors;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // ─────────────────── SUMMARY STATE ───────────────────

  int _totalMentors = 0;
  int get totalMentors => _totalMentors;

  int _totalOnline = 0;
  int get totalOnline => _totalOnline;

  // ─────────────────── FILTER STATE ────────────────────

  /// 'all' | 'online'
  String _selectedFilter = 'all';
  String get selectedFilter => _selectedFilter;

  /// 0 = All, 1 = Online  (for UI chip index)
  int _selectedFilterIndex = 0;
  int get selectedFilterIndex => _selectedFilterIndex;

  String _search = '';
  String get search => _search;

  // ─────────────────── PAGINATION STATE ────────────────

  int _currentPage = 1;
  int get currentPage => _currentPage;

  int _totalPages = 1;
  int get totalPages => _totalPages;

  int _totalItems = 0;
  int get totalItems => _totalItems;

  bool get hasMore => _currentPage < _totalPages;

  // ─────────────────── RATING STATE ────────────────────

  bool _isSubmittingRating = false;
  bool get isSubmittingRating => _isSubmittingRating;

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

  // ─────────────────── FETCH MENTORS ───────────────────

  Future<void> fetchMentors(BuildContext context) async {
  try {
    _setLoading(true);
    clearError();

    _currentPage = 1;
    _mentors = [];

    final model = await _mentorsRepositories.getMentors(
      filter: _selectedFilter,
      page: _currentPage,
      search: _search,
    );

    // ADD THESE
    debugPrint("Mentors count: ${model.data.mentors.length}");
    debugPrint("Total mentors: ${model.data.totalMentors}");
    debugPrint("Total online: ${model.data.totalOnline}");
    debugPrint("Pages: ${model.meta.pages}");
    debugPrint("Total items: ${model.meta.total}");

    _mentors = model.data.mentors;
    _totalMentors = model.data.totalMentors;
    _totalOnline = model.data.totalOnline;
    _totalPages = model.meta.pages;
    _totalItems = model.meta.total;
  } catch (e, stack) {
    debugPrint("❌ ERROR: $e");
    debugPrintStack(stackTrace: stack);

    const msg = "Something went wrong.";
    _setError(msg);
  } finally {
    _setLoading(false);
  }
}
  // ─────────────────── LOAD MORE ───────────────────────

  Future<void> loadMore(BuildContext context) async {
  if (!hasMore || _isPaginationLoading || _isLoading) return;

  final nextPage = _currentPage + 1;

  try {
    _setPaginationLoading(true);

    final model = await _mentorsRepositories.getMentors(
      filter: _selectedFilter,
      page: nextPage,
      search: _search,
    );

    if (model.data.mentors.isEmpty) return; // 🔥 important

    _mentors.addAll(model.data.mentors);
    _currentPage = nextPage;
    _totalPages = model.meta.pages;
    _totalItems = model.meta.total;

  } catch (e) {
    debugPrint("Pagination error: $e");
  } finally {
    _setPaginationLoading(false);
  }
}
  // ─────────────────── FILTER SETTERS ──────────────────

Future<void> setFilter(BuildContext context, int index) async {
  if (_selectedFilterIndex == index) return;

  _selectedFilterIndex = index;

  if (index == 1) {
    _selectedFilter = 'online';
  } else if (index == 2) {
    _selectedFilter = 'offline';
  } else {
    _selectedFilter = 'all';
  }

  notifyListeners();
  await fetchMentors(context);
}
  Future<void> setSearch(BuildContext context, String search) async {
    _search = search;
    await fetchMentors(context);
  }

  void clearSearch(BuildContext context) {
    _search = '';
    notifyListeners();
    fetchMentors(context);
  }

  // ─────────────────── SUBMIT RATING ───────────────────

Future<bool> submitRating(
  BuildContext context, {
  required String teacherId,   // ← Mentor._id from API
  required int rating,         // ← 1–5 integer
}) async {
    try {
      _isSubmittingRating = true;
      notifyListeners();

      final ok = await _mentorsRepositories.submitRating(
        teacherId: teacherId,
        
        rating: rating,
      );

      if (ok && context.mounted) {
        AppToast.success(
          context,
          title: "Thank you!",
          message: "Your rating has been submitted.",
        );
        fetchMentors(context); // refresh to show updated rating
      }

      return ok;
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(context, title: "Rating Failed", message: e.message);
      }
      return false;
    } catch (e, stack) {
      debugPrint("❌ RATING SUBMIT ERROR: $e\n$stack");
      if (context.mounted) {
        AppToast.error(
          context,
          title: "Error",
          message: "Something went wrong. Please try again.",
        );
      }
      return false;
    } finally {
      _isSubmittingRating = false;
      notifyListeners();
    }
  }

  // ─────────────────── RESET ───────────────────────────

  void reset() {
    _isLoading = false;
    _isPaginationLoading = false;
    _isSubmittingRating = false;
    _mentors = [];
    _selectedFilter = 'all';
    _selectedFilterIndex = 0;
    _search = '';
    _currentPage = 1;
    _totalPages = 1;
    _totalItems = 0;
    _totalMentors = 0;
    _totalOnline = 0;
    _errorMessage = '';
    notifyListeners();
  }
}