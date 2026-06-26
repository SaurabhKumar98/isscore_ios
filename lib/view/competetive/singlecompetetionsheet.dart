// ─────────────────────────────────────────────────────────────────────────────
// single_competition_sheet.dart
//
// Bottom sheet shown when a student has access to a competition bundle.
// Lists all unlocked tests and navigates to ExamScreen on tap.
// Also handles the UPGRADE flow if new locked tests were added post-purchase.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firstedu/data/models/api_models/competetive/competetionsingleidby_models.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/questionscreen.dart';
import 'package:firstedu/view_models/competetiveprovider/competetionprovider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SingleCompetitionSheet extends StatelessWidget {
  final String competitionId;

  const SingleCompetitionSheet({super.key, required this.competitionId});

  @override
  Widget build(BuildContext context) {
    return Consumer<CompetitionProvider>(
      builder: (context, provider, _) {
        return DraggableScrollableSheet(
          initialChildSize: 0.58,
          minChildSize: 0.38,
          maxChildSize: 0.92,
          builder: (_, ctrl) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  height: 4,
                  width: 38,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                if (provider.isSingleLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (provider.singleError != null)
                  _ErrorState(
                    message: provider.singleError!,
                    onRetry: () => provider.fetchSingleCompetition(
                        context, competitionId),
                  )
                else if (provider.singleCompetition != null) ...[
                  _SheetHeader(competition: provider.singleCompetition!),
                  const Divider(
                      height: 1, thickness: 1, indent: 16, endIndent: 16),
                  _TestList(
                    ctrl: ctrl,
                    competition: provider.singleCompetition!,
                    competitionId: competitionId,
                  ),
                ] else
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  final CompetitionDetail competition;

  const _SheetHeader({required this.competition});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [activeItemColor.withOpacity(0.7), activeItemColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.emoji_events,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  competition.title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                if (competition.description.isNotEmpty)
                  Text(
                    competition.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: activeItemColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${competition.tests.length} Tests',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Test list ─────────────────────────────────────────────────────────────────

class _TestList extends StatelessWidget {
  final ScrollController ctrl;
  final CompetitionDetail competition;
  final String competitionId;

  const _TestList({
    required this.ctrl,
    required this.competition,
    required this.competitionId,
  });

  @override
  Widget build(BuildContext context) {
    if (competition.tests.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_outlined,
                  size: 60, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text(
                'No tests available',
                style: GoogleFonts.poppins(
                    fontSize: 14, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        controller: ctrl,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        itemCount: competition.tests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) => TestCard(
          test: competition.tests[i],
          index: i,
          competitionTitle: competition.title,
          competitionId: competitionId,
        ),
      ),
    );
  }
}

// ── Test card ─────────────────────────────────────────────────────────────────

class TestCard extends StatelessWidget {
  final Test test;
  final int index;
  final String competitionTitle;
  final String competitionId;

  const TestCard({
    super.key,
    required this.test,
    required this.index,
    required this.competitionTitle,
    required this.competitionId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: drawerBgColor.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          // Index badge
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: activeItemColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: activeItemColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title + meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test.title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                if (test.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    test.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
                if (test.createdAt != null || test.durationMinutes > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (test.createdAt != null) ...[
                        Icon(Icons.calendar_today_outlined,
                            size: 11, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          _fmt(test.createdAt!),
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: Colors.grey[400]),
                        ),
                      ],
                      if (test.durationMinutes > 0) ...[
                        const SizedBox(width: 10),
                        Icon(Icons.timer_outlined,
                            size: 11, color: Colors.grey[400]),
                        const SizedBox(width: 3),
                        Text(
                          '${test.durationMinutes} min',
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: Colors.grey[400]),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Start button
          GestureDetector(
            onTap: () => _startExam(context),
            child: Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: successColor,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _startExam(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExamScreen(
          testId: test.testId,
          examTitle: test.title.isNotEmpty ? test.title : competitionTitle,
        ),
      ),
    );
  }

  String _fmt(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// ── Upgrade prompt card (shown at the bottom of the test list) ────────────────

class UpgradeCard extends StatelessWidget {
  final String competitionId;
  final num upgradeCost;

  const UpgradeCard({
    super.key,
    required this.competitionId,
    required this.upgradeCost,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CompetitionProvider>();

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded,
              color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New tests available',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[800],
                  ),
                ),
                Text(
                  'Upgrade for ₹$upgradeCost to unlock',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: Colors.orange[600]),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => ChangeNotifierProvider.value(
                  value: provider,
                  // child: UpgradePaymentSheet(
                  //   competitionId: competitionId,
                  //   upgradeCost: upgradeCost,
                  // ),
                ),
              );
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Upgrade',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 52, color: Colors.red[300]),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(
                  color: activeItemColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}