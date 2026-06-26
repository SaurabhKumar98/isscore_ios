// ─── lib/presentation/screens/report/call/call_report_list_screen.dart ────────

import 'package:firstedu/data/models/api_models/report/chatcallreportmodels.dart';
import 'package:firstedu/view/report_screen/call_report_details_screen.dart';
import 'package:firstedu/view/report_screen/widgets/reportcolor.dart';
import 'package:firstedu/view/report_screen/widgets/teacheravtar_search.dart';
import 'package:firstedu/view_models/report/call_report_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CallReportListScreen extends StatefulWidget {
  const CallReportListScreen({super.key});

  @override
  State<CallReportListScreen> createState() => _CallReportListScreenState();
}

class _CallReportListScreenState extends State<CallReportListScreen>
    with AutomaticKeepAliveClientMixin {
  final _scrollCtrl = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);

    // FIX: screen was arriving blank because no one ever triggered the first
    // fetch. Call refresh:true so it always loads fresh on first entry.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CallReportProvider>().fetchTeachers(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      final p = context.read<CallReportProvider>();
      if (p.listMeta?.hasMore == true &&
          p.listStatus != ReportStatus.loadingMore) {
        p.fetchTeachers();
      }
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: ReportColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: ReportColors.drawer,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Text(
          'Call Reports',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Consumer<CallReportProvider>(
        builder: (_, p, __) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: ReportSearchBar(
                  hint: 'Search by teacher or subject…',
                  onChanged: p.onSearchChanged,
                ),
              ),
              Expanded(child: _buildBody(p)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(CallReportProvider p) {
    if (p.listStatus == ReportStatus.loading) {
      return const Center(
          child: CircularProgressIndicator(color: ReportColors.accentOrange));
    }

    if (p.listStatus == ReportStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: ReportColors.drawer.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wifi_off_rounded,
                    size: 32, color: ReportColors.drawer),
              ),
              const SizedBox(height: 14),
              Text(
                p.listError,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: ReportColors.mutedOnWhite),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () => p.fetchTeachers(refresh: true),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ReportColors.primaryButton,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (p.teachers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: ReportColors.accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.mic_off_rounded,
                    size: 36, color: ReportColors.accentOrange),
              ),
              const SizedBox(height: 18),
              const Text(
                'No call recordings yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ReportColors.titleOnWhite,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Book a Teacher Connect call to see recordings here.',
                style:
                    TextStyle(fontSize: 13, color: ReportColors.mutedOnWhite),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: ReportColors.accentOrange,
      onRefresh: () => p.fetchTeachers(refresh: true),
      child: ListView.separated(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount:
            p.teachers.length + (p.listMeta?.hasMore == true ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          if (i == p.teachers.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                  child: CircularProgressIndicator(
                      color: ReportColors.accentOrange)),
            );
          }
          return _CallTeacherCard(
            item: p.teachers[i],
            onTap: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) => CallReportDetailScreen(
                  teacherId: p.teachers[i].teacherId,
                  teacherName: p.teachers[i].teacher.name,
                  teacherImage: p.teachers[i].teacher.profileImage,
                  recordingCount: p.teachers[i].recordingCount,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Call teacher card ─────────────────────────────────────────────────────────

class _CallTeacherCard extends StatelessWidget {
  final CallTeacherSummaryModel item;
  final VoidCallback onTap;

  const _CallTeacherCard({required this.item, required this.onTap});

  String get _dateLabel {
    try {
      final dt = DateTime.parse(item.lastCallEndTime).toLocal();
      const months = [
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
        'Dec'
      ];
      return '${dt.day} ${months[dt.month]}';
    } catch (_) {
      return '';
    }
  }

  String get _durationLabel {
    final mins = item.totalDurationMinutes;
    if (mins < 60) return '${mins.toStringAsFixed(0)} min';
    final h = (mins / 60).floor();
    final m = (mins % 60).round();
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final subject = item.latestSubject.isNotEmpty
        ? item.latestSubject
        : (item.teacher.skills.isNotEmpty
            ? item.teacher.skills.first
            : 'General');

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: ReportColors.accentOrange.withOpacity(0.08),
        highlightColor: ReportColors.accentOrange.withOpacity(0.04),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: ReportColors.container,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ReportColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: ReportColors.drawer.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ReportColors.accentOrange.withOpacity(0.35),
                    width: 1.4,
                  ),
                ),
                child: TeacherAvatar(
                  name: item.teacher.name,
                  imageUrl: item.teacher.profileImage,
                  size: 46,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.teacher.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: ReportColors.titleOnWhite,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _dateLabel,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: ReportColors.mutedOnWhite,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: ReportColors.accentOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        subject,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: ReportColors.accentOrange,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Chip(
                          icon: Icons.mic_rounded,
                          label: '${item.recordingCount} recordings',
                          color: ReportColors.accentOrange,
                        ),
                        const SizedBox(width: 8),
                        _Chip(
                          icon: Icons.schedule_rounded,
                          label: _durationLabel,
                          color: ReportColors.drawer,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  color: ReportColors.cardBorder),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}