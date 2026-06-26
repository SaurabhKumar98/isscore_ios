import 'package:firstedu/data/models/api_models/examhall/examhall_models.dart';
import 'package:firstedu/data/models/api_models/resourcestore/Categorymodels.dart';
import 'package:firstedu/data/repo/examhall/examhall_repositories.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_button.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_filter_chips.dart';
import 'package:firstedu/res/widgets/custom_silverappbar.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/bundelsdetailsscreen.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/examinstructionscreen.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/questionscreen.dart';
import 'package:firstedu/view_models/examhallprovider/examhallprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ExamHallScreen extends StatefulWidget {
  const ExamHallScreen({super.key});

  @override
  State<ExamHallScreen> createState() => _ExamHallScreenState();
}

class _ExamHallScreenState extends State<ExamHallScreen> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();

  static const _typeFilters = [
    _TypeChip(value: 'all', label: 'All'),
    _TypeChip(value: 'test', label: 'Test'),
    _TypeChip(value: 'testBundle', label: 'Test Bundle'),
    _TypeChip(value: 'olympiad', label: 'Olympiad'),
    _TypeChip(value: 'tournament', label: 'Tournaments'),
  ];

  @override
  void initState() {
    super.initState();
     WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExamHallProvider>().init(context);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final p = context.read<ExamHallProvider>();
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        p.hasMore &&
        !p.isPaginationLoading) {
      p.loadMore(context);
    }
  }

  @override
  void dispose() {
     WidgetsBinding.instance.removeObserver(this); 
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh when app comes back to foreground
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<ExamHallProvider>().fetchItems(context);
    }
  }

