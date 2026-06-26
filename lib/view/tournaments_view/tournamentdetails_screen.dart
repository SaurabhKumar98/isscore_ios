import 'dart:async';
import 'package:firstedu/data/models/api_models/tournament/tournamentdetailsbyid_models.dart';
import 'package:firstedu/data/repo/examhall/examsessionrepositories.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_button.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/questionscreen.dart';
import 'package:firstedu/view/tournaments_view/tournamentpaymentsheet.dart';
import 'package:firstedu/view/tournaments_view/tournaments_screen.dart';
import 'package:firstedu/view_models/examhallprovider/examhallwebsocket.dart';
import 'package:firstedu/view_models/examhallprovider/examsessionprovider.dart';
import 'package:firstedu/view_models/tournamentprovider/tournament_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TournamentDetailScreen extends StatefulWidget {
  final String tournamentId;
  final String? tournamentTitle;

  const TournamentDetailScreen({
    super.key,
    required this.tournamentId,
    this.tournamentTitle,
  });

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen>
    with RouteAware {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetch());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Subscribe to the same observer so didPopNext fires on back
    tournamentRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    tournamentRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // ✅ Auto-refresh when returning from exam screen
    _fetch();
  }

  void _fetch() {
    if (mounted) {
      context
          .read<TournamentProvider>()
          .fetchTournament(context, widget.tournamentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Consumer<TournamentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final t = provider.tournament;
          if (t == null) {
            return const Center(child: Text("Tournament not found"));
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(t),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 100.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusRow(tournament: t),
                      SizedBox(height: 20.h),
                      _PrizeCard(tournament: t),
                      SizedBox(height: 16.h),
                      _InfoCard(tournament: t),
                      SizedBox(height: 16.h),
                      _StagesCard(tournament: t),
                      SizedBox(height: 24.h),
                      _ActionButton(tournament: t),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(Data t) {
    return SliverAppBar(
      expandedHeight: 200.h,
      pinned: true,
      backgroundColor: const Color(0xFF1A2340),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A2340),
            image: t.imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(t.imageUrl!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.55),
                      BlendMode.darken,
                    ),
                  )
                : null,
          ),
          child: Stack(
            children: [
              Positioned(
                  right: -20.w, top: 20.h, child: _bubble(100.w, 0.06)),
              Positioned(
                  right: 60.w, bottom: 10.h, child: _bubble(70.w, 0.04)),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    20.w, kToolbarHeight + 20.h, 20.w, 20.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (t.isEventLive ?? false)
                      Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.w,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle),
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      t.title ?? "",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bubble(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  STATUS ROW
// ─────────────────────────────────────────────────────────────────────────────

class _StatusRow extends StatelessWidget {
  final Data tournament;
  const _StatusRow({required this.tournament});

  Color get _color {
    if (tournament.isEventLive ?? false) return const Color(0xFFF97316);
    if (tournament.isRegistrationOpen ?? false) return const Color(0xFF16A34A);
    switch (tournament.status?.toLowerCase()) {
      case 'upcoming':
        return const Color(0xFF2563EB);
      default:
        return Colors.grey;
    }
  }

  String get _label {
    if (tournament.isEventLive ?? false) return 'LIVE NOW';
    if (tournament.isRegistrationOpen ?? false) return 'REGISTRATION OPEN';
    switch (tournament.status?.toLowerCase()) {
      case 'upcoming':
        return 'UPCOMING';
      case 'completed':
        return 'COMPLETED';
      default:
        return tournament.status?.toUpperCase() ?? 'UNKNOWN';
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectivePrice = tournament.effectivePrice;
    final originalPrice = tournament.originalPrice;
    final isFree = effectivePrice == 0;
    final hasDiscount = (tournament.discountAmount ?? 0) > 0;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: _color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: _color.withOpacity(0.35)),
          ),
          child: Text(
            _label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: _color,
              letterSpacing: 0.4,
            ),
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasDiscount && (originalPrice ?? 0) > 0)
              Text(
                '₹$originalPrice',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.black38,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Colors.black38,
                ),
              ),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isFree
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                isFree ? 'FREE' : '₹$effectivePrice',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color:
                      isFree ? const Color(0xFF2E7D32) : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PRIZE CARD
// ─────────────────────────────────────────────────────────────────────────────

class _PrizeCard extends StatelessWidget {
  final Data tournament;
  const _PrizeCard({required this.tournament});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F1B3C), Color(0xFF162556)],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_rounded,
                  color: Colors.amber, size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                'Prize Points',
                style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _prizeTile('🥇', '1st Place',
                  '${tournament.firstPlacePoints} pts', const Color(0xFFFFD700)),
              SizedBox(width: 10.w),
              _prizeTile('🥈', '2nd Place',
                  '${tournament.secondPlacePoints} pts', const Color(0xFFCDD0DA)),
              SizedBox(width: 10.w),
              _prizeTile('🥉', '3rd Place',
                  '${tournament.thirdPlacePoints} pts', const Color(0xFFCD7F32)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _prizeTile(String emoji, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 20.sp)),
            SizedBox(height: 6.h),
            Text(value,
                style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: color)),
            SizedBox(height: 2.h),
            Text(label,
                style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  INFO CARD
// ─────────────────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final Data tournament;
  const _InfoCard({required this.tournament});

  String _fmt(DateTime? dt) {
    if (dt == null) return '—';
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour >= 12 ? 'pm' : 'am';
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}, $h:$min $ap';
  }

  @override
  Widget build(BuildContext context) {
    return _card(
      title: 'Tournament Info',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          _row(Icons.app_registration_rounded, 'Reg Opens',
              _fmt(tournament.registrationStartTime)),
          _divider(),
          _row(Icons.app_registration_rounded, 'Reg Ends',
              _fmt(tournament.registrationEndTime)),
          if (tournament.goesLiveAt != null) ...[
            _divider(),
            _row(
              Icons.play_circle_outline_rounded,
              'Goes Live',
              _fmt(DateTime.tryParse(tournament.goesLiveAt.toString()) ??
                  tournament.registrationEndTime),
            ),
          ],
          _divider(),
          _row(Icons.layers_rounded, 'Total Stages',
              '${tournament.stages?.length}'),
          _divider(),
          _row(
            Icons.flag_rounded,
            'Current Stage',
            tournament.currentStage != null
                ? ((tournament.currentStage['name'] as String?) ?? '—')
                : '—',
          ),
          if (tournament.isRegistered ?? false) ...[
            _divider(),
            _row(Icons.check_circle_rounded, 'Registration', 'Registered ✓',
                valueColor: const Color(0xFF16A34A)),
          ],
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 11.h),
      child: Row(
        children: [
          Icon(icon, size: 15.sp, color: Colors.black38),
          SizedBox(width: 10.w),
          Text(label,
              style: TextStyle(fontSize: 13.sp, color: Colors.black54)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87)),
        ],
      ),
    );
  }

  Widget _divider() => Divider(color: Colors.grey.shade100, height: 1);
}

