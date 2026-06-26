// lib/data/models/api_models/leaderboard/leaderboard_models.dart

// ── Leaderboard List Response (multiple events) ───────────────────────────

class LeaderboardListResponse {
  final bool success;
  final String? message;
  final LeaderboardListData? data;

  LeaderboardListResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory LeaderboardListResponse.fromJson(Map<String, dynamic> json) =>
      LeaderboardListResponse(
        success: json['success'] ?? false,
        message: json['message'],
        data: json['data'] != null
            ? LeaderboardListData.fromJson(json['data'] as Map<String, dynamic>)
            : null,
      );
}

class LeaderboardListData {
  final List<LeaderboardEvent> items;
  final LeaderboardPagination? pagination;

  LeaderboardListData({required this.items, this.pagination});

  factory LeaderboardListData.fromJson(Map<String, dynamic> json) =>
      LeaderboardListData(
        items: (json['items'] as List? ?? [])
            .map((e) => LeaderboardEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
        pagination: json['pagination'] != null
            ? LeaderboardPagination.fromJson(
                json['pagination'] as Map<String, dynamic>)
            : null,
      );
}

// ── Single Event in the list ──────────────────────────────────────────────

class LeaderboardEvent {
  final String? type; // "olympiad" | "tournament"
  final String? eventId;
  final String? title;
  final String? stage; // tournament only
  final String? status;
  final List<LeaderboardEntry> leaderboard;
  final int? totalParticipants;

  LeaderboardEvent({
    this.type,
    this.eventId,
    this.title,
    this.stage,
    this.status,
    required this.leaderboard,
    this.totalParticipants,
  });

  factory LeaderboardEvent.fromJson(Map<String, dynamic> json) =>
      LeaderboardEvent(
        type: json['type'],
        eventId: json['eventId'],
        title: json['title'],
        stage: json['stage'],
        status: json['status'],
        leaderboard: (json['leaderboard'] as List? ?? [])
            .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalParticipants: json['totalParticipants'],
      );
}

// ── Single Leaderboard Response (one event by eventId) ───────────────────

class SingleLeaderboardResponse {
  final bool success;
  final String? message;
  final SingleLeaderboardData? data;

  SingleLeaderboardResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory SingleLeaderboardResponse.fromJson(Map<String, dynamic> json) =>
      SingleLeaderboardResponse(
        success: json['success'] ?? false,
        message: json['message'],
        data: json['data'] != null
            ? SingleLeaderboardData.fromJson(
                json['data'] as Map<String, dynamic>)
            : null,
      );
}

class SingleLeaderboardData {
  final String? type;
  final String? eventId;
  final String? title;
  final String? stage;
  final List<LeaderboardEntry> leaderboard;

  SingleLeaderboardData({
    this.type,
    this.eventId,
    this.title,
    this.stage,
    required this.leaderboard,
  });

  factory SingleLeaderboardData.fromJson(Map<String, dynamic> json) =>
      SingleLeaderboardData(
        type: json['type'],
        eventId: json['eventId'],
        title: json['title'],
        stage: json['stage'],
        leaderboard: (json['leaderboard'] as List? ?? [])
            .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ── Leaderboard Entry (a ranked student) ─────────────────────────────────

class LeaderboardEntry {
  final int? rank;
  final String? studentId;
  final String? name;
  final String? email;
final double? score;
final double? maxScore;
  final DateTime? completedAt;

  LeaderboardEntry({
    this.rank,
    this.studentId,
    this.name,
    this.email,
    this.score,
    this.maxScore,
    this.completedAt,
  });

  double get scorePercent =>
      (maxScore != null && maxScore! > 0) ? (score ?? 0) / maxScore! * 100 : 0;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        rank: json['rank'],
        studentId: json['student'],
        name: json['name'],
        email: json['email'],
        score: (json['score'] as num?)?.toDouble(),
maxScore: (json['maxScore'] as num?)?.toDouble(),
        completedAt: json['completedAt'] != null
            ? DateTime.tryParse(json['completedAt'])
            : null,
      );
}

// ── Pagination ────────────────────────────────────────────────────────────

class LeaderboardPagination {
  final int? page;
  final int? limit;
  final int? total;
  final int? pages;

  LeaderboardPagination({this.page, this.limit, this.total, this.pages});

  factory LeaderboardPagination.fromJson(Map<String, dynamic> json) =>
      LeaderboardPagination(
        page: json['page'],
        limit: json['limit'],
        total: json['total'],
        pages: json['pages'],
      );
}
// ── Category Node (for leaderboard category filter) ──────────────────────

class CategoryNode {
  final String? id;
  final String? name;
  final List<CategoryNode> children;

  CategoryNode({
    this.id,
    this.name,
    this.children = const [],
  });

  /// Returns this node's id + all descendant ids (for API filtering)
  List<String> get allIds {
    final ids = <String>[];
    if (id != null) ids.add(id!);
    for (final child in children) {
      ids.addAll(child.allIds);
    }
    return ids;
  }

  factory CategoryNode.fromJson(Map<String, dynamic> json) => CategoryNode(
        id: json['_id'] as String?,
        name: json['name'] as String?,
        children: (json['children'] as List? ?? [])
            .map((e) => CategoryNode.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ── Categories API Response ───────────────────────────────────────────────

class CategoriesResponse {
  final bool success;
  final String? message;
  final List<CategoryNode> data;

  CategoriesResponse({
    required this.success,
    this.message,
    this.data = const [],
  });

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    // Backend might return a List directly or a Map with nested list
    List<dynamic> list = [];
    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map && rawData['items'] is List) {
      list = rawData['items'] as List;
    }

    return CategoriesResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: list
          .map((e) => CategoryNode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}