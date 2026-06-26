import 'package:firstedu/data/models/event_models.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_button.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/res/widgets/statusbar.dart';
import 'package:firstedu/view/event_view/eventsubmissionscreen.dart';
import 'package:flutter/material.dart';

class EventCard extends StatefulWidget {
  final EventModel data;
  final VoidCallback? onParticipate;

  const EventCard({super.key, required this.data, this.onParticipate});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard>
    with SingleTickerProviderStateMixin {

  bool joined = false;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: .95,
      upperBound: 1,
      value: 1,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onTap() {
    if (!joined) {
      setState(() => joined = true);
      widget.onParticipate?.call();
    }
  }

  Color get buttonColor =>
      joined
          ? (widget.data.status == "LIVE" ? accentOrange : successColor)
          : drawerColor;

  String get buttonText =>
      joined
          ? (widget.data.status == "LIVE" ? "Join Live" : "Registered")
          : "Participate Now";

  @override
  Widget build(BuildContext context) {

    final data = widget.data;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HEADER
            Row(
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: data.iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(data.icon, color: drawerColor),
                ),
                const Spacer(),
                StatusBadge(status: data.status),
              ],
            ),

            const SizedBox(height: 12),

            CustomText(
              text: data.title,
              size: 18,
              weight: FontWeight.w600,
              color: drawerColor,
            ),

            const SizedBox(height: 6),

            CustomText(
              text: data.description,
              size: 13,
              color: Colors.black54,
              maxLines: 3,
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              children: [
                _InfoChip(Icons.group, "${data.participants} Participating"),
                _InfoChip(Icons.calendar_today, data.date),
              ],
            ),

            const SizedBox(height: 14),

            ScaleTransition(
              scale: controller,
              child: GestureDetector(
                onTapDown: (_) => controller.reverse(),
                onTapUp: (_) {
                  controller.forward();
                  onTap();
                },
                onTapCancel: () => controller.forward(),
                child: CustomButton(
                  title: buttonText,
                  backgroundColor: buttonColor,
                  textColor: Colors.white,
                  onTap: () {
                     Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventSubmissionScreen(event: data),
      ),
    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.black54),
          const SizedBox(width: 4),
          CustomText(text: label, size: 12, color: Colors.black54),
        ],
      ),
    );
  }
}
