import 'package:firstedu/data/models/api_models/livecompetetion/livecompetionmodels.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view/livecompetetionscreen/livecompetetionsubmitscreen.dart';
import 'package:firstedu/view_models/livecompetetionprovider/livecompetetiondetailsprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProctoringGatewayScreen extends StatefulWidget {
  final LiveCompetition competition;
  final LiveParticipationData participation;
  final String round;
  final String meetingUrl;
  final String? meetingTitle;
  final LiveCompetitionSubmission? submissionConfig; // ← NEW

  const ProctoringGatewayScreen({
    required this.competition,
    required this.participation,
    required this.round,
    required this.meetingUrl,
    this.meetingTitle,
    this.submissionConfig, // ← NEW
    super.key,
  });

  @override
  State<ProctoringGatewayScreen> createState() =>
      _ProctoringGatewayScreenState();
}

class _ProctoringGatewayScreenState extends State<ProctoringGatewayScreen> {
  bool _hasJoinedMeeting = false;
  bool _hasConfirmed = false;
  bool _isLaunching = false;

  static const _steps = [
    _GatewayStep(
      icon: Icons.video_call_rounded,
      color: Color(0xFF1565C0),
      title: 'Join the Proctoring Meeting',
      description:
          'Click the button below to open the meeting link. You must be inside the meeting before proceeding.',
    ),
    _GatewayStep(
      icon: Icons.screen_share_rounded,
      color: Color(0xFFB71C1C),
      title: 'Share Your Entire Screen',
      description:
          'When prompted, select "Entire Screen" — NOT a window or tab. '
          'The proctor must be able to see your full screen at all times.',
    ),
    _GatewayStep(
      icon: Icons.check_circle_rounded,
      color: Color(0xFF2E7D32),
      title: 'Confirm & Proceed',
      description:
          'Once you have joined and shared your screen, tap the confirmation '
          'button below. The exam will then become available.',
    ),
  ];

