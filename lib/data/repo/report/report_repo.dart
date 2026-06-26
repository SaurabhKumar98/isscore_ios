import 'package:dio/dio.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/report/chatcallreportmodels.dart';
import 'package:firstedu/data/models/api_models/report/chatpaginationmodels.dart';
import 'package:firstedu/data/models/api_models/report/chatteachermodels.dart';

class ReportRepository {
  final ApiClient _apiClient;

  ReportRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  // ── Safe parsing helpers ─────────────────────────────────────────────────

  Map<String, dynamic> _body(Response r) {
    final data = r.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  List<dynamic> _dataList(Map<String, dynamic> body) {
    final raw = body['data'];
    if (raw is List) return raw;
    return [];
  }

  Map<String, dynamic> _asMap(dynamic e) {
    if (e is Map<String, dynamic>) return e;
    if (e is Map) return Map<String, dynamic>.from(e);
    return {};
  }

  // ── Chat Report: teacher list ─────────────────────────────────────────

  Future<({List<ChatConversationModel> items, PaginationMeta meta})>
      fetchChatConversations({
    int page = 1,
    int limit = 20,
    String search = '',
  }) async {
    final res = await _apiClient.get(
      '${ApiEndpoint.appBaseUrl}/teacher-sessions/chat-reports',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search.isNotEmpty) 'search': search,
      },
    );

    final body = _body(res);
    final items = _dataList(body)
        .map((e) => ChatConversationModel.fromJson(_asMap(e)))
        .toList();
    final meta = PaginationMeta.fromJson(_asMap(body['meta']));

    return (items: items, meta: meta);
  }

  // ── Chat Report: message thread ───────────────────────────────────────
  //
  // FIX: The API returns data as a Map {messages:[...], sessions:[...]}
  // NOT a List. Previously _dataList(body) returned [] because body['data']
  // was a Map, causing "No messages found" even when messages existed.

  Future<({List<ChatMessageModel> messages, PaginationMeta meta})>
      fetchChatMessages({
    required String teacherId,
    int page = 1,
    int limit = 200,
  }) async {
    final res = await _apiClient.get(
      '${ApiEndpoint.appBaseUrl}/teacher-sessions/chat-reports/$teacherId/messages',
      queryParameters: {'page': page, 'limit': limit},
    );

    final body = _body(res);

    // data is { messages: [...], sessions: [...] } — extract the inner list
    final dataMap = _asMap(body['data']);
    final rawMessages = dataMap['messages'];
    final messageList = rawMessages is List ? rawMessages : <dynamic>[];

    final messages = messageList
        .map((e) => ChatMessageModel.fromJson(_asMap(e)))
        .toList();

    final meta = PaginationMeta.fromJson(_asMap(body['meta']));

    return (messages: messages, meta: meta);
  }

  // ── Call Report: teacher list ─────────────────────────────────────────

  Future<({List<CallTeacherSummaryModel> items, PaginationMeta meta})>
      fetchCallConversations({
    int page = 1,
    int limit = 20,
    String search = '',
  }) async {
    final res = await _apiClient.get(
      '${ApiEndpoint.appBaseUrl}/teacher-sessions/call-reports',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search.isNotEmpty) 'search': search,
      },
    );

    final body = _body(res);
    final items = _dataList(body)
        .map((e) => CallTeacherSummaryModel.fromJson(_asMap(e)))
        .toList();
    final meta = PaginationMeta.fromJson(_asMap(body['meta']));

    return (items: items, meta: meta);
  }

  // ── Call Report: recordings ───────────────────────────────────────────

  Future<({List<CallRecordingModel> recordings, PaginationMeta meta})>
      fetchCallRecordings({
    required String teacherId,
    int page = 1,
    int limit = 50,
  }) async {
    final res = await _apiClient.get(
      '${ApiEndpoint.appBaseUrl}/teacher-sessions/call-reports/$teacherId/recordings',
      queryParameters: {'page': page, 'limit': limit},
    );

    final body = _body(res);
    final recordings = _dataList(body)
        .map((e) => CallRecordingModel.fromJson(_asMap(e)))
        .toList();
    final meta = PaginationMeta.fromJson(_asMap(body['meta']));

    return (recordings: recordings, meta: meta);
  }

  // ── Download MP3 ──────────────────────────────────────────────────────
  //
  // FIX: Was using raw Dio() — a brand-new instance with NO auth headers/
  // interceptors — so every download returned 401 → DownloadState.error →
  // "Retry" button. Now uses _apiClient.dio so the existing auth interceptor
  // (Bearer token) is included automatically.

 Future<List<int>> downloadRecording({
  required String sessionId,
}) async {
  final res = await _apiClient.get(
    '${ApiEndpoint.appBaseUrl}/teacher-sessions/$sessionId/recording/download',
    options: Options(
      responseType: ResponseType.bytes,
      headers: {'Accept': 'audio/mpeg'},
    ),
  );

  final data = res.data;
  if (data is List<int>) return data;
  if (data is List) return List<int>.from(data);
  return <int>[];
}
}