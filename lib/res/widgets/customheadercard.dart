
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// DESIGN 5: BUBBLE PATTERN HEADER
class BubbleHeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;

  const BubbleHeaderCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? const Color(0xFFDC2626);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 120.h),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgColor, bgColor.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        // boxShadow: [
        //   BoxShadow(color: bgColor.withValues(0.3), blurRadius: 20.r, offset: Offset(0, 10.h)),
        // ],
      ),
      child: Stack(
        children: [
          // Bubbles
          Positioned(
            right: 20.w,
            top: 10.h,
            child: Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: -10.w,
            bottom: 20.h,
            child: Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            right: 60.w,
            bottom: -20.h,
            child: Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Container(
                  width: 70.w,
                  height: 70.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha:0.1), blurRadius: 10.r, offset: Offset(0, 5.h)),
                    ],
                  ),
                  child: Icon(icon, size: 35.sp, color: iconColor ?? Colors.amber),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(text: title, size: 20, weight: FontWeight.w700, color: Colors.white, maxLines: 1),
                      SizedBox(height: 6.h),
                      CustomText(text: subtitle, size: 12, color: Colors.white.withValues(alpha: 0.9), maxLines: 2, height: 1.3),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
