import 'dart:convert';

NeedToImproveModel needToImproveModelFromJson(String str) =>
    NeedToImproveModel.fromJson(json.decode(str));

String needToImproveModelToJson(NeedToImproveModel data) =>
    json.encode(data.toJson());

class NeedToImproveModel {
  bool? success;
  String? message;
  ImproveData? data;
  dynamic meta;

  NeedToImproveModel({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory NeedToImproveModel.fromJson(Map<String, dynamic>? json) =>
      NeedToImproveModel(
        success: json?["success"] ?? false,
        message: json?["message"] ?? "",
        data: json?["data"] != null
            ? ImproveData.fromJson(json?["data"])
            : null,
        meta: json?["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
        "meta": meta,
      };
}

class ImproveData {
  String? id;
  String? student;
  int? v;
  DateTime? createdAt;
  DateTime? lastComputedAt;
  DateTime? updatedAt;
  List<WeakCategory>? weakCategories;

  ImproveData({
    this.id,
    this.student,
    this.v,
    this.createdAt,
    this.lastComputedAt,
    this.updatedAt,
    this.weakCategories,
  });

  factory ImproveData.fromJson(Map<String, dynamic>? json) => ImproveData(
        id: json?["_id"],
        student: json?["student"],
        v: json?["__v"],
        createdAt: json?["createdAt"] != null
            ? DateTime.tryParse(json!["createdAt"])
            : null,
        lastComputedAt: json?["lastComputedAt"] != null
            ? DateTime.tryParse(json!["lastComputedAt"])
            : null,
        updatedAt: json?["updatedAt"] != null
            ? DateTime.tryParse(json!["updatedAt"])
            : null,
        weakCategories: json?["weakCategories"] != null
            ? List<WeakCategory>.from(
                json!["weakCategories"]
                    .map((x) => WeakCategory.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "student": student,
        "__v": v,
        "createdAt": createdAt?.toIso8601String(),
        "lastComputedAt": lastComputedAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "weakCategories":
            weakCategories?.map((x) => x.toJson()).toList() ?? [],
      };
}

class WeakCategory {
  Suggestions? suggestions;
  String? categoryId;
  String? categoryName;
  int? percentageScore;

  WeakCategory({
    this.suggestions,
    this.categoryId,
    this.categoryName,
    this.percentageScore,
  });

  factory WeakCategory.fromJson(Map<String, dynamic>? json) =>
      WeakCategory(
        suggestions: json?["suggestions"] != null
            ? Suggestions.fromJson(json?["suggestions"])
            : null,
        categoryId: json?["categoryId"],
        categoryName: json?["categoryName"],
        percentageScore: json?["percentageScore"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "suggestions": suggestions?.toJson(),
        "categoryId": categoryId,
        "categoryName": categoryName,
        "percentageScore": percentageScore,
      };
}

class Suggestions {
  List<PracticeTest>? practiceTests;
  List<StudyMaterial>? videos;
  List<StudyMaterial>? studyMaterials;
  List<dynamic>? teachers;

  Suggestions({
    this.practiceTests,
    this.videos,
    this.studyMaterials,
    this.teachers,
  });

  factory Suggestions.fromJson(Map<String, dynamic>? json) =>
      Suggestions(
        practiceTests: json?["practiceTests"] != null
            ? List<PracticeTest>.from(json!["practiceTests"]
                .map((x) => PracticeTest.fromJson(x)))
            : [],
        videos: json?["videos"] != null
            ? List<StudyMaterial>.from(
                json!["videos"].map((x) => StudyMaterial.fromJson(x)))
            : [],
        studyMaterials: json?["studyMaterials"] != null
            ? List<StudyMaterial>.from(json!["studyMaterials"]
                .map((x) => StudyMaterial.fromJson(x)))
            : [],
        teachers: json?["teachers"] ?? [],
      );

  Map<String, dynamic> toJson() => {
        "practiceTests":
            practiceTests?.map((x) => x.toJson()).toList() ?? [],
        "videos": videos?.map((x) => x.toJson()).toList() ?? [],
        "studyMaterials":
            studyMaterials?.map((x) => x.toJson()).toList() ?? [],
        "teachers": teachers ?? [],
      };
}

class PracticeTest {
  String? testId;
  String? title;
  int? price;
  bool? isPurchased;

  PracticeTest({
    this.testId,
    this.title,
    this.price,
    this.isPurchased,
  });

  factory PracticeTest.fromJson(Map<String, dynamic>? json) =>
      PracticeTest(
        testId: json?["testId"],
        title: json?["title"],
        price: json?["price"] ?? 0,
        isPurchased: json?["isPurchased"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "testId": testId,
        "title": title,
        "price": price,
        "isPurchased": isPurchased,
      };
}

class StudyMaterial {
  String? courseId;
  String? title;
  String? contentType;

  StudyMaterial({
    this.courseId,
    this.title,
    this.contentType,
  });

  factory StudyMaterial.fromJson(Map<String, dynamic>? json) =>
      StudyMaterial(
        courseId: json?["courseId"],
        title: json?["title"],
        contentType: json?["contentType"],
      );

  Map<String, dynamic> toJson() => {
        "courseId": courseId,
        "title": title,
        "contentType": contentType,
      };
}