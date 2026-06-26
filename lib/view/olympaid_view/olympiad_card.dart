import 'dart:async';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/instantresultscreen.dart';
import 'package:firstedu/view_models/examhallprovider/examsessionprovider.dart';
import 'package:firstedu/view_models/olympiadprovider/olympiadcenterprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OlympiadCard extends StatefulWidget {
  final String title;
  final String organizer;
  final String date;
  final String fee;
  final String subject;
  final String description;
  final String status;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final bool isRegistered;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? registrationEndDate;
  final int? discountAmount;
  final int? originalPrice;
  final int? discountedPrice;
  final int? maxParticipants;
  final DateTime? goesLiveAt;

  final bool isExamCompleted;
  final String? examSessionId;
  final String olympiadId;

  final VoidCallback? onTap;
  final VoidCallback? onRegister;
  final VoidCallback? onEnterExam;
  final VoidCallback? onViewResult;
  final DateTime? resultDeclarationDate;

  /// Called when the "live in" countdown reaches zero.
  /// Parent uses this to refresh the list so button state updates automatically.
  final VoidCallback? onCountdownComplete;

  const OlympiadCard({
    super.key,
    required this.title,
    required this.organizer,
    required this.olympiadId,
    required this.date,
    required this.fee,
    required this.status,
    required this.subject,
    required this.description,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.isRegistered = false,
    this.isExamCompleted = false,
    this.examSessionId,
    this.onTap,
    this.onRegister,
    this.onEnterExam,
    this.onViewResult,
    this.startDate,
    this.endDate,
    this.registrationEndDate,
    this.discountAmount,
    this.originalPrice,
    this.discountedPrice,
    this.maxParticipants,
    this.goesLiveAt,
    this.resultDeclarationDate,
    this.onCountdownComplete,
  });

  @override
  State<OlympiadCard> createState() => _OlympiadCardState();
}

