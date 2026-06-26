import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final bool primary;
  final bool enabled;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final IconData? icon;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.title,
    required this.onTap,
    this.primary = true,
    this.enabled = true,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg =
        backgroundColor ?? (primary ? drawerColor : Colors.white);

    final Color txt =
        textColor ?? (primary ? Colors.white : drawerColor);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: enabled ? onTap : null,
        child: Container(
          height: height ?? 44.h,
          width: width,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: enabled ? bg : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(12.r),
            border: primary
                ? null
                : Border.all(color: borderColor ?? drawerColor),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: width != null ? MainAxisSize.min : MainAxisSize.max,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18.sp, color: txt),
                SizedBox(width: 6.w),
              ],
              CustomText(
                text: title,
                size: 13,
                weight: FontWeight.w600,
                color: txt,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}