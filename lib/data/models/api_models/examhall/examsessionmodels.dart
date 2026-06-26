import 'dart:convert';

// ══════════════════════════════════════════════════════════════════════════════
// 1 & 2 ── Start Exam / Get Session
// ══════════════════════════════════════════════════════════════════════════════

class ExamSessionResponse {
  final bool success;
  final String message;
  final ExamSessionData? data;

  ExamSessionResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ExamSessionResponse.fromJson(Map<String, dynamic>? json) =>
      ExamSessionResponse(
        success: json?['success'] ?? false,
        message: json?['message'] ?? '',
        data: json?['data'] != null
            ? ExamSessionData.fromJson(json!['data'])
            : null,
      );
}

class ExamSessionData {
  final SessionInfo session;
  final List<QuestionItem> questions;
  final PaletteSummary palette;
  final List<SectionConfig> sectionConfig;
  final List<SectionedQuestionGroup> sectionedQuestions;

  ExamSessionData({
    required this.session,
    required this.questions,
    required this.palette,
    required this.sectionConfig,
    required this.sectionedQuestions,
  });

  factory ExamSessionData.fromJson(Map<String, dynamic>? json) =>
      ExamSessionData(
        session: SessionInfo.fromJson(json?['session']),
        questions:
            (json?['questions'] as List<dynamic>?)
                ?.map((q) => QuestionItem.fromJson(q))
                .toList() ??
            [],
        palette: PaletteSummary.fromJson(json?['palette']),
        sectionConfig:
            (json?['sectionConfig'] as List<dynamic>?)
                ?.map((s) => SectionConfig.fromJson(s))
                .toList() ??
            [],
        sectionedQuestions:
            (json?['sectionedQuestions'] as List<dynamic>?)
                ?.map((s) => SectionedQuestionGroup.fromJson(s))
                .toList() ??
            [],
      );
}

// ─── Section Config ──────────────────────────────────────────────────────────
class SectionConfig {
  final int index;
  final int id;
  final String name;
  final int count;
  final String difficulty;

  SectionConfig({
    required this.index,
    required this.id,
    required this.name,
    required this.count,
    required this.difficulty,
  });

  factory SectionConfig.fromJson(Map<String, dynamic>? json) => SectionConfig(
    index: (json?['index'] as num?)?.toInt() ?? 0,
    id: (json?['id'] as num?)?.toInt() ?? 0,
    name: json?['name'] ?? '',
    count: (json?['count'] as num?)?.toInt() ?? 0,
    difficulty: json?['difficulty'] ?? 'medium',
  );
}

// ─── Sectioned Question Group ─────────────────────────────────────────────────
class SectionedQuestionGroup {
  final int index;
  final int id;
  final String name;
  final int count;
  final String difficulty;
  final List<QuestionItem> questions;
  final int recommendedTotalTimeMs;
  final String recommendedTotalTimeFormatted;
  final int recommendedPerQuestionMs;
  final String recommendedPerQuestionFormatted;

  SectionedQuestionGroup({
    required this.index,
    required this.id,
    required this.name,
    required this.count,
    required this.difficulty,
    required this.questions,
    required this.recommendedTotalTimeMs,
    required this.recommendedTotalTimeFormatted,
    required this.recommendedPerQuestionMs,
    required this.recommendedPerQuestionFormatted,
  });

  factory SectionedQuestionGroup.fromJson(Map<String, dynamic>? json) =>
      SectionedQuestionGroup(
        index: (json?['index'] as num?)?.toInt() ?? 0,
        id: (json?['id'] as num?)?.toInt() ?? 0,
        name: json?['name'] ?? '',
        count: (json?['count'] as num?)?.toInt() ?? 0,
        difficulty: json?['difficulty'] ?? 'medium',
        questions:
            (json?['questions'] as List<dynamic>?)
                ?.map((q) => QuestionItem.fromJson(q))
                .toList() ??
            [],
        recommendedTotalTimeMs:
            (json?['recommendedTotalTimeMs'] as num?)?.toInt() ?? 0,
        recommendedTotalTimeFormatted:
            json?['recommendedTotalTimeFormatted'] ?? '0:00',
        recommendedPerQuestionMs:
            (json?['recommendedPerQuestionMs'] as num?)?.toInt() ?? 0,
        recommendedPerQuestionFormatted:
            json?['recommendedPerQuestionFormatted'] ?? '0:00',
      );

