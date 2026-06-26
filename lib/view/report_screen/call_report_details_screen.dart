
import 'package:firstedu/data/models/api_models/report/chatcallreportmodels.dart';
import 'package:firstedu/view/report_screen/audio_screen.dart';
import 'package:firstedu/view/report_screen/widgets/filedownloader.dart';
import 'package:firstedu/view/report_screen/widgets/teacheravtar_search.dart';
import 'package:firstedu/view_models/report/call_report_provider.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

class CallReportDetailScreen extends StatefulWidget {
  final String teacherId;
  final String teacherName;
  final String teacherImage;
  final int recordingCount;

  const CallReportDetailScreen({
    super.key,
    required this.teacherId,
    required this.teacherName,
    required this.teacherImage,
    required this.recordingCount,
  });

  @override
  State<CallReportDetailScreen> createState() =>
      _CallReportDetailScreenState();
}

class _CallReportDetailScreenState extends State<CallReportDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CallReportProvider>().fetchRecordings(
            teacherId: widget.teacherId,
          );
    });
  }

  @override
  void dispose() {
    context.read<CallReportProvider>().clearRecordings();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1D2E)),
        title: Row(
          children: [
            TeacherAvatar(
              name: widget.teacherName,
              imageUrl: widget.teacherImage,
              size: 36,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.teacherName,
                    style: const TextStyle(
                      color: Color(0xFF1A1D2E),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${widget.recordingCount} recording${widget.recordingCount != 1 ? 's' : ''}',
                    style: const TextStyle(color: Color(0xFF9EA3B5), fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Consumer<CallReportProvider>(
        builder: (_, p, __) {
          if (p.recStatus == ReportStatus.loading) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF4361EE)));
          }
          if (p.recStatus == ReportStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Color(0xFFCFD3E3)),
                  const SizedBox(height: 12),
                  Text(p.recError,
                      style: const TextStyle(color: Color(0xFF6B7080))),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        p.fetchRecordings(teacherId: widget.teacherId, refresh: true),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4361EE),
                        foregroundColor: Colors.white),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (p.recordings.isEmpty) {
            return const Center(
              child: Text('No recordings found.',
                  style: TextStyle(color: Color(0xFF9EA3B5))),
            );
          }
          return RefreshIndicator(
            color: const Color(0xFF4361EE),
            onRefresh: () =>
                p.fetchRecordings(teacherId: widget.teacherId, refresh: true),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: p.recordings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) => _RecordingCard(
                recording: p.recordings[i],
                teacherName: widget.teacherName,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Recording card ────────────────────────────────────────────────────────────

class _RecordingCard extends StatefulWidget {
  final CallRecordingModel recording;
  final String teacherName;

  const _RecordingCard({required this.recording, required this.teacherName});

  @override
  State<_RecordingCard> createState() => _RecordingCardState();
}

class _RecordingCardState extends State<_RecordingCard> {
  bool _downloading = false;
  String? _savedPath;

  String get _dateTimeLabel {
    try {
      final dt = DateTime.parse(widget.recording.callEndTime).toLocal();
      const months = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day} ${months[dt.month]} ${dt.year} · $hour12:$m $ampm';
    } catch (_) { return ''; }
  }

  String get _durationLabel {
    final mins = widget.recording.durationMinutes;
    if (mins < 1) return '< 1 min';
    if (mins < 60) return '${mins.toStringAsFixed(0)} min';
    final h = (mins / 60).floor();
    final m = (mins % 60).round();
    return '${h}h ${m}m';
  }

  void _play() {
    if (widget.recording.recordingUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No recording URL available'),
        backgroundColor: Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    AudioPlayerSheet.show(
      context,
      url: widget.recording.recordingUrl,
      title: widget.recording.subject.isEmpty ? 'Call Recording' : widget.recording.subject,
      subtitle: '${widget.teacherName} · $_dateTimeLabel',
    );
  }

  Future<void> _download() async {
    if (_downloading) return;
    if (_savedPath != null) {
  await OpenFile.open(_savedPath!);
  return;
}

    setState(() => _downloading = true);
    try {
      final dt = DateTime.tryParse(widget.recording.callEndTime)?.toLocal() ?? DateTime.now();
      final date = '${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}';
      final safeName = widget.teacherName.replaceAll(' ', '_');
      final path = await FileDownloader.downloadAndSave(
        context: context,
        url: widget.recording.recordingUrl,
        fileName: 'call_${safeName}_$date.mp3',
      );
      if (mounted) setState(() => _savedPath = path);
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4361EE).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.call_rounded, size: 18, color: Color(0xFF4361EE)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recording.subject.isEmpty ? 'Call Session' : widget.recording.subject,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1D2E)),
                    ),
                    const SizedBox(height: 2),
                    Text(_dateTimeLabel,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9EA3B5))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(_durationLabel,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF06B6D4), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF0F1F8)),
          const SizedBox(height: 14),
          Row(
            children: [
              // Play → in-app bottom sheet player
              Expanded(
                child: GestureDetector(
                  onTap: _play,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4361EE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_circle_fill_rounded, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text('Play Recording',
                            style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Download → saves to Downloads / Documents folder
              GestureDetector(
                onTap: _download,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: _savedPath != null
                        ? const Color(0xFF22C55E).withOpacity(0.1)
                        : const Color(0xFFF0F1F8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _savedPath != null
                          ? const Color(0xFF22C55E).withOpacity(0.3)
                          : const Color(0xFFE2E4F0),
                    ),
                  ),
                  child: _downloading
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4361EE)),
                        )
                      : Row(
                          children: [
                            Icon(
                              _savedPath != null ? Icons.check_circle_rounded : Icons.download_rounded,
                              size: 16,
                              color: _savedPath != null ? const Color(0xFF22C55E) : const Color(0xFF6B7080),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _savedPath != null ? 'Saved' : 'Download',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _savedPath != null ? const Color(0xFF22C55E) : const Color(0xFF6B7080),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}