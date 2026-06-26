import 'package:firstedu/data/models/api_models/teacherconnect/mentorsmodels.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/view/teacher_connect/callscreen.dart';
import 'package:firstedu/view/teacher_connect/chatscreen.dart';
import 'package:firstedu/view_models/teacherconnectprovider/chatprovider.dart';
import 'package:firstedu/view_models/teacherconnectprovider/mentors_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MentorCard extends StatelessWidget {
  final Mentor data;
  const MentorCard({super.key, required this.data});

  void _startAudioCall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          teacherId: data.id,
          teacherName: data.name,
          teacherImage: data.profileImage.isNotEmpty ? data.profileImage : null,
          subject: data.skills.isNotEmpty ? data.skills.first : '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: GestureDetector(
        onTap: () => _openSheet(context),
        child: CustomCard(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── TOP ROW ──────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Avatar(imageUrl: data.profileImage, isOnline: data.isOnline),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: data.name,
                          size: 16,
                          weight: FontWeight.w700,
                          color: Colors.black87,
                          maxLines: 1,
                        ),
                        SizedBox(height: 2.h),
                        CustomText(
                          text: data.skills.join(' • '),
                          size: 13,
                          weight: FontWeight.w600,
                          color: accentOrange,
                          maxLines: 1,
                        ),
                        SizedBox(height: 5.h),
                        _Pill(Icons.work_outline, data.experience, drawerColor),
                        SizedBox(height: 4.h),
                        _Pill(Icons.language, data.language, Colors.teal),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 9.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: accentOrange.withOpacity(.1),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: accentOrange.withOpacity(.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 13.sp,
                              color: accentOrange,
                            ),
                            SizedBox(width: 3.w),
                            CustomText(
                              text: data.averageRating.toStringAsFixed(1),
                              size: 12,
                              weight: FontWeight.w700,
                              color: accentOrange,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      _Pill(
                        Icons.currency_rupee,
                        '${data.perMinuteRate}/min',
                        drawerBgColor,
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // ── AVAILABILITY ROW ──────────────────────────────────────
              Row(
                children: [
                  Row(
                    children: [
                      _BlinkingDot(isOnline: data.isOnline, size: 8),
                      SizedBox(width: 6.w),
                      CustomText(
                        text: data.isOnline ? 'Online' : 'Currently Offline',
                        size: 12,
                        weight: FontWeight.w600,
                        color: data.isOnline ? successColor : Colors.black45,
                      ),
                    ],
                  ),
                  const Spacer(),
                  CustomText(
                    text: '${data.ratingCount} reviews',
                    size: 11,
                    weight: FontWeight.w500,
                    color: Colors.black38,
                  ),
                ],
              ),

              SizedBox(height: 12.h),
              Divider(color: Colors.black.withOpacity(.07), height: 1),
              SizedBox(height: 12.h),

              // ── ACTION BUTTONS ────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _ActionBtn(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Chat',
                      filled: true,
                      // ✅ Wired to ChatScreen
                      onTap: () => _startChat(context),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _ActionBtn(
                      icon: Icons.call_outlined,
                      label: 'Audio',
                      filled: false,
                      onTap: () => _startAudioCall(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Navigate to ChatScreen ────────────────────────────────────────────────
  void _startChat(BuildContext context) {
    context.read<ChatProvider>().reset();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          teacherId: data.id,
          teacherName: data.name,
          teacherImage: data.profileImage.isNotEmpty ? data.profileImage : null,
        ),
      ),
    );
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MentorDetailSheet(data: data),
    );
  }
}

// ── All private widgets below are identical to original ──────────────────────

class _Avatar extends StatelessWidget {
  final String imageUrl;
  final bool isOnline;
  const _Avatar({required this.imageUrl, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 68.w,
          height: 68.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isOnline
                  ? successColor.withOpacity(.5)
                  : Colors.grey.shade300,
              width: 2.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13.5.r),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
        ),
        Positioned(
          bottom: -4.h,
          right: -4.w,
          child: _BlinkingDot(isOnline: isOnline, size: 14),
        ),
      ],
    );
  }

  Widget _placeholder() => Container(
    color: Colors.grey.shade100,
    child: Center(
      child: Icon(Icons.person, size: 32.sp, color: Colors.grey.shade400),
    ),
  );
}

