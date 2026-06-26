import 'package:firstedu/data/models/api_models/dashboardmodels/dashboard_models.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/view/indexscreen/testattempts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScoreImprovementCard extends StatelessWidget {
  final List<MonthlyScoreTrend> trends;
  final bool isLoading;

  const ScoreImprovementCard({
    super.key,
    this.trends = const [],
    this.isLoading = false,
  });

  // Returns empty list when no data — no hardcoded fallback
  List<FlSpot> get _spots {
    if (trends.isEmpty) return [];

    final spots = trends
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.avgScore.toDouble()))
        .toList();

    // 🔥 FIX: if only one point → add starting point from zero
    if (spots.length == 1) {
      return [
        FlSpot(0, 0), // 👈 start from zero
        FlSpot(1, spots.first.y),
      ];
    }

    return spots;
  }

  // Returns empty list when no data — no hardcoded fallback
  List<String> get _labels {
    if (trends.isEmpty) return [];
    const monthNames = [
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
      'Dec',
    ];
    return trends.map((t) {
      try {
        final parts = t.month.split('-');
        if (parts.length == 2) {
          final m = int.tryParse(parts[1]) ?? 0;
          return monthNames[m];
        }
        return t.month.length > 3 ? t.month.substring(0, 3) : t.month;
      } catch (_) {
        return t.month;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final spots = _spots;
    final labels = _labels;
    final isEmpty = spots.isEmpty;

    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header("Score Improvement",context),
          const SizedBox(height: 20),
          if (isLoading)
            const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (isEmpty)
            const SizedBox(
              height: 180,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.show_chart_rounded,
                      size: 56,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "No score data yet",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Complete tests to track your score progress",
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 25,
                        reservedSize: 36,
                        getTitlesWidget: (value, _) => Text(
                          value.toInt().toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 28,
                        getTitlesWidget: (value, _) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            labels[idx],
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,

                      curveSmoothness: 0.2, // 👈 🔥 MAIN FIX (0.1–0.3 best)

                      color: accentOrange,
                      barWidth: 3,

                      dotData: FlDotData(show: true),

                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            accentOrange.withValues(alpha: 0.35),
                            accentOrange.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
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

Widget _header(String title, BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      CustomText(text: title, size: 16, weight: FontWeight.w600),

      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TestsAttemptedScreen(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: const [
              CustomText(
                text: "View All",
                size: 12,
                weight: FontWeight.w600,
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios, size: 12),
            ],
          ),
        ),
      ),
    ],
  );
}
}
