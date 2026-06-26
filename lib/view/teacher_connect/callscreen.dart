import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/view_models/teacherconnectprovider/callprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CallScreen extends StatefulWidget {
  final String teacherId;
  final String teacherName;
  final String? teacherImage;
  final String subject;

  const CallScreen({
    super.key,
    required this.teacherId,
    required this.teacherName,
    this.teacherImage,
    this.subject = '',
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {
  late AnimationController _rippleCtrl;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  Color _bgTop = const Color(0xFF0D1B2A);
  Color _bgBot = const Color(0xFF132338);

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _ringingPlaying = false;

  // ✅ FIX: Track whether we've already scheduled the auto-pop so it only
  // ever fires once, even if notifyListeners is called multiple times in
  // the ended state.
  bool _popScheduled = false;

  // ✅ FIX: Track whether startCall has already been called for this widget
  // instance so it's never called twice (e.g. on hot-reload or rebuild).
  bool _callStarted = false;

  CallProvider? _callProvider;

  @override
  void initState() {
    super.initState();

    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

    _audioPlayer.setReleaseMode(ReleaseMode.loop);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final provider = context.read<CallProvider>();
      _callProvider = provider;

      // ✅ FIX: Remove before adding so we never accumulate listeners.
      provider.removeListener(_onStateChanged);
      provider.addListener(_onStateChanged);

      // ✅ FIX: Guard — only start the call once per widget instance.
      if (_callStarted) return;
      _callStarted = true;

      // ✅ FIX: resetCall() is now async and fully awaited before starting
      // a new call, ensuring the old Agora engine is fully torn down.
      if (provider.state != CallState.idle) {
        await provider.resetCall();
        if (!mounted) return;
      }

      _popScheduled = false;

      provider.startCall(
        context,
        teacherId: widget.teacherId,
        teacherName: widget.teacherName,
        subject: widget.subject,
      );

      _startRinging();
    });
  }

  Future<void> _startRinging() async {
    if (_ringingPlaying) return;
    _ringingPlaying = true;
    try {
      await _audioPlayer.play(AssetSource('audio/ringtone.mp3'));
    } catch (_) {}
  }

  Future<void> _stopRinging() async {
    if (!_ringingPlaying) return;
    _ringingPlaying = false;
    try {
      await _audioPlayer.stop();
    } catch (_) {}
  }

  void _onStateChanged() {
    if (!mounted) return;

    final s = _callProvider?.state;
    if (s == null) return;

    switch (s) {
      case CallState.active:
        _stopRinging();
        _rippleCtrl.stop();
        _fadeCtrl.forward();
        if (mounted) {
          setState(() {
            _bgTop = const Color(0xFF092420);
            _bgBot = const Color(0xFF0E3530);
          });
        }
        break;

      case CallState.ended:
        _stopRinging();
        _rippleCtrl.stop();
        _fadeCtrl.reset();
        if (mounted) {
          setState(() {
            _bgTop = const Color(0xFF1A0D0D);
            _bgBot = const Color(0xFF2C1414);
          });
        }
        // ✅ FIX: Auto-pop guard — only schedule once.
        if (!_popScheduled) {
          _popScheduled = true;
          Future.delayed(const Duration(seconds: 3), () {
            if (!mounted) return;
            // ✅ FIX: Don't call resetCall() here — it resets state that the
            // _EndedView is currently displaying. Let the next startCall()
            // trigger the reset instead.
            Navigator.pop(context);
          });
        }
        break;

      case CallState.requesting:
      case CallState.waitingTeacher:
        // ✅ FIX: Reset pop flag for each new request attempt.
        _popScheduled = false;
        _startRinging();
        if (!_rippleCtrl.isAnimating) _rippleCtrl.repeat();
        if (mounted) {
          setState(() {
            _bgTop = const Color(0xFF0D1B2A);
            _bgBot = const Color(0xFF132338);
          });
        }
        break;

      case CallState.joiningChannel:
        _stopRinging();
        break;

      case CallState.idle:
        break;
    }
  }

  @override
  void dispose() {
    _callProvider?.removeListener(_onStateChanged);
    _rippleCtrl.dispose();
    _fadeCtrl.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CallProvider>();

    return WillPopScope(
      // ✅ FIX: Intercept back press — don't allow accidental back during
      // active/joining state. User must explicitly cancel/end.
      onWillPop: () async {
        final s = provider.state;
        if (s == CallState.active || s == CallState.joiningChannel) {
          // Show confirmation before allowing back
          final confirm = await _showEndConfirm();
          if (confirm == true) {
            await provider.endCall();
          }
          return false; // Always return false; auto-pop handles navigation
        }
        if (s == CallState.requesting || s == CallState.waitingTeacher) {
          provider.cancelCall();
          return false;
        }
        // idle or ended — allow pop
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_bgTop, _bgBot, const Color(0xFF080D12)],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          child: SafeArea(child: _buildBody(provider)),
        ),
      ),
    );
  }

  Future<bool?> _showEndConfirm() {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('End Call?'),
        content: const Text('Are you sure you want to end this call?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Stay')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('End',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  Widget _buildBody(CallProvider provider) {
    return switch (provider.state) {
      CallState.idle => const SizedBox.shrink(),
      CallState.requesting || CallState.waitingTeacher => _OutgoingView(
          provider: provider,
          rippleCtrl: _rippleCtrl,
          teacherName: widget.teacherName,
          teacherImage: widget.teacherImage,
          subject: widget.subject,
        ),
      CallState.joiningChannel => _JoiningView(
          teacherName: widget.teacherName,
          teacherImage: widget.teacherImage,
        ),
      CallState.active => FadeTransition(
          opacity: _fadeAnim,
          child: _ActiveView(
            provider: provider,
            teacherName: widget.teacherName,
            teacherImage: widget.teacherImage,
          ),
        ),
      CallState.ended => _EndedView(
          provider: provider,
          teacherName: widget.teacherName,
        ),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OUTGOING / RINGING VIEW
// ─────────────────────────────────────────────────────────────────────────────

class _OutgoingView extends StatelessWidget {
  final CallProvider provider;
  final AnimationController rippleCtrl;
  final String teacherName;
  final String? teacherImage;
  final String subject;

  const _OutgoingView({
    required this.provider,
    required this.rippleCtrl,
    required this.teacherName,
    this.teacherImage,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    final isConnecting = provider.state == CallState.requesting;

    return Column(
      children: [
        SizedBox(height: 30.h),

        Center(
          child: _StatusChip(
            label: isConnecting ? 'Connecting…' : 'Ringing…',
            color: isConnecting
                ? const Color(0xFF64B5F6)
                : const Color(0xFF81C784),
            blink: !isConnecting,
          ),
        ),

        const Spacer(),

        AnimatedBuilder(
          animation: rippleCtrl,
          builder: (_, __) {
            return SizedBox(
              width: 300.w,
              height: 300.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildRing(rippleCtrl.value, 300.w, 0.12,
                      const Color(0xFF29B6F6)),
                  _buildRing((rippleCtrl.value + 0.33) % 1, 240.w, 0.18,
                      const Color(0xFF4DD0E1)),
                  _buildRing((rippleCtrl.value + 0.66) % 1, 180.w, 0.25,
                      const Color(0xFF4FC3F7)),
                  Container(
                    width: 140.w,
                    height: 140.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.14),
                        width: 1.5,
                      ),
                    ),
                  ),
                  _Avatar(imageUrl: teacherImage, size: 110),
                ],
              ),
            );
          },
        ),

        SizedBox(height: 34.h),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            teacherName,
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        SizedBox(height: 10.h),

        if (subject.isNotEmpty)
          _GlassPill(
            icon: Icons.menu_book_rounded,
            label: subject,
            color: const Color(0xFF4FC3F7),
          ),

        SizedBox(height: 20.h),

        _PulsingText(
          text: isConnecting
              ? 'Establishing secure connection…'
              : 'Waiting for teacher to accept…',
        ),

        const Spacer(),

        _BigRedButton(
          icon: Icons.call_end_rounded,
          label: 'Cancel',
          onTap: () {
            provider.cancelCall();
            // ✅ FIX: Don't Navigator.pop() here — _EndedView + auto-pop handles it.
            // Popping here races with the 3-second timer and can cause double-pop.
          },
        ),

        SizedBox(height: 60.h),
      ],
    );
  }

  Widget _buildRing(double t, double maxSize, double maxOpacity, Color color) {
    final scale = 0.5 + t * 0.5;
    final opacity = (1 - t) * maxOpacity;
    return Transform.scale(
      scale: scale,
      child: Container(
        width: maxSize,
        height: maxSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withOpacity(opacity),
            width: 1.6,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// JOINING VIEW
// ─────────────────────────────────────────────────────────────────────────────

class _JoiningView extends StatelessWidget {
  final String teacherName;
  final String? teacherImage;

  const _JoiningView({required this.teacherName, this.teacherImage});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Avatar(imageUrl: teacherImage, size: 88),
        SizedBox(height: 28.h),
        Text(
          'Accepted! 🎉',
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF80CBC4),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'Joining audio channel…',
          style: TextStyle(fontSize: 14.sp, color: Colors.white54),
        ),
        SizedBox(height: 32.h),
        SizedBox(
          width: 26.w,
          height: 26.w,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: const Color(0xFF4FC3F7),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVE CALL VIEW
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveView extends StatelessWidget {
  final CallProvider provider;
  final String teacherName;
  final String? teacherImage;

  const _ActiveView({
    required this.provider,
    required this.teacherName,
    this.teacherImage,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        children: [
          SizedBox(height: 16.h),

          _StatusChip(
            label:
                provider.isTeacherInChannel ? '  Live' : 'Connecting…',
            color: const Color(0xFF66BB6A),
            blink: provider.isTeacherInChannel,
          ),

          const Spacer(),

          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 160.w,
                height: 160.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF26A69A).withOpacity(0.45),
                      blurRadius: 70,
                      spreadRadius: 18,
                    ),
                  ],
                ),
              ),
              _Avatar(imageUrl: teacherImage, size: 112),
            ],
          ),

          SizedBox(height: 22.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              teacherName,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.8,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(height: 14.h),

          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 22.w, vertical: 9.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(
                  color: Colors.white.withOpacity(0.1), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7.w,
                  height: 7.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF66BB6A),
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  provider.isTeacherInChannel
                      ? provider.formattedDuration
                      : '--:--',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 3,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _ControlBtn(
                  icon: provider.isMuted
                      ? Icons.mic_off_rounded
                      : Icons.mic_rounded,
                  label: provider.isMuted ? 'Unmute' : 'Mute',
                  active: provider.isMuted,
                  activeColor: const Color(0xFFF4511E),
                  onTap: provider.toggleMute,
                ),

                Column(
                  children: [
                    GestureDetector(
                      onTap: () => provider.endCall(),
                      child: Container(
                        width: 74.w,
                        height: 74.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [
                              Color(0xFFEF5350),
                              Color(0xFFB71C1C)
                            ],
                            center: Alignment(-0.3, -0.4),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFFEF5350).withOpacity(0.55),
                              blurRadius: 28,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(Icons.call_end_rounded,
                            color: Colors.white, size: 32.sp),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'End',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                _ControlBtn(
                  icon: provider.isSpeakerOn
                      ? Icons.volume_up_rounded
                      : Icons.hearing_rounded,
                  label: provider.isSpeakerOn ? 'Speaker' : 'Earpiece',
                  active: provider.isSpeakerOn,
                  activeColor: const Color(0xFF29B6F6),
                  onTap: provider.toggleSpeaker,
                ),
              ],
            ),
          ),

          SizedBox(height: 52.h),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ENDED VIEW
// ─────────────────────────────────────────────────────────────────────────────

class _EndedView extends StatefulWidget {
  final CallProvider provider;
  final String teacherName;
  const _EndedView({required this.provider, required this.teacherName});

  @override
  State<_EndedView> createState() => _EndedViewState();
}

class _EndedViewState extends State<_EndedView>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _scale = Tween(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reason = widget.provider.endReason;
    final msg = widget.provider.errorMessage;

    final (icon, iconColor, title, subtitle, showDuration) = switch (reason) {
      CallEndReason.teacherRejected => (
          Icons.call_end_rounded,
          const Color(0xFFEF9A9A),
          'Call Declined',
          msg.isNotEmpty ? msg : '${widget.teacherName} is unavailable.',
          false,
        ),
      CallEndReason.autoTimeout => (
          Icons.timer_off_rounded,
          const Color(0xFFFFD54F),
          'No Response',
          '${widget.teacherName} didn\'t respond in time.',
          false,
        ),
      CallEndReason.endedByTeacher => (
          Icons.call_end_rounded,
          const Color(0xFFEF9A9A),
          'Call Ended',
          msg.isNotEmpty ? msg : 'Teacher ended the session.',
          true,
        ),
      CallEndReason.endedByStudent => (
          Icons.check_circle_outline_rounded,
          const Color(0xFF80CBC4),
          'Call Ended',
          'You ended the session.',
          true,
        ),
      CallEndReason.error => (
          Icons.error_outline_rounded,
          const Color(0xFFFFB74D),
          'Call Failed',
          msg.isNotEmpty ? msg : 'Please try again.',
          false,
        ),
      _ => (
          Icons.call_end_rounded,
          Colors.white38,
          'Call Ended',
          '',
          false,
        ),
    };

    return FadeTransition(
      opacity: _opacity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scale,
            child: Container(
              width: 104.w,
              height: 104.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withOpacity(0.1),
                border: Border.all(
                    color: iconColor.withOpacity(0.35), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.2),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 46.sp),
            ),
          ),

          SizedBox(height: 30.h),

          Text(
            title,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.8,
            ),
            textAlign: TextAlign.center,
          ),

          if (subtitle.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 44.w),
              child: Text(
                subtitle,
                style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white54,
                    height: 1.55),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          if (showDuration &&
              widget.provider.callDuration > Duration.zero) ...[
            SizedBox(height: 22.h),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 22.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(
                    color: Colors.white.withOpacity(0.1), width: 1),
              ),
              child: Text(
                'Duration   ${widget.provider.formattedDuration}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white60,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],

          SizedBox(height: 44.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 13.w,
                height: 13.w,
                child: CircularProgressIndicator(
                    strokeWidth: 1.5, color: Colors.white),
              ),
              SizedBox(width: 10.w),
              Text(
                'Closing in a moment…',
                style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white24,
                    letterSpacing: 0.3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS (unchanged from original)
// ─────────────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  const _Avatar({this.imageUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF112233),
        border: Border.all(
            color: Colors.white.withOpacity(0.16), width: 2.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 20,
              spreadRadius: 2),
        ],
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(size),
              )
            : _placeholder(size),
      ),
    );
  }

  Widget _placeholder(double s) => Container(
        color: const Color(0xFF1A2D42),
        child: Icon(Icons.person_rounded,
            size: (s * 0.46).w, color: Colors.white),
      );
}

