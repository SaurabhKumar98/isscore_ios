import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSliverAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool pinned;
  final bool showBack;

  const CustomSliverAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.pinned = false,
    this.showBack = true, // 👈 control back button
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      elevation: 0,
      backgroundColor: const Color(0xFFF6F7FB),
      automaticallyImplyLeading: false,
      pinned: pinned,

      // 👇 BACK BUTTON
      leading: showBack
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios, color: drawerColor),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            )
          : null,

      expandedHeight: subtitle != null ? 100.h : 65.h,
      toolbarHeight: subtitle != null ? 100.h : 65.h,

      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
  showBack ? 56.w : 16.w, // ✅ CORRECT PLACE
  12.h,
  16.w,
  12.h,
),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: title,
                  size: 20,
                  weight: FontWeight.w700,
                  color: drawerColor,
                  maxLines: 1,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 3.h),
                  Flexible(
                    child: CustomText(
                      text: subtitle!,
                      size: 12.5,
                      color: Colors.grey.shade600,
                      maxLines: 2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}