import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChallengeSocketService {
  IO.Socket? _socket;
  bool _connected = false;
  bool get isConnected => _connected;

  final _participantJoined   = StreamController<Map<String, dynamic>>.broadcast();
  final _challengeStarted    = StreamController<Map<String, dynamic>>.broadcast();
  final _startedForYou       = StreamController<Map<String, dynamic>>.broadcast();
  final _challengeDeleted    = StreamController<Map<String, dynamic>>.broadcast();
  final _participantLeft     = StreamController<Map<String, dynamic>>.broadcast();
  final _roomSnapshot        = StreamController<Map<String, dynamic>>.broadcast();
  final _joinedChallengeRoom = StreamController<Map<String, dynamic>>.broadcast();
  final _socketError         = StreamController<String>.broadcast();

  Stream<Map<String, dynamic>> get onParticipantJoined    => _participantJoined.stream;
  Stream<Map<String, dynamic>> get onChallengeStarted     => _challengeStarted.stream;
  Stream<Map<String, dynamic>> get onChallengeStartedForYou => _startedForYou.stream;
  Stream<Map<String, dynamic>> get onChallengeDeleted     => _challengeDeleted.stream;
  Stream<Map<String, dynamic>> get onParticipantLeft      => _participantLeft.stream;
  Stream<Map<String, dynamic>> get onRoomSnapshot         => _roomSnapshot.stream;
  Stream<Map<String, dynamic>> get onJoinedChallengeRoom  => _joinedChallengeRoom.stream;
  Stream<String>               get onSocketError          => _socketError.stream;

  String? _joinedRoomCode;
  String? _pendingRoomCode;

  void connect({required String baseUrl, required String token}) {
    if (_socket != null) {
      _socket!.clearListeners();
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _connected = false;
    }

    final rawToken = token.startsWith('Bearer ')
        ? token.substring(7).trim()
        : token.trim();

    if (rawToken.isEmpty) {
      debugLog('🔴 Token empty — cannot connect');
      _socketError.add('Token is empty');
      return;
    }

    final namespaceUrl = '$baseUrl/challenge';
    debugLog('🔌 Connecting to: $namespaceUrl');

    _socket = IO.io(
      namespaceUrl,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling']) 
          .setAuth({'token': rawToken})
          .setQuery({'token': rawToken})
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(double.maxFinite.toInt())
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(30000)
          .setTimeout(10000)
          .enableForceNew() 
          .build(),
    );

    _socket!.onConnect((_) {
      _connected = true;
      debugLog('✅ Challenge socket connected');
      final toJoin = _joinedRoomCode ?? _pendingRoomCode;
      if (toJoin != null) {
        _emitJoin(toJoin);
        _pendingRoomCode = null;
      }
    });

    _socket!.onDisconnect((reason) {
      _connected = false;
      debugLog('❌ Socket disconnected: $reason');
    });

    _socket!.onReconnect((_) {
      _connected = true;
      debugLog('🔄 Socket reconnected');
      final toJoin = _joinedRoomCode ?? _pendingRoomCode;
      if (toJoin != null) {
        debugLog('🔥 Rejoining room: $toJoin');
        _emitJoin(toJoin);
        _pendingRoomCode = null;
      }
    });

    _socket!.onConnectError((err) {
      _connected = false;
      debugLog('🔴 Connect error: $err');
      _socketError.add('Connection failed: $err');
    });

    _socket!.on('connect_error', (err) {
      _connected = false;
      debugLog('🔴 connect_error: $err');
      _socketError.add(err.toString());
    });

    _socket!.on('error', (d) {
      final msg = d is Map
          ? (d['message'] ?? d['error'] ?? 'Socket error').toString()
          : d.toString();
      debugLog('🔴 error: $msg');
      _socketError.add(msg);
    });

    // ✅ Register all events
    _socket!.on('participant_joined',          _pipe(_participantJoined));
    _socket!.on('challenge_started',           _pipe(_challengeStarted));
    _socket!.on('challenge_started_for_you',   (data) {
      debugLog('🎯 challenge_started_for_you RAW: $data');
      _pipe(_startedForYou)(data);
    });
    _socket!.on('challenge_deleted',           _pipe(_challengeDeleted));
    _socket!.on('participant_left',            _pipe(_participantLeft));
    _socket!.on('room_participants_snapshot',  _pipe(_roomSnapshot));
    _socket!.on('joined_challenge_room',       _pipe(_joinedChallengeRoom));

    _socket!.onAny((event, data) {
      debugLog('📨 [$event]: $data');
    });

    _socket!.connect();
  }

  void joinRoom(String roomCode) {
    if (roomCode.isEmpty) return;
    _joinedRoomCode = roomCode;
    if (_connected && _socket != null) {
      _emitJoin(roomCode);
    } else {
      _pendingRoomCode = roomCode;
      debugLog('⏳ Queued join for: $roomCode');
    }
  }

  void leaveRoom(String roomCode) {
    _socket?.emit('leave_challenge_room', roomCode);
    if (_pendingRoomCode == roomCode) _pendingRoomCode = null;
    if (_joinedRoomCode == roomCode) _joinedRoomCode = null;
    debugLog('👋 Left room: $roomCode');
  }

  void _emitJoin(String roomCode) {
    _socket?.emit('join_challenge_room', roomCode);
    debugLog('✅ Emitted join_challenge_room: $roomCode');
  }

  /// ✅ Fixed pipe — handles List payloads (Socket.IO often wraps in array)
  Function(dynamic) _pipe(StreamController<Map<String, dynamic>> ctrl) =>
      (data) {
        Map<String, dynamic>? map;
        if (data is Map<String, dynamic>) {
          map = data;
        } else if (data is Map) {
          map = Map<String, dynamic>.from(data);
        } else if (data is List && data.isNotEmpty && data.first is Map) {
          map = Map<String, dynamic>.from(data.first as Map);
        }
        if (map != null) ctrl.add(map);
      };

  void debugLog(String msg) => print(msg);

  void disconnect() {
    _socket?.clearListeners();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connected = false;
    _pendingRoomCode = null;
  }

  void dispose() {
    disconnect();
    for (final c in [
      _participantJoined, _challengeStarted, _startedForYou,
      _challengeDeleted, _participantLeft, _roomSnapshot,
      _joinedChallengeRoom, _socketError,
    ]) { c.close(); }
  }
}