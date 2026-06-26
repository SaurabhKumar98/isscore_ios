import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/coursedownload/purchasecourse.dart';
import 'package:firstedu/data/repo/coursedownload/downloadcourse.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

class DownloadCourseProvider extends ChangeNotifier {
  final DownloadCourseRepositories _repo;
  DownloadCourseProvider(this._repo);

  // ── General Courses ───────────────────────────────────────────────────────
  bool _isGeneralLoading = false;
  bool get isGeneralLoading => _isGeneralLoading;
  List<PurchasedCourse> _generalCourses = [];
  List<PurchasedCourse> get generalCourses => _generalCourses;

  // ── Certification Courses ─────────────────────────────────────────────────
  bool _isCertificationLoading = false;
  bool get isCertificationLoading => _isCertificationLoading;
  List<PurchasedCourse> _certificationCourses = [];
  List<PurchasedCourse> get certificationCourses => _certificationCourses;

  // ── Free Materials ────────────────────────────────────────────────────────
  bool _isFreeMaterialsLoading = false;
  bool get isFreeMaterialsLoading => _isFreeMaterialsLoading;
  List<PurchasedCourse> _freeMaterials = [];
  List<PurchasedCourse> get freeMaterials => _freeMaterials;

  // ── Legacy (kept for compatibility) ──────────────────────────────────────
  bool get isLoading => _isGeneralLoading;
  List<PurchasedCourse> get courses => _generalCourses;

  String? _selectedType;
  String get selectedAccess => 'both';

  // ── FETCH GENERAL COURSES ─────────────────────────────────────────────────
  Future<void> fetchGeneralCourses(BuildContext context) async {
    if (_isGeneralLoading) return;
    try {
      _isGeneralLoading = true;
      notifyListeners();

      final response = await _repo.getCourseDownloads(
        isCertification: false,
        type: _selectedType,
        page: 1,
      );
      _generalCourses = response.data ?? [];
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(context, title: 'Error', message: e.message);
      }
    } catch (e) {
      debugPrint('General courses fetch error: $e');
    } finally {
      _isGeneralLoading = false;
      notifyListeners();
    }
  }

  // ── FETCH CERTIFICATION COURSES ───────────────────────────────────────────
  Future<void> fetchCertificationCourses(BuildContext context) async {
    if (_isCertificationLoading) return;
    try {
      _isCertificationLoading = true;
      notifyListeners();

      final response = await _repo.getCourseDownloads(
        isCertification: true,
        type: _selectedType,
        page: 1,
      );
      _certificationCourses = response.data ?? [];
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(context, title: 'Error', message: e.message);
      }
    } catch (e) {
      debugPrint('Certification courses fetch error: $e');
    } finally {
      _isCertificationLoading = false;
      notifyListeners();
    }
  }

  // ── FETCH FREE MATERIALS ──────────────────────────────────────────────────
  Future<void> fetchFreeMaterials(
    BuildContext context, {
    String? pillarName,
  }) async {
    if (_isFreeMaterialsLoading) return;
    try {
      _isFreeMaterialsLoading = true;
      notifyListeners();

      final response = await _repo.getFreeMaterials(
        pillarName: pillarName,
      );
      _freeMaterials = response.data ?? [];
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(context, title: 'Error', message: e.message);
      }
    } catch (e) {
      debugPrint('Free materials fetch error: $e');
    } finally {
      _isFreeMaterialsLoading = false;
      notifyListeners();
    }
  }

  // ── Legacy fetchDownloads (kept for compatibility) ────────────────────────
  Future<void> fetchDownloads(BuildContext context) async {
    await fetchGeneralCourses(context);
  }

  // ── FILTER: type ──────────────────────────────────────────────────────────
  Future<void> setType(BuildContext context, String? type) async {
    if (_selectedType == type) return;
    _selectedType = type;
    // Re-fetch whichever tabs already have data
    if (_generalCourses.isNotEmpty || _isGeneralLoading) {
      await fetchGeneralCourses(context);
    }
    if (_certificationCourses.isNotEmpty || _isCertificationLoading) {
      await fetchCertificationCourses(context);
    }
  }

  // ── RESET ─────────────────────────────────────────────────────────────────
  void reset() {
    _generalCourses = [];
    _certificationCourses = [];
    _freeMaterials = [];
    _isGeneralLoading = false;
    _isCertificationLoading = false;
    _isFreeMaterialsLoading = false;
    _selectedType = null;
    notifyListeners();
  }
}