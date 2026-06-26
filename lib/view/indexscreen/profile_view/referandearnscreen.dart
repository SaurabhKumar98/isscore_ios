import 'package:firstedu/data/models/api_models/refferandearnmodel/refferandearnmodel.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_button.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_silverappbar.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view_models/refferandearnprovider/refferandearn_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ReferEarnScreen extends StatefulWidget {
  const ReferEarnScreen({super.key});

  @override
  State<ReferEarnScreen> createState() => _ReferEarnScreenState();
}

class _ReferEarnScreenState extends State<ReferEarnScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReferAndEarnProvider>().fetchReferData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReferAndEarnProvider>(
      builder: (context, provider, _) {
        final data = provider.data;

        return Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          body: CustomScrollView(
            slivers: [
              const CustomSliverAppBar(
                title: "Refer & Earn",
                subtitle: "Invite friends and earn rewards together",
              ),

              /// 🔥 LOADING
              if (provider.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              /// ❌ ERROR
              else if (provider.error != null)
                SliverFillRemaining(child: Center(child: Text(provider.error!)))
              /// ✅ CONTENT
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildHeroCard(context, data),
                      const SizedBox(height: 24),
                      _buildHowItWorks(),
                      const SizedBox(height: 20),
                      _buildRewardsBenefits(),
                      const SizedBox(height: 20),
                      _buildShareSection(context, data),
                      const SizedBox(height: 80),
                    ]),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ================= HERO CARD =================
  Widget _buildHeroCard(BuildContext context, ReferralData? data) {
    final code = data?.referralCode ?? "";

    return CustomCard(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [drawerColor, Color(0xFF2A4494)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildGiftIcon(),
          const SizedBox(height: 20),

          const CustomText(
            text: "Refer & Earn",
            size: 22,
            weight: FontWeight.w800,
            color: containerColor,
          ),

          const SizedBox(height: 20),

          /// 🔥 CODE BOX
          GestureDetector(
            onTap: () => _copyToClipboard(context, code),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: containerColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CustomText(text: "Your Code: ", color: Colors.white70),
                  CustomText(
                    text: code,
                    size: 20,
                    weight: FontWeight.w900,
                    color: containerColor,
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.copy, color: containerColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftIcon() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: containerColor.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.card_giftcard, size: 40, color: containerColor),
    );
  }

  Widget _buildShareSection(BuildContext context, ReferralData? data) {
    final link = data?.shareLink ?? "";

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: "Share Your Link",
            size: 18,
            weight: FontWeight.w700,
          ),
          const SizedBox(height: 14),

          _buildLinkBox(context, link),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: CustomButton(
                  title: "Copy Link",
                  onTap: () => _copyToClipboard(context, link),
                  primary: false,
                  icon: Icons.copy,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  title: "WhatsApp",
                  onTap: () {
                    // later we add share logic
                  },
                  backgroundColor: const Color(0xFF25D366),
                  textColor: containerColor,
                  icon: Icons.chat,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= STATS =================
  Widget _buildHowItWorks() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.lightbulb_outline,
            title: "How It Works",
            color: accentOrange,
          ),
          const SizedBox(height: 20),
          _buildStep(
            number: 1,
            // icon: Icons.share,
            title: "Share Your Code",
            description:
                "Send your referral code or link to friends via WhatsApp, email, or social media.",
          ),
          _buildStep(
            number: 2,
            // icon: Icons.person_add,
            title: "Friend Signs Up",
            description:
                "Your friend creates a new account using your referral code.",
          ),
          _buildStep(
            number: 3,
            // icon: Icons.emoji_events,
            title: "Both Get Rewarded",
            description: "You earn 100 XP instantly when signup is completed!",
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required int number,
    IconData? icon,
    required String title,
    required String description,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepNumber(number),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon(icon, size: 18, color: accentOrange),
                    const SizedBox(width: 6),
                    CustomText(
                      text: title,
                      size: 15,
                      weight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                CustomText(text: description, size: 13, color: Colors.black54),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepNumber(int number) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [accentOrange, Color(0xFFFF8C00)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: accentOrange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: CustomText(
        text: "$number",
        size: 18,
        weight: FontWeight.w800,
        color: containerColor,
      ),
    );
  }

  // ================= BENEFITS =================
  Widget _buildRewardsBenefits() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.card_giftcard,
            title: "Benefits & Rewards",
            color: successColor,
          ),
          const SizedBox(height: 16),
          _buildBenefit(
            icon: Icons.stars,
            title: "100 XP per referral",
            description: "Earn instantly when friend joins",
            color: const Color(0xFFFFD700),
          ),
          _buildBenefit(
            icon: Icons.all_inclusive,
            title: "Unlimited referrals",
            description: "No cap on how many friends you invite",
            color: const Color(0xFF2196F3),
          ),
          _buildBenefit(
            icon: Icons.lock_open,
            title: "Unlock premium content",
            description: "Use XP for courses, tests & rewards",
            color: const Color(0xFF9C27B0),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: title, size: 14, weight: FontWeight.w700),
                const SizedBox(height: 3),
                CustomText(text: description, size: 12, color: Colors.black54),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= SHARE =================
  Widget _buildLinkBox(BuildContext context, String link) {
    return GestureDetector(
      onTap: () => _copyToClipboard(context, link),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.link, color: drawerColor),
            const SizedBox(width: 10),

            Expanded(child: CustomText(text: link, size: 12, maxLines: 2)),

            const SizedBox(width: 10),
            const Icon(Icons.copy),
          ],
        ),
      ),
    );
  }
  // Widget _buildLinkBox(BuildContext context) {
  //   return GestureDetector(
  //     onTap: () => _copyToClipboard(context, ReferEarnScreen._referralLink),
  //     child: Container(
  //       padding: const EdgeInsets.all(14),
  //       decoration: BoxDecoration(
  //         color: Colors.grey.shade50,
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(color: Colors.grey.shade300),
  //       ),
  //       child: Row(
  //         children: [
  //           const Icon(Icons.link, color: drawerColor, size: 20),
  //           const SizedBox(width: 10),
  //           Expanded(
  //             child: CustomText(text: ReferEarnScreen._referralLink, size: 12, maxLines: 2),
  //           ),
  //           const SizedBox(width: 10),
  //           Icon(Icons.copy, color: Colors.grey.shade600, size: 18),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // ================= UTIL =================
  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        CustomText(text: title, size: 18, weight: FontWeight.w700),
      ],
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: const CustomText(
    //       text: "Copied to clipboard!",
    //       size: 14,
    //       weight: FontWeight.w600,
    //       color: containerColor,
    //     ),
    //     backgroundColor: successColor,
    //     behavior: SnackBarBehavior.floating,
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    //   ),
    // );
    AppToast.successGlobal(message: "Copied to clipboard!");
  }
}
