
import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/everydaychallenge/everydaychallenge_models.dart';
import 'package:firstedu/data/repo/everydaychallenge/everydaychallenge_repo.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

class Everydaychallengeprovider extends ChangeNotifier {
  final EverydaychallengeRepo _repo;

  Everydaychallengeprovider(this._repo);

  Challenge? _challenge;
  Challenge? get challenge => _challenge;

  int _streakDays = 0;
  int get streakDays => _streakDays;

  bool _completedToday = false;
  bool get completedToday => _completedToday;

  int _nextPoints = 0;        // ✅ added
  int get nextPoints => _nextPoints;

  int _nextStreakDay = 0;     // ✅ added
  int get nextStreakDay => _nextStreakDay;

  List<StreakCycle> _streakCycle = [];
  List<StreakCycle> get streakCycle => _streakCycle;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPaginationLoading = false;
  bool get isPaginationLoading => _isPaginationLoading;
int _totalStreak = 0;
int get totalStreak => _totalStreak;
  int _page = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  Future<void> fetchEverydayChallenge(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      final res = await _repo.getEveryDayChallenge(page: 1);
      final data = res.data;
      _totalStreak = res.meta?.total ?? 0;

      if (data != null) {
        _challenge = data.challenge;
        _streakDays = data.streakDays ?? 0;
        _completedToday = data.completedToday ?? false;
        _nextPoints = data.nextPoints ?? 0;       // ✅
        _nextStreakDay = data.nextStreakDay ?? 0;  // ✅
        _streakCycle = data.streakCycle ?? [];
        _totalStreak = res.meta?.total ?? 0;
      }
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(context, title: "Error", message: e.message);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore(BuildContext context) async {
    if (!_hasMore || _isPaginationLoading) return;
    try {
      _isPaginationLoading = true;
      notifyListeners();
      final nextPage = _page + 1;
      final res = await _repo.getEveryDayChallenge(page: nextPage);
      final data = res.data;
      if (data != null) {
        _streakCycle.addAll(data.streakCycle ?? []);
        _page = nextPage;
        if ((data.streakCycle ?? []).isEmpty) _hasMore = false;
      }
    } catch (_) {
    } finally {
      _isPaginationLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _challenge = null;
    _streakDays = 0;
    _completedToday = false;
    _nextPoints = 0;
    _nextStreakDay = 0;
    _streakCycle = [];
    _isLoading = false;
    _isPaginationLoading = false;
    _page = 1;
    _hasMore = true;
    notifyListeners();
  }
}