// import 'dart:convert';

// // import 'package:firstedu/data/models/api_models/examhall/resultmodels.dart';

// Examresultmodel examresultmodelFromJson(String str) =>
//     Examresultmodel.fromJson(json.decode(str));

// String examresultmodelToJson(Examresultmodel data) =>
//     json.encode(data.toJson());

// class Examresultmodel {
//   bool? success;
//   String? message;
//   Data? data;
//   dynamic meta;

//   Examresultmodel({this.success, this.message, this.data, this.meta});

//   factory Examresultmodel.fromJson(Map<String, dynamic> json) =>
//       Examresultmodel(
//         success: json["success"],
//         message: json["message"],
//         data: json["data"] != null ? Data.fromJson(json["data"]) : null,
//         meta: json["meta"],
//       );

//   Map<String, dynamic> toJson() => {
//     "success": success,
//     "message": message,
//     "data": data?.toJson(),
//     "meta": meta,
//   };
// }

// // ─────────────────────────────────────────

// class Data {
//   Session? session;
//   Results? results;
//   Leaderboard? leaderboard;
//   List<SectionWiseResult>? sectionWiseResults;
//   List<QuestionElement>? questions;
//   Tournament? tournament;

//   Data({
//     this.session,
//     this.results,
//     this.leaderboard,
//     this.sectionWiseResults,
//     this.questions,
//     this.tournament,
//   });

//   factory Data.fromJson(Map<String, dynamic> json) => Data(
//     session: json["session"] != null ? Session.fromJson(json["session"]) : null,
//     results: json["results"] != null ? Results.fromJson(json["results"]) : null,
//     leaderboard: json["leaderboard"] != null
//         ? Leaderboard.fromJson(json["leaderboard"])
//         : null,
//     sectionWiseResults: json["sectionWiseResults"] != null
//         ? List<SectionWiseResult>.from(
//             json["sectionWiseResults"].map(
//               (x) => SectionWiseResult.fromJson(x),
//             ),
//           )
//         : [],
//     questions: json["questions"] != null
//         ? List<QuestionElement>.from(
//             json["questions"].map((x) => QuestionElement.fromJson(x)),
//           )
//         : [],
//     tournament: json["tournament"] != null
//         ? Tournament.fromJson(json["tournament"])
//         : null,
//   );

//   Map<String, dynamic> toJson() => {
//     "session": session?.toJson(),
//     "results": results?.toJson(),
//     "leaderboard": leaderboard?.toJson(),
//     "sectionWiseResults": sectionWiseResults?.map((x) => x.toJson()).toList(),
//     "questions": questions?.map((x) => x.toJson()).toList(),
//     "tournament": tournament?.toJson(),
//   };
// }

// // ─────────────────────────────────────────
// class QuestionElement {
//   String? questionId;
//   QuestionQuestion? question;
//   String? studentAnswer;
//   String? correctAnswer;
//   bool? isCorrect;
//   String? explanation;
//   int? marks;
//   int? negativeMarks;
//   String? status;
//   DateTime? answeredAt;

//   QuestionElement({
//     this.questionId,
//     this.question,
//     this.studentAnswer,
//     this.correctAnswer,
//     this.isCorrect,
//     this.explanation,
//     this.marks,
//     this.negativeMarks,
//     this.status,
//     this.answeredAt,
//   });

//   factory QuestionElement.fromJson(Map<String, dynamic> json) =>
//       QuestionElement(
//         questionId: json["questionId"],
//         question: json["question"] != null
//             ? QuestionQuestion.fromJson(json["question"])
//             : null,
//         studentAnswer: json["studentAnswer"],
//         correctAnswer: json["correctAnswer"],
//         isCorrect: json["isCorrect"],
//         explanation: json["explanation"],
//         marks: json["marks"],
//         negativeMarks: json["negativeMarks"],
//         status: json["status"],
//         answeredAt: json["answeredAt"] != null
//             ? DateTime.parse(json["answeredAt"])
//             : null,
//       );

//   Map<String, dynamic> toJson() => {
//     "questionId": questionId,
//     "question": question?.toJson(),
//     "studentAnswer": studentAnswer,
//     "correctAnswer": correctAnswer,
//     "isCorrect": isCorrect,
//     "explanation": explanation,
//     "marks": marks,
//     "negativeMarks": negativeMarks,
//     "status": status,
//     "answeredAt": answeredAt?.toIso8601String(),
//   };
// }

// class QuestionQuestion {
//   String? id;
//   String? questionText;
//   String? questionType;
//   List<ResultOption>? options;
//   String? correctAnswer;
//   String? explanation;
//   int? marks;
//   int? negativeMarks;
//   bool? isParent;
//   dynamic parentQuestionId;
//   dynamic childQuestions;
//   String? questionId;

//   QuestionQuestion({
//     this.id,
//     this.questionText,
//     this.questionType,
//     this.options,
//     this.correctAnswer,
//     this.explanation,
//     this.marks,
//     this.negativeMarks,
//     this.isParent,
//     this.parentQuestionId,
//     this.childQuestions,
//     this.questionId,
//   });

