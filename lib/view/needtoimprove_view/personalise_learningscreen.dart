import 'package:firstedu/data/models/api_models/needtoimprove/needtoimprove_models.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_button.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_silverappbar.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/view/courses/coursesscreen.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/examhallscreen.dart';
import 'package:firstedu/view/indexscreen/store_view/storescreen.dart';
import 'package:firstedu/view/teacher_connect/teacher_connect_screen.dart';
import 'package:firstedu/view_models/needtoimproveprovider/needtoimprove_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PersonalizedLearningScreen extends StatefulWidget {
  const PersonalizedLearningScreen({super.key});

  @override
  State<PersonalizedLearningScreen> createState() =>
      _PersonalizedLearningScreenState();
}

class _PersonalizedLearningScreenState
    extends State<PersonalizedLearningScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NeedToImproveProvider>().fetchData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NeedToImproveProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          body: CustomScrollView(
            slivers: [
              const CustomSliverAppBar(
                title: "Personalized Learning",
                subtitle: "Your customized study plan based on performance",
              ),

              // ── LOADING ──────────────────────────────────────────────
              if (provider.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              // ── ERROR ─────────────────────────────────────────────────
              else if (provider.error != null &&
                  provider.weakCategories.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          CustomText(
                            text: provider.error!,
                            size: 14,
                            color: Colors.grey.shade600,
                            align: TextAlign.center,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            title: "Retry",
                            onTap: () => provider.fetchData(context),
                            backgroundColor: drawerColor,
                            textColor: containerColor,
                            icon: Icons.refresh,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              // ── EMPTY ─────────────────────────────────────────────────
              else if (provider.weakCategories.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: Colors.green,
                        ),
                        SizedBox(height: 14),
                        CustomText(
                          text: "No weak areas found. Keep it up! 🎉",
                          size: 15,
                          color: Colors.black54,
                          align: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              // ── CONTENT ───────────────────────────────────────────────
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _actionPlanCard(),
                      const SizedBox(height: 20),
                      ...provider.weakCategories.map((category) {
                        final score = category.percentageScore ?? 0;
                        return Column(
                          children: [
                            _focusAreaCard(
                              context: context,
                              category: category,
                              bgColor: _bgColor(score),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      }),
                      const SizedBox(height: 60),
                    ]),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ── ACTION PLAN CARD ─────────────────────────────────────────────────────

  Widget _actionPlanCard() {
    return CustomCard(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF4081)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CustomText(
                  text: "🎯 PERSONALIZED ACTION PLAN",
                  size: 11,
                  weight: FontWeight.w700,
                  color: Colors.white70,
                ),
                SizedBox(height: 10),
                CustomText(
                  text: "Need to Improve",
                  size: 22,
                  weight: FontWeight.w800,
                  color: containerColor,
                ),
                SizedBox(height: 8),
                CustomText(
                  text:
                      "Identify weak subjects and follow personalized recommendations to strengthen them.",
                  size: 13,
                  color: Colors.white70,
                  maxLines: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withOpacity(0.15),
            child: const Icon(
              Icons.track_changes,
              color: containerColor,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }

  // ── FOCUS AREA CARD ──────────────────────────────────────────────────────

  Widget _focusAreaCard({
    required BuildContext context,
    required WeakCategory category,
    required Color bgColor,
  }) {
    final score = category.percentageScore ?? 0;
    final suggestions = category.suggestions;

    return CustomCard(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _focusHeader(context, category.categoryName ?? "", "$score%"),
          const SizedBox(height: 20),

          // Practice Tests
          _resourceCard(
            icon: Icons.assignment,
            iconColor: Colors.blue,
            iconBg: const Color(0xFFE3F2FD),
            title: "Practice Tests",
            children: (suggestions?.practiceTests?.isNotEmpty == true)
                ? suggestions!.practiceTests!
                      .map((t) => _practiceTestItem(t))
                      .toList()
                : [_emptyMessage("No tests available for this category yet.")],
          ),
          const SizedBox(height: 14),

          // Suggested Videos
          _resourceCard(
            icon: Icons.play_circle_outline,
            iconColor: Colors.purple,
            iconBg: const Color(0xFFF3E5F5),
            title: "Suggested Videos",
            children: (suggestions?.videos?.isNotEmpty == true)
                ? suggestions!.videos!
                      .map((v) => _studyMaterialItem(v))
                      .toList()
                : [_emptyMessage("No videos suggested yet.")],
          ),
          const SizedBox(height: 14),

          // Study Materials
          _resourceCard(
            icon: Icons.menu_book,
            iconColor: Colors.green,
            iconBg: const Color(0xFFE8F5E9),
            title: "Study Materials",
            children: (suggestions?.studyMaterials?.isNotEmpty == true)
                ? suggestions!.studyMaterials!
                      .map((m) => _studyMaterialItem(m))
                      .toList()
                : [_emptyMessage("No study materials available yet.")],
          ),
        ],
      ),
    );
  }

  // ── FOCUS HEADER ─────────────────────────────────────────────────────────

  Widget _focusHeader(BuildContext context, String title, String percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    text: "FOCUS AREA",
                    size: 11,
                    weight: FontWeight.w600,
                    color: Colors.black45,
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    text: title,
                    size: 26,
                    weight: FontWeight.w800,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      CustomText(
                        text: percentage,
                        size: 14,
                        weight: FontWeight.w700,
                        color: accentOrange,
                      ),
                      const CustomText(
                        text: " • Needs work",
                        size: 14,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        /// 🔥 Button moved DOWN (no overflow ever)
        Align(
          alignment: Alignment.centerRight,
          child: CustomButton(
            title: "Connect Teacher",
            icon: Icons.school,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TeacherConnectScreen()),
              );
            },
            backgroundColor: drawerColor,
            textColor: containerColor,
          ),
        ),
      ],
    );
  }
  // ── RESOURCE CARD WRAPPER ─────────────────────────────────────────────────

  Widget _resourceCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required List<Widget> children,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              CustomText(text: title, size: 14, weight: FontWeight.w700),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  // ── PRACTICE TEST ITEM ────────────────────────────────────────────────────

  Widget _practiceTestItem(PracticeTest test) {
    final isPurchased = test.isPurchased ?? false;
    final price = test.price ?? 0;

    return InkWell(
      onTap: () {
        if (isPurchased) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ExamHallScreen()),
          );
        } else {
          // 👉 If not purchased → go to payment screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => StoreScreen()),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: test.title ?? "", size: 13, maxLines: 1),
                  if (price > 0 && !isPurchased)
                    CustomText(
                      text: "₹$price",
                      size: 11,
                      color: Colors.grey.shade500,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            isPurchased
                ? const Icon(Icons.play_circle, size: 22, color: Colors.blue)
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accentOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const CustomText(text: "Buy", size: 11),
                  ),
          ],
        ),
      ),
    );
  }
  // ── EMPTY MESSAGE ────────────────────────────────────────────────────────────

  Widget _emptyMessage(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: CustomText(text: message, size: 13, color: Colors.grey.shade500),
    );
  }

  // ── STUDY MATERIAL / VIDEO ITEM ───────────────────────────────────────────

  Widget _studyMaterialItem(StudyMaterial material) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CoursesScreen()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Expanded(
              child: CustomText(
                text: material.title ?? "",
                size: 13,
                maxLines: 2,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.play_circle, size: 18, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  // ── HELPER ────────────────────────────────────────────────────────────────

  Color _bgColor(int score) {
    if (score < 40) return const Color(0xFFFFCDD2);
    if (score < 60) return const Color(0xFFFFF9C4);
    return const Color(0xFFB2DFDB);
  }
}
