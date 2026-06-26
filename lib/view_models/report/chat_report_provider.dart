// ─── lib/view_models/report/chat_report_provider.dart ──────────────────────

import 'dart:async';

import 'package:firstedu/data/models/api_models/report/chatteachermodels.dart';
import 'package:firstedu/data/repo/report/report_repo.dart';
import 'package:flutter/material.dart';

import '../../data/models/api_models/report/chatpaginationmodels.dart';


enum ReportStatus { idle, loading, loadingMore, success, error }
 
class ChatReportProvider extends ChangeNotifier {
  final ReportRepository _repo;
 
  ChatReportProvider({required ReportRepository repo}) : _repo = repo;
 
  // ── Conversation list state ──────────────────────────────────────────────
 
  ReportStatus listStatus = ReportStatus.idle;
  List<ChatConversationModel> conversations = [];
  PaginationMeta? listMeta;
  String listError = '';
  String searchQuery = '';
 
  Timer? _debounce;
 
  void onSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery = q;
      fetchConversations(refresh: true);
    });
  }
 
  Future<void> fetchConversations({bool refresh = false}) async {
    if (refresh) {
      conversations.clear();
      listMeta = null;
    }
 
    // FIX 1: search always passes refresh:true — never block it.
    // Only guard a second pagination call firing while one is already in flight.
    if (!refresh && listStatus == ReportStatus.loadingMore) return;
 
    final nextPage = refresh ? 1 : (listMeta?.page ?? 0) + 1;
 
    // FIX 2: full-screen spinner when list is empty (first load or after search
    // clears it). loadingMore on an empty list causes the UI to immediately
    // show "No chat history yet" while the API call is still in flight.
    listStatus = (conversations.isEmpty || refresh)
        ? ReportStatus.loading
        : ReportStatus.loadingMore;
 
    listError = '';
    notifyListeners();
 
    try {
      final result = await _repo.fetchChatConversations(
        page: nextPage,
        search: searchQuery,
      );
      conversations.addAll(result.items);
      listMeta = result.meta;
      listStatus = ReportStatus.success;
    } catch (e) {
      listStatus = ReportStatus.error;
      listError = e.toString();
    }
 
    notifyListeners();
  }
 
  // ── Message detail state ─────────────────────────────────────────────────
 
  ReportStatus msgStatus = ReportStatus.idle;
  List<ChatMessageModel> messages = [];
  PaginationMeta? msgMeta;
  String msgError = '';
  String? activeTeacherId;
 
  Future<void> fetchMessages({
    required String teacherId,
    bool refresh = false,
  }) async {
    if (activeTeacherId != teacherId || refresh) {
      messages.clear();
      msgMeta = null;
      activeTeacherId = teacherId;
    }
 
    // FIX 1: same guard — only block concurrent pagination, not a refresh.
    if (!refresh && msgStatus == ReportStatus.loadingMore) return;
 
    final nextPage = refresh ? 1 : (msgMeta?.page ?? 0) + 1;
 
    // FIX 2: show full-screen spinner on first open (messages is empty).
    // Without this the detail screen shows "No messages found" for the
    // entire duration of the API call.
    msgStatus = (messages.isEmpty || refresh)
        ? ReportStatus.loading
        : ReportStatus.loadingMore;
 
    msgError = '';
    notifyListeners();
 
    try {
      final result = await _repo.fetchChatMessages(
        teacherId: teacherId,
        page: nextPage,
      );
      // Prepend older messages (scroll-up pagination)
      messages = [...result.messages, ...messages];
      msgMeta = result.meta;
      msgStatus = ReportStatus.success;
    } catch (e) {
      msgStatus = ReportStatus.error;
      msgError = e.toString();
    }
 
    notifyListeners();
  }
 
  bool get canLoadMoreMessages => msgMeta != null && msgMeta!.hasMore;
 
  void clearMessages() {
    messages.clear();
    msgMeta = null;
    activeTeacherId = null;
    msgStatus = ReportStatus.idle;
    notifyListeners();
  }
 
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}