//   factory QuestionQuestion.fromJson(Map<String, dynamic> json) =>
//       QuestionQuestion(
//         id: json["_id"],
//         questionText: json["questionText"],
//         questionType: json["questionType"],
//         options: json["options"] == null
//             ? []
//             : List<ResultOption>.from(
//                 json["options"].map((x) => ResultOption.fromJson(x)),
//               ),
//         correctAnswer: json["correctAnswer"],
//         explanation: json["explanation"],
//         marks: json["marks"],
//         negativeMarks: json["negativeMarks"],
//         isParent: json["isParent"],
//         parentQuestionId: json["parentQuestionId"],
//         childQuestions: json["childQuestions"],
//         questionId: json["id"],
//       );

//   Map<String, dynamic> toJson() => {
//     "_id": id,
//     "questionText": questionText,
//     "questionType": questionType,
//     "options": options == null
//         ? []
//         : List<dynamic>.from(options!.map((x) => x.toJson())),
//     "correctAnswer": correctAnswer,
//     "explanation": explanation,
//     "marks": marks,
//     "negativeMarks": negativeMarks,
//     "isParent": isParent,
//     "parentQuestionId": parentQuestionId,
//     "childQuestions": childQuestions,
//     "id": questionId,
//   };
// }

// class ResultOption {
//   String? text;
//   bool? isCorrect;
//   String? id;

//   ResultOption({this.text, this.isCorrect, this.id});

//   factory ResultOption.fromJson(Map<String, dynamic> json) => ResultOption(
//     text: json["text"],
//     isCorrect: json["isCorrect"],
//     id: json["_id"],
//   );

//   Map<String, dynamic> toJson() => {
//     "text": text,
//     "isCorrect": isCorrect,
//     "_id": id,
//   };
// }

// class Leaderboard {
//   List<Top3>? top3;
//   int? myRank;
//   int? totalParticipants;

//   Leaderboard({this.top3, this.myRank, this.totalParticipants});

//   factory Leaderboard.fromJson(Map<String, dynamic> json) => Leaderboard(
//     top3: json["top3"] != null
//         ? List<Top3>.from(json["top3"].map((x) => Top3.fromJson(x)))
//         : [],
//     myRank: json["myRank"],
//     totalParticipants: json["totalParticipants"],
//   );

//   Map<String, dynamic> toJson() => {
//     "top3": top3?.map((x) => x.toJson()).toList(),
//     "myRank": myRank,
//     "totalParticipants": totalParticipants,
//   };
// }

// // ─────────────────────────────────────────

// class Top3 {
//   int? rank;
//   String? student;
//   String? name;
//   String? email;
//   int? score;
//   int? maxScore;
//   DateTime? completedAt;

//   Top3({
//     this.rank,
//     this.student,
//     this.name,
//     this.email,
//     this.score,
//     this.maxScore,
//     this.completedAt,
//   });

//   factory Top3.fromJson(Map<String, dynamic> json) => Top3(
//     rank: json["rank"],
//     student: json["student"],
//     name: json["name"],
//     email: json["email"],
//     score: json["score"],
//     maxScore: json["maxScore"],
//     completedAt: json["completedAt"] != null
//         ? DateTime.tryParse(json["completedAt"])
//         : null,
//   );

//   Map<String, dynamic> toJson() => {
//     "rank": rank,
//     "student": student,
//     "name": name,
//     "email": email,
//     "score": score,
//     "maxScore": maxScore,
//     "completedAt": completedAt?.toIso8601String(),
//   };
// }

// // ─────────────────────────────────────────

// class Results {
//   int? score;
//   int? maxScore;
//   int? earnedMarks;
//   int? negativeMarksDeducted;
//   int? totalNegativeMarksPossible;
//   int? correctCount;
//   int? wrongCount;
//   int? skippedCount;
//   int? percentile;
//   int? percentage;
//   int? rank;

//   Results({
//     this.score,
//     this.maxScore,
//     this.earnedMarks,
//     this.negativeMarksDeducted,
//     this.totalNegativeMarksPossible,
//     this.correctCount,
//     this.wrongCount,
//     this.skippedCount,
//     this.percentile,
//     this.percentage,
//     this.rank,
//   });

//   factory Results.fromJson(Map<String, dynamic> json) => Results(
//     score: json["score"],
//     maxScore: json["maxScore"],
//     earnedMarks: json["earnedMarks"],
//     negativeMarksDeducted: json["negativeMarksDeducted"],
//     totalNegativeMarksPossible: json["totalNegativeMarksPossible"],
//     correctCount: json["correctCount"],
//     wrongCount: json["wrongCount"],
//     skippedCount: json["skippedCount"],
//     percentile: json["percentile"],
//     percentage: json["percentage"],
//     rank: json["rank"],
//   );

//   Map<String, dynamic> toJson() => {
//     "score": score,
//     "maxScore": maxScore,
//     "earnedMarks": earnedMarks,
//     "negativeMarksDeducted": negativeMarksDeducted,
//     "totalNegativeMarksPossible": totalNegativeMarksPossible,
//     "correctCount": correctCount,
//     "wrongCount": wrongCount,
//     "skippedCount": skippedCount,
//     "percentile": percentile,
//     "percentage": percentage,
//     "rank": rank,
//   };
// }