  String get difficultyLabel =>
      difficulty[0].toUpperCase() + difficulty.substring(1);
}

// ─── Session Info ─────────────────────────────────────────────────────────────
class SessionInfo {
  final String id;
  final SessionTest? test;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? completedAt;
  final String status;
  final int maxScore;
  final int remainingTime;
  final String remainingTimeFormatted;
  final bool sectionWiseQuestionsEnabled;
  final String timeAllocationStrategy;

  SessionInfo({
    required this.id,
    this.test,
    this.startTime,
    this.endTime,
    this.completedAt,
    required this.status,
    required this.maxScore,
    required this.remainingTime,
    required this.remainingTimeFormatted,
    this.sectionWiseQuestionsEnabled = false,
    this.timeAllocationStrategy = 'section_equal',
  });

  factory SessionInfo.fromJson(Map<String, dynamic>? json) => SessionInfo(
    id: json?['id'] ?? '',
    test: json?['test'] != null ? SessionTest.fromJson(json!['test']) : null,
    startTime: _parseDate(json?['startTime']),
    endTime: _parseDate(json?['endTime']),
    completedAt: _parseDate(json?['completedAt']),
    status: json?['status'] ?? 'in_progress',
    maxScore: (json?['maxScore'] as num?)?.toInt() ?? 0,
    remainingTime: (json?['remainingTime'] as num?)?.toInt() ?? 0,
    remainingTimeFormatted: json?['remainingTimeFormatted'] ?? '00:00',
    sectionWiseQuestionsEnabled: json?['sectionWiseQuestionsEnabled'] ?? false,
    timeAllocationStrategy:
        json?['timeAllocationStrategy'] ?? 'section_equal',
  );

  int get remainingSeconds => (remainingTime / 1000).floor();
  bool get isCompleted => status == 'completed';
}

class SessionTest {
  final String? title;
  final String? description;
  final int? durationMinutes;
  final String? proctoringInstructions;

  SessionTest({
    this.title,
    this.description,
    this.durationMinutes,
    this.proctoringInstructions,
  });

