// lib/view/challenge_view/daily_challenges_screen.dart

import 'package:firstedu/data/models/api_models/everydaychallenge/everydaychallenge_models.dart';
import 'package:firstedu/data/repo/examhall/examsessionrepositories.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_button.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_silverappbar.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/view/challenge_view/gamechallengemode.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/examhallscreen.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/questionscreen.dart';
import 'package:firstedu/view_models/everydaychallengeprovider/everydaychallengeprovider.dart';
import 'package:firstedu/view_models/examhallprovider/examhallwebsocket.dart';
import 'package:firstedu/view_models/examhallprovider/examsessionprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class DailyChallengesScreen extends StatefulWidget {
  const DailyChallengesScreen({super.key});

  @override
  State<DailyChallengesScreen> createState() => _DailyChallengesScreenState();
}

class _DailyChallengesScreenState extends State<DailyChallengesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context
          .read<Everydaychallengeprovider>()
          .fetchEverydayChallenge(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: CustomScrollView(
        slivers: [
          const CustomSliverAppBar(
            title: "Daily Challenges",
            subtitle: "Complete challenges and build your streak",
          ),

          Consumer<Everydaychallengeprovider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.all(16.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeroCard(provider),
                    SizedBox(height: 20.h),
                    _buildTodaysChallengeCard(context, provider),
                    SizedBox(height: 20.h),
                    _buildStreakCycle(provider),
                    SizedBox(height: 20.h),
                    _buildExploreMore(context),
                    SizedBox(height: 100.h),
                  ]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(Everydaychallengeprovider provider) {
    final streak = provider.streakDays;
    final challenge = provider.challenge;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8C00), Color(0xFFFF6B6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8C00).withOpacity(0.4),
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.white, size: 14.sp),
                SizedBox(width: 4.w),
                const CustomText(
                  text: "DAILY PRACTICE",
                  size: 11,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          CustomText(
            text: challenge?.title ?? 'Everyday\nChallenges',
            size: 32,
            weight: FontWeight.w800,
            color: Colors.white,
            maxLines: 2,
            height: 1.2,
          ),
          SizedBox(height: 12.h),

          CustomText(
            text: challenge?.description ??
                'Complete a quick challenge every day to build consistency.',
            size: 14,
            color: Colors.white.withOpacity(0.95),
            maxLines: 4,
            height: 1.5,
          ),
          SizedBox(height: 24.h),

          // Streak box
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Icon(Icons.local_fire_department,
                    color: Colors.white, size: 32.sp),
                SizedBox(height: 8.h),
                CustomText(
                  text: '$streak',
                  size: 36,
                  weight: FontWeight.w800,
                  color: Colors.white,
                ),
                SizedBox(height: 4.h),
                const CustomText(
                  text: "DAY STREAK",
                  size: 12,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysChallengeCard(
      BuildContext context, Everydaychallengeprovider provider) {
    final challenge = provider.challenge;
    if (challenge == null) {
    return CustomCard(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_rounded,
              size: 56.sp, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          CustomText(
            text: "No challenge for today",
            size: 18,
            weight: FontWeight.w800,
            color: Colors.black87,
          ),
          SizedBox(height: 8.h),
          CustomText(
            text:
                "Check back tomorrow for a new everyday challenge. In the meantime, explore the Exam Hall for more practice.",
            size: 14,
            color: Colors.grey.shade600,
            maxLines: 3,
            height: 1.5,
            align: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          CustomButton(
            title: "Go to Exam Hall",
            icon: Icons.school_outlined,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => ExamHallScreen())),
            backgroundColor: const Color(0xFFFF8C00),
            textColor: Colors.white,
            height: 52.h,
          ),
        ],
      ),
    );
  }

    final completedToday = provider.completedToday;
    final streakDays = provider.streakDays;
    final nextPoints = provider.nextPoints ?? 0;

    // Today's date
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final dateStr =
        '${now.day} ${months[now.month - 1]} ${now.year}';

    // Current day number in streak cycle
    final currentDay = (streakDays % 7) + 1;

    return CustomCard(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.emoji_events,
                    color: Colors.amber, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomText(
                  text: "Day $currentDay Challenge —\n$dateStr",
                  size: 16,
                  weight: FontWeight.w700,
                  color: Colors.black87,
                  maxLines: 2,
                ),
              ),
              // Completed badge
              if (completedToday)
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border:
                        Border.all(color: successColor.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: successColor, size: 12.sp),
                      SizedBox(width: 4.w),
                      CustomText(
                        text: 'Done',
                        size: 11,
                        weight: FontWeight.w700,
                        color: successColor,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 20.h),

          // Title
          CustomText(
            text: challenge?.title ?? "Today's Challenge",
            size: 20,
            weight: FontWeight.w800,
            color: Colors.black87,
            maxLines: 2,
            height: 1.3,
          ),
          SizedBox(height: 12.h),

          // Description
          CustomText(
            text: challenge?.description ?? 'Complete today\'s challenge.',
            size: 14,
            color: Colors.grey.shade600,
            maxLines: 3,
            height: 1.5,
          ),
          SizedBox(height: 20.h),

          // Info tags
          if (challenge?.questionBank?.categories?.isNotEmpty == true)
            _buildInfoTag(
              Icons.book_outlined,
              challenge!.questionBank!.categories!.first.name ?? '',
            ),
          SizedBox(height: 10.h),
          if (challenge?.durationMinutes != null)
            _buildInfoTag(
              Icons.access_time,
              '~${challenge!.durationMinutes} min',
            ),
          SizedBox(height: 16.h),

          // XP badge
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stars, color: Colors.orange, size: 18.sp),
                SizedBox(width: 6.w),
                CustomText(
                  text: '+$nextPoints XP for Day $currentDay',
                  size: 13,
                  weight: FontWeight.w700,
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Start / Completed button
          completedToday
              ? CustomButton(
                  title: "Already Completed Today",
                  icon: Icons.check_circle_rounded,
                  onTap: () {},
                  enabled: false,
                  backgroundColor: successColor,
                  textColor: Colors.white,
                  height: 52.h,
                )
              : CustomButton(
                  title: "Start Day $currentDay Challenge",
                  icon: Icons.play_arrow_rounded,
                  onTap: () => _startChallenge(context, challenge),
                  backgroundColor: const Color(0xFFFF8C00),
                  textColor: Colors.white,
                  height: 52.h,
                ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  NAVIGATE TO EXAM SCREEN
  // ─────────────────────────────────────────────────────────────────

  void _startChallenge(BuildContext context, Challenge? challenge) {
    final testId = challenge?.id;
    if (testId == null || testId.isEmpty) {
      debugPrint('❌ No challenge testId');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (ctx) => ExamSessionProvider(
            ctx.read<ExamSessionRepository>(),
            ExamSocketService(),
          ),
          child: ExamScreen(
            testId: testId,
            examTitle: challenge?.title ?? "Daily Challenge",
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  7-DAY STREAK CYCLE
  // ─────────────────────────────────────────────────────────────────

  Widget _buildStreakCycle(Everydaychallengeprovider provider) {
    final cycle = provider.streakCycle;
    final streakDays = provider.streakDays;
    final currentDay = (streakDays % 7) + 1;

    return CustomCard(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department,
                  size: 20.sp, color: Colors.orange),
              SizedBox(width: 8.w),
              const CustomText(
                text: "7-Day Streak Cycle",
                size: 18,
                weight: FontWeight.w800,
                color: Colors.black87,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          CustomText(
            text: 'You\'re on Day $currentDay of your streak cycle',
            size: 13,
            color: Colors.grey.shade600,
          ),
          SizedBox(height: 20.h),

          // Day cards
          cycle.isEmpty
              ? _buildDefaultStreakCycle(currentDay)
              : SizedBox(
                  height: 110.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: cycle.length,
                    separatorBuilder: (_, __) => SizedBox(width: 10.w),
                    itemBuilder: (context, index) {
                      final item = cycle[index];
                      final day = item.day ?? (index + 1);
                      final points = item.points ?? 0;
                      final completed = item.completed ?? false;
                      final isToday = day == currentDay;

                      return _buildDayCard(
                        day: day,
                        points: points,
                        completed: completed,
                        isToday: isToday,
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildDefaultStreakCycle(int currentDay) {
    // Fallback if no streak cycle from API
    return SizedBox(
      height: 110.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 7,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final day = index + 1;
          return _buildDayCard(
            day: day,
            points: 10 + (index * 5),
            completed: day < currentDay,
            isToday: day == currentDay,
          );
        },
      ),
    );
  }

  Widget _buildDayCard({
    required int day,
    required int points,
    required bool completed,
    required bool isToday,
  }) {
    Color bg;
    Color border;
    Color textColor;
    Widget icon;

    if (completed) {
      bg = successColor.withOpacity(0.1);
      border = successColor.withOpacity(0.4);
      textColor = successColor;
      icon = Icon(Icons.check_circle, color: successColor, size: 22.sp);
    } else if (isToday) {
      bg = const Color(0xFFFF8C00).withOpacity(0.1);
      border = const Color(0xFFFF8C00).withOpacity(0.5);
      textColor = const Color(0xFFFF8C00);
      icon =
          Icon(Icons.play_circle_fill, color: const Color(0xFFFF8C00), size: 22.sp);
    } else {
      bg = Colors.grey.shade50;
      border = Colors.grey.shade200;
      textColor = Colors.grey.shade500;
      icon = Icon(Icons.radio_button_unchecked,
          color: Colors.grey.shade400, size: 22.sp);
    }

    return Container(
      width: 80.w,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: border, width: isToday ? 2 : 1),
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: const Color(0xFFFF8C00).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomText(
            text: 'Day $day',
            size: 10,
            weight: FontWeight.w700,
            color: textColor,
          ),
          SizedBox(height: 6.h),
          icon,
          SizedBox(height: 6.h),
          CustomText(
            text: '+$points XP',
            size: 11,
            weight: FontWeight.w800,
            color: textColor,
          ),
          if (isToday) ...[
            SizedBox(height: 4.h),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8C00),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: CustomText(
                text: 'TODAY',
                size: 7,
                weight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────────────────────────

  Widget _buildInfoTag(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: Colors.grey.shade600),
        SizedBox(width: 8.w),
        CustomText(
          text: text,
          size: 14,
          weight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  EXPLORE MORE
  // ─────────────────────────────────────────────────────────────────

  Widget _buildExploreMore(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: "Explore More",
            size: 18,
            weight: FontWeight.w800,
            color: Colors.black87,
          ),
          SizedBox(height: 16.h),
          _buildExploreItem(
            icon: Icons.school_outlined,
            iconColor: Colors.purple,
            iconBg: Colors.purple.shade50,
            title: "Exam Hall",
            subtitle: "More practice tests",
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => ExamHallScreen())),
          ),
          SizedBox(height: 12.h),
          _buildExploreItem(
            icon: Icons.sports_esports_outlined,
            iconColor: Colors.pink,
            iconBg: Colors.pink.shade50,
            title: "Game Challenge",
            subtitle: "Compete with friends",
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => GameModeScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: iconColor, size: 24.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: title,
                    size: 16,
                    weight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  SizedBox(height: 2.h),
                  CustomText(
                    text: subtitle,
                    size: 13,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 18.sp, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}