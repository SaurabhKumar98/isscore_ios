// ─── lib/presentation/screens/report/chat/chat_report_detail_screen.dart ──────

import 'package:firstedu/data/models/api_models/report/chatteachermodels.dart';
import 'package:firstedu/view/report_screen/widgets/teacheravtar_search.dart';
import 'package:firstedu/view_models/report/chat_report_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ChatReportDetailScreen extends StatefulWidget {
  final String teacherId;
  final String teacherName;
  final String subject;
  final int messageCount;

  const ChatReportDetailScreen({
    super.key,
    required this.teacherId,
    required this.teacherName,
    required this.subject,
    required this.messageCount,
  });

  @override
  State<ChatReportDetailScreen> createState() =>
      _ChatReportDetailScreenState();
}

class _ChatReportDetailScreenState extends State<ChatReportDetailScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatReportProvider>().fetchMessages(
            teacherId: widget.teacherId,
          );
    });
    _scrollCtrl.addListener(_onScroll);
  }

  // Load older messages when user scrolls to top
  void _onScroll() {
    if (_scrollCtrl.position.pixels <= 80) {
      final p = context.read<ChatReportProvider>();
      if (p.canLoadMoreMessages &&
          p.msgStatus != ReportStatus.loadingMore) {
        p.fetchMessages(teacherId: widget.teacherId);
      }
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    context.read<ChatReportProvider>().clearMessages();
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
            TeacherAvatar(name: widget.teacherName, size: 36),
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
                    '${widget.subject} · ${widget.messageCount} messages',
                    style: const TextStyle(
                      color: Color(0xFF9EA3B5),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Consumer<ChatReportProvider>(
        builder: (_, p, __) {
          if (p.msgStatus == ReportStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4361EE)),
            );
          }

          if (p.msgStatus == ReportStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Color(0xFFCFD3E3)),
                  const SizedBox(height: 12),
                  Text(p.msgError,
                      style: const TextStyle(color: Color(0xFF6B7080))),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => p.fetchMessages(
                        teacherId: widget.teacherId, refresh: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4361EE),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (p.messages.isEmpty) {
            return const Center(
              child: Text(
                'No messages found.',
                style: TextStyle(color: Color(0xFF9EA3B5)),
              ),
            );
          }

          return ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: p.messages.length +
                (p.msgStatus == ReportStatus.loadingMore ? 1 : 0),
            itemBuilder: (ctx, i) {
              // Loading indicator at top while paginating
              if (i == 0 && p.msgStatus == ReportStatus.loadingMore) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFF4361EE)),
                    ),
                  ),
                );
              }

              final msgIndex =
                  p.msgStatus == ReportStatus.loadingMore ? i - 1 : i;
              final msg = p.messages[msgIndex];

              // Date separator
              final showDate = msgIndex == 0 ||
                  !_sameDay(
                    p.messages[msgIndex - 1].sentAt,
                    msg.sentAt,
                  );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showDate) _DateSeparator(isoDate: msg.sentAt),
                  _MessageBubble(
                    msg: msg,
                    teacherName: widget.teacherName,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  bool _sameDay(String a, String b) {
    try {
      final da = DateTime.parse(a);
      final db = DateTime.parse(b);
      return da.year == db.year &&
          da.month == db.month &&
          da.day == db.day;
    } catch (_) {
      return false;
    }
  }
}

// ── Date separator ────────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  final String isoDate;

  const _DateSeparator({required this.isoDate});

  String get _label {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        return 'Today';
      }
      final yesterday = now.subtract(const Duration(days: 1));
      if (dt.day == yesterday.day &&
          dt.month == yesterday.month &&
          dt.year == yesterday.year) {
        return 'Yesterday';
      }
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.black.withOpacity(0.08))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9EA3B5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.black.withOpacity(0.08))),
        ],
      ),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel msg;
  final String teacherName;

  const _MessageBubble({required this.msg, required this.teacherName});

  String get _timeLabel {
    try {
      final dt = DateTime.parse(msg.sentAt).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = msg.isStudent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isStudent ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isStudent) ...[
            TeacherAvatar(name: teacherName, size: 28),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isStudent
                    ? const Color(0xFF4361EE)
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isStudent ? 16 : 4),
                  bottomRight: Radius.circular(isStudent ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (msg.hasAttachment) _AttachmentChip(msg: msg, isStudent: isStudent),
                  if (msg.text.isNotEmpty) ...[
                    if (msg.hasAttachment) const SizedBox(height: 4),
                    Text(
                      msg.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: isStudent ? Colors.white : const Color(0xFF1A1D2E),
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _timeLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: isStudent
                          ? Colors.white.withOpacity(0.65)
                          : const Color(0xFF9EA3B5),
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
}

class _AttachmentChip extends StatelessWidget {
  final ChatMessageModel msg;
  final bool isStudent;

  const _AttachmentChip({required this.msg, required this.isStudent});

  @override
  Widget build(BuildContext context) {
    final att = msg.attachment!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isStudent
            ? Colors.white.withOpacity(0.15)
            : const Color(0xFFF0F1F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _iconForType(att.type),
            size: 16,
            color: isStudent ? Colors.white : const Color(0xFF4361EE),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              att.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isStudent ? Colors.white : const Color(0xFF1A1D2E),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    if (type.contains('pdf')) return Icons.picture_as_pdf_rounded;
    if (type.contains('image')) return Icons.image_rounded;
    if (type.contains('audio')) return Icons.audio_file_rounded;
    return Icons.insert_drive_file_rounded;
  }
}