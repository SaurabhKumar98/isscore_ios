import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_button.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_silverappbar.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view/supportdesk_view/newticketscreen.dart';
import 'package:firstedu/view_models/supportdesk/supportdeskprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SupportDeskScreen extends StatefulWidget {
  const SupportDeskScreen({super.key});

  @override
  State<SupportDeskScreen> createState() => _SupportDeskScreenState();
}

class _SupportDeskScreenState extends State<SupportDeskScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<SupportDeskProvider>();
      p.fetchTickets();
      p.connectSocket();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: CustomScrollView(
        slivers: [
          const CustomSliverAppBar(
            title: "Support Desk",
            subtitle: "Get help from our team",
          ),
          SliverPadding(
            padding: EdgeInsets.all(16.w),
            sliver: Consumer<SupportDeskProvider>(
              builder: (context, provider, _) {
                return SliverList(
                  delegate: SliverChildListDelegate([
                    _headerSection(context, provider),
                    SizedBox(height: 20.h),
                    _ticketsSection(context, provider),
                    SizedBox(height: 80.h),
                  ]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _headerSection(BuildContext context, SupportDeskProvider provider) {
    return CustomCard(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [drawerColor, drawerColor.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.headset_mic_rounded,
              color: Colors.white,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  text: "Support Desk",
                  size: 18,
                  weight: FontWeight.w700,
                  color: Colors.black87,
                ),
                SizedBox(height: 4.h),
                const CustomText(
                  text: "Get help from our team",
                  size: 13,
                  color: Colors.grey,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          CustomButton(
            title: "New Ticket",
            icon: Icons.add_rounded,
            onTap: () => _openNewTicketSheet(context),
            backgroundColor: drawerColor,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  // ── Ticket list ────────────────────────────────────────────────────────────
  Widget _ticketsSection(BuildContext context, SupportDeskProvider provider) {
    // Loading skeleton
    if (provider.isLoadingTickets) {
      return Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Container(
              height: 100.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ),
      );
    }

    // Error state
    if (provider.ticketsError.isNotEmpty && provider.tickets.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60.h),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 50.sp,
                color: Colors.red.shade300,
              ),
              SizedBox(height: 12.h),
              CustomText(
                text: provider.ticketsError,
                size: 14,
                color: Colors.grey.shade600,
                align: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              CustomButton(
                title: "Retry",
                onTap: provider.fetchTickets,
                backgroundColor: drawerColor,
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (provider.tickets.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60.h),
          child: Column(
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 50.sp,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 12.h),
              CustomText(
                text: "No tickets yet",
                size: 16,
                weight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
              SizedBox(height: 6.h),
              CustomText(
                text: "Tap 'New Ticket' to raise a support request.",
                size: 13,
                color: Colors.grey.shade400,
                align: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Ticket list
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CustomText(
              text: "Your tickets",
              size: 16,
              weight: FontWeight.w700,
              color: Colors.black87,
            ),
            CustomText(
              text:
                  "${provider.tickets.length} ticket${provider.tickets.length > 1 ? 's' : ''}",
              size: 13,
              weight: FontWeight.w600,
              color: Colors.grey,
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ...provider.tickets.map((t) => _ticketCard(context, t)),
      ],
    );
  }

  Widget _ticketCard(BuildContext context, ticket) {
    final Color statusColor = _statusColor(ticket.status ?? '');
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: CustomCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TicketDetailScreen(ticket: ticket),
            ),
          ),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _pill(
                      ticket.ticketNumber ?? '—',
                      Colors.grey.shade700,
                      Colors.grey.shade100,
                    ),
                    SizedBox(width: 8.w),
                    _pill(
                      _statusLabel(ticket.status ?? ''),
                      statusColor,
                      statusColor.withOpacity(0.1),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14.sp,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                CustomText(
                  text: ticket.subject ?? '—',
                  size: 15,
                  weight: FontWeight.w600,
                  color: Colors.black87,
                  maxLines: 2,
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 13.sp,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: 4.w),
                    CustomText(
                      text: _relativeTime(ticket.updatedAt),
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pill(String text, Color textColor, Color bg) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: CustomText(
      text: text,
      size: 11,
      weight: FontWeight.w700,
      color: textColor,
    ),
  );

  void _openNewTicketSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NewTicketSheet(),
    );
  }

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

  String _relativeTime(String? iso) {
    if (iso == null) return '—';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '—';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// NEW TICKET SHEET
// ══════════════════════════════════════════════════════════════════════════════
class NewTicketSheet extends StatefulWidget {
  const NewTicketSheet({super.key});

  @override
  State<NewTicketSheet> createState() => _NewTicketSheetState();
}

class _NewTicketSheetState extends State<NewTicketSheet> {
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _selectedCategory;

  static const _categories = [
    'technical',
    'billing',
    'course',
    'account',
    'payment',
    'exam_issue',
    'proctoring_issue',
    'certificate_issue',
    'content_error',
    'feature_request',
    'teacher_connect',
    'live_event',
    'feedback',
    'general_inquiry',
    'other',
  ];

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final subject = _subjectCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    if (subject.length < 3) {
      AppToast.error(
        context,
        title: 'Validation Error',
        message: 'Subject must be at least 3 characters.',
      );
      return;
    }
    if (desc.length < 10) {
      AppToast.error(
        context,
        title: 'Validation Error',
        message: 'Description must be at least 10 characters.',
      );
      return;
    }

    final provider = context.read<SupportDeskProvider>();
    final id = await provider.createTicket(
      subject: subject,
      description: desc,
      category: _selectedCategory,
    );

    if (!mounted) return;
    // ✅ AppToast is shown from provider — just close the sheet
    if (id != null) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 24.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            Row(
              children: [
                const Expanded(
                  child: CustomText(
                    text: "Submit a New Request",
                    size: 20,
                    weight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 24.sp),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Subject
            _label("SUBJECT"),
            SizedBox(height: 8.h),
            _textField(
              controller: _subjectCtrl,
              hint: "Brief description of your issue",
              maxLines: 1,
            ),
            SizedBox(height: 20.h),

            // Category
            _label("CATEGORY (OPTIONAL)"),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: Text(
                "Select a category",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: drawerColor, width: 2),
                ),
              ),
              items: _categories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(
                        c.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(fontSize: 13.sp),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
            ),
            SizedBox(height: 20.h),

            // Description
            _label("DESCRIBE YOUR PROBLEM"),
            SizedBox(height: 8.h),
            _textField(
              controller: _descCtrl,
              hint: "Provide details so we can help you faster...",
              maxLines: 5,
            ),
            SizedBox(height: 28.h),

            // Buttons
            Consumer<SupportDeskProvider>(
              builder: (_, provider, __) => Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      title: "Cancel",
                      onTap: () => Navigator.pop(context),
                      primary: false,
                      backgroundColor: Colors.white,
                      textColor: Colors.grey.shade700,
                      borderColor: Colors.grey.shade300,
                      height: 50.h,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: provider.isCreatingTicket
                        ? Container(
                            height: 50.h,
                            decoration: BoxDecoration(
                              color: drawerColor,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : CustomButton(
                            title: "Submit",
                            onTap: _submit,
                            backgroundColor: drawerColor,
                            textColor: Colors.white,
                            height: 50.h,
                          ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => CustomText(
    text: text,
    size: 12,
    weight: FontWeight.w700,
    color: Colors.grey,
  );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) => TextField(
    controller: controller,
    maxLines: maxLines,
    style: TextStyle(fontSize: 15.sp),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: EdgeInsets.all(16.w),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: drawerColor, width: 2),
      ),
    ),
  );
}
