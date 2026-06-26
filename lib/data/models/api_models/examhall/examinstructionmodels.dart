// // ══════════════════════════════════════════════════════════════════════════════
// // EXAM INSTRUCTIONS MODELS
// // GET /user/tests/:testId/exam-instructions
// // ══════════════════════════════════════════════════════════════════════════════

// class ExamInstructionsResponse {
//   final bool success;
//   final String message;
//   final ExamInstructionsData? data;

//   ExamInstructionsResponse({
//     required this.success,
//     required this.message,
//     this.data,
//   });

//   factory ExamInstructionsResponse.fromJson(Map<String, dynamic>? json) =>
//       ExamInstructionsResponse(
//         success: json?['success'] ?? false,
//         message: json?['message'] ?? '',
//         data: json?['data'] != null
//             ? ExamInstructionsData.fromJson(
//                 json!['data'] as Map<String, dynamic>,
//               )
//             : null,
//       );
// }

// // ─────────────────────────────────────────────────────────────────────────────

// class ExamInstructionsData {
//   final InstructionTest test;
//   final InstructionStats stats;
//   final InstructionSections sections;
//   final InstructionSession session;
//   final InstructionEligibility eligibility;
//   final InstructionContent instructions;
//   final List<String> instructionPoints;

//   ExamInstructionsData({
//     required this.test,
//     required this.stats,
//     required this.sections,
//     required this.session,
//     required this.eligibility,
//     required this.instructions,
//     required this.instructionPoints,
//   });

//   factory ExamInstructionsData.fromJson(Map<String, dynamic>? json) =>
//       ExamInstructionsData(
//         test: InstructionTest.fromJson(json?['test'] as Map<String, dynamic>?),
//         stats: InstructionStats.fromJson(
//           json?['stats'] as Map<String, dynamic>?,
//         ),
//         sections: InstructionSections.fromJson(
//           json?['sections'] as Map<String, dynamic>?,
//         ),
//         session: InstructionSession.fromJson(
//           json?['session'] as Map<String, dynamic>?,
//         ),
//         eligibility: InstructionEligibility.fromJson(
//           json?['eligibility'] as Map<String, dynamic>?,
//         ),
//         instructions: InstructionContent.fromJson(
//           json?['instructions'] as Map<String, dynamic>?,
//         ),
//         instructionPoints:
//             (json?['instructionPoints'] as List<dynamic>?)
//                 ?.map((e) => e.toString())
//                 .toList() ??
//             [],
//       );
// }

// // ─────────────────────────────────────────────────────────────────────────────

// class InstructionTest {
//   final String id;
//   final String title;
//   final String? description;
//   final String? imageUrl;
//   final String? applicableFor;
//   final bool isFree;
//   final int? durationMinutes;
//   final String? proctoringInstructions;
//   final String? questionBankName;
//   final List<InstructionCategory> categories;

//   InstructionTest({
//     required this.id,
//     required this.title,
//     this.description,
//     this.imageUrl,
//     this.applicableFor,
//     required this.isFree,
//     this.durationMinutes,
//     this.proctoringInstructions,
//     this.questionBankName,
//     required this.categories,
//   });

//   factory InstructionTest.fromJson(Map<String, dynamic>? json) =>
//       InstructionTest(
//         id: json?['id']?.toString() ?? '',
//         title: json?['title']?.toString() ?? '',
//         description: json?['description']?.toString(),
//         imageUrl: json?['imageUrl']?.toString(),
//         applicableFor: json?['applicableFor']?.toString(),
//         isFree: json?['isFree'] ?? false,
//         durationMinutes: (json?['durationMinutes'] as num?)?.toInt(),
//         proctoringInstructions: json?['proctoringInstructions']?.toString(),
//         questionBankName: json?['questionBankName']?.toString(),
//         categories:
//             (json?['categories'] as List<dynamic>?)
//                 ?.map(
//                   (c) =>
//                       InstructionCategory.fromJson(c as Map<String, dynamic>),
//                 )
//                 .toList() ??
//             [],
//       );
// }

// class InstructionCategory {
//   final String id;
//   final String name;
//   final List<String> fullPath;
//   final String fullPathText;

//   InstructionCategory({
//     required this.id,
//     required this.name,
//     required this.fullPath,
//     required this.fullPathText,
//   });

