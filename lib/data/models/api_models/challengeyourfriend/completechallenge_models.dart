// completechallenge_models.dart
// Matches GET /user/challenges/completed-challenges response

class CompletedChallengesModel {
  final bool? success;
  final String? message;
  final List<CompletedChallenge>? data;
  final CompletedMeta? meta;

  CompletedChallengesModel({this.success, this.message, this.data, this.meta});

  factory CompletedChallengesModel.fromJson(Map<String, dynamic> json) {
    return CompletedChallengesModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List?)
          ?.map((e) => CompletedChallenge.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      meta: json['meta'] != null
          ? CompletedMeta.fromJson(Map<String, dynamic>.from(json['meta'] as Map))
          : null,
    );
  }
}

class CompletedMeta {
  final int? page;
  final int? limit;
  final int? total;
  final int? pages;

  CompletedMeta({this.page, this.limit, this.total, this.pages});

  factory CompletedMeta.fromJson(Map<String, dynamic> json) {
    return CompletedMeta(
      page: json['page'] as int?,
      limit: json['limit'] as int?,
      total: json['total'] as int?,
      pages: json['pages'] as int?,
    );
  }
}

class CompletedChallenge {
  final String? challengeId;
  final String? challengeName; // "challengeName" from API = the room title
  final String? roomCode;
  final CompletedTest? test;
  final DateTime? completedAt;
  final int? myScore;
  final int? myRank;
  final int? highestScore;
  final int? totalParticipants;
  final List<CompletedParticipant>? participants;
  final List<LeaderboardEntry>? leaderboard;

  CompletedChallenge({
    this.challengeId,
    this.challengeName,
    this.roomCode,
    this.test,
    this.completedAt,
    this.myScore,
    this.myRank,
    this.highestScore,
    this.totalParticipants,
    this.participants,
    this.leaderboard,
  });

  // Convenience getters used by the UI
  String? get title => challengeName;
  int? get participantCount => totalParticipants;

  CompletedStats? get myStats => CompletedStats(
    myRank: myRank ?? 0,
    myScore: myScore ?? 0,
    highestScore: highestScore ?? 0,
  );

  factory CompletedChallenge.fromJson(Map<String, dynamic> json) {
    return CompletedChallenge(
      challengeId: json['challengeId']?.toString(),
      challengeName: json['challengeName']?.toString(),
      roomCode: json['roomCode']?.toString(),
      test: json['test'] != null
          ? CompletedTest.fromJson(Map<String, dynamic>.from(json['test'] as Map))
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
      myScore: (json['myScore'] as num?)?.toInt(),
      myRank: (json['myRank'] as num?)?.toInt(),
      highestScore: (json['highestScore'] as num?)?.toInt(),
      totalParticipants: (json['totalParticipants'] as num?)?.toInt(),
      participants: (json['participants'] as List?)
          ?.map((e) => CompletedParticipant.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      leaderboard: (json['leaderboard'] as List?)
          ?.map((e) => LeaderboardEntry.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class CompletedTest {
  final String? id;
  final String? title;
  final int? durationMinutes;

  CompletedTest({this.id, this.title, this.durationMinutes});

  factory CompletedTest.fromJson(Map<String, dynamic> json) {
    return CompletedTest(
      id: (json['_id'] ?? json['id'])?.toString(),
      title: json['title']?.toString(),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
    );
  }
}

class CompletedParticipant {
  final String? studentId;
  final String? name;
  final String? email;
  final int? score;
  final int? maxScore;
  final DateTime? completedAt;
  final int? rank;
  final DateTime? joinedAt;

  CompletedParticipant({
    this.studentId,
    this.name,
    this.email,
    this.score,
    this.maxScore,
    this.completedAt,
    this.rank,
    this.joinedAt,
  });

  factory CompletedParticipant.fromJson(Map<String, dynamic> json) {
    return CompletedParticipant(
      studentId: json['studentId']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      score: (json['score'] as num?)?.toInt(),
      maxScore: (json['maxScore'] as num?)?.toInt(),
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'].toString()) : null,
      rank: (json['rank'] as num?)?.toInt(),
      joinedAt: json['joinedAt'] != null ? DateTime.tryParse(json['joinedAt'].toString()) : null,
    );
  }
}

class LeaderboardEntry {
  final int? rank;
  final String? studentId;
  final String? name;
  final String? email;
  final int? score;
  final int? maxScore;
  final DateTime? completedAt;

  LeaderboardEntry({
    this.rank,
    this.studentId,
    this.name,
    this.email,
    this.score,
    this.maxScore,
    this.completedAt,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: (json['rank'] as num?)?.toInt(),
      studentId: json['studentId']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      score: (json['score'] as num?)?.toInt(),
      maxScore: (json['maxScore'] as num?)?.toInt(),
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'].toString()) : null,
    );
  }
}

/// Convenience wrapper used by the UI (derived from CompletedChallenge fields)
class CompletedStats {
  final int myRank;
  final int myScore;
  final int highestScore;

  CompletedStats({
    required this.myRank,
    required this.myScore,
    required this.highestScore,
  });
}