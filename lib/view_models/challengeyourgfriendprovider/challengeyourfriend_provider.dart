import 'dart:async';

import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/challengeyourfriend/challengedetailsmodels.dart';
import 'package:firstedu/data/models/api_models/challengeyourfriend/challengeroom_models.dart';
import 'package:firstedu/data/models/api_models/challengeyourfriend/challengeyourfriend_models.dart';
import 'package:firstedu/data/models/api_models/challengeyourfriend/completechallenge_models.dart';
import 'package:firstedu/data/models/api_models/challengeyourself/challengeyourself_models.dart';
import 'package:firstedu/data/repo/challengeyourfriend/challengewebsocket.dart';
import 'package:firstedu/data/repo/challengeyourfriend/challengeyourfriend_repo.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ChallengeProvider extends ChangeNotifier {
  final ChallengeRepo _repo;
  final ChallengeSocketService _socket;

  ChallengeProvider(this._repo, this._socket);

  String? currentUserId;

  List<ChallengeItem> _challenges = [];
  List<ChallengeItem> get challenges => _challenges;

  List<ChallengeRoom> _rooms = [];
  List<ChallengeRoom> get rooms => _rooms;

  List<CompletedChallenge> _completed = [];
  List<CompletedChallenge> get completed => _completed;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isJoining = false;
  bool get isJoining => _isJoining;

  bool _isCreating = false;
  bool get isCreating => _isCreating;

  bool _isStarting = false;
  bool get isStarting => _isStarting;

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  String? _error;
  String? get error => _error;

  String? pendingSessionId;
  String? pendingChallengeId;

  String? pendingTestId;

  List<CategoryNode> _categories = [];
List<CategoryNode> get categories => _categories;

CategoryNode? _selectedCategory;
CategoryNode? get selectedCategory => _selectedCategory;

String _testSearchQuery = '';
String get testSearchQuery => _testSearchQuery;

bool _isCategoryLoading = false;
bool get isCategoryLoading => _isCategoryLoading;

void selectCategory(CategoryNode? node) {
  _selectedCategory = node;
  notifyListeners();
  // Automatically re-fetch tests when category changes
}

void setTestSearchQuery(String q) {
  _testSearchQuery = q;
  notifyListeners();
}

