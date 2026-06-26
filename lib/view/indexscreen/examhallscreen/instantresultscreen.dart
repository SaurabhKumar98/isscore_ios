import 'package:firstedu/data/models/api_models/examhall/examsessionmodels.dart';
import 'package:firstedu/data/models/api_models/examhall/resultmodels.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';

class InstantResultsScreen extends StatefulWidget {
  final List<double> scoreProgression;
  final ExamResultsData? resultsData;

  const InstantResultsScreen({
    super.key,
    required this.scoreProgression,
    this.resultsData,
  });

  @override
  State<InstantResultsScreen> createState() => _InstantResultsScreenState();
}

class _InstantResultsScreenState extends State<InstantResultsScreen> {
  ExamResults? get _r => widget.resultsData?.results;
  String _formatNum(num value) {
  if (value == value.truncate()) {
    return value.truncate().toString();
  }
  // Keep at most 1 decimal place if needed
  return value.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
}

 String get _scoreText => _r != null ? _formatNum(_r!.score) : '-';

String get _maxScoreText => _r != null ? '/${_formatNum(_r!.maxScore)}' : '';

String get _percentageText =>
    _r != null ? '${_r!.percentage.toStringAsFixed(0)}%' : '-';

String get _percentileText =>
    _r != null ? _formatNum(_r!.percentile) : '-';


double get _finalScore => _r != null ? _r!.percentage : 0.0;

  /// ✅ KEY GATE — when true, hide "Question Explanations" and "Student Ranking"
  bool get _isCertificationFailed => _r?.isCertificationFailed ?? false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScoreOverview(),
                  SizedBox(height: 16.h),
                  _buildPerformanceOverview(),
                  SizedBox(height: 16.h),
                  _buildRanking(),
                  SizedBox(height: 16.h),

                  // ✅ HIDE leaderboard if certification failed
                  if (!_isCertificationFailed &&
                      widget.resultsData?.leaderboard != null) ...[
                    _buildLeaderboard(),
                    SizedBox(height: 16.h),
                  ],

                  // ✅ Show a locked banner instead when certification failed
                  if (_isCertificationFailed) ...[
                    _buildCertFailedBanner(),
                    SizedBox(height: 16.h),
                  ],

                  if (widget.resultsData?.sectionWiseResults?.isNotEmpty ==
                      true) ...[
                    _buildSectionWisePerformance(),
                    SizedBox(height: 16.h),
                  ],

                  // ✅ HIDE question explanations if certification failed
                  if (!_isCertificationFailed)
                    _buildQuestionExplanations(),

                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Certification failed locked banner ────────────────────────────────────

