// ─── lib/presentation/screens/report/chat/chat_report_list_screen.dart ────────

import 'package:firstedu/data/models/api_models/report/chatteachermodels.dart';
import 'package:firstedu/view/report_screen/chat_report_details_screen.dart';
import 'package:firstedu/view/report_screen/widgets/reportcolor.dart';
import 'package:firstedu/view/report_screen/widgets/teacheravtar_search.dart';
import 'package:firstedu/view_models/report/chat_report_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ChatReportListScreen extends StatefulWidget {
  const ChatReportListScreen({super.key});

  @override
  State<ChatReportListScreen> createState() => _ChatReportListScreenState();
}

class _ChatReportListScreenState extends State<ChatReportListScreen>
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
      context.read<ChatReportProvider>().fetchConversations(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      final p = context.read<ChatReportProvider>();
      if (p.listMeta?.hasMore == true &&
          p.listStatus != ReportStatus.loadingMore) {
        p.fetchConversations();
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
          'Chat Reports',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Consumer<ChatReportProvider>(
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
              Expanded(
                child: _buildBody(p),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(ChatReportProvider p) {
    if (p.listStatus == ReportStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: ReportColors.accentOrange),
      );
    }

    if (p.listStatus == ReportStatus.error) {
      return _ErrorState(
        message: p.listError,
        onRetry: () => p.fetchConversations(refresh: true),
      );
    }

    if (p.conversations.isEmpty) {
      return const _EmptyState(
        icon: Icons.chat_bubble_outline,
        title: 'No chat history yet',
        subtitle: 'Start a Teacher Connect chat to see reports here.',
      );
    }

    return RefreshIndicator(
      color: ReportColors.accentOrange,
      onRefresh: () => p.fetchConversations(refresh: true),
      child: ListView.separated(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount:
            p.conversations.length + (p.listMeta?.hasMore == true ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          if (i == p.conversations.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(
                    color: ReportColors.accentOrange),
              ),
            );
          }
          return _ChatConversationCard(
            item: p.conversations[i],
            onTap: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) => ChatReportDetailScreen(
                  teacherId: p.conversations[i].teacherId,
                  teacherName: p.conversations[i].teacher.name,
                  subject: p.conversations[i].teacher.skills.isNotEmpty
                      ? p.conversations[i].teacher.skills.first
                      : 'General',
                  messageCount: p.conversations[i].messageCount,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Chat conversation card ────────────────────────────────────────────────────

class _ChatConversationCard extends StatelessWidget {
  final ChatConversationModel item;
  final VoidCallback onTap;

  const _ChatConversationCard({required this.item, required this.onTap});

  String get _previewText {
    final msg = item.lastMessage;
    final prefix = msg.from == 'student' ? 'You: ' : '';
    if (msg.attachment != null) return '$prefix📎 ${msg.attachment!.name}';
    return '$prefix${msg.text}';
  }

  String get _timeLabel {
    try {
      final dt = DateTime.parse(item.lastActivityAt).toLocal();
      final now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        final h = dt.hour.toString().padLeft(2, '0');
        final m = dt.minute.toString().padLeft(2, '0');
        return '$h:$m';
      }
      return '${dt.day} ${_month(dt.month)}';
    } catch (_) {
      return '';
    }
  }

  String _month(int m) => const [
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
      ][m];

  @override
  Widget build(BuildContext context) {
    final subject = item.teacher.skills.isNotEmpty
        ? item.teacher.skills.first
        : 'General';

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
                          _timeLabel,
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
                    const SizedBox(height: 6),
                    Text(
                      _previewText,
                      style: const TextStyle(
                        fontSize: 13,
                        color: ReportColors.mutedOnWhite,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: ReportColors.cardBorder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared helper widgets ─────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
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
              child: Icon(icon, size: 36, color: ReportColors.accentOrange),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ReportColors.titleOnWhite,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: ReportColors.mutedOnWhite,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
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
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: ReportColors.mutedOnWhite,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ReportColors.primaryButton,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}