void clearCategoryFilter() {
  _selectedCategory = null;
  _testSearchQuery = '';
  notifyListeners();
}


  /// Set when you join a socket room that is already `started` but you missed
  /// `challenge_started_for_you`. Call your backend (e.g. exam session by
  /// challenge) then set [pendingSessionId] from the response.
  String? pendingStaleStartedRoomCode;
  String? pendingStaleStartedChallengeId;

  bool _socketInitialized = false;
  String? _socketBaseUrl;
  String? _socketToken;

  final List<StreamSubscription> _subs = [];
  String? _joinedRoomCode;

  static String _normalizeToken(String token) {
    final t = token.trim();
    if (t.startsWith('Bearer ')) return t.substring(7).trim();
    return t;
  }

  void initSocket({required String baseUrl, required String token}) {
    final normToken = _normalizeToken(token);
    final base = baseUrl.replaceAll(RegExp(r'/$'), '');

    final sameCreds = _socketInitialized &&
        _socketBaseUrl == base &&
        _socketToken == normToken;

    if (sameCreds && _socket.isConnected) {
      debugPrint('⚡ Socket already up with same credentials — skipping');
      return;
    }

    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();

    if (_socketInitialized) {
      _socket.disconnect();
      leaveSocketRoom();
    }

    _socketInitialized = true;
    _socketBaseUrl = base;
    _socketToken = normToken;

    debugPrint('🔌 initSocket — connecting...');
    _socket.connect(baseUrl: base, token: normToken);

    _subs.addAll([
      _socket.onParticipantJoined.listen(_handleParticipantJoined),
      _socket.onChallengeStarted.listen(_handleChallengeStarted),
      _socket.onChallengeStartedForYou.listen(_handleStartedForYou),
      _socket.onChallengeDeleted.listen(_handleChallengeDeleted),
      _socket.onParticipantLeft.listen(_handleParticipantLeft),
      _socket.onRoomSnapshot.listen(_handleRoomSnapshot),
      _socket.onJoinedChallengeRoom.listen(_handleJoinedChallengeRoom),
      _socket.onSocketError.listen((err) {
        debugPrint('⚠️ Socket error in provider: $err');
      }),
    ]);
  }

  void joinSocketRoom(String roomCode) {
    if (roomCode.isEmpty) return;
    if (_joinedRoomCode != null && _joinedRoomCode != roomCode) {
      _socket.leaveRoom(_joinedRoomCode!);
    }
    _joinedRoomCode = roomCode;
    _socket.joinRoom(roomCode);
  }

  void leaveSocketRoom() {
    if (_joinedRoomCode != null) {
      _socket.leaveRoom(_joinedRoomCode!);
      _joinedRoomCode = null;
    }
  }

  void _clearStaleStartedHint() {
    pendingStaleStartedRoomCode = null;
    pendingStaleStartedChallengeId = null;
  }

  void _handleJoinedChallengeRoom(Map<String, dynamic> data) {
    final roomCode = data['roomCode']?.toString();
    final challengeId = data['challengeId']?.toString();
    final status = (data['roomStatus'] ?? data['status'])?.toString();

    if (status?.toLowerCase() == 'started') {
      pendingStaleStartedRoomCode = roomCode;
      pendingStaleStartedChallengeId = challengeId;
      debugPrint(
        '⚠️ Joined room already started — socket start event may have been '
        'missed; resolve session via API if needed (room=$roomCode)',
      );
      notifyListeners();
    }
  }

  void consumePendingSession() {
    pendingSessionId = null;
    pendingChallengeId = null;
    pendingTestId = null;
    _clearStaleStartedHint();
  }

// Replace _handleParticipantJoined — also triggers fetchRooms for safety
void _handleParticipantJoined(Map<String, dynamic> data) {
  debugPrint('👤 participant_joined: $data');
  final roomCode = data['roomCode']?.toString();
  final participant = data['participant'];

  if (roomCode == null) return;

  Map<String, dynamic>? pm;
  if (participant is Map<String, dynamic>) {
    pm = participant;
  } else if (participant is Map) {
    pm = Map<String, dynamic>.from(participant);
  } else {
    // ✅ Some servers send flat payload without 'participant' key
    pm = data;
  }

  final newP = Participant(
    id: pm['studentId']?.toString(),
    student: UserModel(
      id: pm['studentId']?.toString(),
      name: pm['name']?.toString(),
      email: pm['email']?.toString(),
    ),
    joinedAt: DateTime.tryParse(pm['joinedAt']?.toString() ?? ''),
  );

  bool found = false;
  _rooms = _rooms.map((r) {
    if (r.roomCode != roomCode) return r;
    found = true;
    // ✅ Deduplicate — don't add same student twice
    final existing = r.participants ?? [];
    final alreadyIn = existing.any((p) => p.student?.id == newP.student?.id);
    if (alreadyIn) return r;
    return _copyRoomWith(r, participants: [...existing, newP]);
  }).toList();

  if (!found) {
    debugPrint('⚠️ participant_joined for unknown room $roomCode — ignoring');
  }

  notifyListeners();
}
 
  void _handleParticipantLeft(Map<String, dynamic> data) {
    final roomCode = data['roomCode']?.toString();
    final studentId = data['studentId']?.toString();
    if (roomCode == null || studentId == null) return;

    _rooms = _rooms.map((r) {
      if (r.roomCode != roomCode) return r;
      return _copyRoomWith(
        r,
        participants: r.participants
                ?.where((p) => p.student?.id != studentId)
                .toList() ??
            [],
      );
    }).toList();
    notifyListeners();
  }

  /// Match [roomCode] or [challengeId] (same as web).
  void _handleChallengeStarted(Map<String, dynamic> data) {
    final roomCode = data['roomCode']?.toString();
    final challengeId = data['challengeId']?.toString();
    if ((roomCode == null || roomCode.isEmpty) &&
        (challengeId == null || challengeId.isEmpty)) {
      return;
    }

    _clearStaleStartedHint();

    _rooms = _rooms.map((r) {
      final byCode =
          roomCode != null && roomCode.isNotEmpty && r.roomCode == roomCode;
      final byId =
          challengeId != null &&
          challengeId.isNotEmpty &&
          r.id == challengeId;
      if (!byCode && !byId) return r;
      return _copyRoomWith(r, roomStatus: 'started');
    }).toList();
    notifyListeners();
  }

