import 'dart:convert';

StudentDashboardModel studentDashboardModelFromJson(String str) =>
    StudentDashboardModel.fromJson(json.decode(str));

String studentDashboardModelToJson(StudentDashboardModel data) =>
    json.encode(data.toJson());

class StudentDashboardModel {
  final bool success;
  final String message;
  final DashboardData? data;
  final dynamic meta;

  StudentDashboardModel({
    required this.success,
    required this.message,
    this.data,
    this.meta,
  });

  factory StudentDashboardModel.fromJson(Map<String, dynamic> json) =>
      StudentDashboardModel(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] != null
            ? DashboardData.fromJson(json["data"])
            : null,
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
    "meta": meta,
  };
}

class DashboardData {
  final int totalTestsTaken;
  final double averageScore; // ✅ was int — API returns 46.7 (double)
  final int bestScore;
  final TotalTimeLearning? totalTimeLearning;
  final List<TestResult> recentTestResults;
  final List<TestResult> allTestResults;
  final List<MonthlyScoreTrend> monthlyScoreTrend;
  final List<CategoryPerformance> categoryPerformance;
  final List<TestTypeStat> testTypeStats;
  final List<UpcomingEvent> upcomingEvents;
  final List<FeaturedBundle> featuredBundles;
  final List<WeakCategory> weakCategories;
  final RecentResumeExam? recentResumeExam;
  DashboardData({
    required this.totalTestsTaken,
    required this.averageScore,
    required this.bestScore,
    this.totalTimeLearning,
    required this.recentTestResults,
    required this.allTestResults,
    required this.monthlyScoreTrend,
    required this.categoryPerformance,
    required this.testTypeStats,
    required this.upcomingEvents,
    required this.featuredBundles,
    required this.weakCategories,
    this.recentResumeExam,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
    totalTestsTaken: json["totalTestsTaken"] ?? 0,
    averageScore:
        (json["averageScore"] as num?)?.toDouble() ?? 0.0, // ✅ safe toDouble()
    bestScore: (json["bestScore"] as num?)?.toInt() ?? 0,
    totalTimeLearning: json["totalTimeLearning"] != null
        ? TotalTimeLearning.fromJson(json["totalTimeLearning"])
        : null,
    recentTestResults: (json["recentTestResults"] as List? ?? [])
        .map((x) => TestResult.fromJson(x))
        .toList(),
    allTestResults: (json["allTestResults"] as List? ?? [])
        .map((x) => TestResult.fromJson(x))
        .toList(),
    monthlyScoreTrend: (json["monthlyScoreTrend"] as List? ?? [])
        .map((x) => MonthlyScoreTrend.fromJson(x))
        .toList(),
    categoryPerformance: (json["categoryPerformance"] as List? ?? [])
        .map((x) => CategoryPerformance.fromJson(x))
        .toList(),
    testTypeStats: (json["testTypeStats"] as List? ?? [])
        .map((x) => TestTypeStat.fromJson(x))
        .toList(),
    upcomingEvents: (json["upcomingEvents"] as List? ?? [])
        .map((x) => UpcomingEvent.fromJson(x))
        .toList(),
    featuredBundles: (json["featuredBundles"] as List? ?? [])
        .map((x) => FeaturedBundle.fromJson(x))
        .toList(),
    weakCategories: (json["weakCategories"] as List? ?? [])
        .map((x) => WeakCategory.fromJson(x))
        .toList(),

    recentResumeExam: json["recentResumeExam"] != null
        ? RecentResumeExam.fromJson(json["recentResumeExam"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "totalTestsTaken": totalTestsTaken,
    "averageScore": averageScore,
    "bestScore": bestScore,
    "totalTimeLearning": totalTimeLearning?.toJson(),
    "recentTestResults": recentTestResults.map((x) => x.toJson()).toList(),
    "allTestResults": allTestResults.map((x) => x.toJson()).toList(),
    "monthlyScoreTrend": monthlyScoreTrend.map((x) => x.toJson()).toList(),
    "categoryPerformance": categoryPerformance.map((x) => x.toJson()).toList(),
    "testTypeStats": testTypeStats.map((x) => x.toJson()).toList(),
    "upcomingEvents": upcomingEvents.map((x) => x.toJson()).toList(),
    "featuredBundles": featuredBundles.map((x) => x.toJson()).toList(),
    "weakCategories": weakCategories.map((x) => x.toJson()).toList(),
    "recentResumeExam": recentResumeExam?.toJson(),
  };
}

// ── WEAK CATEGORY ─────────────────────────────────────────────────────────────

class WeakCategory {
  final String categoryId;
  final String categoryName;
  final int percentageScore;

  WeakCategory({
    required this.categoryId,
    required this.categoryName,
    required this.percentageScore,
  });

  factory WeakCategory.fromJson(Map<String, dynamic> json) => WeakCategory(
    categoryId: json["categoryId"] ?? "",
    categoryName: json["categoryName"] ?? "",
    percentageScore: json["percentageScore"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "categoryId": categoryId,
    "categoryName": categoryName,
    "percentageScore": percentageScore,
  };
}

// ── FEATURED BUNDLE ───────────────────────────────────────────────────────────

class FeaturedBundle {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final List<BundleTest> tests;
  final double price;
  final double originalPrice;
  final double discountedPrice;
  final bool isActive;

  FeaturedBundle({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.tests,
    required this.price,
    required this.originalPrice,
    required this.discountedPrice,
    required this.isActive,
  });

  factory FeaturedBundle.fromJson(Map<String, dynamic> json) => FeaturedBundle(
    id: json["_id"] ?? "",
    name: json["name"] ?? "",
    description: json["description"] ?? "",
    imageUrl: json["imageUrl"],
    tests: (json["tests"] as List? ?? [])
        .map((x) => BundleTest.fromJson(x))
        .toList(),
    price: (json["price"] ?? 0).toDouble(),
    originalPrice: (json["originalPrice"] ?? 0).toDouble(),
    discountedPrice: (json["discountedPrice"] ?? 0).toDouble(),
    isActive: json["isActive"] ?? true,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "description": description,
    "imageUrl": imageUrl,
    "tests": tests.map((x) => x.toJson()).toList(),
    "price": price,
    "originalPrice": originalPrice,
    "discountedPrice": discountedPrice,
    "isActive": isActive,
  };

  int? get discountPercent {
    if (originalPrice <= 0 || discountedPrice >= originalPrice) return null;
    return (((originalPrice - discountedPrice) / originalPrice) * 100).round();
  }

  int get totalDurationMinutes =>
      tests.fold(0, (sum, t) => sum + t.durationMinutes);

  String get subjectTag {
    if (tests.isEmpty) return "";
    final cats = tests.first.questionBank?.categories ?? [];
    return cats.isNotEmpty ? cats.first.name : "";
  }
}

class BundleTest {
  final String id;
  final String title;
  final BundleQuestionBank? questionBank;
  final int durationMinutes;

  BundleTest({
    required this.id,
    required this.title,
    this.questionBank,
    required this.durationMinutes,
  });

  factory BundleTest.fromJson(Map<String, dynamic> json) => BundleTest(
    id: json["_id"] ?? "",
    title: json["title"] ?? "",
    questionBank: json["questionBank"] != null
        ? BundleQuestionBank.fromJson(json["questionBank"])
        : null,
    durationMinutes: json["durationMinutes"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "questionBank": questionBank?.toJson(),
    "durationMinutes": durationMinutes,
  };
}

class BundleQuestionBank {
  final String id;
  final String name;
  final List<BundleCategory> categories;

  BundleQuestionBank({
    required this.id,
    required this.name,
    required this.categories,
  });

  factory BundleQuestionBank.fromJson(Map<String, dynamic> json) =>
      BundleQuestionBank(
        id: json["_id"] ?? "",
        name: json["name"] ?? "",
        categories: (json["categories"] as List? ?? [])
            .map((x) => BundleCategory.fromJson(x))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "categories": categories.map((x) => x.toJson()).toList(),
  };
}

class BundleCategory {
  final String id;
  final String name;

  BundleCategory({required this.id, required this.name});

  factory BundleCategory.fromJson(Map<String, dynamic> json) =>
      BundleCategory(id: json["_id"] ?? "", name: json["name"] ?? "");

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

// ── TEST RESULT ───────────────────────────────────────────────────────────────

class TestResult {
  final String name;
  final String category;
  final int score;
  final int maxScore;
  final double percentage;
  final DateTime? date;
  final String sessionId;
  final TestType type;

  TestResult({
    required this.name,
    required this.category,
    required this.score,
    required this.maxScore,
    required this.percentage,
    this.date,
    required this.sessionId,
    required this.type,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) => TestResult(
    name: json["name"] ?? "",
    category: json["category"] ?? "",
    score: (json["score"] as num?)?.toInt() ?? 0, // ✅ FIX
    maxScore: (json["maxScore"] as num?)?.toInt() ?? 0, // ✅ FIX
    percentage: (json["percentage"] as num?)?.toDouble() ?? 0.0,
    date: json["date"] != null ? DateTime.tryParse(json["date"]) : null,
    sessionId: json["sessionId"] ?? "",
    type: typeValues.map[json["type"]] ?? TestType.UNKNOWN,
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "category": category,
    "score": score,
    "maxScore": maxScore,
    "percentage": percentage,
    "date": date?.toIso8601String(),
    "sessionId": sessionId,
    "type": typeValues.reverse[type],
  };
}

enum TestType {
  COMPETITION_SECTOR,
  OLYMPIAD,
  TEST,
  TOURNAMENT,
  CHALLENGE_YOURSELF,
  EVERYDAY_CHALLENGE,
  UNKNOWN,
}

final typeValues = EnumValues({
  "competition_sector": TestType.COMPETITION_SECTOR,
  "olympiad": TestType.OLYMPIAD,
  "test": TestType.TEST,
  "tournament": TestType.TOURNAMENT,
  "challenge_yourself": TestType.CHALLENGE_YOURSELF,
  "everyday_challenge": TestType.EVERYDAY_CHALLENGE,
});

// ── CATEGORY PERFORMANCE ──────────────────────────────────────────────────────

class CategoryPerformance {
  final String subject;
  final int avgAccuracy;

  CategoryPerformance({required this.subject, required this.avgAccuracy});

  factory CategoryPerformance.fromJson(Map<String, dynamic> json) =>
      CategoryPerformance(
        subject: json["subject"] ?? "",
        avgAccuracy: (json["avgAccuracy"] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "subject": subject,
    "avgAccuracy": avgAccuracy,
  };
}

// ── MONTHLY SCORE TREND ───────────────────────────────────────────────────────

class MonthlyScoreTrend {
  final String month;
  final int avgScore;

  MonthlyScoreTrend({required this.month, required this.avgScore});

  factory MonthlyScoreTrend.fromJson(Map<String, dynamic> json) =>
      MonthlyScoreTrend(
        month: json["month"] ?? "",
        avgScore: (json["avgScore"] as num?)?.toInt() ?? 0, // ✅ safe toInt()
      );

  Map<String, dynamic> toJson() => {"month": month, "avgScore": avgScore};
}

// ── TEST TYPE STAT ────────────────────────────────────────────────────────────

class TestTypeStat {
  final TestType type;
  final int totalTests;
  final int totalDurationMinutes;
  final double avgScore;
  final int bestScore;
  final List<MonthlyTrend> monthlyTrend;

  TestTypeStat({
    required this.type,
    required this.totalTests,
    required this.totalDurationMinutes,
    required this.avgScore,
    required this.bestScore,
    required this.monthlyTrend,
  });

  factory TestTypeStat.fromJson(Map<String, dynamic> json) => TestTypeStat(
    type: typeValues.map[json["type"]] ?? TestType.UNKNOWN,
    totalTests: (json["totalTests"] as num?)?.toInt() ?? 0, // ✅ safe toInt()
    totalDurationMinutes:
        (json["totalDurationMinutes"] as num?)?.toInt() ?? 0, // ✅ safe toInt()
    avgScore:
        (json["avgScore"] as num?)?.toDouble() ?? 0.0, // ✅ safe toDouble()
    bestScore: (json["bestScore"] as num?)?.toInt() ?? 0, // ✅ safe toInt()
    monthlyTrend: (json["monthlyTrend"] as List? ?? [])
        .map((x) => MonthlyTrend.fromJson(x))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    "type": typeValues.reverse[type],
    "totalTests": totalTests,
    "totalDurationMinutes": totalDurationMinutes,
    "avgScore": avgScore,
    "bestScore": bestScore,
    "monthlyTrend": monthlyTrend.map((x) => x.toJson()).toList(),
  };

  String get displayLabel {
    switch (type) {
      case TestType.TOURNAMENT:
        return "Tournament";
      case TestType.OLYMPIAD:
        return "Olympiad";
      case TestType.TEST:
        return "Tests";
      case TestType.CHALLENGE_YOURSELF:
        return "Challenge Yourself";
      case TestType.COMPETITION_SECTOR:
        return "Competition";
      case TestType.EVERYDAY_CHALLENGE:
        return "Daily Challenge";
      default:
        return "Other";
    }
  }
}

class MonthlyTrend {
  final String month;
  final double avgScore;
  final int count;

  MonthlyTrend({
    required this.month,
    required this.avgScore,
    required this.count,
  });

  factory MonthlyTrend.fromJson(Map<String, dynamic> json) => MonthlyTrend(
    month: json["month"] ?? "",
    avgScore:
        (json["avgScore"] as num?)?.toDouble() ?? 0.0, // ✅ safe toDouble()
    count: json["count"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "month": month,
    "avgScore": avgScore,
    "count": count,
  };
}

// ── TOTAL TIME LEARNING ───────────────────────────────────────────────────────

class TotalTimeLearning {
  final int hours;
  final int minutes;
  final int totalMinutes;

  TotalTimeLearning({
    required this.hours,
    required this.minutes,
    required this.totalMinutes,
  });

  factory TotalTimeLearning.fromJson(Map<String, dynamic> json) =>
      TotalTimeLearning(
        hours: json["hours"] ?? 0,
        minutes: json["minutes"] ?? 0,
        totalMinutes: json["totalMinutes"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "hours": hours,
    "minutes": minutes,
    "totalMinutes": totalMinutes,
  };
}

class RecentResumeExam {
  final String id;
  final String sessionId;
  final String title;
  final String status;
  final DateTime? startTime;
  final DateTime? endTime;
  final int maxScore;
  final int correctCount;
  final int wrongCount;
  final int skippedCount;
  final List<Answer> answers;

  RecentResumeExam({
    required this.id,
    required this.sessionId,
    required this.title,
    required this.status,
    this.startTime,
    this.endTime,
    required this.maxScore,
    required this.correctCount,
    required this.wrongCount,
    required this.skippedCount,
    required this.answers,
  });

  factory RecentResumeExam.fromJson(Map<String, dynamic> json) =>
      RecentResumeExam(
        id: json["_id"] ?? "",
        sessionId: json["sessionId"] ?? "",
        title: json["title"] ?? json["test"]?["title"] ?? "",
        status: json["status"] ?? "",
        startTime: DateTime.tryParse(json["startTime"] ?? ""),
        endTime: DateTime.tryParse(json["endTime"] ?? ""),
        maxScore: json["maxScore"] ?? 0,
        correctCount: json["correctCount"] ?? 0,
        wrongCount: json["wrongCount"] ?? 0,
        skippedCount: json["skippedCount"] ?? 0,
        answers: (json["answers"] as List? ?? [])
            .map((e) => Answer.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "sessionId": sessionId,
    "title": title,
    "status": status,
    "startTime": startTime?.toIso8601String(),
    "endTime": endTime?.toIso8601String(),
    "maxScore": maxScore,
    "correctCount": correctCount,
    "wrongCount": wrongCount,
    "skippedCount": skippedCount,
    "answers": answers.map((e) => e.toJson()).toList(),
  };
}

class Answer {
  final String questionId;
  final List<String>? answer;
  final String status;
  final DateTime? answeredAt;

  Answer({
    required this.questionId,
    this.answer,
    required this.status,
    this.answeredAt,
  });

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
    questionId: json["questionId"] ?? "",
    answer: _parseAnswer(json["answer"]),
    status: json["status"] ?? "",
    answeredAt: DateTime.tryParse(json["answeredAt"] ?? ""),
  );
  static List<String>? _parseAnswer(dynamic raw) {
    if (raw == null) return null;
    if (raw is List) return raw.map((e) => e.toString()).toList();
    if (raw is String) return raw.isEmpty ? null : [raw];
    return [raw.toString()];
  }

  Map<String, dynamic> toJson() => {
    "questionId": questionId,
    "answer": answer,
    "status": status,
    "answeredAt": answeredAt?.toIso8601String(),
  };
}
// ── UPCOMING EVENT ────────────────────────────────────────────────────────────

class UpcomingEvent {
  final String id;
  final String title;
  final String type;
  final String date;

  UpcomingEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
  });

  factory UpcomingEvent.fromJson(Map<String, dynamic> json) => UpcomingEvent(
    id: json["id"] ?? "",
    title: json["title"] ?? "",
    type: json["type"] ?? "",
    date: json["date"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "type": type,
    "date": date,
  };
}

// ── ENUM HELPER ───────────────────────────────────────────────────────────────

class EnumValues<T> {
  final Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