class _StatusChip extends StatefulWidget {
  final String label;
  final Color color;
  final bool blink;

  const _StatusChip(
      {required this.label, required this.color, this.blink = false});

  @override
  State<_StatusChip> createState() => _StatusChipState();
}

class _StatusChipState extends State<_StatusChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _anim = Tween(begin: 0.2, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    if (widget.blink) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _StatusChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.blink != oldWidget.blink) {
      if (widget.blink) {
        _ctrl.repeat(reverse: true);
      } else {
        _ctrl.stop();
        _ctrl.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30.r),
        border:
            Border.all(color: widget.color.withOpacity(0.22), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Container(
              width: 7.w,
              height: 7.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color
                    .withOpacity(widget.blink ? _anim.value : 1.0),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: widget.color,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _GlassPill(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
                fontSize: 13.sp, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final Future<void> Function() onTap;

  const _ControlBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 62.w,
            height: 62.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? activeColor.withOpacity(0.15)
                  : Colors.white.withOpacity(0.07),
              border: Border.all(
                color: active
                    ? activeColor.withOpacity(0.45)
                    : Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: activeColor.withOpacity(0.22),
                        blurRadius: 18,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              size: 25.sp,
              color: active ? activeColor : Colors.white38,
            ),
          ),
          SizedBox(height: 9.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: active
                  ? activeColor.withOpacity(0.75)
                  : Colors.white24,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _BigRedButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BigRedButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 74.w,
            height: 74.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFEF5350), Color(0xFFC62828)],
                center: Alignment(-0.3, -0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF5350).withOpacity(0.52),
                  blurRadius: 28,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white38,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingText extends StatefulWidget {
  final String text;
  const _PulsingText({required this.text});

  @override
  State<_PulsingText> createState() => _PulsingTextState();
}

class _PulsingTextState extends State<_PulsingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1300))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.35, end: 0.85)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Text(
        widget.text,
        style: TextStyle(
          fontSize: 13.sp,
          color: Colors.white.withOpacity(_anim.value),
          letterSpacing: 0.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}