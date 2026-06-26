import 'dart:convert';

import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/examhall/examinstractionmodel.dart';
import 'package:firstedu/data/models/api_models/examhall/examinstructionmodels.dart';
import 'package:firstedu/data/models/api_models/examhall/examsessionmodels.dart';
import 'package:firstedu/data/models/api_models/examhall/resultmodels.dart';
import 'package:firstedu/data/models/api_models/examhall/vistiquestionmodels.dart';
import 'package:flutter/material.dart';

class ExamSessionRepository {
  final ApiClient _apiClient;
  ExamSessionRepository(this._apiClient);

  // ── 0. GET /tests/:testId/exam-instructions  ──────────────────────────────

Future<Examinstructionsmodel> getInstructions(
  String testId, {
  String? categoryId,
}) async {
  try {
    final queryParams = <String, dynamic>{};

    // ✅ ONLY for specific pillars
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams['categoryId'] = categoryId;
    }

    final res = await _apiClient.get(
      '${ApiEndpoint.appBaseUrl}/tests/$testId/exam-instructions',
      queryParameters: queryParams, // ✅ FIX HERE
    );

    final data = res.data;

    final Map<String, dynamic> map = data is String
        ? jsonDecode(data)
        : Map<String, dynamic>.from(data);

    if (map['success'] != true) {
      throw AppException(
        map['message']?.toString() ?? 'Failed to load instructions.',
      );
    }

    return Examinstructionsmodel.fromJson(map);
  } on AppException {
    rethrow;
  } catch (e) {
    throw AppException('Failed to load exam instructions. Please try again.');
  }
}
  // ── 1. POST /tests/:testId/start-exam  ────────────────────────────────────

