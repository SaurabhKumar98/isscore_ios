import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/certificatedownload/certificatedownload_models.dart';
import 'package:firstedu/data/repo/cetficatedownload/certificatedownload_repo.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

class CertificateDownloadProvider extends ChangeNotifier {
  final CertificatedownloadRepo _repo;

  CertificateDownloadProvider(this._repo);

  // ── STATE ─────────────────────────────────────────

  List<Certificate> _certificates = [];
  List<Certificate> get certificates => _certificates;

  Meta? _meta;
  Meta? get meta => _meta;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPaginationLoading = false;
  bool get isPaginationLoading => _isPaginationLoading;

  int _page = 1;
  int _totalPages = 1;
  int _totalCertificates = 0;
int get totalCertificates => _totalCertificates;

  bool get hasMore => _page < _totalPages;

  // ── FETCH CERTIFICATES ────────────────────────────

  Future<void> fetchCertificates(BuildContext context) async {
    try {
      _isLoading = true;
      _page = 1;
      _certificates = [];
      notifyListeners();

      final res = await _repo.getCertificate(page: _page);

      _certificates = res.data ?? [];
      _meta = res.meta;

      _totalPages = res.meta?.pages ?? 1;
      _totalCertificates = res.meta?.total ?? 0;
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.error(
          context,
          title: "Error",
          message: e.message,
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── LOAD MORE (PAGINATION) ───────────────────────

  Future<void> loadMore(BuildContext context) async {
    if (!hasMore || _isPaginationLoading) return;

    try {
      _isPaginationLoading = true;
      notifyListeners();

      final nextPage = _page + 1;

      final res = await _repo.getCertificate(page: nextPage);

      final newData = res.data ?? [];

      _certificates.addAll(newData);
      _page = nextPage;
      _totalPages = res.meta?.pages ?? _totalPages;
    } catch (_) {
      // silent fail
    } finally {
      _isPaginationLoading = false;
      notifyListeners();
    }
  }

  // ── RESET ───────────────────────────────────────

  void reset() {
    _certificates = [];
    _meta = null;
    _isLoading = false;
    _isPaginationLoading = false;
    _page = 1;
    _totalPages = 1;
    notifyListeners();
  }
}