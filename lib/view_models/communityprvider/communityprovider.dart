import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/community_models/communitypostmodels.dart';
import 'package:firstedu/data/repo/communityr/communityrepositories.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

class CommunityProvider extends ChangeNotifier {
  final CommunityRepository _repository;

  CommunityProvider(this._repository);

  // ───────── STATE ─────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPaginationLoading = false;
  bool get isPaginationLoading => _isPaginationLoading;

  List<CommunityPost> _posts = [];
  List<CommunityPost> get posts => _posts;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // ───────── FILTER ─────────

  String? _selectedTopic;
  String? get selectedTopic => _selectedTopic;

  // ───────── PAGINATION ─────────

  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  // ───────── HELPERS ─────────

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

  // ───────── FETCH POSTS ─────────

  Future<void> fetchPosts(BuildContext context) async {
    try {
      _setLoading(true);
      clearError();

      _currentPage = 1;
      _posts = [];

      final model = await _repository.getCommunityPosts(
        page: _currentPage,
        topic: _selectedTopic,
      );

      _posts = model.data;
      _totalPages = model.meta?.pages ?? 1;
    } on AppException catch (e) {
      _setError(e.message);
      if (context.mounted) {
        AppToast.error(
          context,
          title: "Failed to Load",
          message: e.message,
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  // ───────── LOAD MORE ─────────

  Future<void> loadMore(BuildContext context) async {
    if (!hasMore || _isPaginationLoading) return;

    try {
      _setPaginationLoading(true);

      final nextPage = _currentPage + 1;

      final model = await _repository.getCommunityPosts(
        page: nextPage,
        topic: _selectedTopic,
      );

      _posts.addAll(model.data);
      _currentPage = nextPage;
      _totalPages = model.meta?.pages ?? _totalPages;
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(
          context,
          title: "Failed to Load More",
          message: e.message,
        );
      }
    } finally {
      _setPaginationLoading(false);
    }
  }

  // ───────── FILTER ─────────

  Future<void> setTopic(BuildContext context, String? topic) async {
    if (_selectedTopic == topic) return;
    _selectedTopic = topic;
    await fetchPosts(context);
  }

  // ───────── RESET ─────────

  void reset() {
    _isLoading = false;
    _isPaginationLoading = false;
    _posts = [];
    _selectedTopic = null;
    _currentPage = 1;
    _totalPages = 1;
    _errorMessage = '';
    notifyListeners();
  }
}