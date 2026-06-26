import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/dashboardmodels/dashboard_models.dart';
import 'package:firstedu/data/repo/dashboard/dashboardboard_repo.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  final DashBoardRepo _repository;

  DashboardProvider(this._repository);

  // ── STATE ─────────────────────────────────────────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  StudentDashboardModel? _dashboard;
  StudentDashboardModel? get dashboard => _dashboard;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── FETCH DASHBOARD ───────────────────────────────────

  Future<void> fetchDashboard(BuildContext context) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final model = await _repository.getDashBoard();

      _dashboard = model;
    } on AppException catch (e) {
      _errorMessage = e.message;

      // ✅ SHOW BACKEND ERROR USING APPTOAST
      if (context.mounted) {
        AppToast.error(
          context,
          title: 'Error',
          message: e.message,
        );
      }
    } catch (e) {
      _errorMessage = 'Something went wrong';

      if (context.mounted) {
        AppToast.error(
          context,
          title: 'Error',
          message: 'Something went wrong',
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── REFRESH ───────────────────────────────────────────

  Future<void> refresh(BuildContext context) async {
    _dashboard = null;
    await fetchDashboard(context);
  }

  // ── RESET ─────────────────────────────────────────────

  void reset() {
    _isLoading = false;
    _dashboard = null;
    _errorMessage = null;
    notifyListeners();
  }
}