// Replace _handleStartedForYou — fetches session from API when testId missing
void _handleStartedForYou(Map<String, dynamic> data) async {
  debugPrint('🎯 challenge_started_for_you: $data');

  final sessionId = data['sessionId']?.toString();
  if (sessionId == null || sessionId.isEmpty) return;

  final challengeId = data['challengeId']?.toString();
  final testIdFromEvent = data['testId']?.toString();

  pendingChallengeId = challengeId;
  _clearStaleStartedHint();

  // ✅ Try to get testId from event first, then room, then refresh rooms
  String resolvedTestId = '';

  if (testIdFromEvent != null && testIdFromEvent.isNotEmpty) {
    resolvedTestId = testIdFromEvent;
    debugPrint('✅ testId from socket: $resolvedTestId');
  } else {
    // Try from current rooms list
    if (challengeId != null) {
      for (final r in _rooms) {
        if (r.id == challengeId) {
          resolvedTestId = r.test?.id ?? '';
          break;
        }
      }
    }

    // ✅ If still empty, refresh rooms to get test info
    if (resolvedTestId.isEmpty) {
      debugPrint('⚠️ testId not found — refreshing rooms...');
      try {
        final res = await _repo.getChallengeRooms();
        if (res.success == true) {
          _rooms = res.data ?? [];
          notifyListeners();
          if (challengeId != null) {
            for (final r in _rooms) {
              if (r.id == challengeId) {
                resolvedTestId = r.test?.id ?? '';
                break;
              }
            }
          }
        }
      } catch (e) {
        debugPrint('❌ Failed to refresh rooms: $e');
      }
    }
  }

  pendingTestId = resolvedTestId;
  pendingSessionId = sessionId; // ✅ Set LAST so navigation triggers with testId ready

  debugPrint('✅ pendingSessionId=$pendingSessionId pendingTestId=$pendingTestId');
  notifyListeners();
}
  void _handleChallengeDeleted(Map<String, dynamic> data) {
    final challengeId = data['challengeId']?.toString();
    if (challengeId == null) return;
    _rooms = _rooms.where((r) => r.id != challengeId).toList();
    notifyListeners();
  }

