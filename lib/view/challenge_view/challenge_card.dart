import 'package:firstedu/data/models/api_models/challengeyourfriend/completechallenge_models.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_button.dart';
import 'package:firstedu/view/challenge_view/challengeanalytics.dart';
import 'package:firstedu/view_models/challengeyourgfriendprovider/challengeyourfriend_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChallengeCard extends StatelessWidget {
  final  CompletedChallenge data;

  const ChallengeCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TOP HEADER — colored accent strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _statusGradient("COMPLETED"),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  /// AVATAR
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.5), width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        "U",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  /// CREATOR INFO
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Created by",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          "User",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// STATUS BADGE
                  _buildStatusBadge("COMPLETED"),
                ],
              ),
            ),

            /// BODY
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE
                  Text(
                    data.challengeName??'',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// SUBJECT CHIP
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.book_rounded,
                            size: 12, color: accentOrange.withOpacity(0.8)),
                        const SizedBox(width: 5),
                        Text(
                          data.test?.title ?? "",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: accentOrange.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// INFO ROWS
                  _buildInfoRow(
                    icon: Icons.people_alt_rounded,
                    label: "Participants",
                    value: "${data.totalParticipants ?? 0}",
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    icon: Icons.calendar_today_rounded,
                    label: "Ended",
                    value: data.completedAt?.toString() ?? "",
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    icon: Icons.emoji_events_rounded,
                    label: "Leader",
                    value: (data.leaderboard != null && data.leaderboard!.isNotEmpty)
    ? data.leaderboard!.first.name ?? "-"
    : "-",
                    valueColor: const Color(0xFF43A047),
                  ),

                 if (data.myScore != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentOrange.withOpacity(0.08),
                            accentOrange.withOpacity(0.03),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: accentOrange.withOpacity(0.2), width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.score_rounded,
                              size: 18, color: accentOrange),
                          const SizedBox(width: 8),
                          const Text(
                            "Your Score",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                           data.myScore?.toString() ?? "0",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: accentOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  /// ACTION BUTTON
                  if (true)
                 CustomButton(
  title: "View Analytics",
  icon: Icons.analytics_rounded,
  onTap: () async {
    final provider = context.read<ChallengeProvider>();

    final detail = await provider.fetchCompletedChallengeDetail(
      context,
      data.challengeId ?? "",
    );

    if (detail == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeAnalyticsScreen(
          detail: detail,
          currentUserId: provider.currentUserId,
        ),
      ),
    );
  },
)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black45,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color textColor;
    String label;
    IconData icon;

    switch (status.toUpperCase()) {
      case "ACTIVE":
        bg = Colors.green.withOpacity(0.2);
        textColor = Colors.green.shade100;
        label = "Active";
        icon = Icons.play_circle_rounded;
        break;
      case "PENDING":
        bg = Colors.amber.withOpacity(0.2);
        textColor = Colors.amber.shade100;
        label = "Pending";
        icon = Icons.hourglass_top_rounded;
        break;
      case "COMPLETED":
      default:
        bg = Colors.white.withOpacity(0.2);
        textColor = Colors.white;
        label = "Done";
        icon = Icons.check_circle_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _statusGradient(String status) {
    switch (status.toUpperCase()) {
      case "ACTIVE":
        return [const Color(0xFF43A047), const Color(0xFF66BB6A)];
      case "PENDING":
        return [const Color(0xFFF57C00), const Color(0xFFFFB74D)];
      case "COMPLETED":
      default:
        return [const Color(0xFF6750A4), const Color(0xFF9C7EC4)];
    }
  }
}