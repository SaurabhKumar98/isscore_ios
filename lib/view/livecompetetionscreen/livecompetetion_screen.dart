import 'package:firstedu/data/models/api_models/livecompetetion/livecompetionmodels.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_silverappbar.dart';
import 'package:firstedu/view/livecompetetionscreen/livecometitionpaymentsheet.dart';
import 'package:firstedu/view_models/livecompetetionprovider/livecompetetiondetailsprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class LiveCompetitionsScreen extends StatefulWidget {
  const LiveCompetitionsScreen({super.key});

  @override
  State<LiveCompetitionsScreen> createState() =>
      _LiveCompetitionsScreenState();
}

class _LiveCompetitionsScreenState extends State<LiveCompetitionsScreen> {
  String? _filterCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filterCategoryId =
          ModalRoute.of(context)?.settings.arguments as String?;
      context.read<LiveCompetitionProvider>()
        ..setRootContext(context)
        ..fetchLiveCompetitions(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: Consumer<LiveCompetitionProvider>(
        builder: (context, provider, _) {
          final list = _filterCategoryId != null
              ? provider.liveList
                  .where((c) => c.category?.id == _filterCategoryId)
                  .toList()
              : provider.liveList;

          final screenTitle =
              (_filterCategoryId != null && list.isNotEmpty)
                  ? list.first.category?.name ?? 'Live Competitions'
                  : 'Live Competitions';

          return RefreshIndicator(
                  onRefresh: () => provider.fetchLiveCompetitions(context),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                CustomSliverAppBar(
                  title: screenTitle,
                  subtitle:
                      'Participate in real-time events and win accolades.',
                ),
                if (provider.isLoading)
                  const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()))
                else if (provider.error != null)
                  SliverFillRemaining(
                    child: _ErrorView(
                      message: provider.error!,
                      onRetry: () =>
                          provider.fetchLiveCompetitions(context),
                    ),
                  )
                else if (list.isEmpty)
                  const SliverFillRemaining(child: _EmptyView())
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) =>
                            _CompetitionCard(competition: list[i]),
                        childCount: list.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CompetitionCard extends StatelessWidget {
  final LiveCompetition competition;
  const _CompetitionCard({required this.competition});


  bool get _r1HasRegistered =>
      competition.studentStatus?.megaAudition?.hasRegistered ??
      competition.hasRegistered ??
      false;

  bool get _r1HasSubmitted =>
      competition.studentStatus?.megaAudition?.hasSubmitted ??
      competition.hasSubmitted ??
      false;

  bool get _r1IsQualified =>
      competition.studentStatus?.megaAudition?.isQualified ?? false;

  String? get _r1ResultStatus =>
      competition.studentStatus?.megaAudition?.resultStatus;

  /// Round 2 state
  bool get _r2HasRegistered =>
      competition.studentStatus?.grandFinale?.hasRegistered ?? false;

  bool get _r2HasSubmitted =>
      competition.studentStatus?.grandFinale?.hasSubmitted ?? false;

  /// Event / registration open flags (prefer megaAudition, fallback top-level)
  bool get _r1IsRegOpen =>
      competition.megaAudition?.isRegistrationOpen ??
      competition.isRegistrationOpen ??
      false;

  bool get _r1IsEventLive =>
      competition.megaAudition?.isEventLive ??
      competition.isEventLive ??
      false;

  bool get _r1IsResultDeclared =>
      competition.megaAudition?.status == 'RESULT_DECLARED' ||
      competition.status == 'RESULT_DECLARED';

  /// Round 2 availability — only shown when isVisible = true
  bool get _r2IsVisible =>
      competition.grandFinale?.isVisible ?? false;

  bool get _r2IsPaymentOpen =>
      competition.grandFinale?.isPaymentOpen ?? false;

  bool get _r2IsEventLive =>
      competition.grandFinale?.isEventLive ?? false;

  bool get _r2IsResultDeclared =>
      competition.grandFinale?.status == 'RESULT_DECLARED';

  /// Price helpers (megaAudition → top-level fallback)
  double get _effectivePrice {
    final dp = competition.megaAudition?.discountedPrice ??
        competition.discountedPrice;
    if (dp != null) return dp;
    return (competition.megaAudition?.fee?.amount ??
            competition.fee?.amount)
            ?.toDouble() ??
        0;
  }

  double get _originalPrice =>
      (competition.megaAudition?.fee?.amount ?? competition.fee?.amount)
          ?.toDouble() ??
      0;

  bool get _isFree {
    final isPaid = competition.megaAudition?.fee?.isPaid ??
        competition.fee?.isPaid;
    return isPaid == false || _originalPrice == 0;
  }

  // ── Status chip colour / label ─────────────────────────────────────────────
  static Color _statusColor(String? s) {
    switch (s) {
      case 'LIVE':
        return const Color(0xFFE53935);
      case 'UPCOMING':
        return const Color(0xFFF57C00);
      case 'RESULT_DECLARED':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFF78909C);
    }
  }

  static String _statusLabel(String? s) {
    switch (s) {
      case 'LIVE':
        return '● LIVE';
      case 'UPCOMING':
        return 'UPCOMING';
      case 'RESULT_DECLARED':
        return '🏆 RESULT';
      default:
        return s ?? 'CLOSED';
    }
  }

  @override
  Widget build(BuildContext context) {
    final comp = competition;
    final statusColor = _statusColor(comp.status);
    final hasR1 = comp.megaAudition != null;
    final hasR2 = comp.grandFinale != null;

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.10),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(statusColor, hasR1, hasR2),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 4.h),
              child: Column(
                children: [
                  if (hasR1)
                    _RoundTimeline(
                      roundLabel: 'R1',
                      title: comp.megaAudition!.title ?? 'Mega Audition',
                      regStart: comp.megaAudition!.registration?.start,
                      regEnd: comp.megaAudition!.registration?.end,
                      eventStart: comp.megaAudition!.eventWindow?.start,
                      resultDate: comp.megaAudition!.resultDeclarationDate,
                      status: comp.megaAudition!.status,
                      accentColor: const Color(0xFF1565C0),
                    ),
                  if (hasR1 && hasR2)
                    Divider(height: 1, color: Colors.grey.shade100),
                  if (hasR2)
                    _RoundTimeline(
                      roundLabel: 'R2',
                      title: comp.grandFinale!.title ?? 'Grand Finale',
                      regStart: comp.grandFinale!.paymentWindow?.start,
                      regEnd: comp.grandFinale!.paymentWindow?.end,
                      eventStart: comp.grandFinale!.eventWindow?.start,
                      resultDate: comp.grandFinale!.resultDeclarationDate,
                      status: comp.grandFinale!.status,
                      accentColor: const Color(0xFFB71C1C),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 10.h),
              child: Column(
                children: [
                  if (hasR1)
                    _RoundBadge(
                      label: comp.megaAudition!.title ?? 'Round 1 — Mega Audition',
                      status: comp.megaAudition!.status,
                      color: const Color(0xFF1565C0),
                    ),
                  if (hasR2) ...[
                    SizedBox(height: 6.h),
                    _RoundBadge(
                      label: comp.grandFinale!.title ?? 'Round 2 — Grand Finale',
                      status: comp.grandFinale!.status,
                      color: const Color(0xFFB71C1C),
                    ),
                  ],
                ],
              ),
            ),
            if (comp.status == 'RESULT_DECLARED' &&
                (comp.grandFinale?.winners?.isNotEmpty ?? false))
              _WinnerStrip(winner: comp.grandFinale!.winners!.first),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color statusColor, bool hasR1, bool hasR2) {
    final totalRounds = (hasR1 ? 1 : 0) + (hasR2 ? 1 : 0);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.10),
            statusColor.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 14.w, 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (competition.category?.name != null)
                      _Chip(
                        label: competition.category!.name!.toUpperCase(),
                        bg: activeItemColor.withOpacity(0.12),
                        fg: activeItemColor,
                      ),
                    SizedBox(width: 6.w),
                    if (competition.megaAudition?.submission?.type != null)
                      _Chip(
                        label: competition.megaAudition!.submission!.type!,
                        bg: Colors.grey.shade100,
                        fg: Colors.grey.shade600,
                        icon: competition.megaAudition!.submission!.type == 'TEXT'
                            ? Icons.text_fields_rounded
                            : Icons.attach_file_rounded,
                      ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  competition.title ?? 'Untitled',
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1D26),
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 10.w,
                  children: [
                    _MetaChip(
                      icon: Icons.people_outline,
                      label: '${competition.totalParticipants ?? 0} joined',
                    ),
                    _MetaChip(
                      icon: Icons.assignment_turned_in_outlined,
                      label: '${competition.totalSubmissions ?? 0} submitted',
                    ),
                    if (totalRounds > 0)
                      _MetaChip(
                        icon: Icons.emoji_events_outlined,
                        label: '$totalRounds rounds',
                      ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Container(
              //   padding:
              //       EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              //   decoration: BoxDecoration(
              //     color: statusColor,
              //     borderRadius: BorderRadius.circular(20.r),
              //     boxShadow: [
              //       BoxShadow(
              //         color: statusColor.withOpacity(0.35),
              //         blurRadius: 6,
              //       ),
              //     ],
              //   ),
              //   child: Text(
              //     _statusLabel(competition.status),
              //     style: GoogleFonts.poppins(
              //       fontSize: 9.sp,
              //       fontWeight: FontWeight.w700,
              //       color: Colors.white,
              //     ),
              //   ),
              // ),
             
              SizedBox(height: 10.h),
              _isFree
                  ? Text(
                      'FREE',
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.green.shade700,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${_effectivePrice.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: drawerColor,
                          ),
                        ),
                        if (_effectivePrice < _originalPrice)
                          Text(
                            '₹${_originalPrice.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
            ],
          ),
        ],
      ),
    );
  }


