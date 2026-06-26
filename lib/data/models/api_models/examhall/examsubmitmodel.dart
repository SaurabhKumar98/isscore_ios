// import 'dart:convert';

// Examsubmitmodel examsubmitmodelFromJson(String str) =>
//     Examsubmitmodel.fromJson(json.decode(str));

// String examsubmitmodelToJson(Examsubmitmodel data) =>
//     json.encode(data.toJson());

// class Examsubmitmodel {
//   bool? success;
//   String? message;
//   Data? data;
//   dynamic meta;

//   Examsubmitmodel({
//     this.success,
//     this.message,
//     this.data,
//     this.meta,
//   });

//   factory Examsubmitmodel.fromJson(Map<String, dynamic> json) =>
//       Examsubmitmodel(
//         success: json["success"],
//         message: json["message"],
//         data: json["data"] != null ? Data.fromJson(json["data"]) : null,
//         meta: json["meta"],
//       );

//   Map<String, dynamic> toJson() => {
//         "success": success,
//         "message": message,
//         "data": data?.toJson(),
//         "meta": meta,
//       };
// }

// // ─────────────────────────────────────────────

// class Data {
//   Session? session;
//   Results? results;
//   Leaderboard? leaderboard;
//   Tournament? tournament;
//   List<dynamic>? sectionWiseResults;
//   List<dynamic>? questions;
//   String? message;

//   Data({
//     this.session,
//     this.results,
//     this.leaderboard,
//     this.tournament,
//     this.sectionWiseResults,
//     this.questions,
//     this.message,
//   });

//   factory Data.fromJson(Map<String, dynamic> json) => Data(
//         session:
//             json["session"] != null ? Session.fromJson(json["session"]) : null,
//         results:
//             json["results"] != null ? Results.fromJson(json["results"]) : null,
//         leaderboard: json["leaderboard"] != null
//             ? Leaderboard.fromJson(json["leaderboard"])
//             : null,
//         tournament: json["tournament"] != null
//             ? Tournament.fromJson(json["tournament"])
//             : null,
//         sectionWiseResults: json["sectionWiseResults"] != null
//             ? List<dynamic>.from(json["sectionWiseResults"].map((x) => x))
//             : [],
//         questions: json["questions"] != null
//             ? List<dynamic>.from(json["questions"].map((x) => x))
//             : [],
//         message: json["message"],
//       );

//   Map<String, dynamic> toJson() => {
//         "session": session?.toJson(),
//         "results": results?.toJson(),
//         "leaderboard": leaderboard?.toJson(),
//         "tournament": tournament?.toJson(),
//         "sectionWiseResults":
//             sectionWiseResults?.map((x) => x).toList(),
//         "questions": questions?.map((x) => x).toList(),
//         "message": message,
//       };
// }

// // ─────────────────────────────────────────────

// class Leaderboard {
//   bool? resultsHeldUntilStageEnd;
//   DateTime? stageEndTime;
//   List<dynamic>? top3;
//   dynamic myRank;
//   int? totalParticipants;

//   Leaderboard({
//     this.resultsHeldUntilStageEnd,
//     this.stageEndTime,
//     this.top3,
//     this.myRank,
//     this.totalParticipants,
//   });

//   factory Leaderboard.fromJson(Map<String, dynamic> json) => Leaderboard(
//         resultsHeldUntilStageEnd: json["resultsHeldUntilStageEnd"],
//         stageEndTime: json["stageEndTime"] != null
//             ? DateTime.tryParse(json["stageEndTime"])
//             : null,
//         top3: json["top3"] != null
//             ? List<dynamic>.from(json["top3"].map((x) => x))
//             : [],
//         myRank: json["myRank"],
//         totalParticipants: json["totalParticipants"],
//       );

//   Map<String, dynamic> toJson() => {
//         "resultsHeldUntilStageEnd": resultsHeldUntilStageEnd,
//         "stageEndTime": stageEndTime?.toIso8601String(),
//         "top3": top3?.map((x) => x).toList(),
//         "myRank": myRank,
//         "totalParticipants": totalParticipants,
//       };
// }

// // ─────────────────────────────────────────────

// class Results {
//   int? score;
//   int? maxScore;
//   int? correctCount;
//   int? wrongCount;
//   int? skippedCount;
//   int? percentile;
//   int? percentage;
//   bool? resultsHiddenUntilStageEnd;

//   Results({
//     this.score,
//     this.maxScore,
//     this.correctCount,
//     this.wrongCount,
//     this.skippedCount,
//     this.percentile,
//     this.percentage,
//     this.resultsHiddenUntilStageEnd,
//   });

//   factory Results.fromJson(Map<String, dynamic> json) => Results(
//         score: json["score"],
//         maxScore: json["maxScore"],
//         correctCount: json["correctCount"],
//         wrongCount: json["wrongCount"],
//         skippedCount: json["skippedCount"],
//         percentile: json["percentile"],
//         percentage: json["percentage"],
//         resultsHiddenUntilStageEnd: json["resultsHiddenUntilStageEnd"],
//       );

//   Map<String, dynamic> toJson() => {
//         "score": score,
//         "maxScore": maxScore,
//         "correctCount": correctCount,
//         "wrongCount": wrongCount,
//         "skippedCount": skippedCount,
//         "percentile": percentile,
//         "percentage": percentage,
//         "resultsHiddenUntilStageEnd": resultsHiddenUntilStageEnd,
//       };
// }

// // ─────────────────────────────────────────────

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
//         id: json["id"],
//         test: json["test"] != null ? Test.fromJson(json["test"]) : null,
//         startTime: json["startTime"] != null
//             ? DateTime.tryParse(json["startTime"])
//             : null,
//         endTime: json["endTime"] != null
//             ? DateTime.tryParse(json["endTime"])
//             : null,
//         completedAt: json["completedAt"] != null
//             ? DateTime.tryParse(json["completedAt"])
//             : null,
//         status: json["status"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "test": test?.toJson(),
//         "startTime": startTime?.toIso8601String(),
//         "endTime": endTime?.toIso8601String(),
//         "completedAt": completedAt?.toIso8601String(),
//         "status": status,
//       };
// }

// // ─────────────────────────────────────────────

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
//         id: json["_id"],
//         title: json["title"],
//         description: json["description"],
//         questionBank: json["questionBank"],
//         applicableFor: json["applicableFor"],
//         durationMinutes: json["durationMinutes"],
//       );

//   Map<String, dynamic> toJson() => {
//         "_id": id,
//         "title": title,
//         "description": description,
//         "questionBank": questionBank,
//         "applicableFor": applicableFor,
//         "durationMinutes": durationMinutes,
//       };
// }

// // ─────────────────────────────────────────────

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
//         tournamentId: json["tournamentId"],
//         tournamentTitle: json["tournamentTitle"],
//         stageName: json["stageName"],
//         stageEndTime: json["stageEndTime"] != null
//             ? DateTime.tryParse(json["stageEndTime"])
//             : null,
//         resultsReleased: json["resultsReleased"],
//         redirectSuggestion: json["redirectSuggestion"],
//       );

//   Map<String, dynamic> toJson() => {
//         "tournamentId": tournamentId,
//         "tournamentTitle": tournamentTitle,
//         "stageName": stageName,
//         "stageEndTime": stageEndTime?.toIso8601String(),
//         "resultsReleased": resultsReleased,
//         "redirectSuggestion": redirectSuggestion,
//       };
// }