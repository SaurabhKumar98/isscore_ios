// ─── lib/data/models/api_models/report/chatcallreportmodels.dart ──────────

import 'package:firstedu/data/models/api_models/report/chatteachermodels.dart';

// Reuse the private helpers from chatteachermodels if they are in the same
// library, or redeclare them here for safety.
List<String> _toStringList(dynamic value) {
  if (value is! List) return [];
  return value.map((e) => e?.toString() ?? '').toList();
}

Map<String, dynamic> _toMap(dynamic value) {
  if (value == null) return {};
  if (value is Map<String, dynamic>) return value;
  return Map<String, dynamic>.from(value as Map);
}

/// One row in the Call Report teacher list.
class CallTeacherSummaryModel {
  final String teacherId;
  final ChatTeacherModel teacher;
  final int recordingCount;
  final int callCount;
  final double totalDurationMinutes;
  final String lastCallEndTime;
  final String latestSubject;
  final String latestRecordingUrl;

  const CallTeacherSummaryModel({
    required this.teacherId,
    required this.teacher,
    required this.recordingCount,
    required this.callCount,
    required this.totalDurationMinutes,
    required this.lastCallEndTime,
    required this.latestSubject,
    required this.latestRecordingUrl,
  });

  factory CallTeacherSummaryModel.fromJson(Map<String, dynamic> json) =>
      CallTeacherSummaryModel(
        teacherId: json['teacherId']?.toString() ?? '',
        teacher: ChatTeacherModel.fromJson(_toMap(json['teacher'])),
        recordingCount: (json['recordingCount'] as num?)?.toInt() ?? 0,
        callCount: (json['callCount'] as num?)?.toInt() ?? 0,
        totalDurationMinutes:
            (json['totalDurationMinutes'] as num?)?.toDouble() ?? 0.0,
        lastCallEndTime: json['lastCallEndTime']?.toString() ?? '',
        latestSubject: json['latestSubject']?.toString() ?? '',
        latestRecordingUrl: json['latestRecordingUrl']?.toString() ?? '',
      );
}

/// Single recording in the Call Report detail screen.
class CallRecordingModel {
  final String id;
  final ChatTeacherModel teacher;
  final String status;
  final String subject;
  final String sessionKind;
  final String callStartTime;
  final String callEndTime;
  final double durationMinutes;
  final String recordingUrl;
  final double totalAmount;

  const CallRecordingModel({
    required this.id,
    required this.teacher,
    required this.status,
    required this.subject,
    required this.sessionKind,
    required this.callStartTime,
    required this.callEndTime,
    required this.durationMinutes,
    required this.recordingUrl,
    required this.totalAmount,
  });

  factory CallRecordingModel.fromJson(Map<String, dynamic> json) =>
      CallRecordingModel(
        id: json['_id']?.toString() ?? '',
        teacher: ChatTeacherModel.fromJson(_toMap(json['teacher'])),
        status: json['status']?.toString() ?? '',
        subject: json['subject']?.toString() ?? '',
        sessionKind: json['sessionKind']?.toString() ?? '',
        callStartTime: json['callStartTime']?.toString() ?? '',
        callEndTime: json['callEndTime']?.toString() ?? '',
        durationMinutes:
            (json['durationMinutes'] as num?)?.toDouble() ?? 0.0,
        recordingUrl: json['recordingUrl']?.toString() ?? '',
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      );
}