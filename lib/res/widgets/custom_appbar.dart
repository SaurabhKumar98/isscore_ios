import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:flutter/material.dart';
import 'custom_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final List<Widget>? actions;
  final bool useGradient;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.actions,
    this.useGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: useGradient
          ? const BoxDecoration(
              gradient: LinearGradient(
                colors: [drawerColor, Color(0xFF2A4494)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            )
          : const BoxDecoration(
              color: Color(0xFFF6F7FB),
            ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              /// BACK BUTTON
              if (showBack)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: useGradient
                          ? Colors.white.withOpacity(0.15)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: useGradient ? containerColor : drawerColor,
                      size: 22,
                    ),
                  ),
                ),

              if (showBack) const SizedBox(width: 16),

              /// TITLE & SUBTITLE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      text: title,
                      size: 20,
                      weight: FontWeight.w800,
                      color: useGradient ? containerColor : drawerColor,
                      maxLines: 1,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      CustomText(
                        text: subtitle!,
                        size: 13,
                        weight: FontWeight.w500,
                        color: useGradient
                            ? Colors.white70
                            : Colors.grey.shade600,
                        maxLines: 2,
                      ),
                    ],
                  ],
                ),
              ),

              /// ACTIONS
              if (actions != null) ...[
                const SizedBox(width: 12),
                ...actions!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 100 : 70);
}