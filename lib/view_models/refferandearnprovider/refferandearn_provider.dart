import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/refferandearnmodel/refferandearnmodel.dart' show ReferralData;
import 'package:firstedu/data/repo/refferandearn/refferandearn_repo.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

class ReferAndEarnProvider extends ChangeNotifier {
  final ReferAndEarnRepo _repo;

  ReferAndEarnProvider(this._repo);

  // ── STATE ─────────────────────────────

  ReferralData? _data;
  ReferralData? get data => _data;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ── FETCH ─────────────────────────────

  Future<void> fetchReferData(BuildContext context) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final res = await _repo.getReferAndEarnData();

      if (res.success == true) {
        _data = res.data;
      } else {
        _error = res.message ?? "Failed to load data";
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

  // ── RESET ─────────────────────────────

  void reset() {
    _data = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}