  Widget _buildCertFailedBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red.shade200, width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_rounded,
              color: Colors.red.shade600,
              size: 32.sp,
            ),
          ),
          SizedBox(height: 14.h),
          CustomText(
            text: 'Results Locked',
            size: 17,
            weight: FontWeight.w700,
            color: Colors.red.shade700,
            maxLines: 1,
          ),
          SizedBox(height: 8.h),
          CustomText(
            text:
                'You did not pass this certification test. Question explanations and the student leaderboard are hidden to ensure a fair retake.',
            size: 13,
            color: Colors.red.shade600,
            maxLines: 5,
          ),
          SizedBox(height: 14.h),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.replay_rounded,
                    size: 16.sp, color: Colors.red.shade700),
                SizedBox(width: 6.w),
                CustomText(
                  text: 'Retake the test to unlock full results',
                  size: 12,
                  weight: FontWeight.w600,
                  color: Colors.red.shade700,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: drawerColor,
      padding: EdgeInsets.fromLTRB(16.w, 50.h, 16.w, 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: accentOrange, size: 24.sp),
              SizedBox(width: 8.w),
              const CustomText(
                text: 'Instant Results',
                size: 18,
                weight: FontWeight.w600,
                color: Colors.white,
                maxLines: 1,
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: const CustomText(
                text: 'Close',
                size: 14,
                weight: FontWeight.w500,
                color: Colors.white,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreOverview() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _scoreCard()),
            SizedBox(width: 12.w),
            Expanded(child: _percentageCard()),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: _percentileCard()),
            SizedBox(width: 12.w),
            Expanded(child: _statusCard()),
          ],
        ),
      ],
    );
  }

  Widget _scoreCard() => CustomCard(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accentOrange, accentOrange.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: accentOrange.withOpacity(0.3),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText(
              text: 'SCORE',
              size: 11,
              weight: FontWeight.w600,
              color: Colors.white70,
              maxLines: 1,
            ),
            SizedBox(height: 8.h),
            if (_r != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomText(
                    text: _scoreText,
                    size: 36,
                    weight: FontWeight.w700,
                    color: Colors.white,
                    maxLines: 1,
                  ),
                  CustomText(
                    text: _maxScoreText,
                    size: 20,
                    weight: FontWeight.w500,
                    color: Colors.white70,
                    maxLines: 1,
                  ),
                ],
              )
            else
              _comingSoonBadge(),
          ],
        ),
      );

  Widget _comingSoonBadge({bool darkText = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: darkText
            ? Colors.grey.shade200
            : Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 13.sp,
            color: darkText ? Colors.grey.shade600 : Colors.white70,
          ),
          SizedBox(width: 5.w),
          CustomText(
            text: 'Coming Soon',
            size: 12,
            weight: FontWeight.w600,
            color: darkText ? Colors.grey.shade600 : Colors.white70,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _chartComingSoon() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.grey.shade200,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded,
                size: 32.sp, color: Colors.grey.shade400),
            SizedBox(height: 8.h),
            CustomText(
              text: 'Chart will be available soon',
              size: 13,
              weight: FontWeight.w500,
              color: Colors.grey.shade500,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _percentageCard() => CustomCard(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: 'PERCENTAGE',
              size: 11,
              weight: FontWeight.w600,
              color: Colors.grey.shade600,
              maxLines: 1,
            ),
            SizedBox(height: 8.h),
            if (_r != null)
              CustomText(
                text: _percentageText,
                size: 32,
                weight: FontWeight.w700,
                color: Colors.black,
                maxLines: 1,
              )
            else
              _comingSoonBadge(darkText: true),
          ],
        ),
      );

  Widget _percentileCard() => CustomCard(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: 'PERCENTILE',
              size: 11,
              weight: FontWeight.w600,
              color: Colors.grey.shade600,
              maxLines: 1,
            ),
            SizedBox(height: 8.h),
            if (_r != null)
              CustomText(
                text: _percentileText,
                size: 32,
                weight: FontWeight.w700,
                color: const Color(0xFF5B93FF),
                maxLines: 1,
              )
            else
              _comingSoonBadge(darkText: true),
          ],
        ),
      );

  Widget _statusCard() => CustomCard(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [successColor, successColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: successColor.withOpacity(0.3),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText(
              text: 'STATUS',
              size: 11,
              weight: FontWeight.w600,
              color: Colors.white70,
              maxLines: 1,
            ),
            SizedBox(height: 8.h),
            CustomText(
              text: _r != null
                  ? widget.resultsData!.session.status == 'completed'
                      ? 'Completed'
                      : 'Submitted'
                  : 'Submitted',
              size: 16,
              weight: FontWeight.w700,
              color: Colors.white,
              maxLines: 1,
            ),
          ],
        ),
      );

  Widget _buildPerformanceOverview() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            Icons.trending_up,
            'Performance Overview',
            'Question-wise result and score progression',
            accentOrange,
          ),
          SizedBox(height: 20.h),
          const CustomText(
            text: 'Question-wise result',
            size: 12,
            weight: FontWeight.w600,
            color: Colors.black87,
            maxLines: 1,
          ),
          SizedBox(height: 12.h),
          _buildQuestionWiseChart(),
          SizedBox(height: 16.h),
          _buildLegend(),
          SizedBox(height: 24.h),
          const CustomText(
            text: 'Score progression',
            size: 12,
            weight: FontWeight.w600,
            color: Colors.black87,
            maxLines: 1,
          ),
          SizedBox(height: 12.h),
          _buildScoreProgressionChart(),
          SizedBox(height: 8.h),
          CustomText(
            text: 'Dashed line: your final score (${_formatNum(_finalScore)}%)',
            size: 11,
            color: Colors.grey,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

Widget _buildQuestionWiseChart() {
  final qs = widget.resultsData?.questions ?? [];
  if (qs.isEmpty) {
    return SizedBox(height: 140.h, child: _chartComingSoon());
  }

  final total = qs.length;

  // ── Adaptive bar width & label interval ──────────────────────────────────
  // For very few questions, bars should be wider and centered
  // For many questions, bars get thinner
  final double barWidth = total <= 5
      ? 28.w
      : total <= 10
          ? 18.w
          : total <= 30
              ? 10.w
              : total <= 100
                  ? 5.w
                  : total <= 300
                      ? 3.w
                      : 1.5.w;

  // Show label every N questions
  final int labelEvery = total <= 5
      ? 1        // Q1 Q2 Q3 Q4 Q5
      : total <= 10
          ? 2    // Q1 Q3 Q5...
          : total <= 30
              ? 5
              : total <= 100
                  ? 10
                  : total <= 300
                      ? 50
                      : 100;

  // For small counts, center bars instead of spreading them
  final alignment = total <= 10
      ? BarChartAlignment.center
      : BarChartAlignment.spaceEvenly;

  return SizedBox(
    height: 140.h,
    child: BarChart(
      BarChartData(
        alignment: alignment,
        maxY: 1,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: total <= 500, // hide labels entirely for 1000+
              reservedSize: 20.h,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= total) {
                  return const SizedBox.shrink();
                }
                // Always show first label
                final bool showLabel =
                    index == 0 || (index + 1) % labelEvery == 0;
                if (!showLabel) return const SizedBox.shrink();
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    'Q${index + 1}',
                    style: TextStyle(
                      fontSize: total > 100 ? 7.sp : 9.sp,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: qs.asMap().entries.map((e) {
          final q = e.value;
          final Color barColor;
          if (q.status == 'skipped' || q.status == 'not_visited') {
            barColor = Colors.blue;
          } else if (q.isCorrect == true) {
            barColor = successColor;
          } else {
            barColor = Colors.red;
          }
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: 1,
                color: barColor,
                width: barWidth,
                borderRadius: BorderRadius.circular(
                  total > 100 ? 1.r : 3.r,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    ),
  );
}
  Widget _buildLegend() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(successColor, 'Correct'),
          SizedBox(width: 20.w),
          _legendItem(Colors.red, 'Incorrect'),
          SizedBox(width: 20.w),
          _legendItem(Colors.blue, 'Skipped'),
        ],
      );

  Widget _legendItem(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14.w,
            height: 14.h,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
          ),
          SizedBox(width: 6.w),
          CustomText(
            text: label,
            size: 12,
            weight: FontWeight.w500,
            color: Colors.grey.shade700,
            maxLines: 1,
          ),
        ],
      );

 Widget _buildScoreProgressionChart() {
  if (widget.scoreProgression.isEmpty) return _chartComingSoon();

  final spots = List.generate(
    widget.scoreProgression.length,
(i) => FlSpot(i.toDouble(), widget.scoreProgression[i].clamp(0.0, 100.0)),
  );
  final maxX = (spots.length - 1).toDouble();
  final total = widget.scoreProgression.length;

  // Decide label interval based on question count
  final int labelInterval = total <= 10
      ? 1
      : total <= 20
          ? 2
          : total <= 40
              ? 5
              : 10;

  return SizedBox(
    height: 200.h,
    child: LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: 0,
        maxY: 100,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.grey.shade300, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              reservedSize: 30,
             getTitlesWidget: (v, meta) => SideTitleWidget(
  meta: meta,
  child: Text(
    _formatNum(v),   // ← uses _formatNum instead of v.toInt().toString()
    style: TextStyle(fontSize: 10.sp, color: Colors.grey),
  ),
),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24.h,
              interval: labelInterval.toDouble(),
              getTitlesWidget: (v, meta) {
                final index = v.toInt();
                if (index < 0 || index >= total) {
                  return const SizedBox.shrink();
                }
                if (index % labelInterval != 0) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    'Q${index + 1}',
                    style: TextStyle(fontSize: 9.sp, color: Colors.grey),
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
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF5B93FF),
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 3,
                color: Colors.white,
                strokeWidth: 1.5,
                strokeColor: const Color(0xFF5B93FF),
              ),
            ),
          ),
          // Dashed final score line
          LineChartBarData(
            spots: [FlSpot(0, _finalScore), FlSpot(maxX, _finalScore)],
            isCurved: false,
            color: const Color(0xFF5B93FF),
            barWidth: 1.5,
            dashArray: [6, 4],
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    ),
  );
}
  BarChartGroupData _barGroup(int x, double y, {bool highlighted = false}) =>
      BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: y,
            color: highlighted ? accentOrange : Colors.grey.shade600,
            width: 32.w,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ],
      );

  Widget _statRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(text: label, size: 14, color: Colors.grey.shade700),
          CustomText(
            text: value,
            size: 14,
            weight: FontWeight.w600,
            color: Colors.black87,
          ),
        ],
      );

  Widget _buildLeaderboard() {
    final lb = widget.resultsData!.leaderboard!;
    final top3 = lb.top3 ?? [];
    final myRank = lb.myRank ?? 0;
    final total = lb.totalParticipants ?? 0;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            Icons.emoji_events_rounded,
            'Student Ranking',
            'Live rank updates from all completed participants',
            const Color(0xFFF5A623),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _rankSummaryCard(
                  'RANK',
                  '#$myRank',
                  'Global position',
                  Colors.amber.shade600,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _rankSummaryCard(
                  'MY RANK',
                  '#$myRank',
                  'Your current standing',
                  Colors.blue.shade600,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _rankSummaryCard(
                  'PARTICIPANTS',
                  '$total',
                  'Completed exams',
                  Colors.purple.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: 'Top ${top3.length} Students',
                size: 14,
                weight: FontWeight.w700,
                color: Colors.black87,
              ),
              CustomText(
                text: 'Rank | Score | Time',
                size: 11,
                color: Colors.grey,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...top3.map((t) => _topperCard(t, myRank)),
        ],
      ),
    );
  }

  Widget _rankSummaryCard(
      String label, String value, String sub, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: label,
            size: 10,
            weight: FontWeight.w600,
            color: color,
          ),
          SizedBox(height: 4.h),
          CustomText(
            text: value,
            size: 22,
            weight: FontWeight.w700,
            color: color,
          ),
          SizedBox(height: 2.h),
          CustomText(
            text: sub,
            size: 10,
            color: Colors.grey.shade600,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _topperCard(Topper t, int myRank) {
    final isMe = t.rank == myRank;
    final rank = t.rank ?? 0;

    Color rankColor() {
      if (rank == 1) return const Color(0xFFFFD700);
      if (rank == 2) return const Color(0xFFC0C0C0);
      if (rank == 3) return const Color(0xFFCD7F32);
      return Colors.grey.shade400;
    }

    String rankEmoji() {
      if (rank == 1) return '🥇';
      if (rank == 2) return '🥈';
      if (rank == 3) return '🥉';
      return '#$rank';
    }

    final scoreText = '${t.score ?? 0}/${t.maxScore ?? 0}';
    final completedTime = t.completedAt != null
        ? '${t.completedAt!.day.toString().padLeft(2, '0')}/'
              '${t.completedAt!.month.toString().padLeft(2, '0')}/'
              '${t.completedAt!.year}, '
              '${t.completedAt!.hour.toString().padLeft(2, '0')}:'
              '${t.completedAt!.minute.toString().padLeft(2, '0')} pm'
        : '';

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.amber.shade50
            : (rank == 1 ? const Color(0xFFFFFBEA) : Colors.white),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isMe
              ? Colors.amber.shade400
              : (rank == 1
                    ? const Color(0xFFFFD700).withOpacity(0.4)
                    : Colors.grey.shade200),
          width: isMe ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: rankColor().withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: rankColor(), width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(rankEmoji(), style: TextStyle(fontSize: 16.sp)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomText(
                        text: t.name ?? 'Unknown',
                        size: 14,
                        weight: FontWeight.w700,
                        color: Colors.black87,
                        maxLines: 1,
                      ),
                    ),
                    if (isMe)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(color: Colors.amber.shade400),
                        ),
                        child: CustomText(
                          text: 'You',
                          size: 10,
                          weight: FontWeight.w700,
                          color: Colors.amber.shade800,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 2.h),
                CustomText(
                  text: t.email ?? '',
                  size: 11,
                  color: Colors.grey.shade500,
                  maxLines: 1,
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    _miniTag('Score', scoreText, Colors.blue.shade600),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: CustomText(
                        text: 'Completed: $completedTime',
                        size: 10,
                        color: Colors.grey.shade500,
                        maxLines: 1,
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

  Widget _miniTag(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: CustomText(
        text: '$label: $value',
        size: 11,
        weight: FontWeight.w600,
        color: color,
      ),
    );
  }

  Widget _buildSectionWisePerformance() {
    final sections = widget.resultsData!.sectionWiseResults!;
    final r = widget.resultsData!.results;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            Icons.bar_chart_rounded,
            'Section-wise Performance',
            'Score and negative marking split by section',
            Colors.teal,
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _sectionSummaryChip(
                  'EARNED MARKS',
                  '${r.earnedMarks}',
                  Colors.green.shade700,
                  Colors.green.shade50,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _sectionSummaryChip(
                  'NEGATIVE DEDUCTED',
                  '-${r.negativeMarksDeducted}',
                  Colors.red.shade700,
                  Colors.red.shade50,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _sectionSummaryChip(
                  'NET SCORE',
                  '${r.score}',
                  Colors.blue.shade700,
                  Colors.blue.shade50,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...sections.map((s) => _sectionCard(s)),
        ],
      ),
    );
  }

  Widget _sectionSummaryChip(
      String label, String value, Color textColor, Color bgColor) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: label,
            size: 9,
            weight: FontWeight.w700,
            color: textColor.withOpacity(0.8),
            maxLines: 2,
          ),
          SizedBox(height: 4.h),
          CustomText(
            text: value,
            size: 22,
            weight: FontWeight.w700,
            color: textColor,
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(SectionWiseResult s) {
    final pct = s.percentage;
    final Color pctColor = pct >= 60
        ? Colors.green.shade600
        : pct >= 30
            ? Colors.orange.shade600
            : Colors.red.shade600;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: s.sectionName,
                size: 14,
                weight: FontWeight.w700,
                color: Colors.black87,
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: pctColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: CustomText(
                  text: '$pct%',
                  size: 13,
                  weight: FontWeight.w700,
                  color: pctColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: (pct / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(pctColor),
              minHeight: 6.h,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                        text: 'Score', size: 11, color: Colors.grey.shade500),
                    CustomText(
                      text: '${s.score}/${s.maxScore}',
                      size: 15,
                      weight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                        text: 'Marks', size: 11, color: Colors.grey.shade500),
                    CustomText(
                      text: '${s.earnedMarks} | -${s.negativeMarksDeducted}',
                      size: 15,
                      weight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              _miniTag('C', '${s.correctCount}', Colors.green.shade600),
              SizedBox(width: 6.w),
              _miniTag('W', '${s.wrongCount}', Colors.red.shade600),
              SizedBox(width: 6.w),
              _miniTag('S', '${s.skippedCount}', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRanking() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            Icons.leaderboard,
            'Ranking',
            'Your position in the leaderboard',
            accentOrange,
          ),
          SizedBox(height: 16.h),
          _statRow('Percentile', '$_percentileText%'),
          SizedBox(height: 12.h),
          _statRow('Score', '$_scoreText$_maxScoreText'),
          SizedBox(height: 12.h),
          _statRow('Percentage', _percentageText),
        ],
      ),
    );
  }

  Widget _buildQuestionExplanations() {
    final qs = widget.resultsData?.questions;
    if (qs == null || qs.isEmpty) return const SizedBox.shrink();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            Icons.help_outline,
            'Question-by-Question Explanation',
            'Review each question with correct answers',
            const Color(0xFF5B93FF),
          ),
          SizedBox(height: 16.h),
          ...qs.asMap().entries.map((e) {
            return Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: _questionItem(e.key, e.value),
            );
          }),
        ],
      ),
    );
  }

  String? normaliseAnswer(dynamic raw) {
    if (raw == null) return null;
    if (raw is bool) return raw ? 'True' : 'False';
    if (raw is List) return raw.map((e) => e.toString()).join('|||');
    return raw.toString();
  }

  bool _isOptionInAnswer(dynamic answer, String? optionText) {
    if (answer == null || optionText == null) return false;
    if (answer is List)
      return answer.map((e) => e.toString()).contains(optionText);
    return answer.toString() == optionText;
  }

  Widget _questionItem(int index, QuestionItem item) {
    if (item.question.questionType == 'connected') {
      return _connectedQuestionItem(index, item);
    }

    final isCorrect = item.isCorrect == true;
    final isAnswered = item.answer != null;
    final detail = item.question;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isAnswered
              ? (isCorrect
                    ? successColor.withOpacity(0.3)
                    : Colors.red.withOpacity(0.3))
              : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isAnswered
                ? (isCorrect
                      ? successColor.withOpacity(0.08)
                      : Colors.red.withOpacity(0.08))
                : Colors.black.withOpacity(0.03),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                decoration: BoxDecoration(
                  gradient: isAnswered
                      ? LinearGradient(
                          colors: isCorrect
                              ? [successColor, successColor.withOpacity(0.8)]
                              : [Colors.red, Colors.red.withOpacity(0.8)],
                        )
                      : null,
                  color: isAnswered ? null : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      text: 'Q${index + 1}',
                      size: 13,
                      weight: FontWeight.w700,
                      color: Colors.white,
                      maxLines: 1,
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      isAnswered
                          ? (isCorrect ? Icons.check_circle : Icons.cancel)
                          : Icons.remove_circle_outline,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomText(
                  text: isAnswered
                      ? (isCorrect ? 'Correct' : 'Incorrect')
                      : 'Not Attempted',
                  size: 13,
                  weight: FontWeight.w600,
                  color: isAnswered
                      ? (isCorrect ? successColor : Colors.red)
                      : Colors.grey.shade600,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          CustomText(
            text: detail.questionText ?? '',
            size: 15,
            weight: FontWeight.w600,
            color: Colors.black87,
            maxLines: 6,
          ),
          if (detail.imageUrls.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _resultQuestionImages(detail.imageUrls),
          ],
          SizedBox(height: 14.h),
          ...detail.options.asMap().entries.map((e) {
            final optionLabel = String.fromCharCode(65 + e.key);
            final option = e.value;
            final isCorrectOpt =
                _isOptionInAnswer(item.correctAnswer, option.text);
            final isUserOpt = _isOptionInAnswer(item.answer, option.text);
            final isWrongUser = isUserOpt && item.isCorrect != true;

            return Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: isCorrectOpt
                    ? successColor.withOpacity(0.08)
                    : (isWrongUser
                          ? Colors.red.withOpacity(0.08)
                          : Colors.grey.shade50),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isCorrectOpt
                      ? successColor
                      : (isWrongUser ? Colors.red : Colors.grey.shade300),
                  width: isCorrectOpt || isWrongUser ? 2 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isCorrectOpt || isWrongUser) ...[
                    Icon(
                      isCorrectOpt ? Icons.check_circle : Icons.cancel,
                      color: isCorrectOpt ? successColor : Colors.red,
                      size: 18.sp,
                    ),
                    SizedBox(width: 10.w),
                  ],
                  Container(
                    width: 26.w,
                    height: 26.h,
                    margin: EdgeInsets.only(right: 10.w),
                    decoration: BoxDecoration(
                      color: isCorrectOpt
                          ? successColor
                          : (isWrongUser
                                ? Colors.red
                                : Colors.grey.shade300),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: CustomText(
                      text: optionLabel,
                      size: 12,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: option.isImageOption
                        ? _resultOptionImage(
                            option.imageUrl!,
                            isCorrect: isCorrectOpt,
                            isWrong: isWrongUser,
                          )
                        : CustomText(
                            text: option.text,
                            size: 14,
                            weight: isCorrectOpt
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isCorrectOpt
                                ? successColor
                                : (isWrongUser
                                      ? Colors.red
                                      : Colors.black87),
                            maxLines: 3,
                          ),
                  ),
                ],
              ),
            );
          }),
          if (item.explanation != null && item.explanation!.isNotEmpty) ...[
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF5B93FF).withOpacity(0.1),
                    const Color(0xFF5B93FF).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFF5B93FF).withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          color: const Color(0xFF5B93FF), size: 18.sp),
                      SizedBox(width: 8.w),
                      const CustomText(
                        text: 'EXPLANATION',
                        size: 11,
                        weight: FontWeight.w700,
                        color: Color(0xFF5B93FF),
                        maxLines: 1,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  CustomText(
                    text: item.explanation!,
                    size: 13,
                    color: Colors.black87,
                    maxLines: 10,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _resultQuestionImages(List<String> urls) {
    return Column(
      children: urls.map((url) {
        return Container(
          margin: EdgeInsets.only(bottom: 8.h),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Image.network(
            url,
            width: double.infinity,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(
                height: 140.h,
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                      : null,
                  color: const Color(0xFF5B93FF),
                  strokeWidth: 2,
                ),
              );
            },
            errorBuilder: (_, __, ___) => Container(
              height: 60.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.broken_image_outlined,
                  color: Colors.grey.shade400, size: 26.sp),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _resultOptionImage(String url,
      {bool isCorrect = false, bool isWrong = false}) {
    final borderColor = isCorrect
        ? successColor.withOpacity(0.5)
        : isWrong
            ? Colors.red.withOpacity(0.5)
            : Colors.grey.shade300;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Image.network(
          url,
          width: double.infinity,
          fit: BoxFit.contain,
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Container(
              height: 100.h,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                    : null,
                color: const Color(0xFF5B93FF),
                strokeWidth: 2,
              ),
            );
          },
          errorBuilder: (_, __, ___) => Container(
            height: 60.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.broken_image_outlined,
                color: Colors.grey.shade400, size: 22.sp),
          ),
        ),
      ),
    );
  }

  Widget _connectedQuestionItem(int index, QuestionItem item) {
    final detail = item.question;
    final subQuestions = detail.subQuestions ?? [];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
            color: const Color(0xFF5B93FF).withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5B93FF), Color(0xFF7AABFF)],
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: 'Q${index + 1}',
                  size: 13,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
                SizedBox(width: 6.w),
                Icon(Icons.link, color: Colors.white, size: 14.sp),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          if (detail.title != null && detail.title!.isNotEmpty)
            CustomText(
              text: detail.title!,
              size: 15,
              weight: FontWeight.w700,
              color: Colors.black87,
              maxLines: 3,
            ),
          SizedBox(height: 8.h),
          if (detail.paragraph != null && detail.paragraph!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                    color: const Color(0xFF5B93FF).withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu_book,
                          color: const Color(0xFF5B93FF), size: 16.sp),
                      SizedBox(width: 6.w),
                      const CustomText(
                        text: 'PASSAGE',
                        size: 11,
                        weight: FontWeight.w700,
                        color: Color(0xFF5B93FF),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  CustomText(
                    text: detail.paragraph!,
                    size: 14,
                    color: Colors.black87,
                    maxLines: 20,
                  ),
                ],
              ),
            ),
        if (detail.imageUrls.isNotEmpty) ...[
  SizedBox(height: 12.h),
  _resultQuestionImages(detail.imageUrls),
],
        
          SizedBox(height: 16.h),
          ...subQuestions.asMap().entries.map((e) {
            final subIndex = e.key;
            final sub = e.value;
            final subIsCorrect = sub.isCorrect == true;
            final subIsAnswered = sub.studentAnswer != null;

            return Container(
              margin: EdgeInsets.only(bottom: 14.h),
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: subIsAnswered
                    ? (subIsCorrect
                          ? successColor.withOpacity(0.04)
                          : Colors.red.withOpacity(0.04))
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: subIsAnswered
                      ? (subIsCorrect
                            ? successColor.withOpacity(0.3)
                            : Colors.red.withOpacity(0.3))
                      : Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: subIsAnswered
                              ? (subIsCorrect ? successColor : Colors.red)
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomText(
                              text: '${index + 1}.${subIndex + 1}',
                              size: 12,
                              weight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              subIsAnswered
                                  ? (subIsCorrect
                                        ? Icons.check_circle
                                        : Icons.cancel)
                                  : Icons.remove_circle_outline,
                              color: Colors.white,
                              size: 14.sp,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: CustomText(
                          text: subIsAnswered
                              ? (subIsCorrect ? 'Correct' : 'Incorrect')
                              : 'Not Attempted',
                          size: 12,
                          weight: FontWeight.w600,
                          color: subIsAnswered
                              ? (subIsCorrect ? successColor : Colors.red)
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  CustomText(
                    text: sub.questionText ?? '',
                    size: 14,
                    weight: FontWeight.w600,
                    color: Colors.black87,
                    maxLines: 5,
                  ),
                  if (sub.imageUrls.isNotEmpty) ...[
  SizedBox(height: 8.h),
  _resultQuestionImages(sub.imageUrls),
],

                  SizedBox(height: 10.h),
                  ...sub.options.asMap().entries.map((oe) {
                    final optionLabel = String.fromCharCode(65 + oe.key);
                    final option = oe.value;
                    final isCorrectOpt =
                        _isOptionInAnswer(sub.correctAnswer, option.text);
                    final isUserOpt =
                        _isOptionInAnswer(sub.studentAnswer, option.text);
                    final isWrongUser = isUserOpt && sub.isCorrect != true;

                    return Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isCorrectOpt
                            ? successColor.withOpacity(0.08)
                            : (isWrongUser
                                  ? Colors.red.withOpacity(0.08)
                                  : Colors.grey.shade50),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isCorrectOpt
                              ? successColor
                              : (isWrongUser
                                    ? Colors.red
                                    : Colors.grey.shade300),
                          width: isCorrectOpt || isWrongUser ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          if (isCorrectOpt || isWrongUser) ...[
                            Icon(
                              isCorrectOpt
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color:
                                  isCorrectOpt ? successColor : Colors.red,
                              size: 16.sp,
                            ),
                            SizedBox(width: 8.w),
                          ],
                          Expanded(
                            child: CustomText(
                              text: '$optionLabel. ${option.text}',
                              size: 13,
                              weight: isCorrectOpt
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isCorrectOpt
                                  ? successColor
                                  : (isWrongUser
                                        ? Colors.red
                                        : Colors.black87),
                              maxLines: 3,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (sub.explanation != null &&
                      sub.explanation!.isNotEmpty) ...[
                    SizedBox(height: 10.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B93FF).withOpacity(0.07),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                            color: const Color(0xFF5B93FF).withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb_outline,
                                  color: const Color(0xFF5B93FF),
                                  size: 16.sp),
                              SizedBox(width: 6.w),
                              const CustomText(
                                text: 'EXPLANATION',
                                size: 11,
                                weight: FontWeight.w700,
                                color: Color(0xFF5B93FF),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          CustomText(
                            text: sub.explanation!,
                            size: 12,
                            color: Colors.black87,
                            maxLines: 8,
                          ),
                        ],
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

  Widget _sectionHeader(
      IconData icon, String title, String subtitle, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: iconColor, size: 22.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: title,
                size: 16,
                weight: FontWeight.w600,
                color: Colors.black87,
                maxLines: 1,
              ),
              SizedBox(height: 2.h),
              CustomText(
                text: subtitle,
                size: 12,
                color: Colors.grey,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}