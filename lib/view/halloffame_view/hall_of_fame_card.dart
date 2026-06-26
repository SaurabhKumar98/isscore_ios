import 'package:firstedu/data/models/api_models/halloffamemodels/halloffame_models.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class HallOfFameEventCard extends StatelessWidget {
  final HallOfFameItem item;

  const HallOfFameEventCard({super.key, required this.item});

  bool get _isOlympiad =>
      (item.eventType ?? '').toLowerCase() == 'olympiad';

  String get _formattedDate {
    final date = item.eventDate;
    if (date == null) return '';
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String get _eventLabel {
    final title = item.eventId?.title;
    if (title != null && title.isNotEmpty) return title;
    final type = item.eventType ?? 'Event';
    return type.isNotEmpty
        ? type[0].toUpperCase() + type.substring(1)
        : 'Event';
  }

  @override
  Widget build(BuildContext context) {
    final winners = item.winners ?? [];

    final sorted = [...winners]
      ..sort((a, b) => (a.position ?? 99).compareTo(b.position ?? 99));

    /// ✅ FIXED (removed null! crash)
   final Winner? gold =
    sorted.where((w) => w.position == 1).isNotEmpty
        ? sorted.firstWhere((w) => w.position == 1)
        : (sorted.isNotEmpty ? sorted[0] : null);

    final Winner? silver =
        sorted.where((w) => w.position == 2).isNotEmpty
            ? sorted.firstWhere((w) => w.position == 2)
            : sorted.length >= 2 ? sorted[1] : null;

    final Winner? bronze =
        sorted.where((w) => w.position == 3).isNotEmpty
            ? sorted.firstWhere((w) => w.position == 3)
            : sorted.length >= 3 ? sorted[2] : null;

    return CustomCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _isOlympiad
                      ? const Color(0xFFEAF3DE)
                      : const Color(0xFFE6F1FB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isOlympiad
                        ? const Color(0xFF3B6D11)
                        : const Color(0xFF185FA5),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isOlympiad
                          ? Icons.school_outlined
                          : Icons.emoji_events_outlined,
                      size: 12,
                      color: _isOlympiad
                          ? const Color(0xFF3B6D11)
                          : const Color(0xFF185FA5),
                    ),
                    const SizedBox(width: 5),
                    CustomText(
                      text: _eventLabel,
                      size: 11,
                      weight: FontWeight.w700,
                      color: _isOlympiad
                          ? const Color(0xFF3B6D11)
                          : const Color(0xFF185FA5),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentOrange.withOpacity(0.3), width: 0.8),
                ),
                child: CustomText(
                  text: _formattedDate,
                  size: 11,
                  weight: FontWeight.w700,
                  color: accentOrange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// PODIUM / SOLO
          if (gold != null && sorted.length >= 2)
            _buildPodium(gold: gold, silver: silver, bronze: bronze)
          else if (gold != null)
            _buildSoloWinner(gold)
          else
            const CustomText(
              text: 'No winners recorded.',
              size: 13,
              color: Colors.black38,
            ),
        ],
      ),
    );
  }

  Widget _buildPodium({
    required Winner gold,
    Winner? silver,
    Winner? bronze,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: silver != null
              ? _PodiumItem(
                  name: silver.student?.name ??
    silver.studentName ??
    'N/A',
                  blockHeight: 90,
                  color: const Color(0xFFC0C0C0),
                  rank: 2,
                  score: silver.score,
                )
              : const SizedBox(),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PodiumItem(
            name: gold.student?.name ??
      gold.studentName ??
      'N/A',
            blockHeight: 120,
            color: const Color(0xFFFFD700),
            rank: 1,
            score: gold.score,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: bronze != null
              ? _PodiumItem(
                  name: bronze.student?.name ??
    bronze.studentName ??
    'N/A',
                  blockHeight: 75,
                  color: const Color(0xFFCD7F32),
                  rank: 3,
                  score: bronze.score,
                )
              : const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildSoloWinner(Winner winner) {
    final name =
    winner.student?.name ??
    winner.studentName ??
    '';
    final firstChar =
        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';

    return Row(
      children: [
      Container(
  width: 52,
  height: 52,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: const Color(0xFFFFD700).withOpacity(0.2),
    border: Border.all(
      color: const Color(0xFFFFD700),
      width: 2.5,
    ),
  ),
  child: ClipOval(
    child: (winner.student?.profileImage != null &&
                winner.student!.profileImage!.isNotEmpty)
            ||
            (winner.profileImage.isNotEmpty)
        ? Image.network(
            winner.student?.profileImage ??
                winner.profileImage,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Center(
                child: CustomText(
                  text: firstChar,
                  size: 22,
                  weight: FontWeight.w900,
                  color: const Color(0xFFFFD700),
                ),
              );
            },
          )
        : Center(
            child: CustomText(
              text: firstChar,
              size: 22,
              weight: FontWeight.w900,
              color: const Color(0xFFFFD700),
            ),
          ),
  ),
),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: name.isNotEmpty ? name : 'Unknown',
                size: 15,
                weight: FontWeight.w700,
                color: Colors.black87,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              CustomText(
                text: '${winner.prize ?? 'Gold Medal'}  ·  Score: ${winner.score ?? 0}',
                size: 12,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 30),
      ],
    );
  }
}

/// PODIUM ITEM

class _PodiumItem extends StatelessWidget {
  final String name;
  final double blockHeight;
  final Color color;
  final int rank;
  final double? score;

  const _PodiumItem({
    required this.name,
    required this.blockHeight,
    required this.color,
    required this.rank,
    this.score,
  });

  @override
  Widget build(BuildContext context) {
    final firstChar =
        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: CustomText(
              text: '$rank',
              size: 12,
              weight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),

        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
            border: Border.all(color: color, width: 2.5),
          ),
          child: Center(
            child: CustomText(
              text: firstChar,
              size: 20,
              weight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 6),

        CustomText(
          text: name,
          size: 11,
          weight: FontWeight.w700,
          color: Colors.black87,
          align: TextAlign.center,
          maxLines: 1,
        ),
        const SizedBox(height: 2),

        CustomText(
          text: 'Score: ${score ?? 0}',
          size: 10,
          color: Colors.black45,
        ),
        const SizedBox(height: 6),

        Container(
          height: blockHeight,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: color, width: 1.5),
          ),
        ),
      ],
    );
  }
}