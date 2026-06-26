import 'package:firstedu/data/models/api_models/supportdesk/ticketlist_models.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_appbar.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/view_models/supportdesk/supportdeskprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TicketDetailScreen extends StatefulWidget {
  final Ticket ticket;
  const TicketDetailScreen({super.key, required this.ticket});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  // ✅ Store provider reference at initState — safe to use in dispose()
  // Never call context.read() inside dispose() — this fixes the crash!
  late final SupportDeskProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = context.read<SupportDeskProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.enterTicket(widget.ticket.id!);
      _provider.fetchMessages(widget.ticket.id!).then((_) => _scrollToBottom());
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _provider.exitTicket(widget.ticket.id!);
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    final ok = await _provider.sendMessage(widget.ticket.id!, text);
    if (ok) _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(widget.ticket.status ?? '');

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: CustomAppBar(
        title: widget.ticket.ticketNumber ?? '—',
        subtitle: widget.ticket.subject ?? '—',
        showBack: true,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomText(
              text: _statusLabel(widget.ticket.status ?? ''),
              size: 11,
              weight: FontWeight.w700,
              color: containerColor,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<SupportDeskProvider>(
        builder: (context, provider, _) {
          final ticketId = widget.ticket.id!;
          final messages = provider.messagesFor(ticketId);
          final isLoading = provider.isLoadingMessagesFor(ticketId);
          final isSending = provider.isSendingMessageFor(ticketId);
          final agentTyping = provider.isAgentTyping(ticketId);

          // Show full loader only when loading with no cached messages
          if (isLoading && messages.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Scroll to bottom whenever messages update
          if (messages.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollCtrl.hasClients) {
                _scrollCtrl.animateTo(
                  _scrollCtrl.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              }
            });
          }

          return Column(
            children: [
              // ── Messages ─────────────────────────────────────────────────
              Expanded(
                child: messages.isEmpty && !isLoading
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 50.sp,
                              color: Colors.grey.shade300,
                            ),
                            SizedBox(height: 12.h),
                            CustomText(
                              text: 'No messages yet',
                              size: 16,
                              weight: FontWeight.w600,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 4.h),
                            CustomText(
                              text: 'Start the conversation below',
                              size: 13,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                        itemCount: messages.length + (agentTyping ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (agentTyping && i == messages.length) {
                            return _typingIndicator();
                          }
                          final msg = messages[i];
                          final isUser = msg.senderType == 'User';
                          final isOptimistic =
                              msg.id?.startsWith('optimistic_') == true;
                          return _buildMessage(
                            text: msg.message ?? '',
                            time: _formatTime(msg.createdAt),
                            isUser: isUser,
                            isOptimistic: isOptimistic,
                          );
                        },
                      ),
              ),

              // ── Input bar ─────────────────────────────────────────────────
              _buildInput(isSending),
            ],
          );
        },
      ),
    );
  }

  // ── Message bubble ─────────────────────────────────────────────────────────
  Widget _buildMessage({
    required String text,
    required String time,
    required bool isUser,
    bool isOptimistic = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[_avatar(false), SizedBox(width: 10.w)],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isUser) ...[
                      CustomText(
                        text: time,
                        size: 11,
                        color: Colors.grey.shade500,
                      ),
                      SizedBox(width: 6.w),
                      const CustomText(
                        text: 'You',
                        size: 12,
                        weight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ] else ...[
                      const CustomText(
                        text: 'Support Team',
                        size: 12,
                        weight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      SizedBox(width: 6.w),
                      CustomText(
                        text: time,
                        size: 11,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 8.h),
                Container(
                  constraints: BoxConstraints(maxWidth: 280.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? LinearGradient(
                            colors: isOptimistic
                                ? [Colors.grey.shade400, Colors.grey.shade500]
                                : [drawerColor, const Color(0xFF2A4494)],
                          )
                        : null,
                    color: isUser ? null : containerColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isUser ? 16.r : 4.r),
                      topRight: Radius.circular(isUser ? 4.r : 16.r),
                      bottomLeft: Radius.circular(16.r),
                      bottomRight: Radius.circular(16.r),
                    ),
                    border: isUser
                        ? null
                        : Border.all(color: Colors.grey.shade200),
                  ),
                  child: CustomText(
                    text: text,
                    size: 14,
                    color: isUser ? containerColor : Colors.black87,
                    maxLines: 500,
                    height: 1.5,
                  ),
                ),
                if (isUser && isOptimistic) ...[
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 11.sp,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(width: 3.w),
                      CustomText(
                        text: 'Sending...',
                        size: 10,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (isUser) ...[SizedBox(width: 10.w), _avatar(true)],
        ],
      ),
    );
  }

  Widget _avatar(bool isUser) => Container(
    width: 38.w,
    height: 38.h,
    decoration: BoxDecoration(
      gradient: isUser
          ? const LinearGradient(colors: [accentOrange, Color(0xFFFF8C00)])
          : const LinearGradient(colors: [successColor, Color(0xFF66BB6A)]),
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Icon(
        isUser ? Icons.person : Icons.support_agent,
        color: containerColor,
        size: 20.sp,
      ),
    ),
  );

  Widget _typingIndicator() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          _avatar(false),
          SizedBox(width: 10.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dot(0),
                SizedBox(width: 4.w),
                _dot(150),
                SizedBox(width: 4.w),
                _dot(300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(int delayMs) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: Duration(milliseconds: 600 + delayMs),
    builder: (_, v, __) => Container(
      width: 8.w,
      height: 8.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade400.withOpacity(0.4 + 0.6 * v),
        shape: BoxShape.circle,
      ),
    ),
  );

  // ── Input bar — WhatsApp style ─────────────────────────────────────────────
  Widget _buildInput(bool isSending) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: containerColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10.r,
              offset: Offset(0, -2.h),
            ),
          ],
        ),
        child: Row(
          // ✅ KEY: align send button to bottom so it stays at bottom-right
          // as the text box grows upward
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                // ✅ KEY: maxHeight caps growth — box scrolls internally after 5 lines
                constraints: BoxConstraints(maxHeight: 120.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: TextField(
                  controller: _msgCtrl,
                  // ✅ null = grows with content; keyboard type = multiline
                  maxLines: null,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) => _provider.emitTyping(widget.ticket.id!),
                  style: TextStyle(fontSize: 14.sp, height: 1.4),
                  decoration: InputDecoration(
                    hintText: 'Type your reply...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: isSending ? null : _send,
              child: Container(
                width: 44.w,
                height: 44.h,
                decoration: BoxDecoration(
                  gradient: isSending
                      ? LinearGradient(
                          colors: [Colors.grey.shade400, Colors.grey.shade500],
                        )
                      : const LinearGradient(
                          colors: [drawerColor, Color(0xFF2A4494)],
                        ),
                  shape: BoxShape.circle,
                ),
                child: isSending
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: containerColor,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return successColor;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return 'OPEN';
      case 'in_progress':
        return 'IN PROGRESS';
      case 'resolved':
        return 'RESOLVED';
      case 'closed':
        return 'CLOSED';
      default:
        return status.toUpperCase();
    }
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}, $h:$min $ampm';
  }
}
