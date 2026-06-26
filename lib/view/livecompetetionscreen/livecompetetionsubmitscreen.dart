import 'dart:async';

import 'package:firstedu/data/models/api_models/livecompetetion/livecompetionmodels.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view_models/livecompetetionprovider/livecompetetiondetailsprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LiveCompetitionSubmissionScreen extends StatefulWidget {
  final LiveCompetition competition;
  final LiveParticipationData participation;
  final String round;
  final LiveCompetitionSubmission? submissionConfig; // ← NEW

  const LiveCompetitionSubmissionScreen({
    required this.competition,
    required this.participation,
    required this.round,
    this.submissionConfig, // ← NEW
    super.key,
  });

  @override
  State<LiveCompetitionSubmissionScreen> createState() =>
      _LiveCompetitionSubmissionScreenState();
}

class _LiveCompetitionSubmissionScreenState
    extends State<LiveCompetitionSubmissionScreen> {
  final TextEditingController _textCtrl = TextEditingController();

  Timer? _countdownTimer;
  Timer? _draftTimer;

  int _secondsRemaining = 0;
  bool _isSubmitting = false;
  bool _isSavingDraft = false;
  int _wordCount = 0;

  LiveCompetition get comp => widget.competition;

  // ── Use passed-in submissionConfig instead of top-level comp.submission ──
  LiveCompetitionSubmission? get _sub => widget.submissionConfig;

  int get _wordLimit => _sub?.text?.limit ?? 0;
  int get _durationMinutes => _sub?.duration ?? 0;
  bool get _limitByWords => (_sub?.text?.limitType ?? 'WORDS') == 'WORDS';

  @override
  void initState() {
    super.initState();
    _secondsRemaining = _durationMinutes * 60;
    _startCountdown();
    _startDraftTimer();
    _textCtrl.addListener(_onTextChanged);
  }

  // ── Countdown timer ───────────────────────────────────────────────────────
  void _startCountdown() {
    // Only start if duration is set
    if (_durationMinutes <= 0) return;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsRemaining <= 0) {
        _countdownTimer?.cancel();
        _autoSubmit();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  // ── Auto-save draft every 30 seconds ─────────────────────────────────────
  void _startDraftTimer() {
    _draftTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _saveDraft();
    });
  }

  Future<void> _saveDraft() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || _isSubmitting) return;

    setState(() => _isSavingDraft = true);
    final provider = context.read<LiveCompetitionProvider>();
    await provider.saveDraft(
      competitionId: comp.id!,
      textContent: text,
      round: widget.round,
    );
    if (mounted) setState(() => _isSavingDraft = false);
  }

  void _onTextChanged() {
    final words = _textCtrl.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    setState(() => _wordCount = words);
  }

  void _autoSubmit() {
    if (!_isSubmitting) _handleSubmit(autoSubmit: true);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _draftTimer?.cancel();
    _textCtrl.dispose();
    super.dispose();
  }

  // ── Timer display ─────────────────────────────────────────────────────────
  String get _timerDisplay {
    if (_durationMinutes <= 0) return '∞';
    final h = _secondsRemaining ~/ 3600;
    final m = (_secondsRemaining % 3600) ~/ 60;
    final s = _secondsRemaining % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color get _timerColor {
    if (_durationMinutes <= 0) return Colors.blue;
    if (_secondsRemaining <= 60) return Colors.red;
    if (_secondsRemaining <= 300) return Colors.orange;
    return Colors.green;
  }

  double get _wordProgress =>
      _wordLimit > 0 ? (_wordCount / _wordLimit).clamp(0.0, 1.0) : 0;

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _confirmExit(context),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildTopicCard(),
            _buildTopBar(),
            Expanded(child: _buildEditor()),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() => AppBar(
        backgroundColor: drawerColor,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              comp.title ?? 'Live Competition',
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              _isSavingDraft ? 'Saving draft…' : 'Write & Submit',
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: _isSavingDraft ? Colors.yellow[200] : Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 14.w, top: 10.h, bottom: 10.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _timerColor,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, size: 14.sp, color: Colors.white),
                SizedBox(width: 4.w),
                Text(
                  _timerDisplay,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildTopicCard() {
    // ← Fixed: use _sub instead of comp.submission
    final topic = _sub?.text?.topic ?? '';

    if (topic.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade50,
            Colors.deepOrange.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.topic_outlined,
                  color: Colors.orange,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'Competition Topic',
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            topic,
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1D26),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() => Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.format_list_numbered_outlined,
                    size: 15.sp, color: activeItemColor),
                SizedBox(width: 6.w),
                Text(
                  _limitByWords
                      ? '$_wordCount / $_wordLimit words'
                      : '$_wordCount words',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: _wordCount > _wordLimit && _wordLimit > 0
                        ? Colors.red
                        : Colors.black54,
                  ),
                ),
                const Spacer(),
                if (_limitByWords && _wordLimit > 0)
                  Text(
                    '${(_wordProgress * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color:
                          _wordProgress >= 1 ? Colors.red : activeItemColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            if (_limitByWords && _wordLimit > 0) ...[
              SizedBox(height: 6.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: _wordProgress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(
                    _wordProgress >= 1 ? Colors.red : activeItemColor,
                  ),
                  minHeight: 5.h,
                ),
              ),
            ],
          ],
        ),
      );

  Widget _buildEditor() => Container(
        margin: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _textCtrl,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          style: GoogleFonts.merriweather(
            fontSize: 14.sp,
            color: const Color(0xFF1A1D26),
            height: 1.7,
          ),
          decoration: InputDecoration(
            hintText: 'Start writing your essay here…',
            hintStyle: GoogleFonts.merriweather(
              fontSize: 14.sp,
              color: Colors.black26,
              fontStyle: FontStyle.italic,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(16.w),
          ),
        ),
      );

  Widget _buildBottomBar() => Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
        child: Row(
          children: [
            GestureDetector(
              onTap: _isSubmitting ? null : _saveDraft,
              child: Container(
                height: 52.h,
                width: 52.h,
                margin: EdgeInsets.only(right: 10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F1F7),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Center(
                  child: _isSavingDraft
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: activeItemColor,
                          ),
                        )
                      : Icon(Icons.save_outlined,
                          color: activeItemColor, size: 22.sp),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _isSubmitting ? null : () => _handleSubmit(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 52.h,
                  decoration: BoxDecoration(
                    color:
                        _isSubmitting ? Colors.grey[300] : Colors.green[700],
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: _isSubmitting
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Center(
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.send_rounded,
                                  size: 18.sp, color: Colors.white),
                              SizedBox(width: 8.w),
                              Text(
                                'Submit Work',
                                style: GoogleFonts.poppins(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Future<void> _handleSubmit({bool autoSubmit = false}) async {
    final text = _textCtrl.text.trim();

    if (!autoSubmit && text.isEmpty) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Please write something before submitting.',
      //         style: GoogleFonts.poppins()),
      //     backgroundColor: Colors.orange,
      //     behavior: SnackBarBehavior.floating,
      //   ),
      // );
      AppToast.warning(context, message: 'Please write something before submitting.');
      return;
    }

    if (!autoSubmit) {
      final confirmed = await _confirmSubmit(context);
      if (!confirmed) return;
    }

    setState(() => _isSubmitting = true);
    _countdownTimer?.cancel();
    _draftTimer?.cancel();

    final provider = context.read<LiveCompetitionProvider>();
    final ok = await provider.submitWork(
      context,
      competitionId: comp.id!,
      round: widget.round,
      textContent: text.isEmpty ? null : text,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (ok) {
      _showSubmitSuccess();
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //         provider.singleError ?? 'Submission failed. Please try again.',
      //         style: GoogleFonts.poppins()),
      //     backgroundColor: Colors.red,
      //     behavior: SnackBarBehavior.floating,
      //   ),
      // );
      AppToast.error(context, message: provider.singleError?? 'Submission failed. Please try again.');
    }
  }

  void _showSubmitSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r)),
        title: Column(
          children: [
            Icon(Icons.check_circle_rounded,
                size: 56.sp, color: Colors.green[600]),
            SizedBox(height: 12.h),
            Text(
              'Submitted!',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
        content: Text(
          'Your work has been submitted successfully. Results will be announced soon.',
          textAlign: TextAlign.center,
          style:
              GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black54),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                'Done',
                style: GoogleFonts.poppins(
                  color: activeItemColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmSubmit(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: Text('Submit Work?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
          'Once submitted, you cannot edit your work. Are you sure?',
          style: GoogleFonts.poppins(fontSize: 13.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Submit',
                style: GoogleFonts.poppins(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<bool> _confirmExit(BuildContext context) async {
    await _saveDraft();

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: Text('Exit Submission?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
          'Your progress has been saved as a draft. Exit?',
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
    return result ?? false;
  }
}