import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/view/download_view/download_screen.dart';
import 'package:firstedu/view/indexscreen/leaderboard_view/leaderboard_screen.dart';
import 'package:firstedu/view/needtoimprove_view/personalise_learningscreen.dart';
import 'package:firstedu/view/orderhistory_view/orderhistory_screen.dart';
import 'package:flutter/material.dart';

class QuickLinksCard extends StatelessWidget {
  const QuickLinksCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: "Quick Links",
            size: 16,
            weight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
          const SizedBox(height: 24),
          _quickLinkItem(
            icon: Icons.track_changes_outlined,
            iconColor: const Color(0xFFFF6B35),
            iconBgColor: const Color(0xFFFF6B35).withOpacity(0.12),
            title: "Need to Improve",
            onTap: () {
              // TODO: Navigate to Need to Improve screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonalizedLearningScreen(),
                ),
              );
            },
          ),

          _quickLinkItem(
            icon: Icons.emoji_events_outlined,
            iconColor: const Color(0xFFFFB800),
            iconBgColor: const Color(0xFFFFB800).withOpacity(0.12),
            title: "Leaderboards",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LeaderboardsScreen(),
                ),
              );
            },
          ),

          _quickLinkItem(
            icon: Icons.download_outlined,
            iconColor: const Color(0xFF2563EB),
            iconBgColor: const Color(0xFF2563EB).withOpacity(0.12),
            title: "Downloads",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DownloadsScreen()),
              );
            },
          ),

          _quickLinkItem(
            icon: Icons.shopping_bag_outlined,
            iconColor: const Color(0xFF14B8A6),
            iconBgColor: const Color(0xFF14B8A6).withOpacity(0.12),
            title: "Order History",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderHistoryScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _quickLinkItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            // Title
            Expanded(
              child: CustomText(
                text: title,
                size: 16,
                weight: FontWeight.w500,
                color: const Color(0xFF1E293B),
              ),
            ),
            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
