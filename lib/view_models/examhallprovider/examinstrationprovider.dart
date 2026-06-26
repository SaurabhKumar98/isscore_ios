import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/repo/examhall/examinstraction_repo.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

import 'package:firstedu/data/models/api_models/examhall/examinstractionmodel.dart';

class Examinstrationprovider with ChangeNotifier {
  bool _isloading = false;
  bool get isloading => _isloading;

  set isloading(bool value) {
    _isloading = value;
    notifyListeners();
  }

  ExaminstractionRepo _examinstractionRepo = ExaminstractionRepo();

  Data? _data;

  Data? get data => _data;

  Future<void> examinstractionview(String testid, BuildContext context) async {
    try {
      isloading = true;
      final response = await _examinstractionRepo.examintractionrepo(testid);
      if (response.success == true) {
        _data = response.data;
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("${response.message}")));
      }
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(context, title: "Failed to Load", message: e.message);
      }
    } finally {
      isloading = false;
    }
  }
}
