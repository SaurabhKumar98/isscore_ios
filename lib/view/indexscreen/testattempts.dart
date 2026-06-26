import 'package:firstedu/data/models/api_models/dashboardmodels/dashboard_models.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_silverappbar.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/view_models/dashboardprovider/dashboardprovider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TestsAttemptedScreen extends StatefulWidget {
  const TestsAttemptedScreen({super.key});

  @override
  State<TestsAttemptedScreen> createState() => _TestsAttemptedScreenState();
}

class _TestsAttemptedScreenState extends State<TestsAttemptedScreen> {
  int? _selectedPerformanceIndex;
  int? _selectedTrendIndex;

  // Colours cycled for performance bars
  static const _barColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.red,
  ];

  // ── helpers to build chart-ready lists from API data ──────────────

  /// One bar per test result — subject = category, score = percentage
  List<Map<String, dynamic>> _buildPerformanceData(List<TestResult> results) {
    return results.asMap().entries.map((e) {
      return {
        'subject': e.value.category.isNotEmpty
            ? e.value.category
            : e.value.name,
        'score': e.value.percentage,
        'time': '—',
        'color': _barColors[e.key % _barColors.length],
      };
    }).toList();
  }

  /// Month + avgScore from monthlyScoreTrend
  List<Map<String, dynamic>> _buildTrendData(List<MonthlyScoreTrend> trends) {
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
      String label = t.month;
      try {
        final parts = t.month.split('-');
        if (parts.length == 2) {
          final m = int.tryParse(parts[1]) ?? 0;
          label = monthNames[m];
        }
      } catch (_) {}
      return {'month': label, 'score': t.avgScore};
    }).toList();
  }

  /// All test results as the list card rows
  List<Map<String, dynamic>> _buildAllTests(List<TestResult> results) {
    return results.map((r) {
      final dateStr = r.date != null
          ? '${r.date!.day} ${_monthName(r.date!.month)} ${r.date!.year}'
          : '—';
      return {
        'subject': r.category.isNotEmpty ? r.category : '—',
        'title': r.name,
        'status': 'Completed',
        'date': dateStr,
        'duration': '—',
        'score': r.percentage,
        'total': 100,
        'rank': '${r.score}/${r.maxScore}',
      };
    }).toList();
  }

  String _monthName(int m) {
    const names = [
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
    return m >= 1 && m <= 12 ? names[m] : '';
  }

  // ── build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        final data = provider.dashboard?.data;
        final isLoading = provider.isLoading;

        final performanceData = _buildPerformanceData(
          data?.allTestResults ?? [],
        );
        final trendData = _buildTrendData(data?.monthlyScoreTrend ?? []);
        final allTests = _buildAllTests(data?.allTestResults ?? []);

        // Summary stats
        final totalTests = data?.totalTestsTaken ?? 0;
        final avgScore = data?.averageScore ?? 0.0;
        final timeLearning = data?.totalTimeLearning;
        final timeStr = timeLearning != null
            ? timeLearning.hours > 0
                  ? '${timeLearning.hours}h ${timeLearning.minutes}m'
                  : '${timeLearning.minutes}m'
            : '0m';

        return Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          body: CustomScrollView(
            slivers: [
              const CustomSliverAppBar(
                title: "Tests Attempted",
                subtitle:
                    "Detailed breakdown of your test attempts and performance insights",
              ),
              SliverPadding(
                padding: EdgeInsets.all(16.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildTimeStatsCards(
                      isLoading: isLoading,
                      totalTests: totalTests,
                      avgScore: avgScore,
                      timeStr: timeStr,
                    ),
                    SizedBox(height: 20.h),
                    _buildPerformanceChart(
                      performanceData: performanceData,
                      isLoading: isLoading,
                    ),
                    SizedBox(height: 20.h),
                    _buildScoreTrendChart(
                      trendData: trendData,
                      isLoading: isLoading,
                    ),
                    SizedBox(height: 20.h),
                    _buildPerformanceInsights(
                      totalTests: totalTests,
                      avgScore: avgScore,
                      timeStr: timeStr,
                      bestScore: data?.bestScore ?? 0,
                    ),
                    SizedBox(height: 20.h),
                    _buildAllTestAttempts(
                      allTests: allTests,
                      isLoading: isLoading,
                    ),
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

  // ── STATS CARDS ────────────────────────────────────────────────────

  Widget _buildTimeStatsCards({
    required bool isLoading,
    required int totalTests,
    required double avgScore,
    required String timeStr,
  }) {
    return Column(
      children: [
        _buildTimeCard(
          icon: Icons.blur_circular,
          iconColor: Colors.orange,
          label: "Tests Taken",
          value: isLoading ? '—' : '$totalTests',
        ),
        SizedBox(height: 12.h),
        _buildTimeCard(
          icon: Icons.score,
          iconColor: Colors.blue,
          label: "Avg Score",
          value: isLoading ? '—' : '${avgScore.toStringAsFixed(1)}%',
        ),
        SizedBox(height: 12.h),
        _buildTimeCard(
          icon: Icons.access_time_rounded,
          iconColor: Colors.green,
          label: "Total Time",
          value: isLoading ? '—' : timeStr,
        ),
      ],
    );
  }

  Widget _buildTimeCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return CustomCard(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: iconColor, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: label,
                size: 11,
                weight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
              SizedBox(height: 4.h),
              CustomText(
                text: value,
                size: 24,
                weight: FontWeight.w700,
                color: Colors.black87,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── PERFORMANCE BAR CHART ──────────────────────────────────────────
  Widget _buildPerformanceChart({
    required List<Map<String, dynamic>> performanceData,
    required bool isLoading,
  }) {
    return CustomCard(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.blue,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              const Expanded(
                child: CustomText(
                  text: "Performance by Test",
                  size: 16,
                  weight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          const CustomText(
            text: "Tap on any bar to see details",
            size: 11,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),

          /// LOADING
          if (isLoading)
            SizedBox(
              height: 220.h,
              child: const Center(child: CircularProgressIndicator()),
            )
          /// EMPTY
          else if (performanceData.isEmpty)
            SizedBox(
              height: 220.h,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bar_chart_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "No test data yet",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          /// CHART
          else ...[
            SizedBox(
              height: 220.h,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final chartWidth = (performanceData.length * 70)
                      .toDouble()
                      .clamp(constraints.maxWidth, double.infinity);

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(
                      width: chartWidth,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceBetween,
                          maxY: 100,

                          /// TOUCH
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchCallback:
                                (FlTouchEvent event, barTouchResponse) {
                                  setState(() {
                                    if (barTouchResponse != null &&
                                        barTouchResponse.spot != null &&
                                        event is FlTapUpEvent) {
                                      _selectedPerformanceIndex =
                                          barTouchResponse
                                              .spot!
                                              .touchedBarGroupIndex;
                                    }
                                  });
                                },
                          ),

                          /// TITLES
                          titlesData: FlTitlesData(
                            show: true,

                            /// X AXIS
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final idx = value.toInt();

                                  if (idx < performanceData.length) {
                                    final label =
                                        performanceData[idx]['subject']
                                            .toString();

                                    return Padding(
                                      padding: EdgeInsets.only(top: 8.h),
                                      child: Transform.rotate(
                                        angle: -0.5,
                                        child: Text(
                                          label.length > 6
                                              ? "${label.substring(0, 6)}.."
                                              : label,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),

                            /// Y AXIS
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 35.w,
                                getTitlesWidget: (value, meta) => CustomText(
                                  text: value.toInt().toString(),
                                  size: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),

                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),

                          /// GRID
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 25,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.grey.shade200,
                              strokeWidth: 1,
                            ),
                          ),

                          borderData: FlBorderData(show: false),

                          /// BARS
                          barGroups: List.generate(performanceData.length, (
                            index,
                          ) {
                            final isSelected =
                                _selectedPerformanceIndex == index;

                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: (performanceData[index]['score'] as num)
                                      .toDouble(),
                                  width: isSelected ? 32.w : 26.w,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(8.r),
                                  ),
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            performanceData[index]['color'],
                                            performanceData[index]['color']
                                                .withOpacity(0.7),
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        )
                                      : null,
                                  color: isSelected
                                      ? null
                                      : performanceData[index]['color'],
                                ),
                              ],
                            );
                          }),

                          /// ANIMATION
                          // swapAnimationDuration: const Duration(milliseconds: 300),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            /// SELECTED INFO
            if (_selectedPerformanceIndex != null &&
                _selectedPerformanceIndex! < performanceData.length) ...[
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      performanceData[_selectedPerformanceIndex!]['color']
                          .withOpacity(0.15),
                      performanceData[_selectedPerformanceIndex!]['color']
                          .withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: performanceData[_selectedPerformanceIndex!]['color']
                        .withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color:
                                performanceData[_selectedPerformanceIndex!]['color'],
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: CustomText(
                            text:
                                performanceData[_selectedPerformanceIndex!]['subject'],
                            size: 15,
                            weight: FontWeight.w700,
                            color: Colors.black87,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricBox(
                            Icons.stars_rounded,
                            "Score",
                            "${performanceData[_selectedPerformanceIndex!]['score']}%",
                            performanceData[_selectedPerformanceIndex!]['color'],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildMetricBox(
                            Icons.timer_outlined,
                            "Time",
                            performanceData[_selectedPerformanceIndex!]['time'],
                            performanceData[_selectedPerformanceIndex!]['color'],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildMetricBox(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22.sp),
          SizedBox(height: 8.h),
          CustomText(
            text: label,
            size: 11,
            weight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
          SizedBox(height: 4.h),
          CustomText(
            text: value,
            size: 16,
            weight: FontWeight.w700,
            color: Colors.black87,
          ),
        ],
      ),
    );
  }

  // ── SCORE TREND CHART ──────────────────────────────────────────────

  Widget _buildScoreTrendChart({
    required List<Map<String, dynamic>> trendData,
    required bool isLoading,
  }) {
    return CustomCard(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: "Score Trend",
            size: 16,
            weight: FontWeight.w700,
            color: Colors.black87,
          ),
          SizedBox(height: 16.h),
          if (isLoading)
            SizedBox(
              height: 200.h,
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (trendData.isEmpty)
            SizedBox(
              height: 200.h,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.show_chart, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      "No trend data yet",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 200.h,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchCallback: (FlTouchEvent event, barTouchResponse) {
                      setState(() {
                        if (barTouchResponse != null &&
                            barTouchResponse.spot != null &&
                            event is FlTapUpEvent) {
                          _selectedTrendIndex =
                              barTouchResponse.spot!.touchedBarGroupIndex;
                        }
                      });
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < trendData.length) {
                            return Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: CustomText(
                                text: trendData[idx]['month'],
                                size: 11,
                                color: Colors.grey,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35.w,
                        getTitlesWidget: (value, meta) => CustomText(
                          text: value.toInt().toString(),
                          size: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                  ),
                  barGroups: List.generate(trendData.length, (index) {
                    final isSelected = _selectedTrendIndex == index;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: (trendData[index]['score'] as num).toDouble(),
                          color: activeItemColor,
                          width: isSelected ? 32.w : 28.w,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(6.r),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            if (_selectedTrendIndex != null &&
                _selectedTrendIndex! < trendData.length) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: activeItemColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: activeItemColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 18.sp,
                      color: activeItemColor,
                    ),
                    SizedBox(width: 8.w),
                    CustomText(
                      text: "${trendData[_selectedTrendIndex!]['month']} - ",
                      size: 14,
                      weight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    CustomText(
                      text: "${trendData[_selectedTrendIndex!]['score']}%",
                      size: 18,
                      weight: FontWeight.w700,
                      color: activeItemColor,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ── PERFORMANCE INSIGHTS ───────────────────────────────────────────

  Widget _buildPerformanceInsights({
    required int totalTests,
    required double avgScore,
    required String timeStr,
    required int bestScore,
  }) {
    return CustomCard(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: "Performance Insights",
            size: 16,
            weight: FontWeight.w700,
            color: Colors.black87,
          ),
          SizedBox(height: 16.h),
          _buildInsightItem(
            Icons.emoji_events,
            Colors.amber,
            bestScore > 0
                ? "Your best score is $bestScore%—keep up the momentum!"
                : "Complete a test to set your first best score!",
          ),
          SizedBox(height: 12.h),
          _buildInsightItem(
            Icons.trending_up,
            successColor,
            totalTests > 0
                ? "You've spent $timeStr on tests—consistent practice leads to improvement."
                : "Start a test to begin tracking your study time.",
          ),
          SizedBox(height: 12.h),
          _buildInsightItem(
            Icons.bar_chart,
            Colors.blue,
            avgScore > 0
                ? "Average score of ${avgScore.toStringAsFixed(1)}% across all attempts. ${avgScore >= 80 ? 'Excellent performance!' : 'Keep pushing!'}"
                : "Your average score will appear after you attempt tests.",
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(IconData icon, Color color, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color, size: 18.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: CustomText(
            text: text,
            size: 13,
            color: Colors.grey.shade700,
            maxLines: 5,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ── ALL TEST ATTEMPTS LIST ─────────────────────────────────────────

  Widget _buildAllTestAttempts({
    required List<Map<String, dynamic>> allTests,
    required bool isLoading,
  }) {
    return CustomCard(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: drawerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  color: drawerColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              const Expanded(
                child: CustomText(
                  text: "All Test Attempts",
                  size: 16,
                  weight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              CustomText(
                text: "${allTests.length} tests",
                size: 12,
                weight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (allTests.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  "No tests attempted yet.",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else
            ...allTests.asMap().entries.map((entry) {
              return _buildTestCard(entry.value, entry.key, allTests.length);
            }),
        ],
      ),
    );
  }

  Widget _buildTestCard(Map<String, dynamic> test, int index, int total) {
    return Container(
      margin: EdgeInsets.only(bottom: index < total - 1 ? 12.h : 0),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getScoreColor(test['score']),
                  _getScoreColor(test['score']).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.description_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
                CustomText(
                  text: "#${index + 1}",
                  size: 9,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: test['subject'],
                  size: 13,
                  weight: FontWeight.w700,
                  color: Colors.black87,
                  maxLines: 1,
                ),
                SizedBox(height: 2.h),
                CustomText(
                  text: test['title'],
                  size: 12,
                  weight: FontWeight.w500,
                  color: Colors.grey.shade700,
                  maxLines: 1,
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 11.sp,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: 4.w),
                    CustomText(
                      text: test['date'],
                      size: 10,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.timer, size: 11.sp, color: Colors.grey.shade500),
                    SizedBox(width: 4.w),
                    CustomText(
                      text: test['duration'],
                      size: 10,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: _getScoreColor(test['score']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: _getScoreColor(test['score']).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                CustomText(
                  text: "${test['score']}%",
                  size: 18,
                  weight: FontWeight.w700,
                  color: _getScoreColor(test['score']),
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: CustomText(
                    text: test['rank'],
                    size: 9,
                    weight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return successColor;
    if (score >= 75) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
