import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/challengeyourfriend/category_models.dart';
import 'package:firstedu/data/models/api_models/challengeyourfriend/challengedetailsmodels.dart';
import 'package:firstedu/data/models/api_models/challengeyourfriend/challengeroom_models.dart';
import 'package:firstedu/data/models/api_models/challengeyourfriend/challengeyourfriend_models.dart';
import 'package:firstedu/data/models/api_models/challengeyourfriend/completechallenge_models.dart';
import 'package:firstedu/data/models/api_models/challengeyourfriend/createchallenge_models.dart';
import 'package:firstedu/data/models/api_models/challengeyourfriend/deletechallenge_models.dart';
import 'package:firstedu/data/models/api_models/challengeyourfriend/joinroomchallenge_models.dart';
import 'package:firstedu/data/models/api_models/challengeyourfriend/startchallenge_models.dart';

class ChallengeRepo {
  final ApiClient _apiClient;
  ChallengeRepo(this._apiClient);

  // ── GET /challenges/tests/challenge-yourfriends ───────────────────
  Future<ChallengeYourFriendModel> getChallenges() async {
    try {
      final res = await _apiClient.get(
        '${ApiEndpoint.appBaseUrl}/challenges/tests/challenge-yourfriends',
      );
      final data = res.data;
      if (data == null || data is! Map<String, dynamic>) {
        throw AppException('Invalid response format');
      }
      return ChallengeYourFriendModel.fromJson(data);
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Failed to fetch challenges');
    }
  }

  // ── GET /challenges ───────────────────────────────────────────────
  Future<ChallengeFriendJoinModel> getChallengeRooms({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _apiClient.get(
        '${ApiEndpoint.appBaseUrl}/challenges?page=$page&limit=$limit',
      );
      final data = res.data;
      if (data == null || data is! Map<String, dynamic>) {
        throw AppException('Invalid response format');
      }
      return ChallengeFriendJoinModel.fromJson(data);
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Failed to fetch challenge rooms');
    }
  }

  // ── POST /challenges ──────────────────────────────────────────────
  Future<CreateChallengeModel> createRoom({
    required String title,
    required String description,
    required String testId,
  }) async {
    try {
      final res = await _apiClient.post(
        '${ApiEndpoint.appBaseUrl}/challenges',
        data: {'title': title, 'description': description, 'testId': testId},
      );
      final data = res.data;
      if (data == null || data is! Map<String, dynamic>) {
        throw AppException('Invalid response format');
      }
      return CreateChallengeModel.fromJson(data);
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Failed to create room');
    }
  }

  // ── POST /challenges/join-by-code ─────────────────────────────────
  Future<JoinRoomChallengeModel> joinRoomByCode(String roomCode) async {
    try {
      final res = await _apiClient.post(
        '${ApiEndpoint.appBaseUrl}/challenges/join-by-code',
        data: {'roomCode': roomCode},
      );
      final data = res.data;
      if (data == null || data is! Map<String, dynamic>) {
        throw AppException('Invalid response format');
      }
      return JoinRoomChallengeModel.fromJson(data);
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Failed to join room');
    }
  }

  // ── POST /challenges/:id/start ────────────────────────────────────
  Future<StartChallengeModel> startChallenge(String challengeId) async {
    try {
      final res = await _apiClient.post(
        '${ApiEndpoint.appBaseUrl}/challenges/$challengeId/start',
      );
      final data = res.data;
      if (data == null || data is! Map<String, dynamic>) {
        throw AppException('Invalid response format');
      }
      return StartChallengeModel.fromJson(data);
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Failed to start challenge');
    }
  }

  // ── DELETE /challenges/:id ────────────────────────────────────────
  Future<DeleteChallengeModel> deleteChallenge(String challengeId) async {
    try {
      final res = await _apiClient.delete(
        '${ApiEndpoint.appBaseUrl}/challenges/$challengeId',
      );
      final data = res.data;
      if (data == null || data is! Map<String, dynamic>) {
        throw AppException('Invalid response format');
      }
      return DeleteChallengeModel.fromJson(data);
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Failed to delete challenge');
    }
  }

  // ── GET /challenges/completed-challenges ──────────────────────────
  Future<CompletedChallengesModel> getCompletedChallenges({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final res = await _apiClient.get(
        '${ApiEndpoint.appBaseUrl}/challenges/completed-challenges?page=$page&limit=$limit',
      );
      final data = res.data;
      if (data == null || data is! Map<String, dynamic>) {
        throw AppException('Invalid response format');
      }
      return CompletedChallengesModel.fromJson(data);
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Failed to fetch completed challenges');
    }
  }

   Future<CompletedChallengeDetailModel> getCompletedChallengeDetail(
      String challengeId) async {
    try {
      final res = await _apiClient.get(
        '${ApiEndpoint.appBaseUrl}/challenges/completed-challenges/$challengeId',
      );
      final data = res.data;
      if (data == null || data is! Map<String, dynamic>) {
        throw AppException('Invalid response format');
      }
      return CompletedChallengeDetailModel.fromJson(data);
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Failed to fetch challenge details');
    }
  }

// ── GET /user/categories?excludeGamification=true ─────────────────
Future<CategoriesModel> getCategories() async {
  try {
    final res = await _apiClient.get(
      '${ApiEndpoint.appBaseUrl}/categories?excludeGamification=true',
    );
    final data = res.data;
    if (data == null || data is! Map<String, dynamic>) {
      throw AppException('Invalid response format');
    }
    return CategoriesModel.fromJson(data);
  } on AppException {
    rethrow;
  } catch (_) {
    throw AppException('Failed to fetch categories');
  }
}

// ── GET /challenges/tests/challenge-yourfriends?page&limit&search&categoryIds ──
Future<ChallengeYourFriendModel> getChallengesFiltered({
  int page = 1,
  int limit = 10,
  String search = '',
  List<String> categoryIds = const [],
}) async {
  try {
    final queryParams = StringBuffer(
      '${ApiEndpoint.appBaseUrl}/challenges/tests/challenge-yourfriends?page=$page&limit=$limit',
    );
    if (search.isNotEmpty) queryParams.write('&search=$search');
    if (categoryIds.isNotEmpty) {
      queryParams.write('&categoryIds=${categoryIds.join(',')}');
    }

    final res = await _apiClient.get(queryParams.toString());
    final data = res.data;
    if (data == null || data is! Map<String, dynamic>) {
      throw AppException('Invalid response format');
    }
    return ChallengeYourFriendModel.fromJson(data);
  } on AppException {
    rethrow;
  } catch (_) {
    throw AppException('Failed to fetch challenges');
  }
}
}