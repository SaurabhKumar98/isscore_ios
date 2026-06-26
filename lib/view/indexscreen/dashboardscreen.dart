import 'package:firstedu/data/models/api_models/dashboardmodels/dashboard_models.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/view/challenge_view/challenge_screen.dart';
import 'package:firstedu/view/everydaychallenge_view/everydaychallenge_screen.dart';
import 'package:firstedu/view/indexscreen/certificatedownload_screen.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/questionscreen.dart';
import 'package:firstedu/view/indexscreen/learningscreen.dart';
import 'package:firstedu/view/indexscreen/notificationscreen.dart';
import 'package:firstedu/view/indexscreen/profile_view/profilescreen.dart';
import 'package:firstedu/view/indexscreen/store_view/storescreen.dart';
import 'package:firstedu/view/indexscreen/testattempts.dart';
import 'package:firstedu/view/indexscreen/widgets/everydaychallengesbutton.dart';
import 'package:firstedu/view/indexscreen/widgets/quickcard.dart';
import 'package:firstedu/view/indexscreen/widgets/scoreimprovementcard.dart';
import 'package:firstedu/view/indexscreen/widgets/subjectstrengthcard.dart';
import 'package:firstedu/view/indexscreen/widgets/upcomingcard.dart';
import 'package:firstedu/view/tournaments_view/tournaments_screen.dart';
import 'package:firstedu/view_models/authprovider/userSessionProvider.dart';
import 'package:firstedu/view_models/certificatedownloadprovider/certificatedownload_provider.dart';
import 'package:firstedu/view_models/dashboardprovider/dashboardprovider.dart';
import 'package:firstedu/view_models/notificationprovider/notificationprovider.dart';
import 'package:firstedu/view_models/profile_provider/profile_provider.dart';
import 'package:firstedu/view_models/wallet_provider/wallet_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onMenuTap;

  const DashboardScreen({super.key, required this.onMenuTap});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _waitForSessionAndFetch();
    });
  }

  Future<void> _waitForSessionAndFetch() async {
    final session = context.read<UserSessionProvider>();

    while (!session.hydrated) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    if (session.accessToken != null && session.accessToken!.isNotEmpty) {
      context.read<DashboardProvider>().fetchDashboard(context);
      context.read<ProfileProvider>().fetchProfile(context);

      // 🔥 ALSO ADD (for notifications)
      context.read<NotificationProvider>().fetchNotifications(context);
      context.read<CertificateDownloadProvider>().fetchCertificates(context);
      context.read<WalletProvider>().fetchBalance();
    }
  }

  @override
  Widget build(BuildContext context) {
    final certProvider = context.watch<CertificateDownloadProvider>();
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        final data = provider.dashboard?.data;
        final isLoading = provider.isLoading;

        return SafeArea(
          child: RefreshIndicator(
            color: drawerColor,
            onRefresh: () => provider.refresh(context),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(context),
                  const SizedBox(height: 20),
                  _welcomeText(),
                  const SizedBox(height: 24),
                  _challengeHeroCard(context),
                  const SizedBox(height: 24),
                  _featuredHeader(context),
                  const SizedBox(height: 16),
                  _featuredBundles(data?.featuredBundles, isLoading),
                  const SizedBox(height: 24),
                  _progressCard(context, data),
                  const SizedBox(height: 20),

                  _statsCard(
                    icon: Icons.description_outlined,
                    title: "TESTS TAKEN",
                    value: isLoading ? '—' : '${data?.totalTestsTaken ?? 0}',
                    isLoading: isLoading,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TestsAttemptedScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _statsCard(
                    icon: Icons.access_time,
                    title: "HOURS LEARNED",
                    value: isLoading
                        ? '—'
                        : data?.totalTimeLearning != null
                        ? '${data!.totalTimeLearning!.hours}h ${data.totalTimeLearning!.minutes}m'
                        : '0h',
                    isLoading: isLoading,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LearningActivityScreen(),
                      ),
                    ),
                  ),
                  // const SizedBox(height: 12),
                  // _statsCard(
                  //   icon: Icons.emoji_events_outlined,
                  //   title: "BEST SCORE",
                  //   value: isLoading ? '—' : '${data?.bestScore ?? 0}%',
                  //   isLoading: isLoading,
                  // ),
                  const SizedBox(height: 12),
                  _statsCard(
                    icon: Icons.workspace_premium,
                    title: "CERTIFICATES",
                    value: certProvider.isLoading
                        ? '-'
                        : '${certProvider.totalCertificates.toString() ?? 0}', // ✅ dynamic count
                    isLoading: certProvider.isLoading,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CertificatesEarnedScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── SCORE IMPROVEMENT CHART ────────────────────
                  ScoreImprovementCard(
                    trends: data?.monthlyScoreTrend ?? [],
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 24),

                  // ── SUBJECT STRENGTH RADAR ─────────────────────
                  SubjectStrengthCard(
                    categoryPerformance: data?.categoryPerformance ?? [],
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 24),

                  // ── TIME BY ACTIVITY (Test Type Stats) ──────────
                  _TimeByActivityCard(
                    stats: data?.testTypeStats,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 24),

                  // ── RECENT PERFORMANCE ─────────────────────────
                  _allTestAttemptsPreview(
                    context,
                    data?.recentTestResults,
                    isLoading,
                  ),
                  const SizedBox(height: 20),
                  const QuickLinksCard(),
                  const SizedBox(height: 20),
                  UpcomingCard(events: data?.upcomingEvents ?? []),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // TOP BAR
  // ─────────────────────────────────────────────────────────────────

  Widget _topBar(BuildContext context) {
    final unreadCount = context.watch<NotificationProvider>().unreadCount;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(onTap: widget.onMenuTap, child: _iconButton(Icons.menu)),

        Row(
          children: [
            // ✅ Wallet Balance
            Consumer<WalletProvider>(
              builder: (context, walletProvider, _) {
                final balance = walletProvider.balance?.monetaryBalance ?? 0;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 242, 242, 243),
                        Colors.white,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: drawerBgColor),
                  ),
                  child: Row(
                    children: [
                      // Wallet Icon
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: drawerColor.withOpacity(.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: drawerBgColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Wallet Text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wallet',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),

                          Text(
                            '₹${balance.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1D26),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 12),

            Stack(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                  child: _iconButton(Icons.notifications_none),
                ),

                if (unreadCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.blue,
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: Consumer<ProfileProvider>(
                builder: (context, profileProvider, _) {
                  final profile = profileProvider.profile;

                  return CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.indigo,
                    backgroundImage:
                        (profile?.profileImage != null &&
                            profile!.profileImage!.isNotEmpty)
                        ? NetworkImage(profile.profileImage!)
                        : null,
                    child:
                        (profile?.profileImage == null ||
                            profile!.profileImage!.isEmpty)
                        ? Text(
                            profile?.name?.isNotEmpty == true
                                ? profile!.name![0].toUpperCase()
                                : "S",
                            style: const TextStyle(color: Colors.white),
                          )
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: drawerColor),
    );
  }

  Widget _welcomeText() {
    return const CustomText(
      text: "Welcome back! 👋",
      size: 22,
      weight: FontWeight.w600,
      color: Color(0xFF0F172A),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // CHALLENGE HERO CARD
  // ─────────────────────────────────────────────────────────────────

  Widget _challengeHeroCard(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [drawerColor, drawerColor.withOpacity(.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber),
            ),
            child: const CustomText(
              text: "🏆 COMPETE & WIN",
              size: 11,
              weight: FontWeight.w600,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 12),
          const CustomText(
            text: "Challenge friends or groups",
            size: 20,
            weight: FontWeight.w700,
            color: Colors.white,
          ),
          const SizedBox(height: 6),
          const CustomText(
            text:
                "Create or join challenges, compete in gamified tournaments, and climb the leaderboard.",
            size: 13,
            weight: FontWeight.w400,
            color: Colors.white70,
            maxLines: 3,
          ),
          const SizedBox(height: 18),
          EveryDayChallengeButton(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DailyChallengesScreen()),
            ),
          ),
          const SizedBox(height: 10),
          MyChallengesButton(
            count: 3,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChallengeScreen()),
            ),
          ),
          const SizedBox(height: 10),
          GamifiedTournamentsButton(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TournamentScreen()),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // FEATURED BUNDLES  (API-connected)
  // ─────────────────────────────────────────────────────────────────

  Widget _featuredHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const CustomText(
          text: "Featured Bundles",
          size: 16,
          weight: FontWeight.w600,
        ),
        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StoreScreen()),
          ),
          child: CustomText(
            text: "View Store",
            size: 14,
            weight: FontWeight.w500,
            color: primaryButtonColor,
          ),
        ),
      ],
    );
  }

  Widget _featuredBundles(List<FeaturedBundle>? bundles, bool isLoading) {
    if (isLoading) {
      return SizedBox(
        height: 140,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, __) =>
              _shimmerBox(width: 260, height: 140, radius: 18),
        ),
      );
    }

    if (bundles == null || bundles.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: const CustomText(
          text: "No featured bundles available",
          size: 13,
          color: Colors.grey,
        ),
      );
    }

    final colors = [
      const Color(0xFF2F55D4),
      const Color(0xFF4CAF7A),
      primaryButtonColor,
    ];

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: bundles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final b = bundles[i];
          final discount = b.discountPercent;
          return _bundleCard(
            title: b.name,
            subtitle: b.description.isNotEmpty
                ? b.description
                : '${b.tests.length} Tests',
            price: '₹${b.discountedPrice.toStringAsFixed(0)}',
            discount: discount != null ? '$discount% OFF' : null,
            color: colors[i % colors.length],
          );
        },
      ),
    );
  }

  Widget _bundleCard({
    required String title,
    required String subtitle,
    required String price,
    required Color color,
    String? discount,
  }) {
    return SizedBox(
      width: 260,
      child: CustomCard(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [color, color.withOpacity(.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                Icons.school,
                size: 90,
                color: Colors.white.withOpacity(.08),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (discount != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: CustomText(
                      text: discount,
                      size: 12,
                      weight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                const Spacer(),
                CustomText(
                  text: title,
                  size: 15,
                  weight: FontWeight.w600,
                  color: Colors.white,
                  maxLines: 1,
                ),
                CustomText(
                  text: subtitle,
                  size: 12,
                  color: Colors.white70,
                  maxLines: 1,
                ),
                const SizedBox(height: 8),
                CustomText(
                  text: price,
                  size: 18,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


Widget _progressCard(BuildContext context, DashboardData? data) {
  final resume = data?.recentResumeExam;
  final title = resume?.title ?? 'No Resume Test';

  return CustomCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE8D5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: CustomText(
            text: resume != null ? "IN PROGRESS" : "NO ACTIVE TEST",
            size: 11,
            color: primaryButtonColor,
            weight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        CustomText(
          text: title,
          size: 16,
          weight: FontWeight.w600,
          maxLines: 1,
        ),

        const SizedBox(height: 16),

        /// 🔥 RESUME BUTTON
        Center(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: drawerColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              if (resume == null) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExamScreen(
                    testId: "",
                    examTitle: resume.title,
                    existingSessionId: resume.sessionId,
                    showPauseButton: true,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: Text(resume != null ? "Resume" : "No Test"),
          ),
        ),
      ],
    ),
  );
}
  // ─────────────────────────────────────────────────────────────────
  // STATS CARDS
  // ─────────────────────────────────────────────────────────────────

  Widget _statsCard({
    required IconData icon,
    required String title,
    required String value,
    bool isLoading = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CustomCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: drawerColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: title,
                    size: 11,
                    color: Colors.grey,
                    weight: FontWeight.w600,
                  ),
                  isLoading
                      ? _shimmerBox(width: 60, height: 18, radius: 4)
                      : CustomText(
                          text: value,
                          size: 18,
                          weight: FontWeight.w600,
                        ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }

  Widget _allTestAttemptsPreview(
    BuildContext context,
    List<TestResult>? results,
    bool isLoading,
  ) {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: CustomText(
                  text: "Recent Performance",
                  size: 16,
                  weight: FontWeight.w700,
                ),
              ),
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TestsAttemptedScreen(),
                  ),
                ),
                child: CustomText(
                  text: "View All",
                  size: 13,
                  weight: FontWeight.w600,
                  color: primaryButtonColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            Column(
              children: List.generate(
                2,
                (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _shimmerBox(
                    width: double.infinity,
                    height: 72,
                    radius: 12,
                  ),
                ),
              ),
            )
          else if (results == null || results.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CustomText(
                  text: "No tests attempted yet.",
                  size: 13,
                  color: Colors.grey,
                ),
              ),
            )
          else
            ...results.take(3).map((r) => _attemptPreviewCard(r)).toList(),
        ],
      ),
    );
  }

  Widget _attemptPreviewCard(TestResult test) {
    final scoreColor = _getScoreColor(test.percentage);
    final dateStr = test.date != null
        ? '${test.date!.day} ${_monthName(test.date!.month)} ${test.date!.year}'
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CustomCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CustomText(
                  text: "${test.percentage}%",
                  size: 14,
                  weight: FontWeight.w700,
                  color: scoreColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: test.name,
                    size: 13,
                    weight: FontWeight.w700,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: drawerColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: CustomText(
                            text: test.category,
                            size: 10,
                            weight: FontWeight.w600,
                            color: drawerColor,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      CustomText(
                        text: '${test.score}/${test.maxScore}',
                        size: 11,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomText(
                  text: dateStr,
                  size: 10,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(height: 4),
                _testTypeBadge(test.type),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _testTypeBadge(TestType type) {
    final label = _testTypeShortLabel(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 9,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────

  Color _getScoreColor(double score) {
    if (score >= 90) return successColor;
    if (score >= 75) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _monthName(int m) {
    const names = [
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
      'Dec',
    ];
    return m >= 1 && m <= 12 ? names[m] : '';
  }

  String _testTypeShortLabel(TestType t) {
    switch (t) {
      case TestType.TOURNAMENT:
        return 'Tournament';
      case TestType.OLYMPIAD:
        return 'Olympiad';
      case TestType.TEST:
        return 'Test';
      case TestType.CHALLENGE_YOURSELF:
        return 'Challenge';
      case TestType.COMPETITION_SECTOR:
        return 'Competition';
      case TestType.EVERYDAY_CHALLENGE:
        return 'Daily';
      default:
        return 'Other';
    }
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// TIME BY ACTIVITY CARD  —  tap a slice to see title + time
// ═══════════════════════════════════════════════════════════════════

class _TimeByActivityCard extends StatefulWidget {
  final List<TestTypeStat>? stats;
  final bool isLoading;

  const _TimeByActivityCard({this.stats, this.isLoading = false});

  @override
  State<_TimeByActivityCard> createState() => _TimeByActivityCardState();
}

class _TimeByActivityCardState extends State<_TimeByActivityCard> {
  int _touchedIndex = -1;

  static const _pieColors = [
    Color(0xFF3B82F6), // blue
    Color(0xFFF97316), // orange
    Color(0xFF8B5CF6), // purple
    Color(0xFF22C55E), // green
    Color(0xFFEC4899), // pink
    Color(0xFF14B8A6), // teal
  ];

  // Returns empty list when no data — no hardcoded fallback
  List<_PieSlice> get _slices {
    final stats = widget.stats;
    if (stats == null || stats.isEmpty) return [];
    return stats.asMap().entries.map((e) {
      final s = e.value;
      final color = _pieColors[e.key % _pieColors.length];
      final hrs = s.totalDurationMinutes ~/ 60;
      final mins = s.totalDurationMinutes % 60;
      final timeLabel = hrs > 0 ? '${hrs}h ${mins}m' : '${mins}m';
      return _PieSlice(
        label: s.displayLabel,
        timeLabel: timeLabel,
        value: s.totalDurationMinutes.toDouble().clamp(1, double.infinity),
        color: color,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final slices = _slices;
    final touched = _touchedIndex >= 0 && _touchedIndex < slices.length
        ? slices[_touchedIndex]
        : null;

    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CustomText(
                text: "Time by Activity",
                size: 16,
                weight: FontWeight.w700,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: drawerColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomText(
                  text: "All Time",
                  size: 11,
                  weight: FontWeight.w600,
                  color: drawerColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Pie chart / Empty state ───────────────────────
          if (widget.isLoading)
            const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (slices.isEmpty)
            const SizedBox(
              height: 160,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pie_chart_outline, size: 56, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      "No activity data yet",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Start learning to track your time here",
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Center(
              child: SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        centerSpaceRadius: 58,
                        sectionsSpace: 3,
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, PieTouchResponse? res) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      res == null ||
                                      res.touchedSection == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  final idx =
                                      res.touchedSection!.touchedSectionIndex;
                                  _touchedIndex = _touchedIndex == idx
                                      ? -1
                                      : idx;
                                });
                              },
                        ),
                        sections: slices.asMap().entries.map((e) {
                          final i = e.key;
                          final s = e.value;
                          final isTouched = i == _touchedIndex;
                          return PieChartSectionData(
                            color: s.color,
                            value: s.value,
                            title: '',
                            radius: isTouched ? 64 : 52,
                          );
                        }).toList(),
                      ),
                    ),

                    // Center tooltip when a slice is tapped
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: touched != null
                          ? _CenterTooltip(key: UniqueKey(), slice: touched)
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Legend ────────────────────────────────────────
            SizedBox(
              height: (slices.length / 2).ceil() * 50, // dynamic height
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: slices.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 👈 2 items per row
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 3.5, // 👈 adjust UI
                ),
                itemBuilder: (context, index) {
                  final s = slices[index];
                  final isActive = _touchedIndex == index;

                  return GestureDetector(
                    onTap: () =>
                        setState(() => _touchedIndex = isActive ? -1 : index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? s.color.withOpacity(0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive ? s.color : Colors.transparent,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: s.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              s.label,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isActive
                                    ? s.color
                                    : const Color(0xFF374151),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            s.timeLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: s.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Animated center tooltip shown inside the donut hole ──────────────

class _CenterTooltip extends StatelessWidget {
  final _PieSlice slice;

  const _CenterTooltip({super.key, required this.slice});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          slice.timeLabel,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: slice.color,
          ),
        ),
        Text(
          slice.label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Simple data model for a pie slice ────────────────────────────────

class _PieSlice {
  final String label;
  final String timeLabel;
  final double value;
  final Color color;

  const _PieSlice({
    required this.label,
    required this.timeLabel,
    required this.value,
    required this.color,
  });
}
