import 'package:firstedu/data/models/api_models/workshops_models/workshopmodels.dart';
import 'package:firstedu/data/models/api_models/workshops_models/workshopsbyidmodels.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_button.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view_models/workshopprovider/paymentsheet.dart';
import 'package:firstedu/view_models/workshopprovider/workshopsprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

Color _statusColor(String s) {
  switch (s) {
    case 'live':
      return Colors.red;
    case 'upcoming':
      return Colors.blue;
    case 'completed':
      return Colors.grey;
    default:
      return Colors.orange;
  }
}

String _statusLabel(String s) {
  switch (s) {
    case 'live':
      return 'LIVE';
    case 'upcoming':
      return 'Upcoming';
    case 'completed':
      return 'Completed';
    default:
      return s.toUpperCase();
  }
}

IconData _eventIcon(String? type) {
  switch (type?.toLowerCase()) {
    case 'webinar':
      return Icons.live_tv_rounded;
    case 'seminar':
      return Icons.school_rounded;
    default:
      return Icons.videocam_rounded;
  }
}

Future<void> _launchMeetingUrl(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    if (context.mounted) {
      AppToast.error(
        context,
        title: 'Failed',
        message: 'Could not open meeting link.',
      );
    }
  }
}

class WorkshopCard extends StatelessWidget {
  final Workshop data;
  const WorkshopCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final status = data.status.toLowerCase();
    final sColor = _statusColor(status);

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: GestureDetector(
        onTap: () => _openDetail(context),
        child: CustomCard(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event icon box
                  Container(
                    width: 46.w,
                    height: 46.w,
                    decoration: BoxDecoration(
                      color: drawerColor.withOpacity(.08),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      _eventIcon(data.eventType),
                      color: drawerColor,
                      size: 22.sp,
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // Title
                  Expanded(
                    child: CustomText(
                      text: data.title,
                      size: 14,
                      weight: FontWeight.w700,
                      color: const Color(0xFF1A1D26),
                      maxLines: 2,
                      height: 1.35,
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // Status badge
                  _StatusBadge(status: status, color: sColor),
                ],
              ),

              // Description
              if (data.description?.isNotEmpty == true) ...[
                SizedBox(height: 10.h),
                CustomText(
                  text: data.description!,
                  size: 12,
                  color: Colors.black45,
                  maxLines: 2,
                  height: 1.5,
                ),
              ],

              SizedBox(height: 10.h),

              // Meta chips
              Wrap(
                spacing: 12.w,
                runSpacing: 6.h,
                children: [
                  if (data.startTime != null) ...[
                    _MetaChip(
                      icon: Icons.calendar_today_outlined,
                      label: DateFormat(
                        'dd MMM yyyy',
                      ).format(data.startTime!.toLocal()),
                    ),
                    _MetaChip(
                      icon: Icons.access_time_rounded,
                      label: DateFormat(
                        'hh:mm a',
                      ).format(data.startTime!.toLocal()),
                    ),
                  ],
                  if (data.eventType != null)
                    _MetaChip(
                      icon: Icons.videocam_outlined,
                      label: data.eventType!,
                    ),
                  if (data.maxParticipants != null)
                    _MetaChip(
                      icon: Icons.people_outline,
                      label: '${data.maxParticipants} seats',
                    ),
                ],
              ),

              SizedBox(height: 14.h),
              Divider(color: const Color(0xFFEEEFF3), height: 1),
              SizedBox(height: 12.h),

              // Price + action
              Row(
                children: [
                  _PriceLabel(price: data.price),
                  const Spacer(),
                  if (data.isRegistered)
                    _RegisteredBadge(status: status)
                  else
                    CustomButton(
                      title: 'View Details',
                      // icon: Icons.arrow_forward_rounded,
                      onTap: () => _openDetail(context),
                      backgroundColor: drawerColor,
                      textColor: Colors.white,
                      height: 36.h,
                      width: 130.w,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => WorkshopDetailScreen(workshopId: data.workshopId),
    ),
  );
}

class WorkshopDetailScreen extends StatefulWidget {
  final String workshopId;
  const WorkshopDetailScreen({super.key, required this.workshopId});

  @override
  State<WorkshopDetailScreen> createState() => _WorkshopDetailScreenState();
}

class _WorkshopDetailScreenState extends State<WorkshopDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkshopProvider>().fetchWorkshopDetail(
        context,
        widget.workshopId,
      );
    });
  }

  @override
  void dispose() {
    context.read<WorkshopProvider>().clearDetail();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<WorkshopProvider>();

    if (p.isDetailLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F7FB),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (p.detailError.isNotEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: AppBar(
          backgroundColor: drawerColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: CustomText(
            text: p.detailError,
            size: 14,
            color: Colors.black45,
            maxLines: 3,
          ),
        ),
      );
    }
    if (p.selectedWorkshop == null) return const SizedBox();
    return _DetailView(w: p.selectedWorkshop!);
  }
}

