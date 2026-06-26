import 'package:firstedu/data/models/api_models/coursedownload/coursedownloadallmodels.dart';
import 'package:firstedu/data/models/api_models/resourcestore/Categorymodels.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/routes/approutesname.dart';
import 'package:firstedu/res/widgets/custom_filter_chips.dart';
import 'package:firstedu/res/widgets/custom_silverappbar.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/res/widgets/customheadercard.dart';
import 'package:firstedu/view/courses/cateogrysheet.dart';
import 'package:firstedu/view/courses/coursepaymentsheet.dart';
import 'package:firstedu/view_models/coursedownloadprovider/coursedownloadprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final isCertification =
          ModalRoute.of(context)?.settings.arguments as bool?;

      final provider = context.read<CourseDownloadProvider>();

      provider.setCertification(context, isCertification);

      provider.fetchCategories(isCertification: isCertification);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: RefreshIndicator(
        onRefresh: () {
          final isCertification =
              ModalRoute.of(context)?.settings.arguments as bool?;
          final provider = context.read<CourseDownloadProvider>();
          return provider.fetchCategories(isCertification: isCertification);
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            const CustomSliverAppBar(
              title: "Courses",
              subtitle:
                  "Premium courses in PDF, Video & Audio. Browse, purchase and learn.",
              showBack: true,
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(9.w),
                child: const BubbleHeaderCard(
                  title: "Courses",
                  subtitle:
                      "Premium courses in PDF, Video & Audio. Browse, purchase, and learn.",
                  icon: Icons.auto_awesome,
                  backgroundColor: drawerColor,
                  iconColor: Colors.white,
                ),
              ),
            ),

            /// FILTERS
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Consumer<CourseDownloadProvider>(
                  builder: (context, provider, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),

                        /// TYPE
                        const CustomText(
                          text: "TYPE",
                          size: 14,
                          weight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 10.h),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              CustomFilterChip(
                                label: "All",
                                selected: provider.selectedType == null,
                                onTap: () => provider.setType(context, null),
                              ),
                              SizedBox(width: 10.w),
                              CustomFilterChip(
                                label: "PDF",
                                selected: provider.selectedType == "pdf",
                                onTap: () => provider.setType(context, "pdf"),
                              ),
                              SizedBox(width: 10.w),
                              CustomFilterChip(
                                label: "Video",
                                selected: provider.selectedType == "video",
                                onTap: () => provider.setType(context, "video"),
                              ),
                              SizedBox(width: 10.w),
                              CustomFilterChip(
                                label: "Audio",
                                selected: provider.selectedType == "audio",
                                onTap: () => provider.setType(context, "audio"),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16.h),

                        /// ACCESS
                        const CustomText(
                          text: "ACCESS",
                          size: 14,
                          weight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 10.h),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              CustomFilterChip(
                                label: "All",
                                selected: provider.selectedAccess == "both",
                                onTap: () =>
                                    provider.setAccess(context, "both"),
                              ),
                              SizedBox(width: 10.w),
                              CustomFilterChip(
                                label: "Free",
                                selected: provider.selectedAccess == "free",
                                onTap: () =>
                                    provider.setAccess(context, "free"),
                              ),
                              SizedBox(width: 10.w),
                              CustomFilterChip(
                                label: "Paid",
                                selected: provider.selectedAccess == "paid",
                                onTap: () =>
                                    provider.setAccess(context, "paid"),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16.h),

                        /// CATEGORY ROW
                        Row(
                          children: [
                            const CustomText(
                              text: "CATEGORY",
                              size: 14,
                              weight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            const Spacer(),
                            if (provider.selectedCategory != null)
                              GestureDetector(
                                onTap: () => provider.clearCategory(context),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: const CustomText(
                                    text: "Clear",
                                    size: 12,
                                    color: Colors.red,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 10.h),

                        /// CATEGORY CHIP BUTTON
                        GestureDetector(
                          onTap: () => _openCategorySheet(context, provider),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: provider.selectedCategory != null
                                  ? drawerColor.withOpacity(0.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: provider.selectedCategory != null
                                    ? drawerColor
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.category_outlined,
                                  size: 16.sp,
                                  color: provider.selectedCategory != null
                                      ? drawerColor
                                      : Colors.grey,
                                ),
                                SizedBox(width: 8.w),
                                CustomText(
                                  text:
                                      provider.selectedCategory?.name ??
                                      "Select Category",
                                  size: 13,
                                  color: provider.selectedCategory != null
                                      ? drawerColor
                                      : Colors.grey,
                                  weight: FontWeight.w500,
                                ),
                                SizedBox(width: 8.w),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18.sp,
                                  color: provider.selectedCategory != null
                                      ? drawerColor
                                      : Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 20.h),
                      ],
                    );
                  },
                ),
              ),
            ),

            /// COURSE LIST
            Consumer<CourseDownloadProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (provider.items.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Text("No courses found")),
                  );
                }
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: _courseCard(context, provider.items[index]),
                      ),
                      childCount: provider.items.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── OPEN CATEGORY SHEET ──────────────────────────────────────────

  void _openCategorySheet(
    BuildContext context,
    CourseDownloadProvider provider,
  ) {
    // Start from root
    _drillInto(context, provider, provider.categories, [], null);
  }

  void _drillInto(
    BuildContext context,
    CourseDownloadProvider provider,
    List<CategoryModel> list,
    List<String> breadcrumb,
    CategoryModel? parent,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategorySheet(
        currentList: list,
        breadcrumb: breadcrumb.isEmpty ? ["Select Category"] : breadcrumb,
        parentCat: parent,
        selectedCategoryId: provider.selectedCategoryId,
        selectedCategory: provider.selectedCategory,
        onDrillDown: (cat) {
          Navigator.pop(context);
          _drillInto(context, provider, cat.children, [
            ...breadcrumb,
            cat.name,
          ], cat);
        },
        onSelect: (cat) {
          Navigator.pop(context);
          provider.selectCategory(context, cat);
        },
        onClear: () {
          Navigator.pop(context);
          provider.clearCategory(context);
        },
        onSelectParent: parent != null
            ? () {
                Navigator.pop(context);
                provider.selectCategory(context, parent);
              }
            : null,
      ),
    );
  }

  // ── COURSE CARD ──────────────────────────────────────────────────

  Widget _courseCard(BuildContext context, CourseData course) {
    final title = course.title ?? 'Course';
    final type = course.contentType ?? 'course';
    final price = (course.price ?? 0).toDouble();
    final originalPrice = (course.originalPrice ?? 0).toDouble();
    final discountedPrice = (course.discountedPrice ?? 0).toDouble();
    final isFree = (course.effectivePrice ?? 0) == 0;
    final hasDiscount =
        originalPrice > 0 &&
        discountedPrice > 0 &&
        originalPrice > discountedPrice;
    final discountPercent = hasDiscount
        ? ((originalPrice - discountedPrice) / originalPrice) * 100
        : 0.0;
    final isPurchased = course.isPurchased ?? false;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutesName.coursedetail,
        arguments: course.id,
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: const Border(
            left: BorderSide(color: Colors.deepOrange, width: 6),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                type.toUpperCase(),
                style: const TextStyle(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              course.description ?? 'Important topics',
              style: const TextStyle(color: Colors.grey),
            ),

            if (course.categoryPath.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: course.categoryPath
                    .map(
                      (path) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          path,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],

            const Divider(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFree
                          ? 'FREE'
                          : '₹${(hasDiscount ? discountedPrice : price).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isFree ? Colors.green : Colors.black,
                      ),
                    ),
                    if (hasDiscount)
                      Row(
                        children: [
                          Text(
                            '₹${originalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '-${discountPercent.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                isPurchased
                    ? Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Purchased',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () =>
                            showCoursePaymentSheet(context, course: course),
                        icon: Icon(
                          isFree ? Icons.download_rounded : Icons.shopping_bag,
                        ),
                        label: Text(isFree ? 'Get Free' : 'Buy Now'),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
