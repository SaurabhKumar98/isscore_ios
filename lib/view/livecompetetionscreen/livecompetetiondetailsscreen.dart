// lib/view/livecompetetionscreen/live_competition_detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firstedu/data/models/api_models/livecompetetion/livecompetionmodels.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view/livecompetetionscreen/livecompetionjoininglink.dart';
import 'package:firstedu/view/livecompetetionscreen/singingdancinguploadfile.dart';
import 'package:firstedu/view/livecompetetionscreen/livecometitionpaymentsheet.dart';
import 'package:firstedu/view/livecompetetionscreen/livecompetetionsubmitscreen.dart';
import 'package:firstedu/view_models/livecompetetionprovider/livecompetetiondetailsprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class LiveCompetitionDetailScreen extends StatefulWidget {
  final String competitionId;
  const LiveCompetitionDetailScreen({required this.competitionId, super.key});

  @override
  State<LiveCompetitionDetailScreen> createState() =>
      _LiveCompetitionDetailScreenState();
}

class _LiveCompetitionDetailScreenState
    extends State<LiveCompetitionDetailScreen> {
  bool _startingR1 = false;
  bool _startingR2 = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LiveCompetitionProvider>().fetchSingleLiveCompetition(
        context,
        widget.competitionId,
      );
    });
  }

  // ── Start handler ─────────────────────────────────────────────────────────
  Future<void> _handleStart(
    LiveCompetition comp,
    LiveCompetitionProvider provider,
    bool isR1,
  ) async {
    if (isR1 ? _startingR1 : _startingR2) return;
    setState(() => isR1 ? _startingR1 = true : _startingR2 = true);

    try {
      final round = isR1 ? LiveRound.megaAudition : LiveRound.grandFinale;

      // Pull submission config from the correct round, not top-level
      final LiveCompetitionSubmission? submissionConfig = isR1
          ? comp.megaAudition?.submission
          : comp.grandFinale?.submission;

      final String? subType = submissionConfig?.type;
      final LiveExternalLink? externalLink = submissionConfig?.externalLink;

      // ── FILE submissions: skip /start entirely, go straight to upload ──
      if (subType == 'FILE') {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: provider,
              child: FileUploadScreen(competition: comp, round: round),
            ),
          ),
        );
        if (mounted) {
          provider.fetchSingleLiveCompetition(context, comp.id!);
        }
        return; // done — no /start call needed
      }

      // ── TEXT / proctored: call /start first ───────────────────────────
      final participation = await provider.startCompetition(
        context,
        comp.id!,
        round: round,
      );

      if (!mounted) return;

      if (participation != null) {
        final requiresGateway =
            subType == 'TEXT' &&
            externalLink != null &&
            (externalLink.url ?? '').isNotEmpty;

        if (requiresGateway) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: provider,
                child: ProctoringGatewayScreen(
                  competition: comp,
                  participation: participation,
                  round: round,
                  meetingUrl: externalLink.url!,
                  meetingTitle: externalLink.title,
                  submissionConfig: submissionConfig,
                ),
              ),
            ),
          );
        } else {
          // Plain TEXT — no proctoring
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: provider,
                child: LiveCompetitionSubmissionScreen(
                  competition: comp,
                  participation: participation,
                  round: round,
                  submissionConfig: submissionConfig,
                ),
              ),
            ),
          );
        }

        if (mounted) {
          provider.fetchSingleLiveCompetition(context, comp.id!);
        }
      } else {
        _showSnack(
          provider.singleError ?? 'Could not start. Try again.',
          isError: true,
        );
      }
    } catch (_) {
      if (mounted) {
        _showSnack('Something went wrong. Please try again.', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => isR1 ? _startingR1 = false : _startingR2 = false);
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(msg, style: GoogleFonts.poppins()),
    //     backgroundColor: isError ? Colors.red : Colors.green,
    //     behavior: SnackBarBehavior.floating,
    //   ),
    // );
    AppToast.success(context, message: msg);
  }

  void _openPaymentSheet(
    BuildContext context,
    LiveCompetitionProvider provider,
    LiveCompetition comp,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: LiveCompetitionPaymentSheet(competition: comp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Consumer<LiveCompetitionProvider>(
        builder: (context, provider, _) {
          if (provider.isSingleLoading)
            return const Center(child: CircularProgressIndicator());
          if (provider.singleError != null)
            return _ErrorBody(
              message: provider.singleError!,
              onRetry: () => provider.fetchSingleLiveCompetition(
                context,
                widget.competitionId,
              ),
            );
          final comp = provider.selectedCompetition;
          if (comp == null)
            return const Center(child: CircularProgressIndicator());

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _DetailAppBar(competition: comp),
              SliverPadding(
                padding: EdgeInsets.all(16.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _OverviewCard(competition: comp),
                    SizedBox(height: 14.h),
                    if (comp.prizes != null && comp.prizes!.isNotEmpty) ...[
                      _PrizesCard(prizes: comp.prizes!),
                      SizedBox(height: 14.h),
                    ],
                    // ── Round 1 ───────────────────────────────────────
                    if (comp.megaAudition != null) ...[
                      _RoundCard(
                        roundLabel: 'Round 1',
                        roundTitle:
                            comp.megaAudition!.title ?? 'Mega Audition',
                        accentColor: const Color(0xFF1565C0),
                        roundData: comp.megaAudition!,
                        studentStatus: comp.studentStatus?.megaAudition,
                        isStarting: _startingR1,
                        onStart: () => _handleStart(comp, provider, true),
                        onRegister: () =>
                            _openPaymentSheet(context, provider, comp),
                      ),
                      SizedBox(height: 14.h),
                    ],
                    // ── Round 2 (only shown when isVisible = true) ───
                    if (comp.grandFinale != null &&
                        (comp.grandFinale!.isVisible ?? false)) ...[
                      _GrandFinaleCard(
                        comp: comp,
                        isStarting: _startingR2,
                        onStart: () => _handleStart(comp, provider, false),
                        onRegister: () =>
                            _openPaymentSheet(context, provider, comp),
                      ),
                      SizedBox(height: 14.h),
                    ],
                    SizedBox(height: 24.h),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _DetailAppBar extends StatelessWidget {
  final LiveCompetition competition;
  const _DetailAppBar({required this.competition});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 210.h,
      pinned: true,
      backgroundColor: drawerColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            competition.bannerUrl != null
                ? CachedNetworkImage(
                    imageUrl: competition.bannerUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        Container(color: drawerColor),
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [drawerColor, drawerColor.withBlue(100)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    drawerColor.withOpacity(0.92)
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16.h,
              left: 16.w,
              right: 16.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (competition.category?.name != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        competition.category!.name!,
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  SizedBox(height: 6.h),
                  Text(
                    competition.title ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  _StatusPill(status: competition.status ?? ''),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Overview Card ────────────────────────────────────────────────────────────

class _OverviewCard extends StatelessWidget {
  final LiveCompetition competition;
  const _OverviewCard({required this.competition});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Overview'),
          SizedBox(height: 10.h),
          _InfoRow(
            icon: Icons.people_outline,
            label: 'Total Participants',
            value: '${competition.totalParticipants ?? 0}',
          ),
          _InfoRow(
            icon: Icons.assignment_turned_in_outlined,
            label: 'Total Submissions',
            value: '${competition.totalSubmissions ?? 0}',
          ),
          if (competition.category?.submissionType != null)
            _InfoRow(
              icon: Icons.category_outlined,
              label: 'Category Type',
              value: competition.category!.submissionType!,
            ),
          if (competition.studentStatus?.walletBalance != null)
            _InfoRow(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Wallet Balance',
              value:
                  '₹${competition.studentStatus!.walletBalance!.toStringAsFixed(0)}',
            ),
          if ((competition.description ?? '').isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              competition.description!,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Prizes Card ─────────────────────────────────────────────────────────────

class _PrizesCard extends StatelessWidget {
  final List<CompetitionPrize> prizes;
  const _PrizesCard({required this.prizes});

  @override
  Widget build(BuildContext context) {
    final rankColors = [
      Colors.amber.shade700,
      Colors.grey.shade500,
      Colors.brown.shade400,
    ];
    final rankEmojis = ['🥇', '🥈', '🥉'];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Prizes'),
          SizedBox(height: 10.h),
          ...prizes.asMap().entries.map((e) {
            final i = e.key;
            final prize = e.value;
            final color = i < rankColors.length ? rankColors[i] : Colors.teal;
            final emoji = i < rankEmojis.length ? rankEmojis[i] : '🏅';
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: color.withOpacity(0.07),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Text(emoji, style: TextStyle(fontSize: 20.sp)),
                  SizedBox(width: 10.w),
                  Text(
                    'Rank ${prize.rank}',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.stars_rounded, size: 15.sp, color: color),
                  SizedBox(width: 4.w),
                  Text(
                    '${prize.walletPoints} pts',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  if ((prize.description ?? '').isNotEmpty) ...[
                    SizedBox(width: 8.w),
                    Text(
                      prize.description!,
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        color: color.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Round 1 Card ─────────────────────────────────────────────────────────────

class _RoundCard extends StatelessWidget {
  final String roundLabel, roundTitle;
  final Color accentColor;
  final MegaAuditionData roundData;
  final RoundStudentStatus? studentStatus;
  final bool isStarting;
  final VoidCallback onStart, onRegister;

  const _RoundCard({
    required this.roundLabel,
    required this.roundTitle,
    required this.accentColor,
    required this.roundData,
    required this.studentStatus,
    required this.isStarting,
    required this.onStart,
    required this.onRegister,
  });

  static final _fmt = DateFormat('dd MMM yy, hh:mm a');
  String _f(DateTime? dt) => dt != null ? _fmt.format(dt.toLocal()) : '—';

  bool get _isRegOpen => roundData.isRegistrationOpen ?? false;
  bool get _isLive => roundData.isEventLive ?? false;
  bool get _isResultDeclared => roundData.status == 'RESULT_DECLARED';
  bool get _isFree =>
      roundData.fee?.isPaid == false || (roundData.fee?.amount ?? 0) == 0;
  double get _effectivePrice =>
      roundData.discountedPrice ?? roundData.fee?.amount?.toDouble() ?? 0;
  double get _originalPrice => roundData.fee?.amount?.toDouble() ?? 0;

  @override
  Widget build(BuildContext context) {
    final hasRegistered = studentStatus?.hasRegistered ?? false;
    final hasSubmitted = studentStatus?.hasSubmitted ?? false;
    final isQualified = studentStatus?.isQualified ?? false;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RoundHeader(
            label: roundLabel,
            title: roundTitle,
            status: roundData.status ?? '',
            accentColor: accentColor,
          ),
          SizedBox(height: 12.h),
          _StudentBanner(
            hasRegistered: hasRegistered,
            hasSubmitted: hasSubmitted,
            isQualified: isQualified,
            isLive: _isLive,
            isResultDeclared: _isResultDeclared,
            accentColor: accentColor,
          ),
          SizedBox(height: 12.h),
          _StatsRow(
            participants: roundData.totalParticipants,
            submissions: roundData.totalSubmissions,
            accentColor: accentColor,
          ),
          SizedBox(height: 12.h),
          if (roundData.fee != null)
            _InfoRow(
              icon: Icons.attach_money,
              label: 'Entry Fee',
              value: _isFree
                  ? 'FREE'
                  : '₹${_effectivePrice.toStringAsFixed(0)}'
                        '${_effectivePrice < _originalPrice ? ' (was ₹${_originalPrice.toStringAsFixed(0)})' : ''}',
            ),
          if (roundData.registration != null)
            _InfoRow(
              icon: Icons.how_to_reg_outlined,
              label: 'Registration',
              value:
                  '${_f(roundData.registration!.start)} → ${_f(roundData.registration!.end)}',
            ),
          if (roundData.eventWindow != null)
            _InfoRow(
              icon: Icons.event_outlined,
              label: 'Event Window',
              value:
                  '${_f(roundData.eventWindow!.start)} → ${_f(roundData.eventWindow!.end)}',
            ),
          if (roundData.resultDeclarationDate != null)
            _InfoRow(
              icon: Icons.announcement_outlined,
              label: 'Result On',
              value: _f(roundData.resultDeclarationDate),
            ),
          if ((roundData.maxQualifiers ?? 0) > 0)
            _InfoRow(
              icon: Icons.military_tech_outlined,
              label: 'Max Qualifiers',
              value: '${roundData.maxQualifiers}',
            ),
          if (roundData.submission != null) ...[
            SizedBox(height: 8.h),
            _SubmissionChips(submission: roundData.submission!),
          ],
          _RulesSection(
            rules: roundData.submission?.text?.rules ?? [],
            instructions: roundData.submission?.file?.instructions ?? [],
            accentColor: accentColor,
          ),
          if ((roundData.googleMeetLink ?? '').isNotEmpty) ...[
            SizedBox(height: 12.h),
            _GoogleMeetCard(
              link: roundData.googleMeetLink!,
              password: roundData.googleMeetPassword,
            ),
          ],
          if ((roundData.winners ?? []).isNotEmpty) ...[
            SizedBox(height: 12.h),
            _WinnersList(winners: roundData.winners!),
          ],
          if (roundData.appliedOffer != null) ...[
            SizedBox(height: 12.h),
            _OfferBanner(offer: roundData.appliedOffer!),
          ],
          SizedBox(height: 16.h),
          _RoundCTA(
            hasRegistered: hasRegistered,
            hasSubmitted: hasSubmitted,
            isLive: _isLive,
            isRegOpen: _isRegOpen,
            isResultDeclared: _isResultDeclared,
            submissionType: roundData.submission?.type,
            isStarting: isStarting,
            onStart: onStart,
            onRegister: onRegister,
            accentColor: accentColor,
            isFree: _isFree,
            price: _effectivePrice,
          ),
        ],
      ),
    );
  }
}

// ─── Grand Finale Card ────────────────────────────────────────────────────────

class _GrandFinaleCard extends StatelessWidget {
  final LiveCompetition comp;
  final bool isStarting;
  final VoidCallback onStart, onRegister;

  const _GrandFinaleCard({
    required this.comp,
    required this.isStarting,
    required this.onStart,
    required this.onRegister,
  });

  static final _fmt = DateFormat('dd MMM yy, hh:mm a');
  String _f(DateTime? dt) => dt != null ? _fmt.format(dt.toLocal()) : '—';

  @override
  Widget build(BuildContext context) {
    final gf = comp.grandFinale!;
    final ss = comp.studentStatus?.grandFinale;
    final hasRegistered = ss?.hasRegistered ?? false;
    final hasSubmitted = ss?.hasSubmitted ?? false;
    final isQualifiedR1 =
        comp.studentStatus?.megaAudition?.isQualified ?? false;
    final isLive = gf.isEventLive ?? false;
    final isPaymentOpen = gf.isPaymentOpen ?? false;
    final isResultDeclared = gf.status == 'RESULT_DECLARED';
    const accentColor = Color(0xFFB71C1C);

    final isFree = gf.fee?.isPaid == false || (gf.fee?.amount ?? 0) == 0;
    final effectivePrice =
        gf.discountedPrice ?? gf.fee?.amount?.toDouble() ?? 0;
    final originalPrice = gf.fee?.amount?.toDouble() ?? 0;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RoundHeader(
            label: 'Round 2',
            title: gf.title ?? 'Grand Finale',
            status: gf.status ?? '',
            accentColor: accentColor,
            isGrandFinale: true,
          ),
          SizedBox(height: 12.h),
          _StudentBanner(
            hasRegistered: hasRegistered,
            hasSubmitted: hasSubmitted,
            isQualified: isQualifiedR1,
            isLive: isLive,
            isResultDeclared: isResultDeclared,
            accentColor: accentColor,
            isGrandFinale: true,
          ),
          SizedBox(height: 12.h),
          _StatsRow(
            participants: gf.totalParticipants,
            submissions: gf.totalSubmissions,
            accentColor: accentColor,
          ),
          SizedBox(height: 12.h),
          if (gf.fee != null)
            _InfoRow(
              icon: Icons.attach_money,
              label: 'Entry Fee',
              value: isFree
                  ? 'FREE'
                  : '₹${effectivePrice.toStringAsFixed(0)}'
                        '${effectivePrice < originalPrice ? ' (was ₹${originalPrice.toStringAsFixed(0)})' : ''}',
            ),
          if (gf.paymentWindow != null)
            _InfoRow(
              icon: Icons.payment_outlined,
              label: 'Payment Window',
              value:
                  '${_f(gf.paymentWindow!.start)} → ${_f(gf.paymentWindow!.end)}',
            ),
          if (gf.eventWindow != null)
            _InfoRow(
              icon: Icons.event_outlined,
              label: 'Event Window',
              value:
                  '${_f(gf.eventWindow!.start)} → ${_f(gf.eventWindow!.end)}',
            ),
          if (gf.resultDeclarationDate != null)
            _InfoRow(
              icon: Icons.announcement_outlined,
              label: 'Result On',
              value: _f(gf.resultDeclarationDate),
            ),
          if (gf.submission != null) ...[
            SizedBox(height: 8.h),
            _SubmissionChips(submission: gf.submission!),
          ],
          if ((gf.googleMeetLink ?? '').isNotEmpty) ...[
            SizedBox(height: 12.h),
            _GoogleMeetCard(
              link: gf.googleMeetLink!,
              password: gf.googleMeetPassword,
            ),
          ],
          if ((gf.winners ?? []).isNotEmpty) ...[
            SizedBox(height: 12.h),
            _WinnersList(winners: gf.winners!),
          ],
          if (gf.appliedOffer != null) ...[
            SizedBox(height: 12.h),
            _OfferBanner(offer: gf.appliedOffer!),
          ],
          SizedBox(height: 16.h),
          _RoundCTA(
            hasRegistered: hasRegistered,
            hasSubmitted: hasSubmitted,
            isLive: isLive,
            isRegOpen: isPaymentOpen,
            isResultDeclared: isResultDeclared,
            submissionType: gf.submission?.type,
            isStarting: isStarting,
            onStart: onStart,
            onRegister: onRegister,
            accentColor: accentColor,
            isFree: isFree,
            price: effectivePrice,
            registerLabel: 'Pay & Join Grand Finale',
          ),
        ],
      ),
    );
  }
}

// ─── Round CTA ────────────────────────────────────────────────────────────────

class _RoundCTA extends StatelessWidget {
  final bool hasRegistered,
      hasSubmitted,
      isLive,
      isRegOpen,
      isResultDeclared,
      isStarting,
      isFree;
  final String? submissionType, registerLabel;
  final VoidCallback onStart, onRegister;
  final Color accentColor;
  final double price;

  const _RoundCTA({
    required this.hasRegistered,
    required this.hasSubmitted,
    required this.isLive,
    required this.isRegOpen,
    required this.isResultDeclared,
    required this.submissionType,
    required this.isStarting,
    required this.onStart,
    required this.onRegister,
    required this.accentColor,
    required this.isFree,
    required this.price,
    this.registerLabel,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Submitted
    if (hasSubmitted) {
      return _PillState(
        icon: Icons.check_circle_rounded,
        label: isResultDeclared
            ? 'Submitted ✓  —  Result Declared'
            : 'Submitted ✓  —  Awaiting Evaluation',
        color: Colors.green,
      );
    }

    // 2. Result declared and never registered
    if (isResultDeclared && !hasRegistered) {
      return const _PillState(
        icon: Icons.lock_outline,
        label: 'Result Declared',
        color: Colors.grey,
      );
    }

    // 3. Registered + event is LIVE
    if (hasRegistered && isLive) {
      final isFile = submissionType == 'FILE';
      return _PrimaryBtn(
        label: isStarting
            ? 'Starting…'
            : (isFile ? 'Upload File' : 'Start Submission'),
        icon: isFile ? Icons.upload_file_rounded : Icons.play_arrow_rounded,
        color: Colors.red,
        isLoading: isStarting,
        onTap: isStarting ? null : onStart,
      );
    }

    // 4. Registered but event not yet live
    if (hasRegistered && !isLive) {
      return _PillState(
        icon: Icons.hourglass_top_rounded,
        label: 'Registered  —  Waiting for Event to Go Live',
        color: Colors.orange,
      );
    }

    // 5. Registration is open
    if (isRegOpen) {
      return _PrimaryBtn(
        label: registerLabel ??
            (isFree
                ? 'Register Free'
                : 'Pay ₹${price.toStringAsFixed(0)} & Register'),
        icon: Icons.app_registration_rounded,
        color: accentColor,
        onTap: onRegister,
      );
    }

    // 6. Closed
    return const _PillState(
      icon: Icons.lock_outline,
      label: 'Registration Closed',
      color: Colors.grey,
    );
  }
}

// ─── Student Banner ───────────────────────────────────────────────────────────
// ← FIXED: uses isQualified + isResultDeclared instead of resultStatus string

class _StudentBanner extends StatelessWidget {
  final bool hasRegistered,
      hasSubmitted,
      isQualified,
      isLive,
      isResultDeclared;
  final Color accentColor;
  final bool isGrandFinale;

  const _StudentBanner({
    required this.hasRegistered,
    required this.hasSubmitted,
    required this.isQualified,
    required this.isLive,
    required this.isResultDeclared,
    required this.accentColor,
    this.isGrandFinale = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    String msg;
    IconData icon;

    if (hasSubmitted && isResultDeclared && isQualified) {
      // Submitted + result out + qualified
      bg = Colors.green;
      msg = '🎉 Result Declared — You are Qualified for the Grand Finale!';
      icon = Icons.military_tech_outlined;
    } else if (hasSubmitted && isResultDeclared && !isQualified) {
      // Submitted + result out + not qualified
      bg = Colors.grey;
      msg = 'Result Declared — Not qualified for next round.';
      icon = Icons.info_outline;
    } else if (hasSubmitted) {
      // Submitted, awaiting result
      bg = Colors.green;
      msg = 'Submitted ✓  —  Awaiting Results';
      icon = Icons.check_circle_outline;
    } else if (isResultDeclared && !hasRegistered) {
      // Result declared but student never registered
      bg = Colors.grey;
      msg = 'Result has been declared.';
      icon = Icons.info_outline;
    } else if (isGrandFinale && !isQualified && !hasRegistered) {
      // Grand finale but not qualified from R1
      bg = Colors.orange;
      msg = 'Qualify in Round 1 to join the Grand Finale.';
      icon = Icons.lock_outline;
    } else if (hasRegistered && isLive) {
      // Registered and event is live
      bg = Colors.red;
      msg = '🔴 LIVE  —  Submit your work now!';
      icon = Icons.live_tv;
    } else if (hasRegistered && !isLive) {
      // Registered but event not started
      bg = Colors.orange;
      msg = 'Registered! Waiting for event to go live.';
      icon = Icons.how_to_reg_outlined;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: bg.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: bg, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              msg,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: bg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Submission Chips ─────────────────────────────────────────────────────────

class _SubmissionChips extends StatelessWidget {
  final LiveCompetitionSubmission submission;
  const _SubmissionChips({required this.submission});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 6.h,
      children: [
        if (submission.type != null)
          _MiniChip(
            icon: submission.type == 'FILE'
                ? Icons.attach_file_outlined
                : submission.type == 'EXTERNAL_LINK'
                    ? Icons.link_outlined
                    : Icons.text_fields_outlined,
            label: 'Type: ${submission.type}',
            color: activeItemColor,
          ),
        if (submission.duration != null)
          _MiniChip(
            icon: Icons.timer_outlined,
            label: '${submission.duration} min',
            color: Colors.orange,
          ),
        if ((submission.text?.limit ?? 0) > 0)
          _MiniChip(
            icon: Icons.format_list_numbered_outlined,
            label:
                '${submission.text!.limit} ${submission.text!.limitType?.toLowerCase() ?? ''}',
            color: Colors.purple,
          ),
        if ((submission.text?.topic ?? '').isNotEmpty)
          _MiniChip(
            icon: Icons.topic_outlined,
            label: 'Topic: ${submission.text!.topic}',
            color: Colors.teal,
          ),
        if ((submission.text?.walletPoints ?? 0) > 0)
          _MiniChip(
            icon: Icons.stars_rounded,
            label: '+${submission.text!.walletPoints} pts',
            color: Colors.amber.shade700,
          ),
        if ((submission.file?.walletPoints ?? 0) > 0)
          _MiniChip(
            icon: Icons.stars_rounded,
            label: '+${submission.file!.walletPoints} pts',
            color: Colors.amber.shade700,
          ),
        if ((submission.file?.allowedTypes ?? []).isNotEmpty)
          _MiniChip(
            icon: Icons.file_present_outlined,
            label: submission.file!.allowedTypes!.join(', '),
            color: Colors.indigo,
          ),
      ],
    );
  }
}

// ─── Rules Section ────────────────────────────────────────────────────────────

class _RulesSection extends StatelessWidget {
  final List<String> rules, instructions;
  final Color accentColor;
  const _RulesSection({
    required this.rules,
    required this.instructions,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (rules.isEmpty && instructions.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (rules.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Text(
            'Rules',
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
          SizedBox(height: 8.h),
          ...rules.asMap().entries.map(
                (e) => _RuleTile(
              num: '${e.key + 1}',
              text: e.value,
              color: accentColor,
            ),
          ),
        ],
        if (instructions.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Text(
            'Instructions',
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: Colors.orange,
            ),
          ),
          SizedBox(height: 8.h),
          ...instructions.asMap().entries.map(
                (e) => _RuleTile(
              num: '${e.key + 1}',
              text: e.value,
              color: Colors.orange,
            ),
          ),
        ],
      ],
    );
  }
}

class _RuleTile extends StatelessWidget {
  final String num, text;
  final Color color;
  const _RuleTile(
      {required this.num, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                num,
                style: GoogleFonts.poppins(
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Google Meet Card ─────────────────────────────────────────────────────────

class _GoogleMeetCard extends StatelessWidget {
  final String link;
  final String? password;
  const _GoogleMeetCard({required this.link, this.password});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.video_call_rounded,
                  color: Colors.blue.shade700, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Google Meet',
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  link,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.blue.shade600,
                    decoration: TextDecoration.underline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () async {
                  final uri = Uri.parse(link);
                  if (await canLaunchUrl(uri)) launchUrl(uri);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Join',
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if ((password ?? '').isNotEmpty) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.lock_outline, size: 13.sp, color: Colors.blue),
                SizedBox(width: 6.w),
                Text(
                  'Password: ',
                  style: GoogleFonts.poppins(
                      fontSize: 12.sp, color: Colors.black54),
                ),
                Text(
                  password!,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: password!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password copied!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Icon(Icons.copy_outlined,
                      size: 14.sp, color: Colors.blue),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Winners List ─────────────────────────────────────────────────────────────

class _WinnersList extends StatelessWidget {
  final List<dynamic> winners;
  const _WinnersList({required this.winners});

  @override
  Widget build(BuildContext context) {
    final rankColors = [
      Colors.amber.shade700,
      Colors.grey.shade500,
      Colors.brown.shade400,
    ];
    final rankEmojis = ['🥇', '🥈', '🥉'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Winners',
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: Colors.orange.shade800,
          ),
        ),
        SizedBox(height: 10.h),
        ...winners.asMap().entries.map((e) {
          final i = e.key;
          final w = e.value as Map<String, dynamic>;
          final color =
              i < rankColors.length ? rankColors[i] : Colors.teal;
          final emoji =
              i < rankEmojis.length ? rankEmojis[i] : '🏅';
          return Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundImage: (w['profilePic'] as String?) != null
                      ? NetworkImage(w['profilePic'] as String)
                      : null,
                  backgroundColor: color.withOpacity(0.15),
                  child: w['profilePic'] == null
                      ? Text(emoji,
                          style: TextStyle(fontSize: 16.sp))
                      : null,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        w['name'] as String? ?? 'Winner',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if ((w['email'] as String? ?? '').isNotEmpty)
                        Text(
                          w['email'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: Colors.black45,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Rank ${w['rank'] ?? i + 1}',
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ─── Offer Banner ─────────────────────────────────────────────────────────────

class _OfferBanner extends StatelessWidget {
  final LiveCompetitionOffer offer;
  const _OfferBanner({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.teal.shade50],
        ),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.local_offer_rounded,
              color: Colors.green[700], size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.offerName ?? 'Special Offer',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.green[700],
                  ),
                ),
                Text(
                  '${offer.discountType == 'PERCENTAGE' ? '${offer.discountValue?.toStringAsFixed(0)}%' : '₹${offer.discountValue?.toStringAsFixed(0)}'} off applied',
                  style: GoogleFonts.poppins(
                      fontSize: 11.sp, color: Colors.green[600]),
                ),
                if ((offer.description ?? '').isNotEmpty)
                  Text(
                    offer.description!,
                    style: GoogleFonts.poppins(
                        fontSize: 10.sp, color: Colors.green[500]),
                  ),
                if (offer.validTill != null)
                  Text(
                    'Valid till: ${DateFormat('dd MMM yy').format(offer.validTill!.toLocal())}',
                    style: GoogleFonts.poppins(
                        fontSize: 10.sp, color: Colors.green[500]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────

class _RoundHeader extends StatelessWidget {
  final String label, title, status;
  final Color accentColor;
  final bool isGrandFinale;

  const _RoundHeader({
    required this.label,
    required this.title,
    required this.status,
    required this.accentColor,
    this.isGrandFinale = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            gradient: isGrandFinale
                ? const LinearGradient(
                    colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
                  )
                : null,
            color: isGrandFinale ? null : accentColor,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1D26),
            ),
          ),
        ),
        _StatusPill(status: status),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int? participants, submissions;
  final Color accentColor;
  const _StatsRow({
    this.participants,
    this.submissions,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
          icon: Icons.people_outline,
          label: '${participants ?? 0} participants',
          color: accentColor,
        ),
        SizedBox(width: 8.w),
        _StatChip(
          icon: Icons.assignment_outlined,
          label: '${submissions ?? 0} submissions',
          color: Colors.orange,
        ),
      ],
    );
  }
}

class _PillState extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _PillState({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18.sp),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback? onTap;
  const _PrimaryBtn({
    required this.label,
    required this.icon,
    required this.color,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50.h,
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey.shade300 : color,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      label,
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

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final map = {
      'UPCOMING': (Colors.blue, 'Upcoming'),
      'LIVE': (Colors.green, '● Live'),
      'RESULT_DECLARED': (Colors.purple, '🏆 Results Out'),
      'CLOSED': (Colors.grey, 'Closed'),
    };
    final entry = map[status];
    final color = entry?.$1 ?? Colors.grey;
    final label = entry?.$2 ?? status;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MiniChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 5.w),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14.sp, color: activeItemColor),
          SizedBox(width: 8.w),
          Text(
            label,
            style:
                GoogleFonts.poppins(fontSize: 12.sp, color: Colors.black54),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1D26),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A1D26),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 56.sp, color: Colors.red[300]),
          SizedBox(height: 16.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: activeItemColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}