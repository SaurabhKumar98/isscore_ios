

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AudioPlayerSheet extends StatefulWidget {
  final String url;
  final String title;
  final String subtitle;

  const AudioPlayerSheet({
    super.key,
    required this.url,
    required this.title,
    required this.subtitle,
  });

  /// Opens the player as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required String url,
    required String title,
    required String subtitle,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AudioPlayerSheet(
        url: url,
        title: title,
        subtitle: subtitle,
      ),
    );
  }

  @override
  State<AudioPlayerSheet> createState() => _AudioPlayerSheetState();
}

class _AudioPlayerSheetState extends State<AudioPlayerSheet> {
  late final AudioPlayer _player;
  bool _loading = true;
  String? _error;
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _player = AudioPlayer();

    // Tell iOS/Android this is music/speech so it handles audio focus properly
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    try {
      await _player.setUrl(widget.url);
      if (mounted) setState(() => _loading = false);
      await _player.play();
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration? d) {
    if (d == null) return '0:00';
    final m = d.inMinutes.remainder(60).toString();
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E4F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF4361EE).withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.mic_rounded,
                size: 32, color: Color(0xFF4361EE)),
          ),
          const SizedBox(height: 16),

          // title
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1D2E),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            widget.subtitle,
            style: const TextStyle(fontSize: 13, color: Color(0xFF9EA3B5)),
          ),
          const SizedBox(height: 24),

          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(color: Color(0xFF4361EE)),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  const Icon(Icons.error_outline,
                      size: 40, color: Color(0xFFEF4444)),
                  const SizedBox(height: 8),
                  const Text('Could not load recording',
                      style: TextStyle(color: Color(0xFFEF4444))),
                ],
              ),
            )
          else ...[
            // ── Progress bar ───────────────────────────────────────────────
            StreamBuilder<Duration>(
              stream: _player.positionStream,
              builder: (_, posSnap) {
                return StreamBuilder<Duration?>(
                  stream: _player.durationStream,
                  builder: (_, durSnap) {
                    final pos = posSnap.data ?? Duration.zero;
                    final dur = durSnap.data ?? Duration.zero;
                    final progress =
                        dur.inMilliseconds > 0
                            ? (pos.inMilliseconds / dur.inMilliseconds)
                                .clamp(0.0, 1.0)
                            : 0.0;

                    return Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 7),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14),
                            activeTrackColor: const Color(0xFF4361EE),
                            inactiveTrackColor: const Color(0xFFE2E4F0),
                            thumbColor: const Color(0xFF4361EE),
                            overlayColor:
                                const Color(0xFF4361EE).withOpacity(0.15),
                          ),
                          child: Slider(
                            value: progress,
                            onChanged: (v) {
                              final target = Duration(
                                  milliseconds:
                                      (v * dur.inMilliseconds).round());
                              _player.seek(target);
                            },
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_fmt(pos),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF9EA3B5))),
                              Text(_fmt(dur),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF9EA3B5))),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),

            // ── Controls ───────────────────────────────────────────────────
            StreamBuilder<PlayerState>(
              stream: _player.playerStateStream,
              builder: (_, snap) {
                final playing = snap.data?.playing ?? false;
                final completed =
                    snap.data?.processingState == ProcessingState.completed;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // rewind 10s
                    IconButton(
                      onPressed: () {
                        final newPos = (_player.position) -
                            const Duration(seconds: 10);
                        _player.seek(
                            newPos < Duration.zero ? Duration.zero : newPos);
                      },
                      icon: const Icon(Icons.replay_10_rounded),
                      iconSize: 32,
                      color: const Color(0xFF6B7080),
                    ),
                    const SizedBox(width: 12),

                    // play / pause / replay
                    GestureDetector(
                      onTap: () {
                        if (completed) {
                          _player.seek(Duration.zero);
                          _player.play();
                        } else if (playing) {
                          _player.pause();
                        } else {
                          _player.play();
                        }
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4361EE),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          completed
                              ? Icons.replay_rounded
                              : playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // forward 10s
                    IconButton(
                      onPressed: () {
                        final dur = _player.duration ?? Duration.zero;
                        final newPos = _player.position +
                            const Duration(seconds: 10);
                        _player.seek(newPos > dur ? dur : newPos);
                      },
                      icon: const Icon(Icons.forward_10_rounded),
                      iconSize: 32,
                      color: const Color(0xFF6B7080),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // ── Speed selector ─────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Speed:',
                    style: TextStyle(
                        fontSize: 12, color: Color(0xFF9EA3B5))),
                const SizedBox(width: 8),
                for (final s in [0.5, 1.0, 1.5, 2.0])
                  GestureDetector(
                    onTap: () {
                      setState(() => _speed = s);
                      _player.setSpeed(s);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _speed == s
                            ? const Color(0xFF4361EE)
                            : const Color(0xFFF0F1F8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${s}x',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _speed == s
                              ? Colors.white
                              : const Color(0xFF6B7080),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}