// ─────────────────────────────────────────────────────────────────────────────
//  STAGES CARD
// ─────────────────────────────────────────────────────────────────────────────

class _StagesCard extends StatelessWidget {
  final Data tournament;
  const _StagesCard({required this.tournament});

  @override
  Widget build(BuildContext context) {
    final stages = tournament.stages;
    if (stages == null || stages.isEmpty) return const SizedBox.shrink();

    return _card(
      title: 'Stages',
      icon: Icons.layers_rounded,
      child: Column(
        children: stages.asMap().entries.map((entry) {
          final i = entry.key;
          final stage = entry.value;
          final isLast = i == stages.length - 1;
          final isQualified =
              tournament.qualifiedStages?.contains(stage.id) ?? false;
          final isCurrent = tournament.currentStage != null &&
              (tournament.currentStage['_id'] as String?) == stage.id;

          return Column(
            children: [
              _StageTile(
                stage: stage,
                index: i,
                isQualified: isQualified,
                isCurrent: isCurrent,
                isLast: isLast,
                isRegistered: tournament.isRegistered ?? false,
                data: tournament,
              ),
              if (!isLast)
                Padding(
                  padding: EdgeInsets.only(left: 20.w),
                  child: Row(
                    children: [
                      Container(
                          width: 2.w,
                          height: 20.h,
                          color: Colors.grey.shade200),
                    ],
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  STAGE TILE
// ─────────────────────────────────────────────────────────────────────────────

class _StageTile extends StatefulWidget {
  final Stage stage;
  final int index;
  final bool isQualified;
  final bool isCurrent;
  final bool isLast;
  final bool isRegistered;
  final Data? data;

  const _StageTile({
    required this.stage,
    required this.index,
    required this.isQualified,
    required this.isCurrent,
    required this.isLast,
    required this.isRegistered,
    this.data,
  });

  @override
  State<_StageTile> createState() => _StageTileState();
}

class _StageTileState extends State<_StageTile> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startCountdownIfNeeded();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdownIfNeeded() {
    final stage = widget.stage;
    if (stage.status == 'completed' || (stage.isEventLive ?? false)) return;
    if (stage.startTime == null) return;

    final diff = stage.startTime!.difference(DateTime.now());
    if (diff <= Duration.zero) return;

    _remaining = diff;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final newDiff = widget.stage.startTime!.difference(DateTime.now());
      if (newDiff <= Duration.zero) {
        _timer?.cancel();
        setState(() => _remaining = Duration.zero);
      } else {
        setState(() => _remaining = newDiff);
      }
    });
  }

  bool get _showCountdown =>
      _remaining > Duration.zero &&
      widget.stage.status != 'completed' &&
      !(widget.stage.isEventLive ?? false);

  String get _countdownLabel {
    final d = _remaining.inDays;
    final h = _remaining.inHours.remainder(24);
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d > 0) return '${d}d ${h}h ${m}m ${s}s';
    if (h > 0) return '${h}h ${m}m ${s}s';
    return '${m}m ${s}s';
  }

  Color get _stageColor {
    if (widget.isQualified) return const Color(0xFF16A34A);
    if (widget.isCurrent) return const Color(0xFFF97316);
    switch (widget.index) {
      case 0:
        return Colors.orange;
      case 1:
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF7C3AED);
    }
  }

  String _fmt(DateTime dt) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${m[dt.month - 1]}, ${dt.year}';
  }

  /// ✅ Button label driven purely by backend testStatus
  String get _buttonLabel {
    if (!widget.isRegistered) return 'Not Registered';
    final testStatus = widget.stage.test?.testStatus;
    switch (testStatus) {
      case 'completed':
        return 'View Result';
      case 'in_progress':
      case 'resume':
        return 'Resume';
      case 'not_started':
        return 'Join Now';
      default:
        return 'Join Now';
    }
  }

  IconData get _buttonIcon {
    final testStatus = widget.stage.test?.testStatus;
    switch (testStatus) {
      case 'completed':
        return Icons.bar_chart_rounded;
      case 'in_progress':
      case 'resume':
        return Icons.play_circle_outline_rounded;
      default:
        return Icons.play_arrow_rounded;
    }
  }

  Color get _buttonColor {
    final testStatus = widget.stage.test?.testStatus;
    switch (testStatus) {
      case 'completed':
        return const Color(0xFF5B93FF);
      case 'in_progress':
      case 'resume':
        return Colors.orange;
      default:
        return const Color(0xFF16A34A);
    }
  }

  /// ✅ Enabled only when backend says canJoin OR viewing a completed result
  bool get _isButtonEnabled {
    if (!widget.isRegistered) return false;

    final stage = widget.stage;
    final testStatus = stage.test?.testStatus;

    // Always allow viewing result
    if (testStatus == 'completed') {
      return stage.test?.sessionId != null &&
          stage.test!.sessionId!.isNotEmpty;
    }

    // For joining/resuming — trust backend canJoin flag entirely
    return stage.canJoin ?? false;
  }

  String get _stageBadgeLabel {
    final stage = widget.stage;
    final prev = stage.previousStageQualification;

    if (stage.isEventLive ?? false) return 'LIVE';

    if (prev != null) {
      if (!(prev.previousRoundEnded ?? false)) return 'WAITING';
      if (!(prev.meetsScoreThreshold ?? false)) return 'NOT ELIGIBLE';
      if (prev.canAdvanceToThisStage ?? false) return 'ELIGIBLE';
      return 'NOT ELIGIBLE';
    }

    if (stage.status == 'upcoming') {
      return (stage.eligibleForStage ?? false) ? 'ELIGIBLE' : 'NOT ELIGIBLE';
    }
    if (stage.status == 'completed') return 'COMPLETED';
    return stage.status?.toUpperCase() ?? 'UNKNOWN';
  }

  Color get _stageBadgeColor {
    final stage = widget.stage;
    final prev = stage.previousStageQualification;

    if (stage.isEventLive ?? false) return const Color(0xFFF97316);

    if (prev != null) {
      if (!(prev.previousRoundEnded ?? false)) return Colors.orange;
      if (!(prev.meetsScoreThreshold ?? false)) return Colors.red;
      if (prev.canAdvanceToThisStage ?? false) return const Color(0xFF16A34A);
      return Colors.red;
    }

    if (stage.status == 'upcoming') {
      return (stage.eligibleForStage ?? false)
          ? const Color(0xFF16A34A)
          : Colors.red;
    }
    if (stage.status == 'completed') return Colors.grey;
    return Colors.grey;
  }

 void _handleButton(BuildContext context) {
  final stage      = widget.stage;
  final testStatus = stage.test?.testStatus ?? 'not_started';
  final testId     = stage.test?.id;
  final sessionId  = stage.test?.sessionId;
  final testTitle  = stage.test?.title ?? stage.name ?? '';

  if (testStatus == 'completed') {
    if (sessionId == null || sessionId.isEmpty) return;
    _navigate(
      context,
      ExamResultsScreen(
        sessionId: sessionId,
        showInstantResult: false,                      // ✅ tournament — gate by date
        resultDeclaredAt: widget.stage.endTime, // ✅ pass from tournament model
      ),
    );
    return;
  }

  if (testId == null || testId.isEmpty) return;

  final effectiveSessionId =
      (sessionId == null || sessionId.isEmpty) ? null : sessionId;

_navigate(
  context,
  ExamScreen(
    testId: testId,
    examTitle: testTitle,
    existingSessionId:
        (testStatus == 'in_progress' || testStatus == 'resume')
            ? effectiveSessionId
            : null,
    resultDeclaredAt: widget.data?.resultDeclaredAt,
    showInstantResult: false,
  ),
);
}
  
  
  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (ctx) => ExamSessionProvider(
            ctx.read<ExamSessionRepository>(),
            ExamSocketService(),
          ),
          child: screen,
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      final tournamentId =
          context.read<TournamentProvider>().tournament?.id;
      if (tournamentId != null && tournamentId.isNotEmpty) {
        context.read<TournamentProvider>().fetchTournament(
              context,
              tournamentId,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final stage = widget.stage;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: widget.isCurrent
            ? _stageColor.withOpacity(0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        border: widget.isCurrent
            ? Border.all(color: _stageColor.withOpacity(0.3), width: 1.5)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circle indicator
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _stageColor.withOpacity(0.12),
              border:
                  Border.all(color: _stageColor.withOpacity(0.4), width: 1.5),
            ),
            child: Center(
              child: widget.isQualified
                  ? Icon(Icons.check_rounded,
                      color: _stageColor, size: 16.sp)
                  : Text(
                      '${widget.index + 1}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: _stageColor,
                      ),
                    ),
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stage name + badges
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: [
                    Text(
                      stage.name ?? "",
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87),
                    ),
                    _badge(_stageBadgeLabel, _stageBadgeColor),
                    if (widget.isCurrent)
                      _badge('CURRENT', _stageColor),
                    if (widget.isQualified)
                      _badge('QUALIFIED', const Color(0xFF16A34A)),
                  ],
                ),

                SizedBox(height: 4.h),

                // Date range
                Row(
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 12.sp, color: Colors.black38),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        '${stage.startTime != null ? _fmt(stage.startTime!.toLocal()) : "—"}'
                        ' – '
                        '${stage.endTime != null ? _fmt(stage.endTime!.toLocal()) : "—"}',
                        style: TextStyle(
                            fontSize: 11.sp, color: Colors.black45),
                      ),
                    ),
                  ],
                ),