class _BlinkingDot extends StatefulWidget {
  final bool isOnline;
  final double size;
  const _BlinkingDot({required this.isOnline, this.size = 10});

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = Tween(
      begin: 0.25,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    if (widget.isOnline) _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isOnline ? successColor : Colors.grey.shade400;
    return widget.isOnline
        ? AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Container(
              width: widget.size.w,
              height: widget.size.w,
              decoration: BoxDecoration(
                color: color.withOpacity(_anim.value),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(_anim.value * .5),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          )
        : Container(
            width: widget.size.w,
            height: widget.size.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42.h,
        decoration: BoxDecoration(
          color: filled ? drawerColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: filled ? drawerColor : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: filled ? Colors.white : Colors.black54,
            ),
            SizedBox(width: 5.w),
            CustomText(
              text: label,
              size: 12,
              weight: FontWeight.w600,
              color: filled ? Colors.white : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}

class MentorDetailSheet extends StatelessWidget {
  final Mentor data;
  const MentorDetailSheet({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final m = data;

    return DraggableScrollableSheet(
      initialChildSize: 0.68,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF6F7FB),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          clipBehavior: Clip.hardEdge,
          child: ListView(
            controller: controller,
            padding: EdgeInsets.zero,
            children: [
              // ── DARK HEADER ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                color: drawerColor,
                child: Column(
                  children: [
                    Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 20.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.3),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18.r),
                                border: Border.all(
                                  color: m.isOnline
                                      ? successColor.withOpacity(.7)
                                      : Colors.grey.shade600,
                                  width: 2.5,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.5.r),
                                child: SizedBox(
                                  width: 76.w,
                                  height: 76.w,
                                  child: m.profileImage.isNotEmpty
                                      ? Image.network(
                                          m.profileImage,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                color: Colors.grey.shade700,
                                                child: Icon(
                                                  Icons.person,
                                                  size: 38.sp,
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                        )
                                      : Container(
                                          color: Colors.grey.shade700,
                                          child: Icon(
                                            Icons.person,
                                            size: 38.sp,
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -4.h,
                              right: -4.w,
                              child: _BlinkingDot(
                                isOnline: m.isOnline,
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: m.name,
                                size: 19,
                                weight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              SizedBox(height: 3.h),
                              CustomText(
                                text: m.skills.join(' • '),
                                size: 13,
                                weight: FontWeight.w600,
                                color: accentOrange,
                                maxLines: 2,
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  ...List.generate(
                                    5,
                                    (i) => Icon(
                                      i < m.averageRating.round()
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      size: 15.sp,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  CustomText(
                                    text:
                                        '${m.averageRating.toStringAsFixed(1)} (${m.ratingCount})',
                                    size: 11,
                                    weight: FontWeight.w600,
                                    color: Colors.white60,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        _Pill(Icons.work_outline, m.experience, drawerColor),
                        _Pill(Icons.language, m.language, Colors.teal),
                        _Pill(
                          Icons.currency_rupee,
                          '${m.perMinuteRate}/min',
                          accentOrange,
                        ),
                        _Pill(
                          Icons.people_outline,
                          '${m.ratingCount} reviews',
                          Colors.purple,
                        ),
                        _Pill(Icons.person_outline, m.gender, Colors.indigo),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        _BlinkingDot(isOnline: m.isOnline, size: 9),
                        SizedBox(width: 8.w),
                        CustomText(
                          text: m.isOnline ? 'Online' : 'Currently Offline',
                          size: 13,
                          weight: FontWeight.w600,
                          color: m.isOnline ? successColor : Colors.black45,
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),

                    // ── ACTION BUTTONS ──────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _ActionBtn(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: 'Chat',
                            filled: true,
                            // ✅ Wired from sheet too
                            onTap: () {
                              Navigator.pop(context);
                              context.read<ChatProvider>().reset();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    teacherId: m.id,
                                    teacherName: m.name,
                                    teacherImage: m.profileImage.isNotEmpty
                                        ? m.profileImage
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _ActionBtn(
                            icon: Icons.call_outlined,
                            label: 'Audio',
                            filled: false,
                            onTap: () {
                              Navigator.pop(context); // close sheet first
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CallScreen(
                                    teacherId: m.id,
                                    teacherName: m.name,
                                    teacherImage: m.profileImage.isNotEmpty
                                        ? m.profileImage
                                        : null,
                                    subject: m.skills.isNotEmpty
                                        ? m.skills.first
                                        : '',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),
                    _SectionTitle('About'),
                    SizedBox(height: 8.h),
                    CustomCard(
                      child: CustomText(
                        text: m.about.isNotEmpty
                            ? m.about
                            : 'No description provided.',
                        size: 13,
                        weight: FontWeight.w400,
                        color: Colors.black54,
                        maxLines: 20,
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    _SectionTitle('Skills'),
                    SizedBox(height: 10.h),
                    CustomCard(
                      child: Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: m.skills
                            .map(
                              (s) => Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: drawerColor.withOpacity(.07),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: drawerColor.withOpacity(.2),
                                  ),
                                ),
                                child: CustomText(
                                  text: s,
                                  size: 12,
                                  weight: FontWeight.w600,
                                  color: drawerColor,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    SizedBox(height: 22.h),
                    _SectionTitle('Rate this Mentor'),
                    SizedBox(height: 12.h),
                    _RatingSection(mentor: m),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _Pill(IconData icon, String label, Color color) => Container(
  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
  decoration: BoxDecoration(
    color: color.withOpacity(.08),
    borderRadius: BorderRadius.circular(10.r),
    border: Border.all(color: color.withOpacity(.2)),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13.sp, color: color),
      SizedBox(width: 4.w),
      CustomText(text: label, size: 11, weight: FontWeight.w600, color: color),
    ],
  ),
);

Widget _SectionTitle(String t) => CustomText(
  text: t,
  size: 16,
  weight: FontWeight.w800,
  color: Colors.black87,
);

class _RatingSection extends StatefulWidget {
  final Mentor mentor;
  const _RatingSection({required this.mentor});

  @override
  State<_RatingSection> createState() => _RatingSectionState();
}

class _RatingSectionState extends State<_RatingSection> {
  int _selected = 0;
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return CustomCard(
        child: Column(
          children: [
            SizedBox(height: 6.h),
            Icon(Icons.check_circle_rounded, color: successColor, size: 44.sp),
            SizedBox(height: 10.h),
            CustomText(
              text: 'Thanks for your feedback!',
              size: 15,
              weight: FontWeight.w700,
              color: successColor,
              align: TextAlign.center,
            ),
            SizedBox(height: 6.h),
          ],
        ),
      );
    }

    return CustomCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final val = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _selected = val),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      key: ValueKey(_selected >= val),
                      _selected >= val
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 46.sp,
                      color: _selected >= val
                          ? Colors.amber
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 14.h),
          Consumer<MentorsProvider>(
            builder: (context, prov, _) => GestureDetector(
              onTap: () async {
                if (_selected == 0 || prov.isSubmittingRating) return;
                final ok = await prov.submitRating(
                  context,
                  teacherId: widget.mentor.id,
                  rating: _selected,
                );
                if (ok && mounted) {
                  setState(() => _submitted = true);
                }
              },
              child: Container(
                width: double.infinity,
                height: 48.h,
                decoration: BoxDecoration(
                  color: _selected > 0 && !prov.isSubmittingRating
                      ? drawerColor
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: prov.isSubmittingRating
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : CustomText(
                          text: 'Submit Rating',
                          size: 14,
                          weight: FontWeight.w700,
                          color: _selected > 0 ? Colors.white : Colors.black38,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
