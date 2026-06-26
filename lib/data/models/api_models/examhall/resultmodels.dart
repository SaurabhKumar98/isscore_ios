import 'package:firstedu/data/models/api_models/examhall/examsessionmodels.dart';

// ── Topper ───────────────────────────────────────────────────────────────────
class Topper {
  final int? rank;
  final String? name;
  final String? email;
  final double? score;
  final double? maxScore;
  final DateTime? completedAt;

  Topper({
    this.rank,
    this.name,
    this.email,
    this.score,
    this.maxScore,
    this.completedAt,
  });

  factory Topper.fromJson(Map<String, dynamic> json) => Topper(
        rank: (json["rank"] as num?)?.toInt(),
        name: json["name"]?.toString(),
        email: json["email"]?.toString(),
        score: (json["score"] as num?)?.toDouble(),
        maxScore: (json["maxScore"] as num?)?.toDouble(),
        completedAt: json["completedAt"] != null
            ? DateTime.tryParse(json["completedAt"].toString())
            : null,
      );

  Map<String, dynamic> toJson() => {
        "rank": rank,
        "name": name,
        "email": email,
        "score": score,
        "maxScore": maxScore,
        "completedAt": completedAt?.toIso8601String(),
      };

  String get scoreDisplay {
    if (score == null) return '0';
    return score! == score!.truncateToDouble()
        ? score!.toInt().toString()
        : score!.toStringAsFixed(1);
  }

  String get maxScoreDisplay {
    if (maxScore == null) return '0';
    return maxScore! == maxScore!.truncateToDouble()
        ? maxScore!.toInt().toString()
        : maxScore!.toStringAsFixed(1);
  }
}

// ── Leaderboard ──────────────────────────────────────────────────────────────
class Leaderboard {
  final List<Topper>? top3;
  final int? myRank;
  final int? totalParticipants;

  Leaderboard({this.top3, this.myRank, this.totalParticipants});

