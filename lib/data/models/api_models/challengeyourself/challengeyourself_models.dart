// ─────────────────────────────────────────────────────────────────────────────
// challengeyourself_models.dart
// ─────────────────────────────────────────────────────────────────────────────

// ── Top-level response ────────────────────────────────────────────────────────

class ChallengeYourselfModel {
  final bool? success;
  final String? message;
  final ChallengeYourselfData? data;
  final dynamic meta;

  ChallengeYourselfModel({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory ChallengeYourselfModel.fromJson(Map<String, dynamic> json) {
    return ChallengeYourselfModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? ChallengeYourselfData.fromJson(
              json['data'] as Map<String, dynamic>)
          : null,
      meta: json['meta'],
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.toJson(),
        'meta': meta,
      };
}

// ── data wrapper ──────────────────────────────────────────────────────────────

class ChallengeYourselfData {
  final List<Stage> stages;
  final List<CategoryNode> categories;

  ChallengeYourselfData({
    required this.stages,
    required this.categories,
  });

  factory ChallengeYourselfData.fromJson(Map<String, dynamic> json) {
    return ChallengeYourselfData(
      stages: (json['stages'] as List<dynamic>?)
              ?.map((e) => Stage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => CategoryNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'stages': stages.map((e) => e.toJson()).toList(),
        'categories': categories.map((e) => e.toJson()).toList(),
      };
}

// ── Stage ─────────────────────────────────────────────────────────────────────

class Stage {
  final String? name;
  final int? totalLevels;
  final String? stageId;
  final List<Level> levels;

  Stage({
    this.name,
    this.totalLevels,
    this.stageId,
    required this.levels,
  });

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      name: json['name'] as String?,
      totalLevels: json['totalLevels'] as int?,
      stageId: json['stageId'] as String?,
      levels: (json['levels'] as List<dynamic>?)
              ?.map((e) => Level.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'totalLevels': totalLevels,
        'stageId': stageId,
        'levels': levels.map((e) => e.toJson()).toList(),
      };
}

// ── Level ─────────────────────────────────────────────────────────────────────

class Level {
  final int? level;
  final ChallengeTest? test;
  final bool? unlocked;
  final bool? completedWithFullMarks;
  final bool? hasCompletedAttempt;
  final bool? isPurchased;
  final num? passingPercentage;
  final String? difficulty;

  Level({
    this.level,
    this.test,
    this.unlocked,
    this.completedWithFullMarks,
    this.hasCompletedAttempt,
    this.isPurchased,
    this.passingPercentage,
    this.difficulty,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      level: json['level'] as int?,
      test: json['test'] != null
          ? ChallengeTest.fromJson(json['test'] as Map<String, dynamic>)
          : null,
      unlocked: json['unlocked'] as bool?,
      completedWithFullMarks: json['completedWithFullMarks'] as bool?,
      hasCompletedAttempt: json['hasCompletedAttempt'] as bool?,
      isPurchased: json['isPurchased'] as bool?,
      passingPercentage: json['passingPercentage'] as num?,
      difficulty: json['difficulty'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'level': level,
        'test': test?.toJson(),
        'unlocked': unlocked,
        'completedWithFullMarks': completedWithFullMarks,
        'hasCompletedAttempt': hasCompletedAttempt,
        'isPurchased': isPurchased,
        'passingPercentage': passingPercentage,
        'difficulty': difficulty,
      };
}

// ── ChallengeTest ─────────────────────────────────────────────────────────────

class ChallengeTest {
  final String? id;
  final String? title;
  final String? description;
  final String? imageUrl;
  final QuestionBank? questionBank;
  final String? categoryId;
  final num? price;
  final String? applicableFor;
  final int? durationMinutes;
  final bool? isPublished;
  final int? rewardPoints;
  final int? gamificationLevel;
  final num? passingPercentage;
  final String? proctoringInstructions;
  final String? createdAt;
  final String? updatedAt;

  ChallengeTest({
    this.id,
    this.title,
    this.description,
    this.imageUrl,
    this.questionBank,
    this.categoryId,
    this.price,
    this.applicableFor,
    this.durationMinutes,
    this.isPublished,
    this.rewardPoints,
    this.gamificationLevel,
    this.passingPercentage,
    this.proctoringInstructions,
    this.createdAt,
    this.updatedAt,
  });

  factory ChallengeTest.fromJson(Map<String, dynamic> json) {
    return ChallengeTest(
      id: (json['_id'] ?? json['id']) as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      questionBank: json['questionBank'] != null
          ? QuestionBank.fromJson(json['questionBank'] as Map<String, dynamic>)
          : null,
      categoryId: json['categoryId'] as String?,
      price: json['price'] as num?,
      applicableFor: json['applicableFor'] as String?,
      durationMinutes: json['durationMinutes'] as int?,
      isPublished: json['isPublished'] as bool?,
      rewardPoints: json['rewardPoints'] as int?,
      gamificationLevel: json['gamificationLevel'] as int?,
      passingPercentage: json['passingPercentage'] as num?,
      proctoringInstructions: json['proctoringInstructions'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'questionBank': questionBank?.toJson(),
        'categoryId': categoryId,
        'price': price,
        'applicableFor': applicableFor,
        'durationMinutes': durationMinutes,
        'isPublished': isPublished,
        'rewardPoints': rewardPoints,
        'gamificationLevel': gamificationLevel,
        'passingPercentage': passingPercentage,
        'proctoringInstructions': proctoringInstructions,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

// ── QuestionBank ──────────────────────────────────────────────────────────────

class QuestionBank {
  final String? id;
  final String? name;
  final int? totalQuestions;
  final int? totalMarks;
  final List<QBCategory> categories;

  QuestionBank({
    this.id,
    this.name,
    this.totalQuestions,
    this.totalMarks,
    required this.categories,
  });

  factory QuestionBank.fromJson(Map<String, dynamic> json) {
    return QuestionBank(
      id: (json['_id'] ?? json['id']) as String?,
      name: json['name'] as String?,
      totalQuestions: json['totalQuestions'] as int?,
      totalMarks: json['totalMarks'] as int?,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => QBCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'totalQuestions': totalQuestions,
        'totalMarks': totalMarks,
        'categories': categories.map((e) => e.toJson()).toList(),
      };
}

// ── QBCategory (category inside a question bank) ──────────────────────────────

class QBCategory {
  final String? id;
  final String? name;
  final String? kind;

  QBCategory({this.id, this.name, this.kind});

  factory QBCategory.fromJson(Map<String, dynamic> json) {
    return QBCategory(
      id: (json['_id'] ?? json['id']) as String?,
      name: json['name'] as String?,
      kind: json['kind'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'_id': id, 'name': name, 'kind': kind};
}

// ── CategoryNode (gamification category tree) ─────────────────────────────────

class CategoryNode {
  final String? id;
  final String? name;
  final CategoryParent? parent;
  final int? order;
  final bool? isActive;
  final String? rootType;
  final String? kind;
  final String? createdAt;
  final String? updatedAt;
  final List<CategoryNode> children;

  CategoryNode({
    this.id,
    this.name,
    this.parent,
    this.order,
    this.isActive,
    this.rootType,
    this.kind,
    this.createdAt,
    this.updatedAt,
    required this.children,
  });

  factory CategoryNode.fromJson(Map<String, dynamic> json) {
    return CategoryNode(
      id: (json['_id'] ?? json['id']) as String?,
      name: json['name'] as String?,
      parent: json['parent'] != null
          ? CategoryParent.fromJson(json['parent'] as Map<String, dynamic>)
          : null,
      order: json['order'] as int?,
      isActive: json['isActive'] as bool?,
      rootType: json['rootType'] as String?,
      kind: json['kind'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => CategoryNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'parent': parent?.toJson(),
        'order': order,
        'isActive': isActive,
        'rootType': rootType,
        'kind': kind,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'children': children.map((e) => e.toJson()).toList(),
      };
      List<String> get allIds {
  final ids = <String>[];
  if (id != null && id!.isNotEmpty) ids.add(id!);
  for (final child in children) {
    ids.addAll(child.allIds);
  }
  return ids;
}
}

// ── CategoryParent ────────────────────────────────────────────────────────────

class CategoryParent {
  final String? id;
  final String? name;
  final int? order;
  final String? kind;

  CategoryParent({this.id, this.name, this.order, this.kind});

  factory CategoryParent.fromJson(Map<String, dynamic> json) {
    return CategoryParent(
      id: (json['_id'] ?? json['id']) as String?,
      name: json['name'] as String?,
      order: json['order'] as int?,
      kind: json['kind'] as String?,
    );
  }

  Map<String, dynamic> toJson() =>
      {'_id': id, 'name': name, 'order': order, 'kind': kind};
      
}