Future<void> _navigateAndRefresh(Widget screen) async {
  // ✅ Do NOT clear before push — causes ugly flash and can break await chain
  await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  if (!mounted) return;

  // ✅ Clear + fetch only AFTER returning
  context.read<ExamHallProvider>().clearItems();
  await context.read<ExamHallProvider>().fetchItems(context);
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: RefreshIndicator(
          onRefresh: () => context.read<ExamHallProvider>().fetchItems(context),
        child: CustomScrollView(
           physics: const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    ),
          controller: _scrollController,
          slivers: [
            const CustomSliverAppBar(
              title: "Exam Hall",
              subtitle: "Your purchased and enrolled tests.",
              showBack: false,
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 120.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SizedBox(height: 20.h),
                  _buildTypeFilters(),
                  SizedBox(height: 20.h),
                  _buildCategoryButton(),
                  SizedBox(height: 20.h),
                  _buildCards(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeFilters() {
    return Consumer<ExamHallProvider>(
      builder: (context, provider, _) {
        return SizedBox(
          height: 42.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _typeFilters.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final chip = _typeFilters[index];
              return CustomFilterChip(
                label: chip.label,
                selected: provider.selectedType == chip.value,
                onTap: () => provider.setType(context, chip.value),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryButton() {
    return Consumer<ExamHallProvider>(
      builder: (context, provider, _) {
        return Row(
          children: [
            GestureDetector(
              onTap: () =>
                  _openCategorySheet(context, provider, provider.categories),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
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
                          provider.selectedCategory?.name ?? "Select Category",
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
            if (provider.selectedCategory != null) ...[
              SizedBox(width: 10.w),
              GestureDetector(
                onTap: () {
                  provider.selectCategory(
                    context,
                    provider.selectedCategory!,
                  ); // toggles off
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: CustomText(
                    text: "Clear",
                    size: 12,
                    color: Colors.red,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _openCategorySheet(
    BuildContext context,
    ExamHallProvider provider,
    List<CategoryModel> list, {
    List<String> breadcrumb = const [],
    CategoryModel? parentCat,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExamCategorySheet(
        currentList: list,
        breadcrumb: breadcrumb.isEmpty ? ["Select Category"] : breadcrumb,
        parentCat: parentCat,
        selectedCategoryId: provider.selectedCategory?.id,
        selectedCategory: provider.selectedCategory,
        onDrillDown: (cat) {
          Navigator.pop(context);
          _openCategorySheet(
            context,
            provider,
            cat.children,
            breadcrumb: [...breadcrumb, cat.name],
            parentCat: cat,
          );
        },
        onSelect: (cat) {
          Navigator.pop(context);
          provider.selectCategory(context, cat);
        },
        onClear: () {
          Navigator.pop(context);
          if (provider.selectedCategory != null) {
            provider.selectCategory(context, provider.selectedCategory!);
          }
        },
        onSelectParent: parentCat != null
            ? () {
                Navigator.pop(context);
                provider.selectCategory(context, parentCat);
              }
            : null,
      ),
    );
  }
  //   Widget _buildCategoryFilters() {
  //     return Consumer<ExamHallProvider>(
  //       builder: (context, provider, _) {
  //         if (provider.isCategoryLoading) {
  //           return Column(
  //             children: [
  //               SizedBox(height: 12.h),
  //               SizedBox(
  //                 height: 38.h,
  //                 child: ListView.separated(
  //                   scrollDirection: Axis.horizontal,
  //                   itemCount: 4,
  //                   separatorBuilder: (_, __) => SizedBox(width: 8.w),
  //                   itemBuilder: (_, __) => Container(
  //                     width: 90.w,
  //                     height: 36.h,
  //                     decoration: BoxDecoration(
  //                       color: Colors.grey.shade200,
  //                       borderRadius: BorderRadius.circular(20.r),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           );
  //         }

  //         final cats = provider.visibleCategories
  //             .where((c) => c.isActive)
  //             .toList();
  //         if (cats.isEmpty) return const SizedBox.shrink();

  //         return Column(
  //           children: [
  //             SizedBox(height: 12.h),
  //             SizedBox(
  //               height: 38.h,
  //               child: ListView.separated(
  //                 scrollDirection: Axis.horizontal,
  //                 itemCount: cats.length,
  //                 separatorBuilder: (_, __) => SizedBox(width: 8.w),
  //                 itemBuilder: (context, index) {
  //                   final cat = cats[index];
  //                   final isSelected = provider.selectedCategory?.id == cat.id;
  //                   return CustomFilterChip(
  //                     label: cat.name,
  //                     selected: isSelected,
  //                   onTap: () {
  //   if (cat.hasChildren) {
  //     _openCategorySheet(
  //       context,
  //       provider,
  //       cat.children,
  //       parentCategory: cat, // ✅ pass parent here
  //     );
  //   } else {
  //     provider.selectCategory(context, cat);
  //   }
  // },
  //                   );
  //                 },
  //               ),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }

  Widget _buildCards() {
    return Consumer<ExamHallProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Column(
            children: List.generate(
              3,
              (_) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Container(
                  height: 220.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
              ),
            ),
          );
        }

        if (provider.errorMessage.isNotEmpty && provider.items.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 60.h),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60.sp,
                    color: Colors.red.shade300,
                  ),
                  SizedBox(height: 16.h),
                  CustomText(
                    text: provider.errorMessage,
                    size: 14,
                    color: Colors.grey.shade600,
                    align: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  CustomButton(
                    title: "Retry",
                    onTap: () => provider.init(context),
                    backgroundColor: drawerColor,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.items.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 60.h),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 60.sp,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16.h),
                  CustomText(
                    text: "No exams found",
                    size: 16,
                    weight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(height: 8.h),
                  CustomText(
                    text: "Try a different filter or check back later.",
                    size: 13,
                    color: Colors.grey.shade400,
                    align: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            ...provider.items.asMap().entries.map(
              (e) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _examCard(context, e.value),
              ),
            ),
            if (provider.isPaginationLoading) ...[
              SizedBox(height: 8.h),
              const Center(child: CircularProgressIndicator()),
              SizedBox(height: 16.h),
            ],
            if (!provider.hasMore && provider.items.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
                child: Center(
                  child: CustomText(
                    text: "You've reached the end",
                    size: 13,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // void _openCategorySheet(
  //   BuildContext context,
  //   ExamHallProvider provider,
  //   List<CategoryModel> children, {
  //   CategoryModel? parentCategory, // pass the parent so we can add "All" option
  // }) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (_) {
  //       return Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Container(
  //               width: 40,
  //               height: 4,
  //               decoration: BoxDecoration(
  //                 color: Colors.grey.shade300,
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //             ),
  //             const SizedBox(height: 12),
  //             Text(
  //               parentCategory != null
  //                   ? "Select in '${parentCategory.name}'"
  //                   : "Select Category",
  //               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  //             ),
  //             const SizedBox(height: 10),
  //             Flexible(
  //               child: ListView(
  //                 shrinkWrap: true,
  //                 children: [
  //                   // ✅ "All [ParentName]" option — filters by parent category
  //                   if (parentCategory != null) ...[
  //                     ListTile(
  //                       contentPadding: EdgeInsets.zero,
  //                       title: Text(
  //                         "All ${parentCategory.name}",
  //                         style: const TextStyle(fontWeight: FontWeight.w500),
  //                       ),
  //                       trailing: provider.selectedCategory?.id == parentCategory.id
  //                           ? const Icon(Icons.check, color: Colors.green)
  //                           : null,
  //                       onTap: () {
  //                         Navigator.pop(context);
  //                         provider.selectCategory(context, parentCategory);
  //                       },
  //                     ),
  //                     Divider(height: 1, color: Colors.grey.shade200),
  //                   ],

  //                   // Children list
  //                   ...List.generate(children.length, (index) {
  //                     final cat = children[index];
  //                     return Column(
  //                       children: [
  //                         ListTile(
  //                           contentPadding: EdgeInsets.zero,
  //                           title: Text(cat.name),
  //                           trailing: cat.hasChildren
  //                               ? const Icon(Icons.chevron_right, size: 18)
  //                               : provider.selectedCategory?.id == cat.id
  //                                   ? const Icon(Icons.check, color: Colors.green)
  //                                   : null,
  //                           onTap: () {
  //                             if (cat.hasChildren) {
  //                               Navigator.pop(context);
  //                               // ✅ Pass current cat as parentCategory for the next level
  //                               _openCategorySheet(
  //                                 context,
  //                                 provider,
  //                                 cat.children,
  //                                 parentCategory: cat,
  //                               );
  //                             } else {
  //                               Navigator.pop(context);
  //                               provider.selectCategory(context, cat);
  //                             }
  //                           },
  //                         ),
  //                         if (index < children.length - 1)
  //                           Divider(height: 1, color: Colors.grey.shade200),
  //                       ],
  //                     );
  //                   }),
  //                 ],
  //               ),
  //             ),
  //             const SizedBox(height: 10),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _examCard(BuildContext context, ExamHallItem item) {
    final bool isBundle = item.type == 'testBundle';
    final String title = isBundle
        ? (item.testBundle?.name ?? 'Untitled Bundle')
        : (item.test?.title ?? 'Untitled Test');
    final String tag = isBundle ? 'Test Bundle' : 'Test';
    final Color tagColor = isBundle ? Colors.indigo : drawerColor;
    final int testCount =
        item.tests?.length ?? item.testBundle?.tests?.length ?? 0;

    final _ButtonConfig btnCfg = isBundle
        ? _ButtonConfig(
            text: 'View Bundle',
            color: Colors.indigo,
            icon: Icons.collections_bookmark_outlined,
          )
        : _buttonConfig(item);

    return CustomCard(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: CustomText(
                  text: tag,
                  size: 12,
                  weight: FontWeight.w600,
                  color: tagColor,
                ),
              ),
              if (!isBundle) _statusBadge(item),
            ],
          ),
          SizedBox(height: 16.h),
CustomText(
  text: title,
  size: 18,
  weight: FontWeight.w600,
  maxLines: 3,
),

if (!isBundle &&
    item.test?.categoryPath != null &&
    item.test!.categoryPath!.isNotEmpty) ...[
  SizedBox(height: 6.h),
  Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        Icons.account_tree_outlined,
        size: 14.sp,
        color: Colors.grey.shade600,
      ),
      SizedBox(width: 4.w),
      Expanded(
        child: CustomText(
          text: item.test!.categoryPath!,
          size: 12,
          color: Colors.grey.shade600,
          maxLines: 2,
        ),
      ),
    ],
  ),
],
          if (isBundle && testCount > 0) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.layers_outlined,
                  size: 14.sp,
                  color: Colors.grey.shade500,
                ),
                SizedBox(width: 4.w),
                CustomText(
                  text: "$testCount tests inside",
                  size: 12,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ],
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: "Purchased",
                size: 13,
                color: Colors.grey.shade600,
              ),
              CustomText(
                text: item.purchaseDate != null
                    ? _formatDate(item.purchaseDate!)
                    : '—',
                size: 13,
                weight: FontWeight.w600,
              ),
            ],
          ),
          SizedBox(height: 6.h),
          LinearProgressIndicator(
            value: item.isCompleted
                ? 1.0
                : item.isInProgress
                ? 0.5
                : 0.0,
            backgroundColor: Colors.grey.shade200,
            color: item.isCompleted ? successColor : accentOrange,
            minHeight: 6.h,
            borderRadius: BorderRadius.circular(6.r),
          ),
          SizedBox(height: 20.h),
          CustomButton(
            title: btnCfg.text,
            onTap: () => _onAction(context, item),
            backgroundColor: btnCfg.color,
            textColor: Colors.white,
            icon: btnCfg.icon,
          ),
        ],
      ),
    );
  }

  _ButtonConfig _buttonConfig(ExamHallItem item) {
    if (item.isCompleted) {
      return _ButtonConfig(
        text: 'View Results',
        color: successColor,
        icon: Icons.bar_chart_rounded,
      );
    } else if (item.isInProgress) {
      return _ButtonConfig(
        text: 'Resume Exam',
        color: accentOrange,
        icon: Icons.play_arrow_rounded,
      );
    } else {
      return _ButtonConfig(
        text: 'Start Exam',
        color: drawerColor,
        icon: Icons.play_circle_outline_rounded,
      );
    }
  }

  Widget _statusBadge(ExamHallItem item) {
    if (item.isCompleted) {
      return _badge('Completed', successColor, Icons.check_circle_rounded);
    } else if (item.isInProgress) {
      return _badge('In Progress', accentOrange, Icons.pending_rounded);
    } else {
      return _badge(
        'Not Started',
        Colors.grey,
        Icons.radio_button_unchecked_rounded,
      );
    }
  }

  Widget _badge(String label, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          CustomText(
            text: label,
            size: 11,
            weight: FontWeight.w600,
            color: color,
          ),
        ],
      ),
    );
  }

 // ✅ Change void → Future<void> so _navigateAndRefresh is properly awaited
Future<void> _onAction(BuildContext context, ExamHallItem item) async {
  if (item.type == 'testBundle') {
    await _navigateAndRefresh(BundleDetailScreen(bundleItem: item));
    return;
  }

  context.read<ExamSessionProvider>().reset();

  if (item.isCompleted && item.examSessionId != null) {
    await _navigateAndRefresh(ExamResultsScreen(sessionId: item.examSessionId!));
    return;
  }

  if (item.isInProgress) {
    await _navigateAndRefresh(
      ExamScreen(
        testId: item.test?.id ?? '',
        examTitle: item.test?.title ?? 'Exam',
        existingSessionId: null,
        showPauseButton: true,
      ),
    );
    return;
  }

  await _navigateAndRefresh(
    ExamInstructionsScreen(
      testId: item.test?.id ?? '',
      examTitle: item.test?.title ?? 'Exam',
      isBundleTest: false,
    ),
  );
}
  String _formatDate(DateTime date) => "${date.day}/${date.month}/${date.year}";
}

class _ButtonConfig {
  final String text;
  final Color color;
  final IconData icon;
  const _ButtonConfig({
    required this.text,
    required this.color,
    required this.icon,
  });
}

class _TypeChip {
  final String value;
  final String label;
  const _TypeChip({required this.value, required this.label});
}

class _ExamCategorySheet extends StatelessWidget {
  final List<CategoryModel> currentList;
  final List<String> breadcrumb;
  final CategoryModel? parentCat;
  final String? selectedCategoryId;
  final CategoryModel? selectedCategory;
  final void Function(CategoryModel) onDrillDown;
  final void Function(CategoryModel) onSelect;
  final VoidCallback onClear;
  final VoidCallback? onSelectParent;

  const _ExamCategorySheet({
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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),

          // ── HEADER ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: breadcrumb.length == 1
                            ? breadcrumb.first
                            : breadcrumb.last,
                        size: 16,
                        weight: FontWeight.w700,
                        color: drawerColor,
                      ),
                      if (breadcrumb.length > 1)
                        CustomText(
                          text: breadcrumb.join(" › "),
                          size: 11,
                          color: Colors.grey.shade500,
                          maxLines: 1,
                        ),
                    ],
                  ),
                ),
                if (onSelectParent != null)
                  _headerBtn(
                    "Select All",
                    drawerColor.withOpacity(0.08),
                    drawerColor,
                    onSelectParent!,
                  ),
                SizedBox(width: 8.w),
                if (selectedCategory != null)
                  _headerBtn("Clear", Colors.red.shade50, Colors.red, onClear),
              ],
            ),
          ),

          SizedBox(height: 12.h),
          Divider(height: 1, color: Colors.grey.shade100),

          // ── LIST ──
          Flexible(
            child: currentList.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(40.w),
                    child: CustomText(
                      text: "No subcategories available",
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    itemCount: currentList.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey.shade100),
                    itemBuilder: (context, index) {
                      final cat = currentList[index];
                      final isSelected = selectedCategoryId == cat.id;
                      return InkWell(
                        onTap: () =>
                            cat.hasChildren ? onDrillDown(cat) : onSelect(cat),
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? drawerColor.withOpacity(0.06)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8.w,
                                height: 8.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? drawerColor
                                      : Colors.grey.shade300,
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: CustomText(
                                  text: cat.name,
                                  size: 14,
                                  weight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? drawerColor
                                      : Colors.grey.shade800,
                                ),
                              ),
                              if (cat.hasChildren) ...[
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: CustomText(
                                    text: "${cat.children.length}",
                                    size: 11,
                                    color: Colors.grey.shade600,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.grey.shade400,
                                  size: 20.sp,
                                ),
                              ],
                              if (!cat.hasChildren && isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: drawerColor,
                                  size: 20.sp,
                                ),
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

  Widget _headerBtn(
    String label,
    Color bg,
    Color textColor,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: CustomText(
        text: label,
        size: 12,
        color: textColor,
        weight: FontWeight.w600,
      ),
    ),
  );
}