// // ─────────────────────────────────────────

// class SectionWiseResult {
//   int? sectionIndex;
//   String? sectionName;
//   int? score;
//   int? maxScore;
//   int? earnedMarks;
//   int? negativeMarksDeducted;
//   int? correctCount;
//   int? wrongCount;
//   int? skippedCount;
//   int? totalQuestions;
//   int? percentage;

//   SectionWiseResult({
//     this.sectionIndex,
//     this.sectionName,
//     this.score,
//     this.maxScore,
//     this.earnedMarks,
//     this.negativeMarksDeducted,
//     this.correctCount,
//     this.wrongCount,
//     this.skippedCount,
//     this.totalQuestions,
//     this.percentage,
//   });

//   factory SectionWiseResult.fromJson(Map<String, dynamic> json) =>
//       SectionWiseResult(
//         sectionIndex: json["sectionIndex"],
//         sectionName: json["sectionName"],
//         score: json["score"],
//         maxScore: json["maxScore"],
//         earnedMarks: json["earnedMarks"],
//         negativeMarksDeducted: json["negativeMarksDeducted"],
//         correctCount: json["correctCount"],
//         wrongCount: json["wrongCount"],
//         skippedCount: json["skippedCount"],
//         totalQuestions: json["totalQuestions"],
//         percentage: json["percentage"],
//       );

//   Map<String, dynamic> toJson() => {
//     "sectionIndex": sectionIndex,
//     "sectionName": sectionName,
//     "score": score,
//     "maxScore": maxScore,
//     "earnedMarks": earnedMarks,
//     "negativeMarksDeducted": negativeMarksDeducted,
//     "correctCount": correctCount,
//     "wrongCount": wrongCount,
//     "skippedCount": skippedCount,
//     "totalQuestions": totalQuestions,
//     "percentage": percentage,
//   };
// }

// // ─────────────────────────────────────────

// class Session {
//   String? id;
//   Test? test;
//   DateTime? startTime;
//   DateTime? endTime;
//   DateTime? completedAt;
//   String? status;

//   Session({
//     this.id,
//     this.test,
//     this.startTime,
//     this.endTime,
//     this.completedAt,
//     this.status,
//   });

//   factory Session.fromJson(Map<String, dynamic> json) => Session(
//     id: json["id"],
//     test: json["test"] != null ? Test.fromJson(json["test"]) : null,
//     startTime: DateTime.tryParse(json["startTime"] ?? ""),
//     endTime: DateTime.tryParse(json["endTime"] ?? ""),
//     completedAt: DateTime.tryParse(json["completedAt"] ?? ""),
//     status: json["status"],
//   );

//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "test": test?.toJson(),
//     "startTime": startTime?.toIso8601String(),
//     "endTime": endTime?.toIso8601String(),
//     "completedAt": completedAt?.toIso8601String(),
//     "status": status,
//   };
// }

// // ─────────────────────────────────────────

// class Test {
//   String? id;
//   String? title;
//   String? description;
//   String? questionBank;
//   String? applicableFor;
//   int? durationMinutes;

//   Test({
//     this.id,
//     this.title,
//     this.description,
//     this.questionBank,
//     this.applicableFor,
//     this.durationMinutes,
//   });

//   factory Test.fromJson(Map<String, dynamic> json) => Test(
//     id: json["_id"],
//     title: json["title"],
//     description: json["description"],
//     questionBank: json["questionBank"],
//     applicableFor: json["applicableFor"],
//     durationMinutes: json["durationMinutes"],
//   );

//   Map<String, dynamic> toJson() => {
//     "_id": id,
//     "title": title,
//     "description": description,
//     "questionBank": questionBank,
//     "applicableFor": applicableFor,
//     "durationMinutes": durationMinutes,
//   };
// }

// // ─────────────────────────────────────────

// class Tournament {
//   String? tournamentId;
//   String? tournamentTitle;
//   String? stageName;
//   DateTime? stageEndTime;
//   bool? resultsReleased;
//   String? redirectSuggestion;

//   Tournament({
//     this.tournamentId,
//     this.tournamentTitle,
//     this.stageName,
//     this.stageEndTime,
//     this.resultsReleased,
//     this.redirectSuggestion,
//   });

//   factory Tournament.fromJson(Map<String, dynamic> json) => Tournament(
//     tournamentId: json["tournamentId"],
//     tournamentTitle: json["tournamentTitle"],
//     stageName: json["stageName"],
//     stageEndTime: DateTime.tryParse(json["stageEndTime"] ?? ""),
//     resultsReleased: json["resultsReleased"],
//     redirectSuggestion: json["redirectSuggestion"],
//   );

//   Map<String, dynamic> toJson() => {
//     "tournamentId": tournamentId,
//     "tournamentTitle": tournamentTitle,
//     "stageName": stageName,
//     "stageEndTime": stageEndTime?.toIso8601String(),
//     "resultsReleased": resultsReleased,
//     "redirectSuggestion": redirectSuggestion,
//   };
// }
