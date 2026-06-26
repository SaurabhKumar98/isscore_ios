import 'package:firstedu/data/models/api_models/dashboardmodels/dashboard_models.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/view/needtoimprove_view/personalise_learningscreen.dart';
import 'package:flutter/material.dart';

class NeedToImproveCard extends StatelessWidget {
  final List<WeakCategory> weakCategories;
  final bool isLoading;

  const NeedToImproveCard({
    super.key,
    this.weakCategories = const [],
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.flag_rounded,
                    color: Colors.red.shade400, size: 22),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: CustomText(
                  text: "Need to Improve",
                  size: 16,
                  weight: FontWeight.w700,
                ),
              ),
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PersonalizedLearningScreen()),
                ),
                child: Row(
                  children: [
                    CustomText(
                      text: "View All",
                      size: 13,
                      weight: FontWeight.w600,
                      color: Colors.red.shade400,
                    ),
                    Icon(Icons.chevron_right,
                        color: Colors.red.shade400, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Body ──────────────────────────────────────────
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (weakCategories.isEmpty)
            _emptyState()
          else
            ...weakCategories
                .take(4)
                .map((c) => _categoryRow(c))
                .toList(),

          const SizedBox(height: 16),

          // ── CTA ───────────────────────────────────────────
          if (!isLoading && weakCategories.isNotEmpty)
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => PersonalizedLearningScreen()),
              ),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.shade400,
                      Colors.orange.shade400,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bolt_rounded,
                        color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    CustomText(
                      text: "Start Improving Now",
                      size: 14,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _categoryRow(WeakCategory cat) {
    final score = cat.percentageScore;
    final color = _barColor(score);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomText(
                  text: cat.categoryName,
                  size: 13,
                  weight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: CustomText(
                      text: "$score%",
                      size: 12,
                      weight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(_trendIcon(score),
                      color: color, size: 16),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle_rounded,
                color: Colors.green.shade400, size: 32),
          ),
          const SizedBox(height: 12),
          const CustomText(
            text: "You're doing great!",
            size: 14,
            weight: FontWeight.w700,
          ),
          const SizedBox(height: 4),
          CustomText(
            text: "No weak categories found. Keep it up! 🎉",
            size: 12,
            color: Colors.grey.shade500,
          ),
        ],
      ),
    );
  }

  Color _barColor(int score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red.shade400;
  }

  IconData _trendIcon(int score) {
    if (score >= 75) return Icons.trending_up_rounded;
    if (score >= 50) return Icons.trending_flat_rounded;
    return Icons.trending_down_rounded;
  }
}