//   factory InstructionCategory.fromJson(Map<String, dynamic>? json) =>
//       InstructionCategory(
//         id: json?['id']?.toString() ?? '',
//         name: json?['name']?.toString() ?? '',
//         fullPath:
//             (json?['fullPath'] as List<dynamic>?)
//                 ?.map((e) => e.toString())
//                 .toList() ??
//             [],
//         fullPathText: json?['fullPathText']?.toString() ?? '',
//       );
// }

// // ─────────────────────────────────────────────────────────────────────────────

// class InstructionStats {
//   final int totalQuestions;
//   final int totalMarks;
//   final int totalNegativeMarks;
//   final int averageTimePerQuestionSeconds;

//   InstructionStats({
//     required this.totalQuestions,
//     required this.totalMarks,
//     required this.totalNegativeMarks,
//     required this.averageTimePerQuestionSeconds,
//   });

//   factory InstructionStats.fromJson(Map<String, dynamic>? json) =>
//       InstructionStats(
//         totalQuestions: (json?['totalQuestions'] as num?)?.toInt() ?? 0,
//         totalMarks: (json?['totalMarks'] as num?)?.toInt() ?? 0,
//         totalNegativeMarks: (json?['totalNegativeMarks'] as num?)?.toInt() ?? 0,
//         averageTimePerQuestionSeconds:
//             (json?['averageTimePerQuestionSeconds'] as num?)?.toInt() ?? 0,
//       );
// }

// // ─────────────────────────────────────────────────────────────────────────────

// class InstructionSections {
//   final bool sectionWiseEnabled;
//   final bool useSectionWiseDifficulty;
//   final String overallDifficulty;
//   final List<dynamic> items;

//   InstructionSections({
//     required this.sectionWiseEnabled,
//     required this.useSectionWiseDifficulty,
//     required this.overallDifficulty,
//     required this.items,
//   });

//   factory InstructionSections.fromJson(Map<String, dynamic>? json) =>
//       InstructionSections(
//         sectionWiseEnabled: json?['sectionWiseEnabled'] ?? false,
//         useSectionWiseDifficulty: json?['useSectionWiseDifficulty'] ?? false,
//         overallDifficulty: json?['overallDifficulty']?.toString() ?? 'medium',
//         items: (json?['items'] as List<dynamic>?) ?? [],
//       );
// }

// // ─────────────────────────────────────────────────────────────────────────────

// class InstructionSession {
//   final String? inProgressSessionId;
//   final String? pausedSessionId;
//   final bool hasResumableSession;
//   final String nextAction; // 'start' | 'resume'

//   InstructionSession({
//     this.inProgressSessionId,
//     this.pausedSessionId,
//     required this.hasResumableSession,
//     required this.nextAction,
//   });

//   factory InstructionSession.fromJson(Map<String, dynamic>? json) =>
//       InstructionSession(
//         inProgressSessionId: json?['inProgressSessionId']?.toString(),
//         pausedSessionId: json?['pausedSessionId']?.toString(),
//         hasResumableSession: json?['hasResumableSession'] ?? false,
//         nextAction: json?['nextAction']?.toString() ?? 'start',
//       );

//   bool get isResume => nextAction == 'resume' || hasResumableSession;
// }

// // ─────────────────────────────────────────────────────────────────────────────

// class InstructionEligibility {
//   final bool canStart;
//   final String? blockReason;
//   final String? accessType;

//   InstructionEligibility({
//     required this.canStart,
//     this.blockReason,
//     this.accessType,
//   });

//   factory InstructionEligibility.fromJson(Map<String, dynamic>? json) =>
//       InstructionEligibility(
//         canStart: json?['canStart'] ?? true,
//         blockReason: json?['blockReason']?.toString(),
//         accessType: json?['accessType']?.toString(),
//       );
// }

// // ─────────────────────────────────────────────────────────────────────────────

// class InstructionContent {
//   final String? proctoringText;
//   final List<String> points;

//   InstructionContent({this.proctoringText, required this.points});

//   factory InstructionContent.fromJson(Map<String, dynamic>? json) =>
//       InstructionContent(
//         proctoringText: json?['proctoringText']?.toString(),
//         points:
//             (json?['points'] as List<dynamic>?)
//                 ?.map((e) => e.toString())
//                 .toList() ??
//             [],
//       );
// }