  factory Leaderboard.fromJson(Map<String, dynamic> json) => Leaderboard(
        top3: (json["top3"] as List?)
                ?.map((x) => Topper.fromJson(x as Map<String, dynamic>))
                .toList() ??
            [],
        myRank: (json["myRank"] as num?)?.toInt(),
        totalParticipants: (json["totalParticipants"] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() => {
        "top3": top3?.map((x) => x.toJson()).toList(),
        "myRank": myRank,
        "totalParticipants": totalParticipants,
      };
}

// ── SectionWiseResult ────────────────────────────────────────────────────────
class SectionWiseResult {
  final int sectionIndex;
  final String sectionName;
  final double score;
  final double maxScore;
  final double earnedMarks;
  final double negativeMarksDeducted;
  final int correctCount;
  final int wrongCount;
  final int skippedCount;
  final int totalQuestions;
  final double percentage;

  SectionWiseResult({
    required this.sectionIndex,
    required this.sectionName,
    required this.score,
    required this.maxScore,
    required this.earnedMarks,
    required this.negativeMarksDeducted,
    required this.correctCount,
    required this.wrongCount,
    required this.skippedCount,
    required this.totalQuestions,
    required this.percentage,
  });

  factory SectionWiseResult.fromJson(Map<String, dynamic> json) =>
      SectionWiseResult(
        sectionIndex: (json["sectionIndex"] as num?)?.toInt() ?? 0,
        sectionName: json["sectionName"]?.toString() ?? '',
        score: (json["score"] as num?)?.toDouble() ?? 0.0,
        maxScore: (json["maxScore"] as num?)?.toDouble() ?? 0.0,
        earnedMarks: (json["earnedMarks"] as num?)?.toDouble() ?? 0.0,
        negativeMarksDeducted:
            (json["negativeMarksDeducted"] as num?)?.toDouble() ?? 0.0,
        correctCount: (json["correctCount"] as num?)?.toInt() ?? 0,
        wrongCount: (json["wrongCount"] as num?)?.toInt() ?? 0,
        skippedCount: (json["skippedCount"] as num?)?.toInt() ?? 0,
        totalQuestions: (json["totalQuestions"] as num?)?.toInt() ?? 0,
        percentage: (json["percentage"] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        "sectionIndex": sectionIndex,
        "sectionName": sectionName,
        "score": score,
        "maxScore": maxScore,
        "earnedMarks": earnedMarks,
        "negativeMarksDeducted": negativeMarksDeducted,
        "correctCount": correctCount,
        "wrongCount": wrongCount,
        "skippedCount": skippedCount,
        "totalQuestions": totalQuestions,
        "percentage": percentage,
      };
}

// ── ExamSession ───────────────────────────────────────────────────────────────
class ExamSession {
  final String id;
  final String status;
  final String? testTitle;
  final DateTime? completedAt;

  ExamSession({
    required this.id,
    required this.status,
    this.testTitle,
    this.completedAt,
  });

  factory ExamSession.fromJson(Map<String, dynamic>? json) => ExamSession(
        id: json?['id']?.toString() ?? json?['_id']?.toString() ?? '',
        status: json?['status']?.toString() ?? 'completed',
        testTitle: json?['test'] is Map
            ? json!['test']['title']?.toString()
            : null,
        completedAt: json?['completedAt'] != null
            ? DateTime.tryParse(json!['completedAt'].toString())
            : null,
      );
}

// ── ExamResults ───────────────────────────────────────────────────────────────
class ExamResults {
  final double score;
  final double maxScore;
  final int correctCount;
  final int wrongCount;
  final int skippedCount;
  final double percentile;
  final double percentage;
  final double earnedMarks;
  final double negativeMarksDeducted;
  final int rank;

  // ✅ NEW FIELD — hides explanations & leaderboard when true
  final bool isCertificationFailed;

  ExamResults({
    required this.score,
    required this.maxScore,
    required this.correctCount,
    required this.wrongCount,
    required this.skippedCount,
    required this.percentile,
    required this.percentage,
    this.earnedMarks = 0,
    this.negativeMarksDeducted = 0,
    this.rank = 0,
    this.isCertificationFailed = false,
  });

  factory ExamResults.fromJson(Map<String, dynamic>? json) => ExamResults(
        score: (json?['score'] as num?)?.toDouble() ?? 0.0,
        maxScore: (json?['maxScore'] as num?)?.toDouble() ?? 0.0,
        correctCount: (json?['correctCount'] as num?)?.toInt() ?? 0,
        wrongCount: (json?['wrongCount'] as num?)?.toInt() ?? 0,
        skippedCount: (json?['skippedCount'] as num?)?.toInt() ?? 0,
        percentile: (json?['percentile'] as num?)?.toDouble() ?? 0.0,
        percentage: (json?['percentage'] as num?)?.toDouble() ?? 0.0,
        earnedMarks: (json?['earnedMarks'] as num?)?.toDouble() ?? 0.0,
        negativeMarksDeducted:
            (json?['negativeMarksDeducted'] as num?)?.toDouble() ?? 0.0,
        rank: (json?['rank'] as num?)?.toInt() ?? 0,
        // ✅ Parse the new field — defaults to false if missing
        isCertificationFailed: json?['isCertificationFailed'] as bool? ?? false,
      );
}

// ── ExamResultsData ───────────────────────────────────────────────────────────
class ExamResultsData {
  final ExamSession session;
  final ExamResults results;
  final List<QuestionItem>? questions;
  final Leaderboard? leaderboard;
  final List<SectionWiseResult> sectionWiseResults;

  ExamResultsData({
    required this.session,
    required this.results,
    this.questions,
    this.leaderboard,
    this.sectionWiseResults = const [],
  });

  factory ExamResultsData.fromJson(Map<String, dynamic>? json) =>
      ExamResultsData(
        session: ExamSession.fromJson(json?['session']),
        results: ExamResults.fromJson(json?['results']),
        questions: (json?['questions'] as List<dynamic>?)
            ?.map((q) => QuestionItem.fromJson(q as Map<String, dynamic>))
            .toList(),
        leaderboard: json?['leaderboard'] != null
            ? Leaderboard.fromJson(
                json!['leaderboard'] as Map<String, dynamic>)
            : null,
        sectionWiseResults: (json?['sectionWiseResults'] as List?)
                ?.map((x) =>
                    SectionWiseResult.fromJson(x as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

// ── ExamResultsResponse ───────────────────────────────────────────────────────
class ExamResultsResponse {
  final bool success;
  final String message;
  final ExamResultsData? data;

  ExamResultsResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ExamResultsResponse.fromJson(Map<String, dynamic>? json) =>
      ExamResultsResponse(
        success: json?['success'] ?? false,
        message: json?['message']?.toString() ?? '',
        data: json?['data'] != null
            ? ExamResultsData.fromJson(
                json!['data'] as Map<String, dynamic>)
            : null,
      );
}