  factory SessionTest.fromJson(Map<String, dynamic>? json) => SessionTest(
    title: json?['title'],
    description: json?['description'],
    durationMinutes: (json?['durationMinutes'] as num?)?.toInt(),
    proctoringInstructions: json?['proctoringInstructions'],
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// QUESTION ITEM
// ══════════════════════════════════════════════════════════════════════════════

class QuestionItem {
  final String questionId;
  final QuestionDetail question;

  // Mutable during exam — stores option text while answering
  dynamic answer;
  String status;
  DateTime? answeredAt;
         // keeps TEXT for UI highlighting
  dynamic answerId; 

  // Per-question time from server (seconds)
  final int recommendedTimeSeconds;

  // Results fields — resolved to TEXT at parse time
  final dynamic correctAnswer;
  final bool? isCorrect;
  final String? explanation;
  final double? marksEarned;
final double? negativeMarksDeducted;

  QuestionItem({
    required this.questionId,
    required this.question,
    this.answer,
     this.answerId,
    this.status = 'not_visited',
    this.answeredAt,
    this.recommendedTimeSeconds = 90,
    this.correctAnswer,
    this.isCorrect,
    this.explanation,
    this.marksEarned,
    this.negativeMarksDeducted,
  });

factory QuestionItem.fromJson(Map<String, dynamic>? json) {
  final options =
      (json?['question']?['options'] as List<dynamic>?)
          ?.map((o) => QuestionOption.fromJson(o))
          .toList() ??
      [];
 
  // ── Resolver: id / text / bool / integer-index → option text ─────────────
  String? resolveToText(dynamic raw) {
    if (raw == null) return null;
 
    // Integer index (results API sends correctAnswer: 1)
    if (raw is int) {
      if (raw >= 0 && raw < options.length) return options[raw].text;
      return null;
    }
 
    final str = raw is bool ? (raw ? 'True' : 'False') : raw.toString();
    if (str.isEmpty) return null;
 
    // Match by id or text
    try {
      return options
          .firstWhere(
            (o) =>
                o.id.toLowerCase() == str.toLowerCase() ||
                o.text.toLowerCase() == str.toLowerCase(),
          )
          .text;
    } catch (_) {
      return str;
    }
  }
 
  final rawAnswer = json?['answer'] ??
      json?['studentAnswer'] ??
      json?['student_answer'];
  final rawCorrect = json?['correctAnswer'];
 
  dynamic resolvedAnswer;
  if (rawAnswer is List) {
    resolvedAnswer =
        rawAnswer.map((e) => resolveToText(e) ?? e.toString()).toList();
  } else {
    resolvedAnswer = resolveToText(rawAnswer);
  }
 
  dynamic resolvedCorrect;
  if (rawCorrect is List) {
    resolvedCorrect =
        rawCorrect.map((e) => resolveToText(e) ?? e.toString()).toList();
  } else {
    resolvedCorrect = resolveToText(rawCorrect);
  }
 
  return QuestionItem(
    questionId: json?['questionId'] ?? '',
    question: QuestionDetail.fromJson(json?['question']),
    answer: resolvedAnswer,
    correctAnswer: resolvedCorrect,
    status: json?['status'] ?? 'not_visited',
    answeredAt: _parseDate(json?['answeredAt']),
    isCorrect: json?['isCorrect'],
    explanation: json?['explanation'],
    marksEarned: (json?['marks'] as num?)?.toDouble(),
    negativeMarksDeducted: (json?['negativeMarks'] as num?)?.toDouble(),
    recommendedTimeSeconds:
        (json?['recommendedTimeSeconds'] as num?)?.toInt() ?? 90,
    answerId: null,
  );
}
  bool get isAnswered => answer != null && status == 'answered';
  bool get isMarkedForReview => status == 'marked_for_review';
  bool get isSkipped => status == 'skipped';
  bool get isNotVisited => status == 'not_visited';
}

// ─── Question Detail ──────────────────────────────────────────────────────────
class QuestionDetail {
  final String? questionText;
  final String questionType;
  final List<QuestionOption> options;
  final String? subject;
  final String? topic;
  final int marks;
  final int negativeMarks;
  final String? difficulty;
  final int sectionIndex;
  final String? paragraph;
  final List<String> imageUrls; // ✅ CHANGED: always a List (was String?)
  final String? title;
  final List<SubQuestion> subQuestions;
 
  QuestionDetail({
    this.questionText,
    required this.questionType,
    required this.options,
    this.subject,
    this.topic,
    this.marks = 1,
    this.negativeMarks = 0,
    this.difficulty,
    this.sectionIndex = 0,
    this.paragraph,
    this.imageUrls = const [], // ✅ CHANGED
    this.title,
    this.subQuestions = const [],
  });
 
  // ✅ Convenience getter — first image or null (keeps existing callers working)
  String? get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;
 
  bool get isConnected => questionType == 'connected';
  bool get hasImages => imageUrls.isNotEmpty;
 
  factory QuestionDetail.fromJson(Map<String, dynamic>? json) {
    // ✅ Parse imageUrl — accepts String, List<String>, or null
    final rawImageUrl = json?['imageUrl'];
    List<String> parsedImageUrls = [];
    if (rawImageUrl is List) {
      parsedImageUrls = rawImageUrl
          .map((e) => e?.toString() ?? '')
          .where((s) => s.trim().isNotEmpty)
          .toList();
    } else if (rawImageUrl is String && rawImageUrl.trim().isNotEmpty) {
      parsedImageUrls = [rawImageUrl];
    }
 
    return QuestionDetail(
      questionText: json?['questionText'],
      questionType: json?['questionType'] ?? 'single',
      options: (json?['options'] as List<dynamic>?)
              ?.map((o) => QuestionOption.fromJson(o))
              .toList() ??
          [],
      subject: json?['subject'],
      topic: json?['topic'],
      marks: (json?['marks'] as num?)?.toInt() ?? 1,
      negativeMarks: (json?['negativeMarks'] as num?)?.toInt() ?? 0,
      difficulty: json?['difficulty'],
      sectionIndex: (json?['sectionIndex'] as num?)?.toInt() ?? 0,
      paragraph: json?['paragraph'],
      imageUrls: parsedImageUrls, // ✅ CHANGED
      title: json?['title'],
      subQuestions: (json?['subQuestions'] as List<dynamic>?)
              ?.map((s) => SubQuestion.fromJson(s))
              .toList() ??
          [],
    );
  }
} 
// ─── Sub-Question ─────────────────────────────────────────────────────────────
/// Used for connected/passage questions.
/// Contains both exam-session fields (studentAnswer, status) and
/// result fields (correctAnswer, isCorrect, explanation).
class SubQuestion {
  final String id;
  final String? questionText;
  final List<String> imageUrls; // ✅ FIXED: was String?, now List<String>
  final String questionType;
  final List<QuestionOption> options;
  final int marks;
  final int negativeMarks;
  final int? remainingQuestionTimeSeconds;
 
  // Results fields
  final dynamic correctAnswer;
  final String? explanation;
  final bool? isCorrect;
 
  // Mutable session/result state
  dynamic studentAnswer;
  String status;
  DateTime? answeredAt;
 
  SubQuestion({
    required this.id,
    this.questionText,
    this.imageUrls = const [], // ✅ FIXED
    required this.questionType,
    required this.options,
    this.marks = 1,
    this.negativeMarks = 0,
    this.correctAnswer,
    this.explanation,
    this.isCorrect,
    this.studentAnswer,
    this.status = 'not_visited',
    this.answeredAt,
    this.remainingQuestionTimeSeconds,
  });
 
  // ✅ Convenience getter — keeps existing callers working
  String? get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;
  bool get hasImages => imageUrls.isNotEmpty;
 
  factory SubQuestion.fromJson(Map<String, dynamic>? json) {
    final options =
        (json?['options'] as List<dynamic>?)
            ?.map((o) => QuestionOption.fromJson(o))
            .toList() ??
        [];
 
    // ✅ Parse imageUrl — accepts null, String, or List<String>
    final rawImageUrl = json?['imageUrl'];
    List<String> parsedImageUrls = [];
    if (rawImageUrl is List) {
      parsedImageUrls = rawImageUrl
          .map((e) => e?.toString() ?? '')
          .where((s) => s.trim().isNotEmpty)
          .toList();
    } else if (rawImageUrl is String && rawImageUrl.trim().isNotEmpty) {
      parsedImageUrls = [rawImageUrl];
    }
 
    String? resolveToText(dynamic raw) {
      if (raw == null) return null;
      if (raw is int) {
        if (raw >= 0 && raw < options.length) return options[raw].text;
        return null;
      }
      final str = raw is bool ? (raw ? 'True' : 'False') : raw.toString();
      if (str.isEmpty) return null;
      try {
        return options
            .firstWhere(
              (o) =>
                  o.id.toLowerCase() == str.toLowerCase() ||
                  o.text.toLowerCase() == str.toLowerCase(),
            )
            .text;
      } catch (_) {
        return str;
      }
    }
 
    final rawAnswer = json?['studentAnswer'];
    dynamic resolvedAnswer;
    if (rawAnswer is List) {
      resolvedAnswer =
          rawAnswer.map((e) => resolveToText(e) ?? e.toString()).toList();
    } else {
      resolvedAnswer = resolveToText(rawAnswer);
    }
 
    final rawCorrect = json?['correctAnswer'];
    dynamic resolvedCorrect;
    if (rawCorrect is List) {
      resolvedCorrect =
          rawCorrect.map((e) => resolveToText(e) ?? e.toString()).toList();
    } else {
      resolvedCorrect = resolveToText(rawCorrect);
    }
 
    return SubQuestion(
      id: json?['_id']?.toString() ?? json?['id']?.toString() ?? '',
      questionText: json?['questionText'],
      imageUrls: parsedImageUrls, // ✅ FIXED
      questionType: json?['questionType'] ?? 'single',
      options: options,
      marks: (json?['marks'] as num?)?.toInt() ?? 1,
      negativeMarks: (json?['negativeMarks'] as num?)?.toInt() ?? 0,
      correctAnswer: resolvedCorrect, // ✅ also resolves index for sub-questions
      explanation: json?['explanation'],
      isCorrect: json?['isCorrect'],
      studentAnswer: resolvedAnswer,
      status: json?['status'] ?? 'not_visited',
      answeredAt: _parseDate(json?['answeredAt']),
      remainingQuestionTimeSeconds:
          (json?['remainingQuestionTimeSeconds'] as num?)?.toInt(),
    );
  }
 
  bool get isAnswered => studentAnswer != null && status == 'answered';
}
// ─── Question Option ──────────────────────────────────────────────────────────
class QuestionOption {
  final String id;
  final String text;
  final bool isCorrect;
  final String? imageUrl; // ✅ NEW — null for text options
 
  QuestionOption({
    required this.id,
    required this.text,
    this.isCorrect = false,
    this.imageUrl,
  });
 
  bool get isImageOption => imageUrl != null && imageUrl!.trim().isNotEmpty;
 
  factory QuestionOption.fromJson(dynamic json) {
    if (json is String) return QuestionOption(id: json, text: json);
    final m = json as Map<String, dynamic>;
    return QuestionOption(
      id: m['_id']?.toString() ?? m['id']?.toString() ?? m['text'] ?? '',
      text: m['text']?.toString() ?? m['option']?.toString() ?? '',
      isCorrect: m['isCorrect'] == true,
      imageUrl: m['imageUrl']?.toString(), // ✅ NEW
    );
  }
}
 
// ══════════════════════════════════════════════════════════════════════════════
// PALETTE
// ══════════════════════════════════════════════════════════════════════════════

class PaletteSummary {
  final int answered;
  final int skipped;
  final int markedForReview;
  final int notVisited;
  final int total;

  PaletteSummary({
    required this.answered,
    required this.skipped,
    required this.markedForReview,
    required this.notVisited,
    required this.total,
  });

  factory PaletteSummary.fromJson(Map<String, dynamic>? json) =>
      PaletteSummary(
        answered: (json?['answered'] as num?)?.toInt() ?? 0,
        skipped: (json?['skipped'] as num?)?.toInt() ?? 0,
        markedForReview: (json?['markedForReview'] as num?)?.toInt() ?? 0,
        notVisited: (json?['notVisited'] as num?)?.toInt() ?? 0,
        total: (json?['total'] as num?)?.toInt() ?? 0,
      );
}

class PaletteResponse {
  final bool success;
  final String message;
  final PaletteData? data;

  PaletteResponse({required this.success, required this.message, this.data});

  factory PaletteResponse.fromJson(Map<String, dynamic>? json) =>
      PaletteResponse(
        success: json?['success'] ?? false,
        message: json?['message'] ?? '',
        data: json?['data'] != null
            ? PaletteData.fromJson(json!['data'])
            : null,
      );
}

class PaletteData {
  final List<PaletteItem> palette;
  final PaletteSummary summary;

  PaletteData({required this.palette, required this.summary});

  factory PaletteData.fromJson(Map<String, dynamic>? json) => PaletteData(
    palette:
        (json?['palette'] as List<dynamic>?)
            ?.map((p) => PaletteItem.fromJson(p))
            .toList() ??
        [],
    summary: PaletteSummary.fromJson(json?['summary']),
  );
}

class PaletteItem {
  final int questionNumber;
  final String questionId;
  final String status;
  final bool hasAnswer;

  PaletteItem({
    required this.questionNumber,
    required this.questionId,
    required this.status,
    required this.hasAnswer,
  });

  factory PaletteItem.fromJson(Map<String, dynamic>? json) => PaletteItem(
    questionNumber: json?['questionNumber'] ?? 0,
    questionId: json?['questionId'] ?? '',
    status: json?['status'] ?? 'not_visited',
    hasAnswer: json?['hasAnswer'] ?? false,
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// PROCTORING
// ══════════════════════════════════════════════════════════════════════════════

class ProctoringResponse {
  final bool success;
  final String message;
  final ProctoringResult? data;

  ProctoringResponse({required this.success, required this.message, this.data});

  factory ProctoringResponse.fromJson(Map<String, dynamic>? json) =>
      ProctoringResponse(
        success: json?['success'] ?? false,
        message: json?['message'] ?? '',
        data: json?['data'] != null
            ? ProctoringResult.fromJson(json!['data'])
            : null,
      );
}

class ProctoringResult {
  final bool success;
  final String message;
  final bool autoSubmitted;

  ProctoringResult({
    required this.success,
    required this.message,
    required this.autoSubmitted,
  });

  factory ProctoringResult.fromJson(Map<String, dynamic>? json) =>
      ProctoringResult(
        success: json?['success'] ?? false,
        message: json?['message'] ?? '',
        autoSubmitted: json?['autoSubmitted'] ?? false,
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// REQUEST BODIES
// ══════════════════════════════════════════════════════════════════════════════

class AnswerRequest {
  final dynamic answer;
  final String status;

  AnswerRequest({required this.answer, this.status = 'answered'});

  Map<String, dynamic> toJson() => {'answer': answer, 'status': status};
}

// ══════════════════════════════════════════════════════════════════════════════
// PROCTORING EVENT TYPES
// ══════════════════════════════════════════════════════════════════════════════

enum ProctoringEventType {
  windowBlur('window_blur'),
  tabSwitch('tab_switch'),
  fullscreenExit('fullscreen_exit'),
  visibilityChange('visibility_change');

  final String value;
  const ProctoringEventType(this.value);
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}