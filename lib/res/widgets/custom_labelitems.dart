import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:flutter/material.dart';

// ADD THIS CLASS ABOVE THE DashboardScreen class or at the end of the file:

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const LegendItem({
    super.key,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        CustomText(
          text: label,
          size: 11,
          weight: FontWeight.w600,
          color: Colors.black87,
        ),
        const SizedBox(width: 4),
        CustomText(
          text: value,
          size: 11,
          weight: FontWeight.w500,
          color: Colors.grey.shade600,
        ),
      ],
    );
  }
}
