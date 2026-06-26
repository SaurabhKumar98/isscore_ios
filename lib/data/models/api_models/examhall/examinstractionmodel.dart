import 'dart:convert';

Examinstructionsmodel examinstructionsmodelFromJson(String str) =>
    Examinstructionsmodel.fromJson(json.decode(str));

String examinstructionsmodelToJson(Examinstructionsmodel data) =>
    json.encode(data.toJson());

class Examinstructionsmodel {
  final bool success;
  final String message;
  final Data? data;
  final dynamic meta;

  Examinstructionsmodel({
    required this.success,
    required this.message,
    this.data,
    this.meta,
  });

  factory Examinstructionsmodel.fromJson(Map<String, dynamic> json) =>
      Examinstructionsmodel(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] != null ? Data.fromJson(json["data"]) : null,
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
        "meta": meta,
      };
}

class Data {
  final Test? test;
  final Stats? stats;
  final Sections? sections;
  final Session? session;
  final Eligibility? eligibility;
  final Instructions? instructions;

  Data({
    this.test,
    this.stats,
    this.sections,
    this.session,
    this.eligibility,
    this.instructions,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        test: json["test"] != null ? Test.fromJson(json["test"]) : null,
        stats: json["stats"] != null ? Stats.fromJson(json["stats"]) : null,
        sections:
            json["sections"] != null ? Sections.fromJson(json["sections"]) : null,
        session:
            json["session"] != null ? Session.fromJson(json["session"]) : null,
        eligibility: json["eligibility"] != null
            ? Eligibility.fromJson(json["eligibility"])
            : null,
        instructions: json["instructions"] != null
            ? Instructions.fromJson(json["instructions"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "test": test?.toJson(),
        "stats": stats?.toJson(),
        "sections": sections?.toJson(),
        "session": session?.toJson(),
        "eligibility": eligibility?.toJson(),
        "instructions": instructions?.toJson(),
      };
}

class Eligibility {
  final bool canStart;
  final String? blockReason;
  final String accessType;

  Eligibility({
    required this.canStart,
    this.blockReason,
    required this.accessType,
  });

  factory Eligibility.fromJson(Map<String, dynamic> json) => Eligibility(
        canStart: json["canStart"] ?? false,
        blockReason: json["blockReason"]?.toString(),
        accessType: json["accessType"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "canStart": canStart,
        "blockReason": blockReason,
        "accessType": accessType,
      };
}

class Instructions {
  final String proctoringText;
  final List<String> points;

  Instructions({
    required this.proctoringText,
    required this.points,
  });

  factory Instructions.fromJson(Map<String, dynamic> json) => Instructions(
        proctoringText: json["proctoringText"] ?? "",
        points: (json["points"] as List?)
                ?.map((x) => x?.toString() ?? "")
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        "proctoringText": proctoringText,
        "points": points,
      };
}

class Sections {
  final bool sectionWiseEnabled;
  final bool useSectionWiseDifficulty;
  final String overallDifficulty;
  final List<SectionItem> items;

  Sections({
    required this.sectionWiseEnabled,
    required this.useSectionWiseDifficulty,
    required this.overallDifficulty,
    required this.items,
  });

  factory Sections.fromJson(Map<String, dynamic> json) => Sections(
        sectionWiseEnabled: json["sectionWiseEnabled"] ?? false,
        useSectionWiseDifficulty:
            json["useSectionWiseDifficulty"] ?? false,
        overallDifficulty: json["overallDifficulty"] ?? "",
        items: (json["items"] as List?)
                ?.map((x) => SectionItem.fromJson(x))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        "sectionWiseEnabled": sectionWiseEnabled,
        "useSectionWiseDifficulty": useSectionWiseDifficulty,
        "overallDifficulty": overallDifficulty,
        "items": items.map((e) => e.toJson()).toList(),
      };
}

class SectionItem {
  final int id;
  final String name;
  final int count;
  final String difficulty;

  SectionItem({
    required this.id,
    required this.name,
    required this.count,
    required this.difficulty,
  });

  factory SectionItem.fromJson(Map<String, dynamic> json) => SectionItem(
        id: json["id"] is int
            ? json["id"]
            : int.tryParse(json["id"].toString()) ?? 0,
        name: json["name"] ?? "",
        count: json["count"] ?? 0,
        difficulty: json["difficulty"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "count": count,
        "difficulty": difficulty,
      };
}

class Session {
  final String? inProgressSessionId;
  final String pausedSessionId;
  final bool hasResumableSession;
  final String nextAction;

  Session({
    this.inProgressSessionId,
    required this.pausedSessionId,
    required this.hasResumableSession,
    required this.nextAction,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        inProgressSessionId: json["inProgressSessionId"]?.toString(),
        pausedSessionId: json["pausedSessionId"] ?? "",
        hasResumableSession: json["hasResumableSession"] ?? false,
        nextAction: json["nextAction"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "inProgressSessionId": inProgressSessionId,
        "pausedSessionId": pausedSessionId,
        "hasResumableSession": hasResumableSession,
        "nextAction": nextAction,
      };
}

class Stats {
  final int totalQuestions;
  final int totalMarks;
  final double totalNegativeMarks;
  final int averageTimePerQuestionSeconds;

  Stats({
    required this.totalQuestions,
    required this.totalMarks,
    required this.totalNegativeMarks,
    required this.averageTimePerQuestionSeconds,
  });

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
        totalQuestions: json["totalQuestions"] ?? 0,
        totalMarks: json["totalMarks"] ?? 0,
        totalNegativeMarks:
            (json["totalNegativeMarks"] as num?)?.toDouble() ?? 0.0,
        averageTimePerQuestionSeconds:
            json["averageTimePerQuestionSeconds"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "totalQuestions": totalQuestions,
        "totalMarks": totalMarks,
        "totalNegativeMarks": totalNegativeMarks,
        "averageTimePerQuestionSeconds":
            averageTimePerQuestionSeconds,
      };
}

class Test {
  final String id;
  final String title;
  final String description;
  final dynamic imageUrl;
  final String applicableFor;
  final bool isFree;
  final int durationMinutes;
  final String proctoringInstructions;
  final String questionBankName;
  final List<Category> categories;

  Test({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.applicableFor,
    required this.isFree,
    required this.durationMinutes,
    required this.proctoringInstructions,
    required this.questionBankName,
    required this.categories,
  });

  factory Test.fromJson(Map<String, dynamic> json) => Test(
        id: json["id"] ?? "",
        title: json["title"] ?? "",
        description: json["description"] ?? "",
        imageUrl: json["imageUrl"],
        applicableFor: json["applicableFor"] ?? "",
        isFree: json["isFree"] ?? false,
        durationMinutes: json["durationMinutes"] ?? 0,
        proctoringInstructions:
            json["proctoringInstructions"] ?? "",
        questionBankName: json["questionBankName"] ?? "",
        categories: (json["categories"] as List?)
                ?.map((x) => Category.fromJson(x))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "imageUrl": imageUrl,
        "applicableFor": applicableFor,
        "isFree": isFree,
        "durationMinutes": durationMinutes,
        "proctoringInstructions": proctoringInstructions,
        "questionBankName": questionBankName,
        "categories": categories.map((e) => e.toJson()).toList(),
      };
}

class Category {
  final String id;
  final String name;
  final List<String> fullPath;
  final String fullPathText;

  Category({
    required this.id,
    required this.name,
    required this.fullPath,
    required this.fullPathText,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"] ?? "",
        name: json["name"] ?? "",
        fullPath: (json["fullPath"] as List?)
                ?.map((x) => x?.toString() ?? "")
                .toList() ??
            [],
        fullPathText: json["fullPathText"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "fullPath": fullPath,
        "fullPathText": fullPathText,
      };
}