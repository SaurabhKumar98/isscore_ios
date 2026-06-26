// ─────────────────────────────────────────────────────────────────────────────
// EXAM HALL MODELS
// ─────────────────────────────────────────────────────────────────────────────

class ExamHallModels {
  final bool? success;
  final String? message;
  final List<ExamHallItem>? data;
  final Pagination? pagination;

  ExamHallModels({
    this.success,
    this.message,
    this.data,
    this.pagination,
  });

  factory ExamHallModels.fromJson(Map<String, dynamic>? json) {
    return ExamHallModels(
      success: json?['success'],
      message: json?['message'],
      data: (json?['data'] as List<dynamic>?)
          ?.map((e) => ExamHallItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json?['pagination'] != null
          ? Pagination.fromJson(json!['pagination'])
          : null,
    );
  }
}

class Pagination {
  final int total;
  final int pages;
  final int page;
  final int limit;

  Pagination({
    required this.total,
    required this.pages,
    required this.page,
    required this.limit,
  });

  factory Pagination.fromJson(Map<String, dynamic>? json) {
    return Pagination(
      total: json?['total'] ?? 0,
      pages: json?['pages'] ?? 1,
      page: json?['page'] ?? 1,
      limit: json?['limit'] ?? 10,
    );
  }
}

// ─── ExamHallItem ─────────────────────────────────────────────────────────────
class ExamHallItem {
  final String id;
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final String type; // 'test' | 'testBundle'

  // For type == 'test'
  final TestDetail? test;
  final String? testId;

  // For type == 'testBundle'
  final TestBundle? testBundle;
  final String? bundleId;
  final List<Test>? tests; // individual tests inside a bundle purchase

  // ── Status from API ──────────────────────────────────────────────────────
  // API returns testStatus: 'resume' | 'completed' | 'not_started'
  // (NOT 'in_progress' — that's only in session models)
  final String? testStatus;

  // The real exam session ID (populated when testStatus == 'resume' or 'completed')
  final String? examSessionId;

  ExamHallItem({
    required this.id,
    this.purchaseDate,
    this.purchasePrice,
    required this.type,
    this.test,
    this.testId,
    this.testBundle,
    this.bundleId,
    this.tests,
    this.testStatus,
    this.examSessionId,
  });

  // ── Status helpers ────────────────────────────────────────────────────────
  // API returns 'resume' for in-progress sessions
  bool get isInProgress =>
      testStatus == 'resume' || testStatus == 'in_progress';

  bool get isCompleted => testStatus == 'completed';

  bool get isNotStarted =>
      testStatus == null ||
      testStatus == 'not_started' ||
      testStatus == 'not_purchased' ||
      (!isInProgress && !isCompleted);

  factory ExamHallItem.fromJson(Map<String, dynamic>? json) {
    // ── Parse testStatus & examSessionId ──────────────────────────────────
    // testStatus lives at the root level: json['testStatus']
    // examSessionId may come as json['examSessionId'] or json['sessionId']
    final String? testStatus = json?['testStatus']?.toString();

    final String? examSessionId = json?['examSessionId']?.toString() ??
        json?['sessionId']?.toString() ??
        json?['session']?['id']?.toString() ??
        json?['session']?['_id']?.toString();

    return ExamHallItem(
      id: json?['_id']?.toString() ?? '',
      purchaseDate: json?['purchaseDate'] != null
          ? DateTime.tryParse(json!['purchaseDate'].toString())
          : null,
      purchasePrice: (json?['purchasePrice'] as num?)?.toDouble(),
      type: json?['type']?.toString() ?? 'test',
      test: json?['test'] != null
          ? TestDetail.fromJson(json!['test'] as Map<String, dynamic>)
          : null,
      testId: json?['testId']?.toString(),
      testBundle: json?['testBundle'] != null
          ? TestBundle.fromJson(json!['testBundle'] as Map<String, dynamic>)
          : null,
      bundleId: json?['bundleId']?.toString(),
      tests: (json?['tests'] as List<dynamic>?)
          ?.map((e) => Test.fromJson(e as Map<String, dynamic>))
          .toList(),
      testStatus: testStatus,
      examSessionId: examSessionId,
    );
  }
}

// ─── TestDetail (for a single purchased test) ─────────────────────────────────
class TestDetail {
  final String? id;
  final String? title;
  final String? description;
  final int? durationMinutes;
  final double? price;
   final String? categoryPath; 

  TestDetail({
    this.id,
    this.title,
    this.description,
    this.durationMinutes,
    this.price,
        this.categoryPath,
  });

  factory TestDetail.fromJson(Map<String, dynamic>? json) {
    return TestDetail(
      id: json?['_id']?.toString() ?? json?['id']?.toString(),
      title: json?['title']?.toString(),
      description: json?['description']?.toString(),
      durationMinutes: (json?['durationMinutes'] as num?)?.toInt(),
      price: (json?['price'] as num?)?.toDouble(),
       categoryPath: json?['categoryPath']?.toString(),
    );
  }
}

// ─── TestBundle ───────────────────────────────────────────────────────────────
class TestBundle {
  final String? id;
  final String? name;
  final String? description;
  final List<Test>? tests;
  final double? price;

  TestBundle({
    this.id,
    this.name,
    this.description,
    this.tests,
    this.price,
  });

  factory TestBundle.fromJson(Map<String, dynamic>? json) {
    return TestBundle(
      id: json?['_id']?.toString() ?? json?['id']?.toString(),
      name: json?['name']?.toString(),
      description: json?['description']?.toString(),
      tests: (json?['tests'] as List<dynamic>?)
          ?.map((e) => Test.fromJson(e as Map<String, dynamic>))
          .toList(),
      price: (json?['price'] as num?)?.toDouble(),
    );
  }
}

// ─── Test (individual test inside a bundle) ───────────────────────────────────
class Test {
  final String? id;
  final String? title;
  final String? description;
  final int? durationMinutes;

  // Status for this individual test within a bundle purchase
  // API returns: 'resume' | 'completed' | 'not_started'
  final String? testStatus;

  // Real session ID for this test (if in-progress or completed)
  final String? sessionId;

  Test({
    this.id,
    this.title,
    this.description,
    this.durationMinutes,
    this.testStatus,
    this.sessionId,
  });

  // ── Status helpers ────────────────────────────────────────────────────────
  bool get isInProgress =>
      testStatus == 'resume' || testStatus == 'in_progress';

  bool get isCompleted => testStatus == 'completed';

  bool get isNotStarted => !isInProgress && !isCompleted;

  factory Test.fromJson(Map<String, dynamic>? json) {
    final String? testStatus = json?['testStatus']?.toString();
    final String? sessionId = json?['sessionId']?.toString() ??
        json?['examSessionId']?.toString() ??
        json?['session']?['id']?.toString() ??
        json?['session']?['_id']?.toString();

    return Test(
      id: json?['_id']?.toString() ?? json?['id']?.toString(),
      title: json?['title']?.toString(),
      description: json?['description']?.toString(),
      durationMinutes: (json?['durationMinutes'] as num?)?.toInt(),
      testStatus: testStatus,
      sessionId: sessionId,
    );
  }
}