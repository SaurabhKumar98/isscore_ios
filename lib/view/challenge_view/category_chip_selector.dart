
import 'package:firstedu/data/models/api_models/challengeyourself/challengeyourself_models.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/view_models/challengeyourselfprovider/challengeyourself_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// ═══════════════════════════════════════════════════════════════════════════

class CategoryChipSelector extends StatelessWidget {
  const CategoryChipSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengeYourselfProvider>(
      builder: (context, provider, _) {
        final parents = provider.categories;
        if (parents.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 40.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: parents.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final parent = parents[index];
              final isSelected =
                  provider.selectedParentCategoryId == parent.id;
              final hasChildren = parent.children.isNotEmpty;

              return GestureDetector(
                onTap: () {
                  if (hasChildren) {
                    _openSubjectSheet(context, provider, parent);
                  } else {
                    provider.selectParentCategory(context, parent.id ?? '');
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1A1A2E)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1A1A2E)
                          : Colors.grey.shade300,
                      width: 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF1A1A2E).withOpacity(0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            )
                          ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _classEmoji(parent.name ?? ''),
                        style: TextStyle(fontSize: 13.sp),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        parent.name ?? '',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1A1A2E),
                        ),
                      ),
                      if (hasChildren) ...[
                        SizedBox(width: 2.w),
                        AnimatedRotation(
                          turns: isSelected ? 0.5 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 15.sp,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _openSubjectSheet(
    BuildContext context,
    ChallengeYourselfProvider provider,
    CategoryNode parent,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SubjectSheet(
        parent: parent,
        provider: provider,
        onSelect: (child) {
          Navigator.pop(context);
          // Mark the parent as selected too so the chip highlights
          provider.selectParentAndChild(context, parent.id ?? '', child.id ?? '');
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUBJECT BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════

class _SubjectSheet extends StatelessWidget {
  final CategoryNode parent;
  final ChallengeYourselfProvider provider;
  final void Function(CategoryNode) onSelect;

  const _SubjectSheet({
    required this.parent,
    required this.provider,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final children = parent.children;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w,
          MediaQuery.of(context).padding.bottom + 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          // Drag handle
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: activeItemColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  _classEmoji(parent.name ?? ''),
                  style: TextStyle(fontSize: 18.sp),
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parent.name ?? '',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  Text(
                    'Select a subject to continue',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 20.h),
          Divider(color: Colors.grey.shade100, height: 1),
          SizedBox(height: 16.h),

          // Subject chips / cards
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: children.map((child) {
              final isSelected = provider.selectedCategoryId == child.id;
              return GestureDetector(
                onTap: () => onSelect(child),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeItemColor
                        : const Color(0xFFF4F5F9),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isSelected
                          ? activeItemColor
                          : Colors.grey.shade200,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: activeItemColor.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _subjectEmoji(child.name ?? ''),
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        child.name ?? '',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1A1A2E),
                        ),
                      ),
                      if (isSelected) ...[
                        SizedBox(width: 6.w),
                        Icon(Icons.check_circle_rounded,
                            size: 14.sp, color: Colors.white),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── helpers ─────────────────────────────────────────────────────────────────

String _classEmoji(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('10')) return '🔟';
  if (lower.contains('1')) return '1️⃣';
  if (lower.contains('2')) return '2️⃣';
  if (lower.contains('3')) return '3️⃣';
  if (lower.contains('4')) return '4️⃣';
  if (lower.contains('5')) return '5️⃣';
  if (lower.contains('6')) return '6️⃣';
  if (lower.contains('7')) return '7️⃣';
  if (lower.contains('8')) return '8️⃣';
  if (lower.contains('9')) return '9️⃣';
  return '📚';
}

String _subjectEmoji(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('math')) return '📐';
  if (lower.contains('bio')) return '🧬';
  if (lower.contains('science')) return '🔬';
  if (lower.contains('physics')) return '⚛️';
  if (lower.contains('chem')) return '🧪';
  if (lower.contains('english')) return '📖';
  if (lower.contains('history')) return '🏛️';
  if (lower.contains('geo')) return '🌍';
  if (lower.contains('hindi')) return '🇮🇳';
  return '📝';
}