Widget _buildFooter(BuildContext context) {
  String ctaLabel;
  Color ctaColor;
  IconData ctaIcon;
  bool disabled = false;
  bool goToDetail = false;

  final r2Active = _r2IsVisible && (_r1IsQualified || _r2HasRegistered);

  if (r2Active) {
    if (_r2HasSubmitted) {
      ctaLabel = _r2IsResultDeclared ? 'R2 Result Out 🏆' : 'R2 Submitted ✓';
      ctaColor = Colors.green;
      ctaIcon = Icons.check_circle_outline;
      disabled = true;
      goToDetail = true;
    } else if (_r2HasRegistered && _r2IsEventLive) {
      ctaLabel = 'Start R2 🔴';
      ctaColor = Colors.red;
      ctaIcon = Icons.play_arrow_rounded;
      goToDetail = true;
    } else if (_r2HasRegistered && !_r2IsEventLive) {
      ctaLabel = 'R2 Registered';
      ctaColor = Colors.orange;
      ctaIcon = Icons.how_to_reg_outlined;
      disabled = true;
      goToDetail = true;
    } else if (_r2IsPaymentOpen) {
      ctaLabel = 'Pay for Round 2';
      ctaColor = const Color(0xFFB71C1C);
      ctaIcon = Icons.emoji_events_outlined;
      goToDetail = false;
    } else {
      ctaLabel = 'Qualified ✓';
      ctaColor = Colors.green;
      ctaIcon = Icons.military_tech_outlined;
      disabled = true;
      goToDetail = true;
    }
  } else if (_r1HasSubmitted) {
    if (_r1IsResultDeclared) {
      ctaLabel = _r1IsQualified ? 'View Result' : 'Not Qualified';
      ctaColor = _r1IsQualified ? Colors.purple : Colors.grey;
      ctaIcon = _r1IsQualified
          ? Icons.emoji_events_outlined
          : Icons.cancel_outlined;
      disabled = !_r1IsQualified;
      goToDetail = _r1IsQualified;
    } else {
      ctaLabel = 'Submitted ✓';
      ctaColor = Colors.green;
      ctaIcon = Icons.check_circle_outline;
      disabled = true;
      goToDetail = true;
    }
  } else if (_r1HasRegistered && _r1IsEventLive) {
    ctaLabel = 'Start Now 🔴';
    ctaColor = Colors.red;
    ctaIcon = Icons.play_arrow_rounded;
    goToDetail = true;
  } else if (_r1HasRegistered && !_r1IsEventLive) {
    ctaLabel = 'Registered';
    ctaColor = Colors.orange;
    ctaIcon = Icons.how_to_reg_outlined;
    disabled = true;
    goToDetail = true;
  } else if (_r1IsRegOpen) {
    ctaLabel = _isFree ? 'Register Free' : 'Register';
    ctaColor = drawerColor;
    ctaIcon = Icons.app_registration_rounded;
    goToDetail = false;
  }
  else if (_r1IsResultDeclared) {
    ctaLabel = 'Closed';
    ctaColor = Colors.grey.shade400;
    ctaIcon = Icons.lock_outline;
    disabled = true;
    goToDetail = false;
  } 
  else {
    ctaLabel = 'Closed';
    ctaColor = Colors.grey.shade400;
    ctaIcon = Icons.lock_outline;
    disabled = true;
    goToDetail = false;
  }

  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF8F9FC),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
      border: Border(top: BorderSide(color: Colors.grey.shade100)),
    ),
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _openDetail(context),
            child: Container(
              height: 40.h,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: Text(
                  'View Details',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1D26),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        GestureDetector(
          onTap: disabled ? null : () => _handleCta(context, goToDetail: goToDetail),
          child: Container(
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: disabled ? Colors.grey.shade300 : ctaColor,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: disabled
                  ? null
                  : [
                      BoxShadow(
                        color: ctaColor.withOpacity(0.28),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(ctaIcon, size: 14.sp, color: Colors.white),
                SizedBox(width: 5.w),
                Text(
                  ctaLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
  void _openDetail(BuildContext context) {
    context
        .read<LiveCompetitionProvider>()
        .setSelectedCompetition(competition);
    Navigator.pushNamed(
      context,
      '/live-competition-detail',
      arguments: competition.id,
    );
  }

  /// goToDetail=true  → open detail screen (start/view result)
  /// goToDetail=false → open payment sheet (register / pay for R2)
  void _handleCta(BuildContext context, {required bool goToDetail}) {
    if (goToDetail) {
      _openDetail(context);
      return;
    }
    // Open payment sheet — backend auto-infers whether this is R1 or R2
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<LiveCompetitionProvider>(),
        child: LiveCompetitionPaymentSheet(competition: competition),
      ),
    );
  }
}

// ─── Round Timeline Row ───────────────────────────────────────────────────────

class _RoundTimeline extends StatelessWidget {
  final String roundLabel, title;
  final DateTime? regStart, regEnd, eventStart, resultDate;
  final String? status;
  final Color accentColor;

  const _RoundTimeline({
    required this.roundLabel,
    required this.title,
    required this.accentColor,
    this.regStart,
    this.regEnd,
    this.eventStart,
    this.resultDate,
    this.status,
  });

  static final _fmt = DateFormat('d MMM, h:mm a');
  String _f(DateTime? dt) => dt != null ? _fmt.format(dt.toLocal()) : '—';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                roundLabel,
                style: GoogleFonts.poppins(
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          if (regStart != null)
                            _TimeRow(
                              icon: Icons.calendar_today_outlined,
                              label: 'Reg Start',
                              value: _f(regStart),
                              iconColor: Colors.blue.shade400,
                            ),
                          if (regEnd != null)
                            _TimeRow(
                              icon: Icons.calendar_month_outlined,
                              label: 'Reg End',
                              value: _f(regEnd),
                              iconColor: Colors.red.shade400,
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        children: [
                          if (eventStart != null)
                            _TimeRow(
                              icon: Icons.timer_outlined,
                              label: 'Event',
                              value: _f(eventStart),
                              iconColor: Colors.green.shade600,
                            ),
                          if (resultDate != null)
                            _TimeRow(
                              icon: Icons.emoji_events_outlined,
                              label: 'Result',
                              value: _f(resultDate),
                              iconColor: status == 'RESULT_DECLARED'
                                  ? Colors.amber.shade700
                                  : Colors.grey.shade500,
                              highlight: status == 'RESULT_DECLARED',
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color iconColor;
  final bool highlight;

  const _TimeRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Icon(icon, size: 10.sp, color: iconColor),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 8.5.sp,
                    color: Colors.black38,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w600,
                    color: highlight
                        ? Colors.amber.shade800
                        : const Color(0xFF1A1D26),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Round Badge ──────────────────────────────────────────────────────────────

class _RoundBadge extends StatelessWidget {
  final String label;
  final String? status;
  final Color color;

  const _RoundBadge(
      {required this.label, required this.color, this.status});

  String get _text {
    switch (status) {
      case 'RESULT_DECLARED':
        return 'Result Declared';
      case 'LIVE':
        return 'Live Now';
      case 'UPCOMING':
        return 'Upcoming';
      default:
        return status ?? 'Closed';
    }
  }

  IconData get _icon {
    switch (status) {
      case 'RESULT_DECLARED':
        return Icons.emoji_events_rounded;
      case 'LIVE':
        return Icons.live_tv_rounded;
      case 'UPCOMING':
        return Icons.hourglass_top_rounded;
      default:
        return Icons.lock_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(_icon, size: 13.sp, color: color),
          SizedBox(width: 7.w),
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              _text,
              style: GoogleFonts.poppins(
                fontSize: 8.5.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Winner Strip ─────────────────────────────────────────────────────────────

class _WinnerStrip extends StatelessWidget {
  final dynamic winner;
  const _WinnerStrip({required this.winner});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.amber.shade50, Colors.orange.shade50]),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events_rounded,
              color: Colors.amber.shade700, size: 22.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🏆 Grand Finale Winner',
                  style: GoogleFonts.poppins(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange.shade800),
                ),
                Text(
                  winner['name'] ?? '',
                  style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1D26)),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 16.r,
            backgroundColor: Colors.amber.shade100,
            backgroundImage: winner['profilePic'] != null
                ? NetworkImage(winner['profilePic'])
                : null,
            child: winner['profilePic'] == null
                ? Icon(Icons.person,
                    size: 14.sp, color: Colors.amber.shade700)
                : null,
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color bg, fg;
  final IconData? icon;
  const _Chip(
      {required this.label,
      required this.bg,
      required this.fg,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 9.sp, color: fg),
            SizedBox(width: 3.w),
          ],
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 8.5.sp,
                  fontWeight: FontWeight.w700,
                  color: fg)),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10.sp, color: Colors.black38),
        SizedBox(width: 3.w),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 10.sp, color: Colors.black38)),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 56.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 13.sp, color: Colors.grey[500])),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: activeItemColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.live_tv_outlined, size: 64.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text('No live competitions right now',
              style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400])),
          SizedBox(height: 6.h),
          Text('Check back soon!',
              style: GoogleFonts.poppins(
                  fontSize: 12.sp, color: Colors.grey[400])),
        ],
      ),
    );
  }
}