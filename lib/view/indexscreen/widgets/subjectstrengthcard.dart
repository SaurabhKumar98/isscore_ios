import 'package:firstedu/data/models/api_models/dashboardmodels/dashboard_models.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/view/needtoimprove_view/personalise_learningscreen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubjectStrengthCard extends StatelessWidget {
  final List<CategoryPerformance> categoryPerformance;
  final bool isLoading;

  const SubjectStrengthCard({ 
    super.key,
    this.categoryPerformance = const [],
    this.isLoading = false,
  });

bool get _hasRealData => categoryPerformance.isNotEmpty;

List<CategoryPerformance> get _usableEntries => categoryPerformance;
  // List<CategoryPerformance> get _usableEntries => categoryPerformance
  //     .where((c) => c.subject.toLowerCase() != 'unknown' || c.avgAccuracy > 0)
  //     .toList();

  // Returns empty list when no real data — no hardcoded fallback
  List<_RadarEntry> get _entries {
  if (!_hasRealData) return [];
  return _usableEntries
      .map((c) => _RadarEntry(
            label: c.subject.toLowerCase() == 'unknown' ? 'General' : c.subject,
            value: c.avgAccuracy.toDouble(),
          ))
      .toList();
}

  @override
  Widget build(BuildContext context) {
    final entries = _entries;

    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.track_changes_rounded,
                    color: Color(0xFF5B4FCF),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Category Performance',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── CHART / EMPTY STATE ──────────────────────────
          if (isLoading)
            const SizedBox(
              height: 280,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (entries.isEmpty)
            const SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bar_chart_outlined,
                      size: 56,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "No category data yet",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Complete some tests to see your performance",
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
  entries.length >= 3
      ? _RadarChartWidget(entries: entries)
      : _BarChartWidget(entries: entries),

          // ── BOTTOM BANNER ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PersonalizedLearningScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Need to improve?',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3730A3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF3730A3),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── RADAR ENTRY MODEL ─────────────────────────────────────────────

class _RadarEntry {
  final String label;
  final double value; // 0–100

  const _RadarEntry({required this.label, required this.value});
}

// ── CUSTOM RADAR CHART WIDGET ─────────────────────────────────────

class _RadarChartWidget extends StatelessWidget {
  final List<_RadarEntry> entries;

  const _RadarChartWidget({required this.entries});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double hPad = 72.0;
          const double vPad = 40.0;
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: hPad,
              vertical: vPad,
            ),
            child: RadarChart(
              RadarChartData(
                radarBackgroundColor: Colors.transparent,
                radarBorderData: const BorderSide(color: Colors.transparent),
                gridBorderData: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
                tickBorderData: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
                ticksTextStyle: const TextStyle(
                  color: Colors.transparent,
                  fontSize: 0,
                ),
                tickCount: 5,
                radarShape: RadarShape.polygon,
                titleTextStyle: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
                titlePositionPercentageOffset: 0.25,
                getTitle: (index, angle) {
                  if (index >= entries.length) {
                    return RadarChartTitle(text: '');
                  }
                  final e = entries[index];
                  return RadarChartTitle(
                    text: '${e.label}\n${e.value.toInt()}%',
                  );
                },
                dataSets: [
                  RadarDataSet(
                    fillColor: const Color(0xFFEA580C).withOpacity(0.18),
                    borderColor: const Color(0xFFEA580C),
                    borderWidth: 2.5,
                    entryRadius: 5,
                    dataEntries: entries
                        .map((e) => RadarEntry(value: e.value))
                        .toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── BAR CHART FALLBACK (< 3 entries) ─────────────────────────────

class _BarChartWidget extends StatelessWidget {
  final List<_RadarEntry> entries;

  const _BarChartWidget({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: entries.map((e) {
          final pct = e.value.clamp(0.0, 100.0);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        e.label,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${pct.toInt()}%',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFEA580C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFEA580C)),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