class _DetailView extends StatelessWidget {
  final WorkshopDetails w;
  const _DetailView({required this.w});

  @override
  Widget build(BuildContext context) {
    final status = w.status.toLowerCase();
    final sColor = _statusColor(status);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220.h,
            pinned: true,
            backgroundColor: drawerColor,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (w.imageUrl != null && w.imageUrl!.isNotEmpty)
                    Image.network(
                      w.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackBg(),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _fallbackBg();
                      },
                    )
                  else
                    _fallbackBg(),

                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xAA162556), Color(0xDD162556)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  Positioned(
                    right: -20.w,
                    bottom: -20.h,
                    child: Icon(
                      Icons.school_rounded,
                      size: 200.sp,
                      color: Colors.white.withOpacity(.06),
                    ),
                  ),

                  Positioned(
                    left: 20.w,
                    right: 20.w,
                    bottom: 24.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _StatusBadge(
                          status: status,
                          color: sColor,
                          liveLabel: 'LIVE NOW',
                        ),
                        SizedBox(height: 10.h),
                        CustomText(
                          text: w.title,
                          size: 20,
                          weight: FontWeight.w800,
                          color: Colors.white,
                          maxLines: 3,
                          height: 1.3,
                        ),
                        if (w.teacher != null) ...[
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 14.sp,
                                color: Colors.white60,
                              ),
                              SizedBox(width: 4.w),
                              CustomText(
                                text: w.teacher!,
                                size: 12,
                                color: Colors.white70,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── CONTENT ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info pills
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      if (w.startTime != null)
                        _DetailPill(
                          icon: Icons.calendar_today_outlined,
                          label: DateFormat(
                            'dd MMM yyyy, hh:mm a',
                          ).format(w.startTime!.toLocal()),
                          color: drawerColor,
                        ),
                      if (w.endTime != null)
                        _DetailPill(
                          icon: Icons.flag_outlined,
                          label:
                              'Ends ${DateFormat('dd MMM, hh:mm a').format(w.endTime!.toLocal())}',
                          color: Colors.teal,
                        ),
                      if (w.eventType != null)
                        _DetailPill(
                          icon: Icons.videocam_outlined,
                          label: w.eventType!,
                          color: Colors.indigo,
                        ),
                      if (w.maxParticipants != null)
                        _DetailPill(
                          icon: Icons.people_outline,
                          label: '${w.maxParticipants} max seats',
                          color: Colors.purple,
                        ),
                      _DetailPill(
                        icon: w.price == 0
                            ? Icons.card_giftcard
                            : Icons.currency_rupee,
                        label: w.price == 0 ? 'Free' : '${w.price}',
                        color: w.price == 0 ? successColor : accentOrange,
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Status flags row
                  CustomCard(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _FlagChip(label: 'Published', active: w.isPublished),
                        _FlagChip(
                          label: 'Reg. Open',
                          active: w.isRegistrationOpen,
                        ),
                        _FlagChip(
                          label: 'Live',
                          active: w.isEventLive,
                          activeColor: Colors.red,
                        ),
                        _FlagChip(
                          label: 'Can Join',
                          active: w.canJoin,
                          activeColor: successColor,
                        ),
                      ],
                    ),
                  ),

                  // Registration window
                  if (w.registrationStartTime != null ||
                      w.registrationEndTime != null) ...[
                    SizedBox(height: 14.h),
                    _SectionCard(
                      title: 'Registration Window',
                      icon: Icons.event_available_outlined,
                      child: Column(
                        children: [
                          if (w.registrationStartTime != null)
                            _InfoRow(
                              icon: Icons.login_rounded,
                              label: 'Opens',
                              value: DateFormat(
                                'dd MMM yyyy, hh:mm a',
                              ).format(w.registrationStartTime!.toLocal()),
                            ),
                          if (w.registrationEndTime != null) ...[
                            SizedBox(height: 8.h),
                            _InfoRow(
                              icon: Icons.logout_rounded,
                              label: 'Closes',
                              value: DateFormat(
                                'dd MMM yyyy, hh:mm a',
                              ).format(w.registrationEndTime!.toLocal()),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  // Meeting link card (shown when registered + canJoin)
                  // NO join button here — only one join button lives at the bottom
                  if (w.isRegistered && w.canJoin && w.meetingLink != null) ...[
                    SizedBox(height: 14.h),
                    _SectionCard(
                      title: 'Meeting Details',
                      icon: Icons.link_rounded,
                      iconColor: Colors.red,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Link row with copy
                          Row(
                            children: [
                              Expanded(
                                child: CustomText(
                                  text: w.meetingLink!,
                                  size: 12,
                                  color: Colors.black54,
                                  maxLines: 1,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                    ClipboardData(text: w.meetingLink!),
                                  );
                                  AppToast.success(
                                    context,
                                    title: 'Copied',
                                    message:
                                        'Meeting link copied to clipboard.',
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(left: 8.w),
                                  child: Icon(
                                    Icons.copy_rounded,
                                    size: 16.sp,
                                    color: drawerColor,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Password
                          if (w.meetingPassword?.isNotEmpty == true) ...[
                            SizedBox(height: 10.h),
                            _InfoRow(
                              icon: Icons.lock_outline,
                              label: 'Password',
                              value: w.meetingPassword!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  // About
                  if (w.description?.isNotEmpty == true) ...[
                    SizedBox(height: 14.h),
                    _SectionCard(
                      title: 'About this Workshop',
                      icon: Icons.info_outline_rounded,
                      child: CustomText(
                        text: w.description!,
                        size: 13,
                        color: Colors.black54,
                        maxLines: 50,
                        height: 1.65,
                      ),
                    ),
                  ],

                  SizedBox(height: 24.h),

                  // ── SINGLE ACTION BUTTON ─────────────────────────────
                  _ActionButton(workshop: w),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackBg() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF162556), Color(0xFF2A3F8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION BUTTON  (single, at bottom — the only join/register button)
// ─────────────────────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final WorkshopDetails workshop;
  const _ActionButton({required this.workshop});

  @override
  Widget build(BuildContext context) {
    final status = workshop.status.toLowerCase();

    // 1. Completed
    if (status == 'completed') {
      return CustomButton(
        title: 'Completed',
        icon: Icons.task_alt,
        onTap: () {},
        primary: false,
        borderColor: drawerColor,
      );
    }

    // 2. Registered + can join → ONLY join button
    if (workshop.isRegistered && workshop.canJoin) {
      return CustomButton(
        title: 'Join Live Session',
        icon: Icons.videocam_rounded,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        onTap: () {
          if (workshop.meetingLink == null) {
            AppToast.error(
              context,
              title: 'Unavailable',
              message: 'No meeting link available.',
            );
            return;
          }
          _launchMeetingUrl(context, workshop.meetingLink!);
        },
      );
    }

    // 3. Registered, session not yet started
    if (workshop.isRegistered) {
      return Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          color: successColor.withOpacity(.08),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: successColor.withOpacity(.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, color: successColor, size: 18.sp),
            SizedBox(width: 6.w),
            CustomText(
              text: 'Already Registered',
              size: 14,
              weight: FontWeight.w700,
              color: successColor,
              maxLines: 1,
            ),
          ],
        ),
      );
    }

    // 4. Registration closed
    if (!workshop.isRegistrationOpen) {
      return CustomButton(
        title: 'Registration Closed',
        onTap: () {},
        enabled: false,
        backgroundColor: Colors.grey.shade200,
        textColor: Colors.black38,
      );
    }

    // 5. Not registered → open payment sheet
    return CustomButton(
      title: workshop.price == 0
          ? 'Register for Free'
          : 'Register  ·  ₹${workshop.price}',
      icon: Icons.how_to_reg_rounded,
      backgroundColor: drawerColor,
      textColor: Colors.white,
      onTap: () => showPaymentSheet(context, workshop: workshop),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  final String? liveLabel; // optional override for live text
  const _StatusBadge({
    required this.status,
    required this.color,
    this.liveLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == 'live')
            _LiveDot()
          else
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          SizedBox(width: 4.w),
          CustomText(
            text: status == 'live'
                ? (liveLabel ?? 'LIVE')
                : _statusLabel(status),
            size: 10,
            weight: FontWeight.w700,
            color: color,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

class _PriceLabel extends StatelessWidget {
  final int price;
  const _PriceLabel({required this.price});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomText(
        text: price == 0 ? 'Free' : '₹$price',
        size: 16,
        weight: FontWeight.w800,
        color: price == 0 ? successColor : drawerColor,
        maxLines: 1,
      ),
      if (price > 0)
        CustomText(
          text: 'per person',
          size: 10,
          color: Colors.black38,
          maxLines: 1,
        ),
    ],
  );
}

class _RegisteredBadge extends StatelessWidget {
  final String status;
  const _RegisteredBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isLive = status == 'live';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: isLive ? Colors.red : successColor.withOpacity(.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isLive ? Colors.red : successColor.withOpacity(.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLive ? Icons.videocam_rounded : Icons.check_circle_rounded,
            size: 13.sp,
            color: isLive ? Colors.white : successColor,
          ),
          SizedBox(width: 5.w),
          CustomText(
            text: isLive ? 'Live' : 'Registered',
            size: 11,
            weight: FontWeight.w700,
            color: isLive ? Colors.white : successColor,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

class _LiveDot extends StatefulWidget {
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _anim = Tween(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Container(
      width: 6.w,
      height: 6.w,
      margin: EdgeInsets.only(right: 4.w),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(_anim.value),
        shape: BoxShape.circle,
      ),
    ),
  );
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12.sp, color: Colors.black38),
      SizedBox(width: 4.w),
      CustomText(text: label, size: 11, color: Colors.black54, maxLines: 1),
    ],
  );
}

class _DetailPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _DetailPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: color.withOpacity(.08),
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: color.withOpacity(.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.sp, color: color),
        SizedBox(width: 5.w),
        CustomText(
          text: label,
          size: 11,
          weight: FontWeight.w600,
          color: color,
          maxLines: 1,
        ),
      ],
    ),
  );
}

class _FlagChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color? activeColor;
  const _FlagChip({
    required this.label,
    required this.active,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = active ? (activeColor ?? successColor) : Colors.grey.shade400;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: c.withOpacity(.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: c.withOpacity(.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 11.sp,
            color: c,
          ),
          SizedBox(width: 4.w),
          CustomText(
            text: label,
            size: 10,
            weight: FontWeight.w600,
            color: c,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Widget child;
  const _SectionCard({
    required this.title,
    required this.icon,
    this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => CustomCard(
    padding: EdgeInsets.all(16.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: iconColor ?? drawerColor.withOpacity(.6),
            ),
            SizedBox(width: 6.w),
            CustomText(
              text: title,
              size: 13,
              weight: FontWeight.w800,
              color: const Color(0xFF1A1D26),
              maxLines: 1,
              letterSpacing: .3,
            ),
          ],
        ),
        SizedBox(height: 12.h),
        child,
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 14.sp, color: drawerColor.withOpacity(.5)),
      SizedBox(width: 8.w),
      CustomText(
        text: '$label:  ',
        size: 12,
        color: Colors.black45,
        maxLines: 1,
      ),
      Expanded(
        child: CustomText(
          text: value,
          size: 12,
          weight: FontWeight.w600,
          color: const Color(0xFF1A1D26),
          maxLines: 2,
        ),
      ),
    ],
  );
}
