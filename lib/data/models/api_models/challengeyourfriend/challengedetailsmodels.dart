// completedchallenge_detail_model.dart
// Matches GET /user/challenges/completed-challenges/:challengeId

class CompletedChallengeDetailModel {
  final bool? success;
  final String? message;
  final CompletedChallengeDetail? data;

  CompletedChallengeDetailModel({this.success, this.message, this.data});

  factory CompletedChallengeDetailModel.fromJson(Map<String, dynamic> json) {
    return CompletedChallengeDetailModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? CompletedChallengeDetail.fromJson(
              Map<String, dynamic>.from(json['data'] as Map))
          : null,
    );
  }
}

class CompletedChallengeDetail {
  final String? challengeId;
  final String? challengeName;
  final String? description;
  final String? roomCode;
  final String? roomStatus;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DetailTest? test;
  final DetailCreatedBy? createdBy;
  final int? myScore;
  final int? myRank;
  final int? highestScore;
  final int? totalParticipants;
  final List<DetailParticipant>? participants;
  final List<DetailLeaderboardEntry>? leaderboard;

  CompletedChallengeDetail({
    this.challengeId,
    this.challengeName,
    this.description,
    this.roomCode,
    this.roomStatus,
    this.startedAt,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
    this.test,
    this.createdBy,
    this.myScore,
    this.myRank,
    this.highestScore,
    this.totalParticipants,
    this.participants,
    this.leaderboard,
  });

  factory CompletedChallengeDetail.fromJson(Map<String, dynamic> json) {
    return CompletedChallengeDetail(
      challengeId: json['challengeId']?.toString(),
      challengeName: json['challengeName']?.toString(),
      description: json['description']?.toString(),
      roomCode: json['roomCode']?.toString(),
      roomStatus: json['roomStatus']?.toString(),
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'].toString())
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      test: json['test'] != null
          ? DetailTest.fromJson(Map<String, dynamic>.from(json['test'] as Map))
          : null,
      createdBy: json['createdBy'] != null
          ? DetailCreatedBy.fromJson(
              Map<String, dynamic>.from(json['createdBy'] as Map))
          : null,
      myScore: (json['myScore'] as num?)?.toInt(),
      myRank: (json['myRank'] as num?)?.toInt(),
      highestScore: (json['highestScore'] as num?)?.toInt(),
      totalParticipants: (json['totalParticipants'] as num?)?.toInt(),
      participants: (json['participants'] as List?)
          ?.map((e) => DetailParticipant.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
      leaderboard: (json['leaderboard'] as List?)
          ?.map((e) => DetailLeaderboardEntry.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class DetailTest {
  final String? id;
  final String? title;
  final String? description;
  final String? applicableFor;
  final int? durationMinutes;
  final bool? isPublished;

  DetailTest({
    this.id,
    this.title,
    this.description,
    this.applicableFor,
    this.durationMinutes,
    this.isPublished,
  });

  factory DetailTest.fromJson(Map<String, dynamic> json) {
    return DetailTest(
      id: (json['_id'] ?? json['id'])?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      applicableFor: json['applicableFor']?.toString(),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      isPublished: json['isPublished'] as bool?,
    );
  }
}

class DetailCreatedBy {
  final String? id;
  final String? name;
  final String? email;

  DetailCreatedBy({this.id, this.name, this.email});

  factory DetailCreatedBy.fromJson(Map<String, dynamic> json) {
    return DetailCreatedBy(
      id: (json['_id'] ?? json['id'])?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
    );
  }
}

class DetailParticipant {
  final String? studentId;
  final String? name;
  final String? email;
  final int? score;
  final int? maxScore;
  final DateTime? completedAt;
  final int? rank;
  final DateTime? joinedAt;

  DetailParticipant({
    this.studentId,
    this.name,
    this.email,
    this.score,
    this.maxScore,
    this.completedAt,
    this.rank,
    this.joinedAt,
  });

  factory DetailParticipant.fromJson(Map<String, dynamic> json) {
    return DetailParticipant(
      studentId: json['studentId']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      score: (json['score'] as num?)?.toInt(),
      maxScore: (json['maxScore'] as num?)?.toInt(),
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
      rank: (json['rank'] as num?)?.toInt(),
      joinedAt: json['joinedAt'] != null
          ? DateTime.tryParse(json['joinedAt'].toString())
          : null,
    );
  }
}

class DetailLeaderboardEntry {
  final int? rank;
  final String? studentId;
  final String? name;
  final String? email;
  final int? score;
  final int? maxScore;
  final DateTime? completedAt;

  DetailLeaderboardEntry({
    this.rank,
    this.studentId,
    this.name,
    this.email,
    this.score,
    this.maxScore,
    this.completedAt,
  });

  factory DetailLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return DetailLeaderboardEntry(
      rank: (json['rank'] as num?)?.toInt(),
      studentId: json['studentId']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      score: (json['score'] as num?)?.toInt(),
      maxScore: (json['maxScore'] as num?)?.toInt(),
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
    );
  }
}