void _handleRoomSnapshot(Map<String, dynamic> data) {
  final roomCode = data['roomCode']?.toString();
  final rawList = data['participants'];
  if (roomCode == null || rawList is! List) return;

  final updatedParticipants = <Participant>[];
  for (final p in rawList) {
    if (p is! Map) continue;
    final pm = Map<String, dynamic>.from(p);

    // ✅ Socket sends flat format — map manually
    updatedParticipants.add(
      Participant(
        id: pm['studentId']?.toString(),
        student: UserModel(
          id: pm['studentId']?.toString(),
          name: pm['name']?.toString(),
          email: pm['email']?.toString(),
        ),
        joinedAt: DateTime.tryParse(pm['joinedAt']?.toString() ?? ''),
      ),
    );
  }

  final status = data['roomStatus']?.toString();

  _rooms = _rooms.map((r) {
    if (r.roomCode != roomCode) return r;
    if (status?.toLowerCase() == 'started') {
      pendingStaleStartedRoomCode = roomCode;
      pendingStaleStartedChallengeId = r.id;
    }
    return _copyRoomWith(
      r,
      roomStatus: status ?? r.roomStatus,
      participants: updatedParticipants,
    );
  }).toList();
  notifyListeners();
}
  Future<void> fetchAll(BuildContext context) async {
    await Future.wait([
      fetchChallenges(context),
      fetchRooms(context),
      fetchCompleted(context),
    ]);
  }

  Future<void> fetchChallenges(BuildContext context) async {
    try {
      _setLoading(true);
      final res = await _repo.getChallenges();
      if (res.success == true) {
        _challenges = res.data ?? [];
      } else {
        _showError(context, res.message ?? 'Failed to load challenges');
      }
    } on AppException catch (e) {
      _showError(context, e.message);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchRooms(BuildContext context) async {
    try {
      _setLoading(true);
      final res = await _repo.getChallengeRooms();
      if (res.success == true) {
        _rooms = res.data ?? [];
      } else {
        _showError(context, res.message ?? 'Failed to load rooms');
      }
    } on AppException catch (e) {
      _showError(context, e.message);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchCompleted(BuildContext context) async {
    try {
      final res = await _repo.getCompletedChallenges();
      if (res.success == true) {
        _completed = res.data ?? [];
        notifyListeners();
      }
    } on AppException catch (e) {
      _showError(context, e.message);
    }
  }

  Future<bool> joinRoom(BuildContext context, String roomCode) async {
    try {
      _isJoining = true;
      _error = null;
      notifyListeners();

      final res = await _repo.joinRoomByCode(roomCode);
      if (res.success == true) {
        await fetchRooms(context);
        joinSocketRoom(roomCode);
        debugPrint('🔥 JOIN SOCKET ROOM after REST join: $roomCode');

        if (context.mounted) {
         AppToast.success(context, message: "Joined successfully — waiting for host to start");
         
        }
        return true;
      } else {
        throw AppException(res.message ?? 'Failed to join room');
      }
    } on AppException catch (e) {
      _showError(context, e.message);
      return false;
    } finally {
      _isJoining = false;
      notifyListeners();
    }
  }

  Future<bool> createRoom(
    BuildContext context, {
    required String title,
    required String description,
    required String testId,
  }) async {
    try {
      _isCreating = true;
      _error = null;
      notifyListeners();

      final res = await _repo.createRoom(
        title: title,
        description: description,
        testId: testId,
      );
      if (res.success == true) {
        await fetchRooms(context);

        final newRoom = _rooms.firstWhere(
          (r) => r.createdBy?.id == currentUserId,
          orElse: () => ChallengeRoom(),
        );
        if (newRoom.roomCode != null && newRoom.roomCode!.isNotEmpty) {
          joinSocketRoom(newRoom.roomCode!);
        }

        if (context.mounted) {
          AppToast.success(context, message:'Room created successfully');
        }
        return true;
      } else {
        throw AppException(res.message ?? 'Failed to create room');
      }
    } on AppException catch (e) {
      _showError(context, e.message);
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    } 
  }

// Replace startChallenge — also refreshes rooms so host gets updated test info
Future<bool> startChallenge(BuildContext context, String challengeId) async {
  try {
    _isStarting = true;
    _error = null;
    notifyListeners();

    final res = await _repo.startChallenge(challengeId);
    if (res.success == true) {
      // ✅ Refresh rooms FIRST so test info is up to date
      await fetchRooms(context);

      final room = _rooms.firstWhere(
        (r) => r.id == challengeId,
        orElse: () => ChallengeRoom(),
      );
      final testId = room.test?.id ?? '';

      // ✅ Try all session ID aliases from spec
     final mySessionId =
    res.data?.mySessionId?.toString() ?? '';

      debugPrint('✅ startChallenge — sessionId=$mySessionId testId=$testId');

      if (mySessionId.isNotEmpty && testId.isNotEmpty) {
        pendingSessionId = mySessionId;
        pendingChallengeId = challengeId;
        pendingTestId = testId;
        _clearStaleStartedHint();
        notifyListeners();
      } else if (mySessionId.isNotEmpty && testId.isEmpty) {
        // ✅ testId missing — try from raw response
        debugPrint('⚠️ testId empty after rooms refresh — check StartChallengeModel');
      }

      if (context.mounted) {
        // 
        AppToast.success(context, message: "Room created successfully");
      }
      return true;
    } else {
      throw AppException(res.message ?? 'Failed to start challenge');
    }
  } on AppException catch (e) {
    _showError(context, e.message);
    return false;
  } finally {
    _isStarting = false;
    notifyListeners();
  }
}

// Replace deleteChallenge — properly removes from list and notifies
Future<bool> deleteChallenge(BuildContext context, String challengeId) async {
  try {
    _isDeleting = true;
    _error = null;
    notifyListeners();

    final res = await _repo.deleteChallenge(challengeId);
    if (res.success == true) {
      // ✅ Remove immediately from local list
      _rooms = _rooms.where((r) => r.id != challengeId).toList();

      // ✅ Leave socket room if it was the joined one
      final deleted = _joinedRoomCode;
      if (deleted != null) {
        leaveSocketRoom();
      }

      notifyListeners();

      if (context.mounted) {
        AppToast.success(context, message: 'Room deleted successfully');
      }
      return true;
    } else {
      throw AppException(res.message ?? 'Failed to delete');
    }
  } on AppException catch (e) {
    _showError(context, e.message);
    return false;
  } finally {
    _isDeleting = false;
    notifyListeners();
  }
}

  Future<CompletedChallengeDetail?> fetchCompletedChallengeDetail(
    BuildContext context,
    String challengeId,
  ) async {
    try {
      final res = await _repo.getCompletedChallengeDetail(challengeId);
      if (res.success == true && res.data != null) {
        return res.data;
      } else {
        _showError(context, res.message ?? 'Failed to load details');
        return null;
      }
    } on AppException catch (e) {
      _showError(context, e.message);
      return null;
    }
  }
Future<void> fetchCategories(BuildContext context) async {
  try {
    _isCategoryLoading = true;
    notifyListeners();
    final res = await _repo.getCategories();
    if (res.success) {
      _categories = res.data;
    } else {
      _showError(context, res.message);
    }
  } on AppException catch (e) {
    _showError(context, e.message);
  } finally {
    _isCategoryLoading = false;
    notifyListeners();
  }
}

Future<void> fetchChallengesFiltered(BuildContext context) async {
  try {
    _setLoading(true);
    final ids = _selectedCategory?.allIds ?? [];
    final res = await _repo.getChallengesFiltered(
      search: _testSearchQuery,
      categoryIds: ids,
    );
    if (res.success == true) {
      _challenges = res.data ?? [];
    } else {
      _showError(context, res.message ?? 'Failed to load challenges');
    }
  } on AppException catch (e) {
    _showError(context, e.message);
  } finally {
    _setLoading(false);
  }
}

  ChallengeRoom _copyRoomWith(
    ChallengeRoom r, {
    String? roomStatus,
    List<Participant>? participants,
  }) {
    return ChallengeRoom(
      id: r.id,
      title: r.title,
      description: r.description,
      test: r.test,
      createdBy: r.createdBy,
      creatorType: r.creatorType,
      roomCode: r.roomCode,
      roomStatus: roomStatus ?? r.roomStatus,
      startedAt: r.startedAt,
      completedAt: r.completedAt,
      isActive: r.isActive,
      participants: participants ?? r.participants,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      v: r.v,
    );
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _showError(BuildContext context, String msg) {
    _error = msg;
    if (context.mounted) {
      AppToast.error(context, title: 'Error', message: msg);
    }
  }

  void reset() {
    _socketInitialized = false;
    _socketBaseUrl = null;
    _socketToken = null;
    _challenges = [];
    _rooms = [];
    _completed = [];
    _error = null;
    _isLoading = _isJoining = _isCreating = _isStarting = _isDeleting = false;
    pendingSessionId = null;
    pendingChallengeId = null;
    pendingTestId = null;
    _clearStaleStartedHint();

    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    leaveSocketRoom();
    _socket.disconnect();
    notifyListeners();
  }

  @override
  void dispose() {
    reset();
    super.dispose();
  }
}