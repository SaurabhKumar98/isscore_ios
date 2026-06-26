
import 'dart:async';
import 'dart:io';
import 'package:firstedu/data/models/api_models/report/chatcallreportmodels.dart';
import 'package:firstedu/data/models/api_models/report/chatpaginationmodels.dart';
import 'package:firstedu/data/repo/report/report_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

enum ReportStatus { idle, loading, loadingMore, success, error }

enum DownloadState { idle, loading, done, error }

class CallReportProvider extends ChangeNotifier {
  final ReportRepository _repo;

  CallReportProvider({required ReportRepository repo}) : _repo = repo;

  // ── Teacher list state ───────────────────────────────────────────────────

  ReportStatus listStatus = ReportStatus.idle;
  List<CallTeacherSummaryModel> teachers = [];
  PaginationMeta? listMeta;
  String listError = '';
  String searchQuery = '';

  Timer? _debounce;

  void onSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery = q;
      fetchTeachers(refresh: true);
    });
  }

  Future<void> fetchTeachers({bool refresh = false}) async {
    if (refresh) {
      teachers.clear();
      listMeta = null;
    }

    // FIX 1: search always passes refresh:true — never block it.
    // Only guard a second pagination call firing while one is already in flight.
    if (!refresh && listStatus == ReportStatus.loadingMore) return;

    final nextPage = refresh ? 1 : (listMeta?.page ?? 0) + 1;

    // FIX 2: full-screen spinner when list is empty (first load or after search
    // clears it). loadingMore on an empty list causes the UI to immediately
    // render "No recordings yet" while the API call is still in flight.
    listStatus = (teachers.isEmpty || refresh)
        ? ReportStatus.loading
        : ReportStatus.loadingMore;

    listError = '';
    notifyListeners();

    try {
      final result = await _repo.fetchCallConversations(
        page: nextPage,
        search: searchQuery,
      );
      teachers.addAll(result.items);
      listMeta = result.meta;
      listStatus = ReportStatus.success;
    } catch (e) {
      listStatus = ReportStatus.error;
      listError = e.toString();
    }

    notifyListeners();
  }

  // ── Recording detail state ───────────────────────────────────────────────

  ReportStatus recStatus = ReportStatus.idle;
  List<CallRecordingModel> recordings = [];
  PaginationMeta? recMeta;
  String recError = '';
  String? activeTeacherId;

  Future<void> fetchRecordings({
    required String teacherId,
    bool refresh = false,
  }) async {
    if (activeTeacherId != teacherId || refresh) {
      recordings.clear();
      recMeta = null;
      activeTeacherId = teacherId;
    }

    // FIX 1: same guard — only block concurrent pagination, not a refresh.
    if (!refresh && recStatus == ReportStatus.loadingMore) return;

    final nextPage = refresh ? 1 : (recMeta?.page ?? 0) + 1;

    // FIX 2: show full-screen spinner on first open (recordings is empty).
    // Without this the detail screen shows "No recordings found" for the
    // entire duration of the API call.
    recStatus = (recordings.isEmpty || refresh)
        ? ReportStatus.loading
        : ReportStatus.loadingMore;

    recError = '';
    notifyListeners();

    try {
      final result = await _repo.fetchCallRecordings(
        teacherId: teacherId,
        page: nextPage,
      );
      recordings.addAll(result.recordings);
      recMeta = result.meta;
      recStatus = ReportStatus.success;
    } catch (e) {
      recStatus = ReportStatus.error;
      recError = e.toString();
    }

    notifyListeners();
  }

  void clearRecordings() {
    recordings.clear();
    recMeta = null;
    activeTeacherId = null;
    recStatus = ReportStatus.idle;
    notifyListeners();
  }

  // ── Download MP3 ─────────────────────────────────────────────────────────

  final Map<String, DownloadState> _downloadStates = {};

  DownloadState downloadStateFor(String sessionId) =>
      _downloadStates[sessionId] ?? DownloadState.idle;

  String? downloadedPathFor(String sessionId) => _downloadPaths[sessionId];

  final Map<String, String> _downloadPaths = {};

  Future<void> downloadRecording({
    required String sessionId,
    required String teacherName,
    required String callEndTime,
  }) async {
    if (_downloadStates[sessionId] == DownloadState.loading) return;

    _downloadStates[sessionId] = DownloadState.loading;
    notifyListeners();

    try {
      final bytes = await _repo.downloadRecording(sessionId: sessionId);

      final dir = await getApplicationDocumentsDirectory();
      final date =
          callEndTime.length >= 10 ? callEndTime.substring(0, 10) : 'unknown';
      final safeName = teacherName.replaceAll(' ', '_');
      final file = File('${dir.path}/call_${safeName}_$date.mp3');
      await file.writeAsBytes(bytes);

      _downloadPaths[sessionId] = file.path;
      _downloadStates[sessionId] = DownloadState.done;
    } catch (e) {
      _downloadStates[sessionId] = DownloadState.error;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}