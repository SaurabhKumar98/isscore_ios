// ─────────────────────────────────────────────────────────────────────────────
// competitionsingleidby_models.dart
// GET /user/competitions/single/:competitionId  →  bundle detail + test list
// ─────────────────────────────────────────────────────────────────────────────

class CompetitionSingleIdByModels {
  final bool success;
  final String message;
  final CompetitionDetail data;

  const CompetitionSingleIdByModels({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CompetitionSingleIdByModels.fromJson(Map<String, dynamic> json) =>
      CompetitionSingleIdByModels(
        success: json['success'] as bool? ?? false,
        message: json['message'] as String? ?? '',
        data: CompetitionDetail.fromJson(
            json['data'] as Map<String, dynamic>? ?? {}),
      );
}

class CompetitionDetail {
  final String id;
  final String title;
  final String description;
  final String status;
  final List<Test> tests;

  const CompetitionDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.tests,
  });

  factory CompetitionDetail.fromJson(Map<String, dynamic> json) =>
      CompetitionDetail(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        status: json['status'] as String? ?? '',
        tests: (json['tests'] as List<dynamic>? ?? [])
            .map((e) => Test.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Test {
  final String testId;
  final String title;
  final String description;
  final int durationMinutes;
  final DateTime? createdAt;

  const Test({
    required this.testId,
    required this.title,
    required this.description,
    required this.durationMinutes,
    this.createdAt,
  });

  factory Test.fromJson(Map<String, dynamic> json) => Test(
        testId: json['testId'] as String? ?? json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        durationMinutes: json['durationMinutes'] as int? ?? 0,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );
}