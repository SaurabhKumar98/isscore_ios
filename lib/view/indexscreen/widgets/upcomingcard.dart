import 'package:firstedu/data/models/api_models/dashboardmodels/dashboard_models.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UpcomingCard extends StatelessWidget {
  final List<UpcomingEvent> events;

  const UpcomingCard({super.key, this.events = const []});

  @override
  Widget build(BuildContext context) {
    final displayEvents = events;

    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: CustomText(
                  text: "Upcoming Events",
                  size: 16,
                  weight: FontWeight.w700,
                ),
              ),
              Icon(Icons.calendar_today_outlined,
                  size: 18, color: drawerColor),
            ],
          ),
          const SizedBox(height: 16),
          if (displayEvents.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: CustomText(
                  text: "No upcoming events.",
                  size: 13,
                  color: Colors.grey,
                ),
              ),
            )
          else
            ...displayEvents.take(4).map((e) => _eventRow(e)).toList(),
        ],
      ),
    );
  }

  Widget _eventRow(UpcomingEvent event) {
    final color = _typeColor(event.type);
    final icon = _typeIcon(event.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: event.title,
                  size: 13,
                  weight: FontWeight.w600,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        _typeLabel(event.type),
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          CustomText(
            text: _formatDate(event.date),
            size: 11,
            color: Colors.grey.shade500,
          ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month]}';
    } catch (_) {
      return raw.length > 10 ? raw.substring(0, 10) : raw;
    }
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'tournament':
        return Colors.purple;
      case 'olympiad':
        return Colors.blue;
      case 'test':
        return primaryButtonColor;
      case 'everyday_challenge':
      case 'challenge':
        return Colors.green;
      default:
        return drawerColor;
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'tournament':
        return Icons.emoji_events_outlined;
      case 'olympiad':
        return Icons.science_outlined;
      case 'test':
        return Icons.description_outlined;
      case 'everyday_challenge':
      case 'challenge':
        return Icons.flash_on_outlined;
      default:
        return Icons.event_outlined;
    }
  }

  String _typeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'tournament':
        return 'TOURNAMENT';
      case 'olympiad':
        return 'OLYMPIAD';
      case 'test':
        return 'TEST';
      case 'everyday_challenge':
        return 'DAILY';
      case 'challenge':
        return 'CHALLENGE';
      default:
        return type.toUpperCase();
    }
  }

  // List<UpcomingEvent> get _fallbackEvents => [
  //       UpcomingEvent(
  //           id: '1',
  //           title: 'JEE Mains Mock Test',
  //           type: 'test',
  //           date: '2025-12-20'),
  //       UpcomingEvent(
  //           id: '2',
  //           title: 'National Science Olympiad',
  //           type: 'olympiad',
  //           date: '2025-12-25'),
  //       UpcomingEvent(
  //           id: '3',
  //           title: 'Winter Tournament',
  //           type: 'tournament',
  //           date: '2026-01-05'),
  //     ];
}