  Future<void> _launchMeeting() async {
    setState(() => _isLaunching = true);
    try {
      final uri = Uri.parse(widget.meetingUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) setState(() => _hasJoinedMeeting = true);
      } else {
        if (mounted) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(
          //       'Could not open the meeting link. Please open it manually: ${widget.meetingUrl}',
          //       style: GoogleFonts.poppins(fontSize: 12.sp),
          //     ),
          //     backgroundColor: Colors.red,
          //     behavior: SnackBarBehavior.floating,
          //     duration: const Duration(seconds: 5),
          //   ),
          // );
          AppToast.warning(context,message:'Could not open the meeting link. Please open it manually: ${widget.meetingUrl}', );
          setState(() => _hasJoinedMeeting = true);
        }
      }
    } finally {
      if (mounted) setState(() => _isLaunching = false);
    }
  }

  void _confirm() {
    setState(() => _hasConfirmed = true);
    // ← Pass submissionConfig through to the submission screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<LiveCompetitionProvider>(),
          child: LiveCompetitionSubmissionScreen(
            competition: widget.competition,
            participation: widget.participation,
            round: widget.round,
            submissionConfig: widget.submissionConfig, // ← NEW
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final exit = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r)),
            title: Text('Exit Proctoring Setup?',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            content: Text(
              'Are you sure you want to go back? '
              'You will need to rejoin the meeting to start the exam.',
              style: GoogleFonts.poppins(fontSize: 13.sp),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Stay',
                    style: GoogleFonts.poppins(color: activeItemColor)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Exit',
                    style: GoogleFonts.poppins(
                        color: Colors.red, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
        return exit ?? false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: AppBar(
          backgroundColor: drawerColor,
          foregroundColor: Colors.white,
          title: Text(
            widget.competition.title ?? 'Exam Setup',
            style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WarningBanner(),
              SizedBox(height: 20.h),
              ..._steps.asMap().entries.map(
                    (e) => _StepCard(
                  step: e.value,
                  stepNumber: e.key + 1,
                  isDone: _stepDone(e.key),
                ),
              ),
              SizedBox(height: 24.h),
              _JoinMeetingButton(
                url: widget.meetingUrl,
                title: widget.meetingTitle,
                isLaunching: _isLaunching,
                hasJoined: _hasJoinedMeeting,
                onTap: _launchMeeting,
              ),
              SizedBox(height: 14.h),
              _ConfirmCheckbox(
                enabled: _hasJoinedMeeting,
                confirmed: _hasConfirmed,
                onChanged: (v) => setState(() => _hasConfirmed = v ?? false),
              ),
              SizedBox(height: 20.h),
              _ProceedButton(
                enabled: _hasJoinedMeeting && _hasConfirmed,
                onTap: _confirm,
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  bool _stepDone(int index) {
    if (index == 0) return _hasJoinedMeeting;
    if (index == 1) return _hasJoinedMeeting;
    if (index == 2) return _hasConfirmed;
    return false;
  }
}

// ── Warning Banner ────────────────────────────────────────────────────────────

class _WarningBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.red.shade300, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.security_rounded,
              color: Colors.red.shade700, size: 22.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Proctored Exam — Mandatory Setup',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'This exam is monitored. You MUST complete all three steps '
                  'below before the exam unlocks. Failure to follow instructions '
                  'may result in disqualification.',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5.sp,
                    color: Colors.red.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step Card ─────────────────────────────────────────────────────────────────

class _GatewayStep {
  final IconData icon;
  final Color color;
  final String title, description;
  const _GatewayStep({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });
}

class _StepCard extends StatelessWidget {
  final _GatewayStep step;
  final int stepNumber;
  final bool isDone;

  const _StepCard({
    required this.step,
    required this.stepNumber,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDone ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDone ? Colors.green.shade300 : Colors.grey.shade200,
          width: isDone ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: isDone ? Colors.green : step.color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isDone
                  ? Icon(Icons.check_rounded,
                      color: Colors.white, size: 18.sp)
                  : Text(
                      '$stepNumber',
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: step.color,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(step.icon,
                        size: 16.sp,
                        color: isDone ? Colors.green : step.color),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        step.title,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: isDone
                              ? Colors.green.shade800
                              : const Color(0xFF1A1D26),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                Text(
                  step.description,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5.sp,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Join Meeting Button ───────────────────────────────────────────────────────

class _JoinMeetingButton extends StatelessWidget {
  final String url;
  final String? title;
  final bool isLaunching, hasJoined;
  final VoidCallback onTap;

  const _JoinMeetingButton({
    required this.url,
    required this.isLaunching,
    required this.hasJoined,
    required this.onTap,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLaunching ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: hasJoined ? Colors.green.shade700 : const Color(0xFF1565C0),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: (hasJoined ? Colors.green : const Color(0xFF1565C0))
                  .withOpacity(0.3),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLaunching)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            else ...[
              Icon(
                hasJoined
                    ? Icons.check_circle_rounded
                    : Icons.video_call_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasJoined ? 'Meeting Joined ✓' : 'Join Meeting Now',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      url,
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new_rounded,
                  color: Colors.white70, size: 16.sp),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Confirm Checkbox ──────────────────────────────────────────────────────────

class _ConfirmCheckbox extends StatelessWidget {
  final bool enabled, confirmed;
  final ValueChanged<bool?> onChanged;

  const _ConfirmCheckbox({
    required this.enabled,
    required this.confirmed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: enabled ? () => onChanged(!confirmed) : null,
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: confirmed ? Colors.green.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: confirmed ? Colors.green.shade400 : Colors.grey.shade300,
              width: confirmed ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  color: confirmed ? Colors.green : Colors.white,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color:
                        confirmed ? Colors.green : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: confirmed
                    ? Icon(Icons.check_rounded,
                        color: Colors.white, size: 14.sp)
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'I have joined the meeting and am sharing my entire screen with the proctor.',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: confirmed
                        ? Colors.green.shade800
                        : const Color(0xFF1A1D26),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Proceed Button ────────────────────────────────────────────────────────────

class _ProceedButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _ProceedButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 54.h,
        decoration: BoxDecoration(
          color: enabled ? Colors.green.shade700 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                enabled ? Icons.lock_open_rounded : Icons.lock_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
              SizedBox(width: 10.w),
              Text(
                enabled
                    ? 'Proceed to Exam'
                    : 'Complete steps above first',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}