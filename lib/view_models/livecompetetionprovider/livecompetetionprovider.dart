import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/livecompetetion/livecompetetion_models.dart';
import 'package:firstedu/data/repo/livecompetetion/livecompetetion_repo.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

class LiveCompetitionDrawerProvider extends ChangeNotifier {
  final LiveCompetitionDrawerRepository _repo;

  LiveCompetitionDrawerProvider(this._repo);

  List<LiveCompetitionDrawer> _liveList = [];
  List<LiveCompetitionDrawer> get liveList => _liveList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchLiveCompetitions(BuildContext context) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final res = await _repo.getAllLiveCompetitions();

      _liveList = res.data
              ?.where((e) => e.isActive == true)
              .toList() ??
          [];
    } on AppException catch (e) {
      _error = e.message;
      if (context.mounted) {
        AppToast.error(context, title: "Error", message: e.message);
      }
    } catch (_) {
      _error = "Something went wrong";
      if (context.mounted) {
        AppToast.error(context, title: "Error", message: _error!);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _liveList = [];
    _isLoading = false;
    _error = null;
  }
}