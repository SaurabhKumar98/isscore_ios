import 'dart:convert';

VisitQuestionsModels visitQuestionsModelsFromJson(String str) =>
    VisitQuestionsModels.fromJson(json.decode(str));

String visitQuestionsModelsToJson(VisitQuestionsModels data) =>
    json.encode(data.toJson());

class VisitQuestionsModels {
  bool? success;
  String? message;
  VisitQuestionsData? data;
  dynamic meta;

  VisitQuestionsModels({this.success, this.message, this.data, this.meta});

  factory VisitQuestionsModels.fromJson(Map<String, dynamic> json) =>
      VisitQuestionsModels(
        success: json["success"],
        message: json["message"],
        data: json["data"] != null
            ? VisitQuestionsData.fromJson(json["data"])
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

/// 🔥 RENAMED FROM Data → VisitQuestionsData
class VisitQuestionsData {
  Session? session;
  List<QuestionElement>? questions;
  Palette? palette;
  List<SectionConfig>? sectionConfig;
  List<SectionedQuestion>? sectionedQuestions;

  VisitQuestionsData({
    this.session,
    this.questions,
    this.palette,
    this.sectionConfig,
    this.sectionedQuestions,
  });

  factory VisitQuestionsData.fromJson(
    Map<String, dynamic> json,
  ) => VisitQuestionsData(
    session: json["session"] != null ? Session.fromJson(json["session"]) : null,
    questions: json["questions"] != null
        ? List<QuestionElement>.from(
            json["questions"].map((x) => QuestionElement.fromJson(x)),
          )
        : [],
    palette: json["palette"] != null ? Palette.fromJson(json["palette"]) : null,
    sectionConfig: json["sectionConfig"] != null
        ? List<SectionConfig>.from(
            json["sectionConfig"].map((x) => SectionConfig.fromJson(x)),
          )
        : [],
    sectionedQuestions: json["sectionedQuestions"] != null
        ? List<SectionedQuestion>.from(
            json["sectionedQuestions"].map(
              (x) => SectionedQuestion.fromJson(x),
            ),
          )
        : [],
  );

  Map<String, dynamic> toJson() => {
    "session": session?.toJson(),
    "questions": questions?.map((x) => x.toJson()).toList(),
    "palette": palette?.toJson(),
    "sectionConfig": sectionConfig?.map((x) => x.toJson()).toList(),
    "sectionedQuestions": sectionedQuestions?.map((x) => x.toJson()).toList(),
  };
}

class Palette {
  int? answered;
  int? skipped;
  int? markedForReview;
  int? notVisited;
  int? total;

  Palette({
    this.answered,
    this.skipped,
    this.markedForReview,
    this.notVisited,
    this.total,
  });

  factory Palette.fromJson(Map<String, dynamic> json) => Palette(
    answered: json["answered"],
    skipped: json["skipped"],
    markedForReview: json["markedForReview"],
    notVisited: json["notVisited"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "answered": answered,
    "skipped": skipped,
    "markedForReview": markedForReview,
    "notVisited": notVisited,
    "total": total,
  };
}

class QuestionElement {
  String? questionId;
  QuestionQuestion? question;
  dynamic answer;
  Status? status;
  dynamic answeredAt;
  int? remainingQuestionTimeSeconds; // ← ADD
  bool? questionTimeExpired;

  QuestionElement({
    this.questionId,
    this.question,
    this.answer,
    this.status,
    this.answeredAt,
    this.remainingQuestionTimeSeconds, // ← ADD
    this.questionTimeExpired,
  });

  factory QuestionElement.fromJson(Map<String, dynamic> json) =>
      QuestionElement(
        questionId: json["questionId"],
        question: json["question"] != null
            ? QuestionQuestion.fromJson(json["question"])
            : null,
        answer: json["answer"],
        status: statusValues.map[json["status"]],
        answeredAt: json["answeredAt"],
        remainingQuestionTimeSeconds: // ← ADD
        (json["remainingQuestionTimeSeconds"] as num?)
            ?.toInt(),
        questionTimeExpired: // ← ADD
            json["questionTimeExpired"] as bool?,
      );

  Map<String, dynamic> toJson() => {
    "questionId": questionId,
    "question": question?.toJson(),
    "answer": answer,
    "status": statusValues.reverse[status],
    "answeredAt": answeredAt,
    "remainingQuestionTimeSeconds": remainingQuestionTimeSeconds, // ← ADD
    "questionTimeExpired": questionTimeExpired,
  };
}

class QuestionQuestion {
  String? id;
  String? questionText;
  QuestionType? questionType;
  List<Option>? options;

  QuestionQuestion({
    this.id,
    this.questionText,
    this.questionType,
    this.options,
  });

  factory QuestionQuestion.fromJson(Map<String, dynamic> json) =>
      QuestionQuestion(
        id: json["_id"],
        questionText: json["questionText"],
        questionType: questionTypeValues.map[json["questionType"]],
        options: json["options"] != null
            ? List<Option>.from(json["options"].map((x) => Option.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "questionText": questionText,
    "questionType": questionTypeValues.reverse[questionType],
    "options": options?.map((x) => x.toJson()).toList(),
  };
}

class Option {
  String? text;
  bool? isCorrect;
  String? id;

  Option({this.text, this.isCorrect, this.id});

  factory Option.fromJson(Map<String, dynamic> json) =>
      Option(text: json["text"], isCorrect: json["isCorrect"], id: json["_id"]);

  Map<String, dynamic> toJson() => {
    "text": text,
    "isCorrect": isCorrect,
    "_id": id,
  };
}

class SectionConfig {
  int? index;
  int? id;
  String? name;

  SectionConfig({this.index, this.id, this.name});

  factory SectionConfig.fromJson(Map<String, dynamic> json) =>
      SectionConfig(index: json["index"], id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"index": index, "id": id, "name": name};
}

class SectionedQuestion {
  int? index;
  int? id;
  String? name;
  List<QuestionElement>? questions;

  SectionedQuestion({this.index, this.id, this.name, this.questions});

  factory SectionedQuestion.fromJson(Map<String, dynamic> json) =>
      SectionedQuestion(
        index: json["index"],
        id: json["id"],
        name: json["name"],
        questions: json["questions"] != null
            ? List<QuestionElement>.from(
                json["questions"].map((x) => QuestionElement.fromJson(x)),
              )
            : [],
      );

  Map<String, dynamic> toJson() => {
    "index": index,
    "id": id,
    "name": name,
    "questions": questions?.map((x) => x.toJson()).toList(),
  };
}

class Session {
  String? id;
  String? status;
  int? remainingTime; // ← ADD (milliseconds, matches server field)
  String? activeQuestionId; // ← ADD (useful for sync)

  Session({this.id, this.status, this.remainingTime, this.activeQuestionId});

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    id: json["id"],
    status: json["status"],
    remainingTime: (json["remainingTime"] as num?)?.toInt(), // ← ADD
    activeQuestionId: json["activeQuestionId"] as String?, // ← ADD
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "remainingTime": remainingTime,
    "activeQuestionId": activeQuestionId,
  };
}

/// ENUMS

enum Status { NOT_VISITED, SKIPPED }

final statusValues = EnumValues({
  "not_visited": Status.NOT_VISITED,
  "skipped": Status.SKIPPED,
});

enum QuestionType { MULTIPLE, SINGLE }

final questionTypeValues = EnumValues({
  "multiple": QuestionType.MULTIPLE,
  "single": QuestionType.SINGLE,
});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap = {};

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
