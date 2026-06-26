import 'package:firstedu/data/models/api_models/dashboardmodels/dashboard_models.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_silverappbar.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/view_models/dashboardprovider/dashboardprovider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LearningActivityScreen extends StatefulWidget {
  const LearningActivityScreen({super.key});

  @override
  State<LearningActivityScreen> createState() => _LearningActivityScreenState();
}

class _LearningActivityScreenState extends State<LearningActivityScreen> {
  int _touchedPieIndex = -1;

  // ── Pie colors ──────────────────────────────────────────────────
  static const _pieColors = [
    Color(0xFF3B82F6),
    Color(0xFFF97316),
    Color(0xFF8B5CF6),
    Color(0xFF22C55E),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DashboardProvider>();
      if (provider.dashboard == null && !provider.isLoading) {
        provider.fetchDashboard(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        final data = provider.dashboard?.data;
        final isLoading = provider.isLoading;

        return Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          body: CustomScrollView(
            slivers: [
              const CustomSliverAppBar(
                title: "Learning Activity",
                subtitle: "Time spent on each activity and detailed breakdown",
              ),
              SliverPadding(
                padding: EdgeInsets.all(16.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _timeStats(data, isLoading),
                    SizedBox(height: 20.h),
                    _timeByActivity(data?.testTypeStats, isLoading),
                    SizedBox(height: 20.h),
                    _activityOverTime(isLoading),
                    SizedBox(height: 20.h),
                    _activityInsights(data),
                    SizedBox(height: 20.h),
                    _detailedBreakdown(data?.testTypeStats, isLoading),
                    SizedBox(height: 100.h),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TIME STATS  (totalTimeLearning + testTypeStats)
  // ═══════════════════════════════════════════════════════════════

  Widget _timeStats(DashboardData? data, bool isLoading) {
    final ttl = data?.totalTimeLearning;
    final stats = data?.testTypeStats ?? [];

    // Sum up exam/test minutes from testTypeStats
    final examMins = stats
        .where((s) =>
            s.type == TestType.TEST ||
            s.type == TestType.OLYMPIAD ||
            s.type == TestType.COMPETITION_SECTOR)
        .fold<int>(0, (sum, s) => sum + s.totalDurationMinutes);

    final courseMins = stats
        .where((s) => s.type == TestType.EVERYDAY_CHALLENGE)
        .fold<int>(0, (sum, s) => sum + s.totalDurationMinutes);

    String _fmt(int minutes) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return h > 0 ? '${h}h ${m}m' : '${m}m';
    }

    final totalLabel = isLoading
        ? '—'
        : ttl != null
            ? '${ttl.hours}h ${ttl.minutes}m'
            : _fmt(stats.fold(0, (s, e) => s + e.totalDurationMinutes));

    return Column(
      children: [
        _TimeCard(
          icon: Icons.access_time_rounded,
          color: Colors.orange,
          label: "TOTAL HOURS",
          value: totalLabel,
          isLoading: isLoading,
        ),
        const SizedBox(height: 12),
        _TimeCard(
          icon: Icons.assignment_outlined,
          color: Colors.blue,
          label: "EXAMS & TESTS",
          value: isLoading ? '—' : _fmt(examMins),
          isLoading: isLoading,
        ),
        const SizedBox(height: 12),
        _TimeCard(
          icon: Icons.menu_book_rounded,
          color: Colors.green,
          label: "COURSES",
          value: isLoading ? '—' : _fmt(courseMins),
          isLoading: isLoading,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TIME BY ACTIVITY  (testTypeStats pie — tap to show time+title)
  // ═══════════════════════════════════════════════════════════════

  Widget _timeByActivity(List<TestTypeStat>? stats, bool isLoading) {
    final slices = _buildSlices(stats);
    final touched = _touchedPieIndex >= 0 && _touchedPieIndex < slices.length
        ? slices[_touchedPieIndex]
        : null;

    return CustomCard(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CustomText(
                  text: "Time by Activity", size: 16, weight: FontWeight.w700),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: drawerColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomText(
                  text: "All Time",
                  size: 11,
                  weight: FontWeight.w600,
                  color: drawerColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          if (isLoading)
            SizedBox(
                height: 220.h,
                child: const Center(child: CircularProgressIndicator()))
          else
            Center(
              child: SizedBox(
                height: 220.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // ── Pie chart ──
                    PieChart(
                      PieChartData(
                        centerSpaceRadius: 62.r,
                        sectionsSpace: 3,
                        pieTouchData: PieTouchData(
                          touchCallback: (event, res) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  res == null ||
                                  res.touchedSection == null) {
                                _touchedPieIndex = -1;
                                return;
                              }
                              final idx =
                                  res.touchedSection!.touchedSectionIndex;
                              _touchedPieIndex =
                                  _touchedPieIndex == idx ? -1 : idx;
                            });
                          },
                        ),
                        sections: slices.asMap().entries.map((e) {
                          final i = e.key;
                          final s = e.value;
                          final isTouched = i == _touchedPieIndex;
                          return PieChartSectionData(
                            color: s.color,
                            value: s.value,
                            title: '',
                            radius: isTouched ? 66 : 52,
                          );
                        }).toList(),
                      ),
                    ),

                    // ── Center tooltip ──
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: touched != null
                          ? _CenterLabel(
                              key: ValueKey(touched.label),
                              label: touched.label,
                              time: touched.timeLabel,
                              color: touched.color,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

          SizedBox(height: 20.h),

          // ── Tappable legend ──
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 14.w,
            runSpacing: 12.h,
            children: slices.asMap().entries.map((e) {
              final i = e.key;
              final s = e.value;
              final isActive = _touchedPieIndex == i;
              return GestureDetector(
                onTap: () =>
                    setState(() => _touchedPieIndex = isActive ? -1 : i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? s.color.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isActive ? s.color : Colors.transparent,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: s.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        s.label,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isActive ? s.color : const Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        s.timeLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: s.color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ACTIVITY OVER TIME  — original stacked bar chart style
  // connected to testTypeStats monthly trend data
  // ═══════════════════════════════════════════════════════════════

  Widget _activityOverTime(bool isLoading) {
    // Build bar data from testTypeStats monthly trends
    // We use monthlyScoreTrend as the month axis and derive activity counts
    // from the provider's testTypeStats per month
    final provider = context.read<DashboardProvider>();
    final allStats = provider.dashboard?.data?.testTypeStats ?? [];

    // Gather all unique months across all testTypeStats monthly trends
    final Map<String, Map<String, double>> monthMap = {};

    for (final stat in allStats) {
      for (final mt in stat.monthlyTrend) {
        monthMap.putIfAbsent(mt.month, () => {});
        // Group into 3 display buckets
        final bucket = _statBucket(stat.type);
        monthMap[mt.month]![bucket] =
            (monthMap[mt.month]![bucket] ?? 0) + mt.avgScore;
      }
    }

    // Sort months chronologically
    final sortedMonths = monthMap.keys.toList()..sort();

    // Fallback to hardcoded if no API data
    final bool hasData = sortedMonths.isNotEmpty;

    final List<Map<String, dynamic>> barData = hasData
        ? sortedMonths.map((m) {
            final vals = monthMap[m]!;
            return {
              'month': _shortMonth(m),
              'exams': (vals['exams'] ?? 0).roundToDouble(),
              'courses': (vals['courses'] ?? 0).roundToDouble(),
              'practice': (vals['practice'] ?? 0).roundToDouble(),
            };
          }).toList()
        : [
            {'month': 'Aug', 'exams': 4.0, 'courses': 2.0, 'practice': 3.0},
            {'month': 'Sep', 'exams': 5.0, 'courses': 5.0, 'practice': 2.0},
            {'month': 'Oct', 'exams': 5.0, 'courses': 4.0, 'practice': 3.0},
            {'month': 'Nov', 'exams': 4.0, 'courses': 3.0, 'practice': 2.0},
            {'month': 'Dec', 'exams': 3.0, 'courses': 1.0, 'practice': 4.0},
          ];

    // Compute maxY dynamically
    double maxY = 12;
    if (hasData) {
      for (final d in barData) {
        final total = (d['exams'] as double) +
            (d['courses'] as double) +
            (d['practice'] as double);
        if (total > maxY) maxY = total + 2;
      }
    }

    return CustomCard(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: "Activity Over Time",
            size: 16,
            weight: FontWeight.w700,
          ),
          SizedBox(height: 24.h),

          if (isLoading)
            SizedBox(
              height: 200.h,
              child: const Center(child: CircularProgressIndicator()),
            )
          else
            SizedBox(
              height: 200.h,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  borderData: FlBorderData(show: false),

                  // Touch tooltip — shows month + breakdown on tap
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, _, rod, __) {
                        final d = barData[group.x.toInt()];
                        return BarTooltipItem(
                          '${d['month']}\n'
                          'Exams: ${(d['exams'] as double).toStringAsFixed(0)}h\n'
                          'Courses: ${(d['courses'] as double).toStringAsFixed(0)}h\n'
                          'Practice: ${(d['practice'] as double).toStringAsFixed(0)}h',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),

                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (v) =>
                        FlLine(color: Colors.grey.shade200),
                  ),

                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final idx = v.toInt();
                          if (idx < 0 || idx >= barData.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: CustomText(
                              text: barData[idx]['month'],
                              size: 11,
                              color: Colors.grey.shade600,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (v, _) => CustomText(
                          text: v.toInt().toString(),
                          size: 10,
                        ),
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),

                  barGroups: List.generate(barData.length, (i) {
                    final d = barData[i];
                    final e = d['exams'] as double;
                    final c = d['courses'] as double;
                    final p = d['practice'] as double;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: e + c + p,
                          width: 24,
                          borderRadius: BorderRadius.circular(4),
                          rodStackItems: [
                            BarChartRodStackItem(0, e, Colors.blue),
                            BarChartRodStackItem(e, e + c, Colors.orange),
                            BarChartRodStackItem(e + c, e + c + p, Colors.green),
                          ],
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),

          SizedBox(height: 16.h),

          // Legend — same as original
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _barLegendItem(Colors.blue, "Exams"),
              SizedBox(width: 20.w),
              _barLegendItem(Colors.orange, "Courses"),
              SizedBox(width: 20.w),
              _barLegendItem(Colors.green, "Practice"),
            ],
          ),
        ],
      ),
    );
  }

  /// Groups TestType into 3 display buckets for the bar chart
  String _statBucket(TestType type) {
    switch (type) {
      case TestType.TEST:
      case TestType.OLYMPIAD:
      case TestType.COMPETITION_SECTOR:
      case TestType.TOURNAMENT:
        return 'exams';
      case TestType.EVERYDAY_CHALLENGE:
      case TestType.CHALLENGE_YOURSELF:
        return 'practice';
      default:
        return 'courses';
    }
  }

  Widget _barLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        CustomText(
          text: label,
          size: 12,
          weight: FontWeight.w600,
          color: Colors.black87,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // INSIGHTS  (dynamic based on API data)
  // ═══════════════════════════════════════════════════════════════

  Widget _activityInsights(DashboardData? data) {
    final ttl = data?.totalTimeLearning;
    final totalHrs = ttl?.hours ?? 45;

    // Find activity type with most time
    final stats = data?.testTypeStats ?? [];
    TestTypeStat? topActivity;
    if (stats.isNotEmpty) {
      topActivity = stats.reduce((a, b) =>
          a.totalDurationMinutes > b.totalDurationMinutes ? a : b);
    }

    // Find weakest category
    final weak = data?.weakCategories ?? [];
    final weakName =
        weak.isNotEmpty ? weak.first.categoryName : 'some topics';

    return CustomCard(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
              text: "Activity Insights", size: 16, weight: FontWeight.w700),
          const SizedBox(height: 16),
          _Insight(
            Icons.star_rounded,
            Colors.amber,
            "You've spent ${totalHrs}h learning — great dedication!",
          ),
          const SizedBox(height: 12),
          _Insight(
            Icons.assignment_outlined,
            Colors.blue,
            topActivity != null
                ? "${topActivity.displayLabel} takes most of your time."
                : "Exams & Tests take most of your time.",
          ),
          const SizedBox(height: 12),
          _Insight(
            Icons.trending_down,
            Colors.red,
            "Focus more on $weakName to boost your scores.",
          ),
          const SizedBox(height: 12),
          _Insight(
            Icons.balance,
            Colors.green,
            "Balance courses and practice for better retention.",
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DETAILED BREAKDOWN  (testTypeStats rows)
  // ═══════════════════════════════════════════════════════════════

  Widget _detailedBreakdown(List<TestTypeStat>? stats, bool isLoading) {
    // Build rows from API, or fall back
    final List<_BreakdownRow> rows;

    if (stats != null && stats.isNotEmpty) {
      final totalMins =
          stats.fold<int>(0, (s, e) => s + e.totalDurationMinutes);
      rows = stats.asMap().entries.map((e) {
        final s = e.value;
        final color = _pieColors[e.key % _pieColors.length];
        final h = s.totalDurationMinutes ~/ 60;
        final m = s.totalDurationMinutes % 60;
        final timeStr = h > 0 ? '${h}h ${m}m' : '${m}m';
        final pct = totalMins > 0
            ? '${((s.totalDurationMinutes / totalMins) * 100).round()}%'
            : '0%';
        return _BreakdownRow(
          label: s.displayLabel,
          time: timeStr,
          pct: pct,
          color: color,
          avgScore: s.avgScore,
          bestScore: s.bestScore,
          totalTests: s.totalTests,
        );
      }).toList();
    } else {
      rows = const [
        _BreakdownRow(label: "Exams & Tests", time: "22h", pct: "49%", color: Color(0xFF3B82F6), avgScore: 0, bestScore: 0, totalTests: 0),
        _BreakdownRow(label: "Courses", time: "15h", pct: "33%", color: Color(0xFFF97316), avgScore: 0, bestScore: 0, totalTests: 0),
        _BreakdownRow(label: "Practice", time: "6h", pct: "13%", color: Color(0xFF22C55E), avgScore: 0, bestScore: 0, totalTests: 0),
        _BreakdownRow(label: "Live Events", time: "2h", pct: "4%", color: Color(0xFF8B5CF6), avgScore: 0, bestScore: 0, totalTests: 0),
      ];
    }

    return CustomCard(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
              text: "Detailed Activity Breakdown",
              size: 16,
              weight: FontWeight.w700),
          SizedBox(height: 16.h),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ...rows.map((r) => _breakdownRowWidget(r)).toList(),
        ],
      ),
    );
  }

  Widget _breakdownRowWidget(_BreakdownRow r) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: r.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomText(
                    text: r.label, size: 14, weight: FontWeight.w600),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomText(
                      text: r.time, size: 18, weight: FontWeight.w700),
                  CustomText(text: r.pct, size: 11, color: Colors.grey),
                ],
              ),
            ],
          ),
          // Show avg score + total tests if available from API
          if (r.totalTests > 0) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  _miniStat(
                      Icons.bar_chart, '${r.avgScore.toStringAsFixed(0)}%', 'Avg Score', r.color),
                  const SizedBox(width: 16),
                  _miniStat(
                      Icons.emoji_events_outlined, '${r.bestScore}%', 'Best', Colors.amber),
                  const SizedBox(width: 16),
                  _miniStat(
                      Icons.description_outlined, '${r.totalTests}', 'Tests', Colors.grey),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          // Progress bar
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: double.tryParse(r.pct.replaceAll('%', '')) != null
                    ? double.parse(r.pct.replaceAll('%', '')) / 100
                    : 0,
                minHeight: 6,
                backgroundColor: r.color.withOpacity(0.12),
                color: r.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String value, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color)),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400)),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  List<_SliceData> _buildSlices(List<TestTypeStat>? stats) {
    if (stats != null && stats.isNotEmpty) {
      return stats.asMap().entries.map((e) {
        final s = e.value;
        final color = _pieColors[e.key % _pieColors.length];
        final h = s.totalDurationMinutes ~/ 60;
        final m = s.totalDurationMinutes % 60;
        final timeLabel = h > 0 ? '${h}h ${m}m' : '${m}m';
        return _SliceData(
          label: s.displayLabel,
          timeLabel: timeLabel,
          value: s.totalDurationMinutes.toDouble().clamp(1, double.infinity),
          color: color,
        );
      }).toList();
    }
    return const [
      _SliceData(label: 'Exams',       timeLabel: '22h', value: 22*60, color: Color(0xFF3B82F6)),
      _SliceData(label: 'Courses',     timeLabel: '15h', value: 15*60, color: Color(0xFFF97316)),
      _SliceData(label: 'Live Events', timeLabel: '2h',  value: 2*60,  color: Color(0xFF8B5CF6)),
      _SliceData(label: 'Practice',    timeLabel: '6h',  value: 6*60,  color: Color(0xFF22C55E)),
    ];
  }

  String _shortMonth(String raw) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    try {
      final parts = raw.split('-');
      if (parts.length == 2) {
        final m = int.tryParse(parts[1]) ?? 0;
        return months[m];
      }
      return raw.length > 3 ? raw.substring(0, 3) : raw;
    } catch (_) {
      return raw;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// CENTER LABEL (shown in donut hole on tap)
// ═══════════════════════════════════════════════════════════════════

class _CenterLabel extends StatelessWidget {
  final String label;
  final String time;
  final Color color;

  const _CenterLabel(
      {super.key,
      required this.label,
      required this.time,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          time,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SMALL WIDGETS
// ═══════════════════════════════════════════════════════════════════

class _TimeCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final bool isLoading;

  const _TimeCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(text: label, size: 11, color: Colors.grey),
              const SizedBox(height: 4),
              isLoading
                  ? Container(
                      width: 60,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )
                  : CustomText(text: value, size: 24, weight: FontWeight.w700),
            ],
          ),
        ],
      ),
    );
  }
}

class _Insight extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _Insight(this.icon, this.color, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(child: CustomText(text: text, size: 13, height: 1.5)),
      ],
    );
  }
}

// ── Data models ─────────────────────────────────────────────────────

class _SliceData {
  final String label;
  final String timeLabel;
  final double value;
  final Color color;

  const _SliceData({
    required this.label,
    required this.timeLabel,
    required this.value,
    required this.color,
  });
}

class _BreakdownRow {
  final String label;
  final String time;
  final String pct;
  final Color color;
  final double avgScore;
  final int bestScore;
  final int totalTests;

  const _BreakdownRow({
    required this.label,
    required this.time,
    required this.pct,
    required this.color,
    required this.avgScore,
    required this.bestScore,
    required this.totalTests,
  });
}