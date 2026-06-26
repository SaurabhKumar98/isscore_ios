import 'package:flutter/material.dart';
import '../constants/colors/appcolors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color getColor() {
    switch (status.toUpperCase()) {

      case "LIVE":
        return Colors.red;

      case "REGISTRATION OPEN":
        return successColor;

      case "ONGOING":
        return activeItemColor;

      case "FINAL ROUND":
        return Colors.purple;

      case "UPCOMING":
        return successColor;

      case "CLOSED":
        return Colors.grey;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
