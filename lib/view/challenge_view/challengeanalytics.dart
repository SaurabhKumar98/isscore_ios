import 'package:firstedu/data/models/api_models/challengeyourfriend/challengedetailsmodels.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_silverappbar.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChallengeAnalyticsScreen extends StatelessWidget {
  /// The full detail object returned by the API.
  final CompletedChallengeDetail detail;

  /// The current user's ID — used to highlight "You" in the leaderboard.
  final String? currentUserId;

  const ChallengeAnalyticsScreen({
    super.key,
    required this.detail,
    this.currentUserId,
  });

  // ── Convenience getters ────────────────────────────────────────────
  String get _title => detail.challengeName ?? 'Challenge';
  int get _myScore => detail.myScore ?? 0;
  int get _myRank => detail.myRank ?? 0;
  int get _highestScore => detail.highestScore ?? 0;
  int get _totalParticipants => detail.totalParticipants ?? 0;
  String get _testTitle => detail.test?.title ?? '';
  int get _durationMinutes => detail.test?.durationMinutes ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            title: _title,
            subtitle:
                'Performance insights & ranking distribution • $_testTitle',
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatsGrid(),
                const SizedBox(height: 16),
                _buildPerformanceChart(),
                const SizedBox(height: 16),
                _buildRankingDistribution(),
                const SizedBox(height: 16),
                _buildParticipantsCard(),
                const SizedBox(height: 16),
                _buildLeaderboard(),
                const SizedBox(height: 16),
                _buildMetaInfo(),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // STATS GRID
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.emoji_events,
                iconColor: const Color(0xFFFFD700),
                label: 'YOUR RANK',
                value: '#$_myRank',
                bgColor: const Color(0xFFFFF9E6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.track_changes,
                iconColor: const Color(0xFF00BFA5),
                label: 'YOUR SCORE',
                value: '$_myScore',
                bgColor: const Color(0xFFE0F7F4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.military_tech,
                iconColor: const Color(0xFF2196F3),
                label: 'HIGHEST SCORE',
                value: '$_highestScore',
                bgColor: const Color(0xFFE3F2FD),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.people,
                iconColor: const Color(0xFF9C27B0),
                label: 'PARTICIPANTS',
                value: '$_totalParticipants',
                bgColor: const Color(0xFFF3E5F5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color bgColor,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 10),
          CustomText(text: label, size: 11, weight: FontWeight.w600, color: Colors.grey.shade600),
          const SizedBox(height: 4),
          CustomText(text: value, size: 24, weight: FontWeight.w800, color: Colors.black87),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // PERFORMANCE CHART — bar showing my score vs highest
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildPerformanceChart() {
    final maxY = (_highestScore > 0 ? _highestScore : 5).toDouble();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: accentOrange, size: 20),
              const SizedBox(width: 8),
              const CustomText(text: 'Your Performance', size: 16, weight: FontWeight.w700, color: Colors.black87),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label = groupIndex == 0 ? 'You' : 'Best';
                      return BarTooltipItem(
                        '$label\n${rod.toY.toInt()}',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxY / 4,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) => CustomText(text: value.toInt().toString(), size: 11, color: Colors.grey.shade600),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final labels = ['You', 'Best'];
                        final idx = value.toInt();
                        if (idx < 0 || idx >= labels.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: CustomText(text: labels[idx], size: 12, weight: FontWeight.w600, color: Colors.black87),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  // Your score bar
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: _myScore.toDouble(),
                        gradient: const LinearGradient(
                          colors: [accentOrange, Color(0xFFFF8C00)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 50,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ],
                  ),
                  // Highest score bar
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: _highestScore.toDouble(),
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade700],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 50,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _chartLegendDot(accentOrange, 'Your score: $_myScore'),
              const SizedBox(width: 16),
              _chartLegendDot(Colors.blue.shade600, 'Highest: $_highestScore'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chartLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        CustomText(text: label, size: 12, weight: FontWeight.w600, color: Colors.black54),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // RANKING DISTRIBUTION  (donut based on actual participants)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildRankingDistribution() {
    final participants = detail.participants ?? [];
    if (participants.isEmpty) return const SizedBox.shrink();

    // Bucket participants by score tier relative to highest
    int excellent = 0, good = 0, average = 0, needsPractice = 0;
    for (final p in participants) {
      final score = p.score ?? 0;
      final maxScore = p.maxScore ?? 1;
      final pct = maxScore > 0 ? score / maxScore : 0.0;
      if (pct >= 0.75) {
        excellent++;
      } else if (pct >= 0.5) {
        good++;
      } else if (pct >= 0.25) {
        average++;
      } else {
        needsPractice++;
      }
    }

    final sections = <PieChartSectionData>[];
    void addSection(int count, Color color) {
      if (count > 0) {
        sections.add(PieChartSectionData(value: count.toDouble(), title: '', color: color, radius: 30));
      }
    }

    addSection(excellent, successColor);
    addSection(good, const Color(0xFF2196F3));
    addSection(average, const Color(0xFFFFD700));
    addSection(needsPractice, Colors.red.shade400);

    if (sections.isEmpty) return const SizedBox.shrink();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people_outline, color: drawerColor, size: 20),
              const SizedBox(width: 8),
              const CustomText(text: 'Ranking Distribution', size: 16, weight: FontWeight.w700, color: Colors.black87),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              height: 180,
              child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 50, sections: sections)),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              if (excellent > 0) _buildLegendItem('Excellent (≥75%)', successColor, '$excellent participant${excellent == 1 ? '' : 's'}'),
              if (good > 0) _buildLegendItem('Good (≥50%)', const Color(0xFF2196F3), '$good participant${good == 1 ? '' : 's'}'),
              if (average > 0) _buildLegendItem('Average (≥25%)', const Color(0xFFFFD700), '$average participant${average == 1 ? '' : 's'}'),
              if (needsPractice > 0) _buildLegendItem('Needs Practice', Colors.red.shade400, '$needsPractice participant${needsPractice == 1 ? '' : 's'}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(height: 6),
        CustomText(text: label, size: 11, weight: FontWeight.w600, color: Colors.black87, align: TextAlign.center),
        const SizedBox(height: 2),
        CustomText(text: count, size: 10, color: Colors.grey, align: TextAlign.center),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // PARTICIPANTS CARD (time breakdown)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildParticipantsCard() {
    final participants = detail.participants ?? [];
    if (participants.isEmpty) return const SizedBox.shrink();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.group_outlined, color: accentOrange, size: 20),
              const SizedBox(width: 8),
              const CustomText(text: 'Participants', size: 16, weight: FontWeight.w700, color: Colors.black87),
            ],
          ),
          const SizedBox(height: 12),
          ...participants.map((p) {
            final isMe = p.studentId == currentUserId;
            final score = p.score ?? 0;
            final maxScore = p.maxScore ?? 0;
            final rank = p.rank ?? 0;
            final name = p.name ?? 'Unknown';
            final pct = maxScore > 0 ? score / maxScore : 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? accentOrange.withOpacity(0.06) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isMe ? accentOrange.withOpacity(0.3) : Colors.grey.shade200,
                  width: isMe ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Rank badge
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: rank == 1 ? const Color(0xFFFFD700) : rank == 2 ? const Color(0xFFC0C0C0) : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text('#$rank', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white))),
                  ),
                  const SizedBox(width: 10),
                  // Name + progress
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMe ? '$name (You)' : name,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isMe ? accentOrange : Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 5,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isMe ? accentOrange : Colors.blue.shade400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Score
                  Text('$score/$maxScore', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isMe ? accentOrange : Colors.black87)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // LEADERBOARD
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildLeaderboard() {
    final lb = detail.leaderboard ?? [];
    if (lb.isEmpty) return const SizedBox.shrink();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.leaderboard_rounded, color: drawerColor, size: 20),
              const SizedBox(width: 8),
              const CustomText(text: 'Leaderboard', size: 16, weight: FontWeight.w700, color: Colors.black87),
            ],
          ),
          const SizedBox(height: 16),
          ...lb.map((entry) {
            final rank = entry.rank ?? 0;
            final name = entry.name ?? 'Unknown';
            final score = entry.score ?? 0;
            final maxScore = entry.maxScore ?? 0;
            final isMe = entry.studentId == currentUserId;

            Color rankColor;
            if (rank == 1) {
              rankColor = const Color(0xFFFFD700);
            } else if (rank == 2) {
              rankColor = const Color(0xFFC0C0C0);
            } else if (rank == 3) {
              rankColor = const Color(0xFFCD7F32);
            } else {
              rankColor = Colors.grey.shade300;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isMe ? accentOrange.withOpacity(0.08) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isMe ? accentOrange.withOpacity(0.3) : Colors.grey.shade200,
                  width: isMe ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Rank badge
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: rankColor, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text('#$rank', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                  const SizedBox(width: 14),
                  // Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
                        if (isMe) const Text('(You)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: accentOrange)),
                      ],
                    ),
                  ),
                  // Score
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$score', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isMe ? accentOrange : Colors.black87)),
                      Text('/ $maxScore', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // META INFO (test details, timing)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildMetaInfo() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey.shade500, size: 18),
              const SizedBox(width: 8),
              const CustomText(text: 'Challenge Info', size: 16, weight: FontWeight.w700, color: Colors.black87),
            ],
          ),
          const SizedBox(height: 12),
          _metaRow(Icons.meeting_room_outlined, 'Room Code', detail.roomCode ?? '-'),
          _metaRow(Icons.quiz_outlined, 'Test', _testTitle),
          _metaRow(Icons.timer_outlined, 'Duration', '$_durationMinutes min'),
          if (detail.createdBy?.name != null)
            _metaRow(Icons.person_outline, 'Host', detail.createdBy!.name!),
          if (detail.startedAt != null)
            _metaRow(Icons.play_circle_outline, 'Started', _formatDateTime(detail.startedAt!)),
          if (detail.completedAt != null)
            _metaRow(Icons.check_circle_outline, 'Completed', _formatDateTime(detail.completedAt!)),
        ],
      ),
    );
  }

  Widget _metaRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87))),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year}  $h:$m';
  }
}