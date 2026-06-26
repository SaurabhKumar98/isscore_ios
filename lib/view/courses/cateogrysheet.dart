import 'package:firstedu/data/models/api_models/resourcestore/Categorymodels.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategorySheet extends StatelessWidget {
  final List<CategoryModel> currentList;
  final List<String> breadcrumb;
  final CategoryModel? parentCat;
  final String? selectedCategoryId;
  final CategoryModel? selectedCategory;
  final void Function(CategoryModel) onDrillDown;
  final void Function(CategoryModel) onSelect;
  final VoidCallback onClear;
  final VoidCallback? onSelectParent;

  const CategorySheet({
    required this.currentList,
    required this.breadcrumb,
    required this.parentCat,
    required this.selectedCategoryId,
    required this.selectedCategory,
    required this.onDrillDown,
    required this.onSelect,
    required this.onClear,
    this.onSelectParent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 36.w, height: 4.h,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r)),
          ),
          SizedBox(height: 16.h),

          /// HEADER
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: breadcrumb.length == 1 ? breadcrumb.first : breadcrumb.last,
                        size: 16, weight: FontWeight.w700, color: drawerColor,
                      ),
                      if (breadcrumb.length > 1)
                        CustomText(text: breadcrumb.join(" › "), size: 11, color: Colors.grey.shade500, maxLines: 1),
                    ],
                  ),
                ),
                if (onSelectParent != null)
                  _headerBtn("Select All", drawerColor.withOpacity(0.08), drawerColor, onSelectParent!),
                SizedBox(width: 8.w),
                if (selectedCategory != null)
                  _headerBtn("Clear", Colors.red.shade50, Colors.red, onClear),
              ],
            ),
          ),

          SizedBox(height: 12.h),
          Divider(height: 1, color: Colors.grey.shade100),

          /// LIST
          Flexible(
            child: currentList.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(40.w),
                    child: CustomText(text: "No subcategories available", size: 14, color: Colors.grey.shade500),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    itemCount: currentList.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                    itemBuilder: (context, index) {
                      final cat = currentList[index];
                      final isSelected = selectedCategoryId == cat.id;
                      return InkWell(
                        onTap: () => cat.hasChildren ? onDrillDown(cat) : onSelect(cat),
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                          decoration: BoxDecoration(
                            color: isSelected ? drawerColor.withOpacity(0.06) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8.w, height: 8.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? drawerColor : Colors.grey.shade300,
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: CustomText(
                                  text: cat.name, size: 14,
                                  weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? drawerColor : Colors.grey.shade800,
                                ),
                              ),
                              if (cat.hasChildren) ...[
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20.r)),
                                  child: CustomText(text: "${cat.children.length}", size: 11, color: Colors.grey.shade600, weight: FontWeight.w600),
                                ),
                                SizedBox(width: 6.w),
                                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20.sp),
                              ],
                              if (!cat.hasChildren && isSelected)
                                Icon(Icons.check_circle_rounded, color: drawerColor, size: 20.sp),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
        ],
      ),
    );
  }

  Widget _headerBtn(String label, Color bg, Color textColor, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8.r)),
          child: CustomText(text: label, size: 12, color: textColor, weight: FontWeight.w600),
        ),
      );
}