class _OlympiadCardState extends State<OlympiadCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _countdownFired = false;

  Duration _resultRemaining = Duration.zero;
  Timer? _resultTimer;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
    _startCountdown();
    _startResultCountdown();
  }

  void _startCountdown() {
    final target = (widget.goesLiveAt ?? widget.startDate)?.toLocal();
    if (target == null) return;
    final diff = target.difference(DateTime.now());
    if (diff.isNegative) return;
    setState(() => _remaining = diff);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final d = target.difference(DateTime.now());
      setState(() => _remaining = d.isNegative ? Duration.zero : d);

      if (d.isNegative) {
        _timer?.cancel();
        // Auto-refresh so the card re-renders with updated button state
        if (!_countdownFired) {
          _countdownFired = true;
          widget.onCountdownComplete?.call();
        }
      }
    });
  }

  void _startResultCountdown() {
    if (widget.resultDeclarationDate == null) return;
    final target = widget.resultDeclarationDate!.toLocal();
    final diff = target.difference(DateTime.now());
    if (diff.isNegative) {
      setState(() => _resultRemaining = Duration.zero);
      return;
    }
    setState(() => _resultRemaining = diff);
    _resultTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final d = target.difference(DateTime.now());
      if (d.isNegative) {
        _resultTimer?.cancel();
        setState(() => _resultRemaining = Duration.zero);
        return;
      }
      setState(() => _resultRemaining = d);
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _timer?.cancel();
    _resultTimer?.cancel();
    super.dispose();
  }

  String get _countdownText {
    final h = _remaining.inHours.toString().padLeft(2, '0');
    final m = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String get _resultCountdownText {
    final h = _resultRemaining.inHours.toString().padLeft(2, '0');
    final m = (_resultRemaining.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_resultRemaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // ── Status helpers ─────────────────────────────────────────────────────────
  String get _s => widget.status.toUpperCase();
  bool get _isOpen => _s == 'OPEN';
  bool get _isLive => _s == 'LIVE';
  bool get _isUpcoming => _s == 'UPCOMING' || _s == 'CLOSE';
  bool get _isCompleted => _s == 'COMPLETED';
  bool get _isClosed => _s == 'CLOSED';

  bool get _showCountdownBadge =>
      (_isOpen || _isUpcoming) && _remaining > Duration.zero;

  Color get _accentColor {
    if (_isLive) return const Color(0xFF1565C0);
    if (_isOpen) return const Color(0xFF2E7D32);
    return Colors.orange.shade600;
  }

  Color get _statusBg {
    if (_isOpen) return const Color(0xFFE8F5E9);
    if (_isLive) return const Color(0xFFE3F2FD);
    if (_isCompleted) return const Color(0xFFF3E5F5);
    if (_isClosed) return const Color(0xFFFFEBEE);
    return const Color(0xFFFFF3E0);
  }

  Color get _statusFg {
    if (_isOpen) return const Color(0xFF2E7D32);
    if (_isLive) return const Color(0xFF1565C0);
    if (_isCompleted) return const Color(0xFF6A1B9A);
    if (_isClosed) return const Color(0xFFC62828);
    return const Color(0xFFE65100);
  }

  bool get _hasDiscount =>
      widget.discountAmount != null &&
      widget.discountAmount! > 0 &&
      widget.originalPrice != null &&
      widget.originalPrice! > 0;

  int? get _discountPercent {
    if (!_hasDiscount) return null;
    return ((widget.discountAmount! / widget.originalPrice!) * 100).round();
  }

  String _fmt(DateTime? dt) {
    if (dt == null) return '—';
    final local = dt.toLocal();
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final h = local.hour > 12
        ? local.hour - 12
        : local.hour == 0
            ? 12
            : local.hour;
    final amPm = local.hour >= 12 ? 'pm' : 'am';
    final mm = local.minute.toString().padLeft(2, '0');
    return '${local.day} ${months[local.month]} ${local.year}, $h:$mm $amPm';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (_, child) =>
          Transform.scale(scale: _scaleAnim.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _animCtrl.forward(),
        onTapUp: (_) {
          _animCtrl.reverse();
          widget.onTap?.call();
        },
        onTapCancel: () => _animCtrl.reverse(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(color: _accentColor, width: 4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Row 1: Status / countdown badge + discount ──────────────
                Row(
                  children: [
                    _showCountdownBadge
                        ? _CountdownBadge(text: 'Live in $_countdownText')
                        : _StatusBadge(
                            label: _s,
                            bg: _statusBg,
                            fg: _statusFg,
                            isLive: _isLive,
                          ),
                    if (_hasDiscount && _discountPercent != null) ...[
                      const SizedBox(width: 8),
                      _DiscountBadge(percent: _discountPercent!),
                    ],
                  ],
                ),

                const SizedBox(height: 10),

                // ── Title ────────────────────────────────────────────────────
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                if (widget.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 14),

                // ── Info rows ────────────────────────────────────────────────
                _InfoRow(
                  icon: Icons.calendar_month_outlined,
                  iconColor: Colors.orange.shade400,
                  text: 'Reg Ends: ${_fmt(widget.registrationEndDate)}',
                ),
                const SizedBox(height: 6),
                _InfoRow(
                  icon: Icons.access_time_rounded,
                  iconColor: Colors.orange.shade400,
                  text: 'Starts: ${_fmt(widget.startDate)}',
                ),
                if (widget.maxParticipants != null) ...[
                  const SizedBox(height: 6),
                  _InfoRow(
                    icon: Icons.people_outline_rounded,
                    iconColor: Colors.orange.shade400,
                    text: 'Max participants: ${widget.maxParticipants}',
                  ),
                ],

                const SizedBox(height: 16),

                // ── Price ────────────────────────────────────────────────────
                _buildPrice(),

                const SizedBox(height: 16),

                // ── Buttons ──────────────────────────────────────────────────
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrice() {
    final displayPrice = int.tryParse(widget.fee) ?? 0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_hasDiscount) ...[
          Text(
            '₹${widget.originalPrice}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 6),
        ],
        Text(
          '₹$displayPrice',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
            height: 1,
          ),
        ),
      ],
    );
  }

Widget _buildButtons() {
  final bool examDone = widget.isExamCompleted;
  final now = DateTime.now();

  final bool isRegistrationExpired = widget.registrationEndDate != null &&
      now.isAfter(widget.registrationEndDate!);

  // ── Local LIVE override ───────────────────────────────────────────────────
  // If startDate has passed but backend hasn't flipped status yet,
  // treat as LIVE locally so the button updates instantly on countdown = 0
  final bool startTimePassed = widget.startDate != null &&
      now.isAfter(widget.startDate!);

  final bool isEffectivelyLive =
      _isLive || (startTimePassed && (_isOpen || _isUpcoming));

  // ── 1. COMPLETED ──────────────────────────────────────────────────────────
  if (_isCompleted) {
    if (!widget.isRegistered) {
      return _twoButtons(
        left: _viewDetailsBtn(),
        right: _disabledBtn(label: 'Not Registered'),
      );
    }

    final resultTime = widget.resultDeclarationDate;
    final bool isResultAvailable =
        resultTime != null && now.isAfter(resultTime);

    return _twoButtons(
      left: _viewDetailsBtn(),
      right: isResultAvailable
          ? _actionBtn(
              label: 'View Result',
              icon: Icons.bar_chart_rounded,
              color: const Color(0xFF2E7D32),
              onTap: () async {
                if (widget.examSessionId != null &&
                    widget.examSessionId!.isNotEmpty) {
                  widget.onViewResult?.call();
                } else {
                  await _handleResultFromCard(context);
                }
              },
            )
          : _disabledBtn(label: 'Result in\n$_resultCountdownText'),
    );
  }

  // ── 2. LIVE (or effectively live after countdown) ─────────────────────────
  if (isEffectivelyLive) {
    final resultTime = widget.resultDeclarationDate;
    final bool isResultAvailable =
        resultTime != null && now.isAfter(resultTime);

    // Exam done + result not yet declared → show ticking countdown
    if (widget.isRegistered && examDone && !isResultAvailable) {
      return _twoButtons(
        left: _viewDetailsBtn(),
        right: _disabledBtn(label: 'Result in\n$_resultCountdownText'),
      );
    }

    // Exam done + result available → View Result
    if (widget.isRegistered && examDone && isResultAvailable) {
      return _twoButtons(
        left: _viewDetailsBtn(),
        right: _actionBtn(
          label: 'View Result',
          icon: Icons.bar_chart_rounded,
          color: const Color(0xFF2E7D32),
          onTap: () async {
            if (widget.examSessionId != null &&
                widget.examSessionId!.isNotEmpty) {
              widget.onViewResult?.call();
            } else {
              await _handleResultFromCard(context);
            }
          },
        ),
      );
    }

    // Registered + exam not done → Enter Exam
    if (widget.isRegistered && !examDone) {
      return _twoButtons(
        left: _viewDetailsBtn(),
        right: _actionBtn(
          label: 'Enter Exam',
          icon: Icons.play_circle_rounded,
          color: const Color(0xFF1565C0),
          onTap: widget.onEnterExam,
        ),
      );
    }

    // Not registered and exam is live
    if (!widget.isRegistered) {
      return _twoButtons(
        left: _viewDetailsBtn(),
        right: _disabledBtn(label: 'Not Registered'),
      );
    }
  }

  // ── 3. OPEN ───────────────────────────────────────────────────────────────
  if (_isOpen) {
    if (isRegistrationExpired && !widget.isRegistered) {
      return _twoButtons(
        left: _viewDetailsBtn(),
        right: _disabledBtn(label: 'Registration Closed'),
      );
    }
    if (widget.onRegister != null) {
      return _twoButtons(
        left: _viewDetailsBtn(),
        right: _actionBtn(
          label: 'Register',
          icon: Icons.how_to_reg_rounded,
          color: drawerColor,
          onTap: widget.onRegister,
        ),
      );
    }
    // Already registered — show registered state
    return _twoButtons(
      left: _viewDetailsBtn(),
      right: _registeredBtn(),
    );
  }

  // ── 4. UPCOMING / CLOSED ──────────────────────────────────────────────────
  if (_isUpcoming) {
    return _twoButtons(
      left: _viewDetailsBtn(),
      right: _disabledBtn(label: 'Coming Soon'),
    );
  }

  if (_isClosed) {
    return _twoButtons(
      left: _viewDetailsBtn(),
      right: _disabledBtn(label: 'Registration\nClosed'),
    );
  }

  return _viewDetailsBtn();
}
  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _twoButtons({required Widget left, required Widget right}) => Row(
        children: [
          Expanded(child: left),
          const SizedBox(width: 10),
          Expanded(child: right),
        ],
      );

  Widget _viewDetailsBtn() => OutlinedButton.icon(
        onPressed: widget.onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 13),
          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          foregroundColor: const Color(0xFF1A1A2E),
          backgroundColor: Colors.white,
        ),
        icon: const Icon(Icons.remove_red_eye_outlined, size: 15),
        label: const Text(
          'View Details',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      );

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _registeredBtn() => Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined,
                size: 15, color: Color(0xFF2E7D32)),
            SizedBox(width: 6),
            Text(
              'Registered',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      );

  Widget _disabledBtn({required String label}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined,
                size: 15, color: Colors.grey.shade400),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      );

  Future<void> _handleResultFromCard(BuildContext context) async {
    try {
      final provider = context.read<OlympiadProvider>();
      await provider.fetchDetail(context, widget.olympiadId);
      final sessionId = provider.detail?.testSessionId;
      if (sessionId == null || sessionId.isEmpty) {
        AppToast.error(context,
            title: 'Error', message: 'No result session found');
        return;
      }
      final examProvider = context.read<ExamSessionProvider>();
      await examProvider.fetchResults(sessionId);
      final resultsData = examProvider.results;
      List<double> scoreProgression = [];
      if (resultsData?.questions != null) {
        int correct = 0;
        int total = 0;
        for (final q in resultsData!.questions ?? []) {
          total++;
          if (q.isCorrect == true) correct++;
          scoreProgression.add((correct / total) * 100);
        }
      }
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InstantResultsScreen(
              scoreProgression: scoreProgression,
              resultsData: resultsData,
            ),
          ),
        );
      }
    } catch (e) {
      AppToast.error(context, title: 'Error', message: 'Failed to load result');
    }
  }
}

// ── Countdown badge ───────────────────────────────────────────────────────────

class _CountdownBadge extends StatelessWidget {
  final String text;
  const _CountdownBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1565C0).withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1565C0),
          letterSpacing: 0.2,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final bool isLive;
  const _StatusBadge({
    required this.label,
    required this.bg,
    required this.fg,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLive) ...[_LiveDot(color: fg), const SizedBox(width: 5)],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Discount badge ────────────────────────────────────────────────────────────

class _DiscountBadge extends StatelessWidget {
  final int percent;
  const _DiscountBadge({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2E7D32).withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Text(
        '$percent% OFF',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2E7D32),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Info row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Animated LIVE dot ─────────────────────────────────────────────────────────

class _LiveDot extends StatefulWidget {
  final Color color;
  const _LiveDot({required this.color});

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _anim,
        child: Icon(Icons.circle, size: 7, color: widget.color),
      );
}