Future<ExamSessionResponse> startExam(
  String testId, {
  bool isBundleTest = false,
  String? categoryId, // 🔥 ADD
}) async {
    try {
      final endpoint = '${ApiEndpoint.appBaseUrl}/tests/$testId/start-exam';

final res = await _apiClient.post(
  endpoint,
  data: categoryId != null && categoryId.isNotEmpty
      ? {'categoryId': categoryId} // ✅ SEND IN BODY
      : {},
);      final map = res.data as Map<String, dynamic>?;

      if (map?['success'] != true) {
        final msg = map?['message']?.toString() ?? 'Something went wrong.';
        String? sessionId;
        final sessionData = map?['data']?['session'];
        if (sessionData is Map) {
          sessionId =
              sessionData['id'] as String? ?? sessionData['_id'] as String?;
        }
        throw AppException(msg, sessionId: sessionId);
      }

      return ExamSessionResponse.fromJson(map!);
    } on AppException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      debugPrint('❌ PARSE ERROR: $e');
      throw AppException('Failed to start exam. Please try again.');
    }
  }

  // ── 2. GET /exam-sessions/:sessionId

  Future<ExamSessionResponse> getSession(String sessionId) async {
    try {
      final res = await _apiClient.get(
        '${ApiEndpoint.appBaseUrl}/exam-sessions/$sessionId',
      );
      _checkSuccess(res.data);
      return ExamSessionResponse.fromJson(res.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to load session.');
    }
  }

  // ── 3. PUT /exam-sessions/:sessionId/questions/:questionId/answer  ─────────

  Future<ExamSessionResponse> saveAnswer({
    required String sessionId,
    required String questionId,
    required dynamic answer,
    String status = 'answered',
  }) async {
    try {
      final res = await _apiClient.put(
        '${ApiEndpoint.appBaseUrl}/exam-sessions/$sessionId/questions/$questionId/answer',
        data: AnswerRequest(answer: answer, status: status).toJson(),
      );
      _checkSuccess(res.data);
      return ExamSessionResponse.fromJson(res.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to save answer.');
    }
  }

  // ── 4. POST /exam-sessions/:sessionId/questions/:questionId/mark-review  ───

  Future<ExamSessionResponse> markForReview({
    required String sessionId,
    required String questionId,
  }) async {
    try {
      final res = await _apiClient.post(
        '${ApiEndpoint.appBaseUrl}/exam-sessions/$sessionId/questions/$questionId/mark-review',
      );
      _checkSuccess(res.data);
      return ExamSessionResponse.fromJson(res.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to mark for review.');
    }
  }

  // ── 5. POST /exam-sessions/:sessionId/questions/:questionId/skip  ──────────

  Future<ExamSessionResponse> skipQuestion({
    required String sessionId,
    required String questionId,
  }) async {
    try {
      final res = await _apiClient.post(
        '${ApiEndpoint.appBaseUrl}/exam-sessions/$sessionId/questions/$questionId/skip',
      );
      _checkSuccess(res.data);
      return ExamSessionResponse.fromJson(res.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to skip question.');
    }
  }

  // ── 6. POST /exam-sessions/:sessionId/questions/:questionId/visit  ─────────
  //
  // Called whenever the student opens / switches to a question.
  // Backend pauses the previous question's timer and starts / resumes
  // the timer for [questionId].
  // Returns the full session snapshot (same shape as getSession).

  Future<VisitQuestionsModels> visitQuestion({
    required String sessionId,
    required String questionId,
  }) async {
    try {
      final res = await _apiClient.post(
        '${ApiEndpoint.appBaseUrl}/exam-sessions/$sessionId/questions/$questionId/visit',
      );
      _checkSuccess(res.data);
      return VisitQuestionsModels.fromJson(res.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      // visit failures are non-fatal — the local timer keeps running

      throw AppException('Failed to open question.');
    }
  }

  // ── 7. POST /exam-sessions/:sessionId/proctoring  ──────────────────────────

  Future<ProctoringResponse> logProctoringEvent({
    required String sessionId,
    required ProctoringEventType eventType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final res = await _apiClient.post(
        '${ApiEndpoint.appBaseUrl}/exam-sessions/$sessionId/proctoring',
        data: {
          'eventType': eventType.value,
          if (metadata != null) 'metadata': metadata,
        },
      );
      return ProctoringResponse.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      return ProctoringResponse(success: false, message: e.toString());
    }
  }

  // ── 8. POST /exam-sessions/:sessionId/pause  ──────────────────────────────

  Future<int?> pauseSession(String sessionId) async {
    try {
      final res = await _apiClient.post(
        '${ApiEndpoint.appBaseUrl}/exam-sessions/$sessionId/pause',
      );
      final map = res.data as Map<String, dynamic>?;
      return (map?['data']?['remainingTimeAtPause'] as num?)?.toInt();
    } catch (_) {
      return null;
    }
  }

  // ── 9. POST /exam-sessions/:sessionId/submit  ─────────────────────────────

  Future<ExamResultsResponse> submitExam(String sessionId) async {
    try {
      final res = await _apiClient.post(
        '${ApiEndpoint.appBaseUrl}/exam-sessions/$sessionId/submit',
      );
      _checkSuccess(res.data);
      
      return ExamResultsResponse.fromJson(res.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to submit exam.');
    }
  }

  // ── 10. GET /exam-sessions/:sessionId/results  ────────────────────────────

Future<ExamResultsResponse> getResults(String sessionId) async {
  try {
    final res = await _apiClient.get(
      '${ApiEndpoint.appBaseUrl}/exam-sessions/$sessionId/results',
    );
    _checkSuccess(res.data);
    return ExamResultsResponse.fromJson(res.data as Map<String, dynamic>);
  } on AppException {
    rethrow;
  } catch (e, stack) {
    debugPrint('❌ getResults error: $e\n$stack');
    rethrow; // ✅ let the real exception bubble up
  }
}  
  
  // ── 11. GET /exam-sessions/:sessionId/palette  ────────────────────────────

  Future<PaletteResponse> getPalette(String sessionId) async {
    try {
      final res = await _apiClient.get(
        '${ApiEndpoint.appBaseUrl}/exam-sessions/$sessionId/palette',
      );
      _checkSuccess(res.data);
      return PaletteResponse.fromJson(res.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to fetch palette.');
    }
  }

  // ─── Helper ────────────────────────────────────────────────────────────────

  void _checkSuccess(dynamic data) {
    final map = data as Map<String, dynamic>?;
    if (map?['success'] != true) {
      throw AppException(
        (map?['message']?.toString().isNotEmpty == true)
            ? map!['message']
            : 'Something went wrong.',
      );
    }
  }
}