                if ((stage.minimumPercentageToQualify ?? 0) > 0) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.star_border_rounded,
                          size: 12.sp, color: Colors.black38),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Min to qualify: ${stage.minimumPercentageToQualify}%',
                              style: TextStyle(
                                  fontSize: 11.sp, color: Colors.black45),
                            ),
                            Text(
                              'Max participants: ${stage.maxParticipants ?? "—"}',
                              style: TextStyle(
                                  fontSize: 11.sp, color: Colors.black45),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                // Countdown timer
                if (_showCountdown) ...[
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                          color: Colors.orange.withOpacity(0.35), width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_outlined,
                            size: 14.sp, color: Colors.orange),
                        SizedBox(width: 6.w),
                        Text(
                          'Starts in  $_countdownLabel',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 10.h),

                // ✅ Button — shown only when registered, driven by backend
                if (widget.isRegistered)
                  CustomButton(
                    title: _buttonLabel,
                    icon: _buttonIcon,
                    onTap: _isButtonEnabled
                        ? () => _handleButton(context)
                        : null,
                    backgroundColor: _isButtonEnabled
                        ? _buttonColor
                        : Colors.grey.shade300,
                    textColor:
                        _isButtonEnabled ? Colors.white : Colors.grey,
                    height: 40.h,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 8.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  ACTION BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final Data tournament;
  const _ActionButton({required this.tournament});

  String get _label {
    if (tournament.isRegistered ?? false) {
      if (tournament.canJoin ?? false) return 'Go to Current Stage';
      return 'Already Registered';
    }
    if (!(tournament.isRegistrationOpen ?? false)) return 'Registration Closed';
    return 'Register Now';
  }

  bool get _enabled {
    if ((tournament.isRegistered ?? false) && !(tournament.canJoin ?? false)) {
      return false;
    }
    if (tournament.canJoin ?? false) return true;
    return tournament.isRegistrationOpen ?? false;
  }

  Color get _color {
    if (tournament.canJoin ?? false) return const Color(0xFF16A34A);
    if (!(tournament.isRegistrationOpen ?? false)) return Colors.grey.shade400;
    return drawerColor;
  }

  IconData get _icon {
    if (tournament.canJoin ?? false) return Icons.arrow_downward_rounded;
    if (!(tournament.isRegistrationOpen ?? false))
      return Icons.lock_outline_rounded;
    return Icons.how_to_reg_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton.icon(
        onPressed: _enabled
            ? () {
                if (tournament.isRegistered == true) return;

                if (tournament.canJoin ?? false) {
                  AppToast.showGlobal(
                    message:
                        'Tap the Join Now button inside your current stage above',
                  );
                  return;
                }

                if (tournament.isRegistrationOpen ?? false) {
                  showTournamentPaymentSheet(context, tournament: tournament);
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _enabled ? _color : Colors.grey.shade200,
          foregroundColor: _enabled ? Colors.white : Colors.grey,
          disabledBackgroundColor: Colors.grey.shade200,
          disabledForegroundColor: Colors.grey,
          elevation: _enabled ? 3 : 0,
          shadowColor: _color.withOpacity(0.35),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r)),
        ),
        icon: Icon(_icon, size: 20.sp),
        label: Text(
          _label,
          style:
              TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SHARED CARD WRAPPER
// ─────────────────────────────────────────────────────────────────────────────

Widget _card({
  required String title,
  required IconData icon,
  required Widget child,
}) {
  return Builder(builder: (context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(7.w),
                  decoration: BoxDecoration(
                    color: drawerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, size: 15.sp, color: drawerColor),
                ),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey.shade100, height: 1),
          Padding(padding: EdgeInsets.all(16.w), child: child),
        ],
      ),
    );
  });
}