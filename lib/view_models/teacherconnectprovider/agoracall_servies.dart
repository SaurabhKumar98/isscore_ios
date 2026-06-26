import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraCallService {
  RtcEngine? _engine;

  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isTeacherInChannel = false;

  bool get isMuted => _isMuted;
  bool get isSpeakerOn => _isSpeakerOn;
  bool get isTeacherInChannel => _isTeacherInChannel;

  // ── Callbacks ─────────────────────────────────────────────────────────

  /// Fired when the local student successfully joins the Agora channel.
  void Function()? onJoinSuccess;

  /// Fired when the remote teacher joins the channel.
  /// ✅ FIX Bug 4 — CallProvider starts the duration timer here, NOT on
  /// onJoinSuccess, so the timer only ticks when both parties are present.
  void Function()? onTeacherJoined;

  /// Fired when the remote teacher leaves or drops.
  void Function()? onTeacherLeft;

  /// Fired on any Agora engine error.
  void Function(String message)? onError;

  // ── Init ──────────────────────────────────────────────────────────────

  Future<void> init(String appId) async {
    // Request mic permission before touching the engine
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      onError?.call('Microphone permission denied. Please allow it in Settings.');
      return;
    }

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(RtcEngineContext(appId: appId));

    // Audio only — disable video
    await _engine!.enableAudio();
    await _engine!.disableVideo();

    // Default: earpiece (call-style), user can toggle to speaker
    await _engine!.setDefaultAudioRouteToSpeakerphone(false);

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          print('✅ [Agora] Joined channel: ${connection.channelId}');
          onJoinSuccess?.call();
        },
        // In onUserJoined — add a small guard so it only fires once per join
onUserJoined: (connection, remoteUid, elapsed) {
  print('✅ [Agora] Teacher joined: uid=$remoteUid');
  if (!_isTeacherInChannel) {  // ✅ guard against duplicate fires
    _isTeacherInChannel = true;
    onTeacherJoined?.call();
  }
},

onUserOffline: (connection, remoteUid, reason) {
  print('❌ [Agora] Teacher left: uid=$remoteUid reason=$reason');
  _isTeacherInChannel = false;
  onTeacherLeft?.call();
},
        onError: (err, msg) {
          print('⚠️ [Agora] Error: $err — $msg');
          onError?.call(msg);
        },
      ),
    );
  }

  // ── Join Channel ──────────────────────────────────────────────────────

  Future<void> joinChannel({
    required String token,
    required String channelName,
    required int uid,
  }) async {
    if (_engine == null) {
      onError?.call('Agora engine not initialized.');
      return;
    }

    await _engine!.joinChannel(
      token: token,
      channelId: channelName,
      uid: uid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: false,
        publishCameraTrack: false,
      ),
    );
  }

  // ── Controls ──────────────────────────────────────────────────────────

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    await _engine?.muteLocalAudioStream(_isMuted);
  }

  Future<void> toggleSpeaker() async {
    _isSpeakerOn = !_isSpeakerOn;
    await _engine?.setEnableSpeakerphone(_isSpeakerOn);
  }

  // ── Leave ─────────────────────────────────────────────────────────────

  Future<void> leaveChannel() async {
    await _engine?.leaveChannel();
    _isTeacherInChannel = false;
    _isMuted = false;
    _isSpeakerOn = false;
  }

  /// Full dispose — releases the engine entirely.
  /// ✅ FIX Bug 3 — resetCall() must call dispose(), not leaveChannel(),
  /// so _engine is set to null and the next init() starts from scratch.
  Future<void> dispose() async {
    await leaveChannel();
    await _engine?.release();
    _engine = null;

    // Clear callbacks so stale references don't fire after disposal
    onJoinSuccess = null;
    onTeacherJoined = null;
    onTeacherLeft = null;
    onError = null;
  }
}