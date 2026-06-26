import 'package:firstedu/data/models/api_models/resourcestore/Categorymodels.dart';
import 'package:firstedu/data/models/api_models/resourcestore/storemodels.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_button.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_filter_chips.dart';
import 'package:firstedu/res/widgets/custom_silverappbar.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/view/indexscreen/store_view/storepaymentsheet.dart';
import 'package:firstedu/view_models/resourcestoreprovider/resourcestoreprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _selectedTypeIndex = 0;

  final List<String> _filterLabels = [
    "All",
    "Test",
    "Bundle",
    // "Olympiad",
    // "Tournaments",
    // "School",
    // "Competitive",
    // "Skill Development",
    // "Challenges",
  ];

final List<String> _filterTypes = [
  'all',            // ✅ was 'both'
  'test',
  'testBundle',
  'olympiad',
  'tournament',
  'school',
  'competitive',
  'skill development',
  'challenges',
];

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  // ✅ Fixed: fetchCategories called after type is already set in provider
  void _loadData() {
    final provider = context.read<StoreProvider>();
   provider.fetchCategories(); 
    provider.fetchItems(context);
    _animController.reset();
    _animController.forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      body: Consumer<StoreProvider>(
        builder: (_, provider, __) {
          return RefreshIndicator(
              onRefresh: () async => _loadData(),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
              slivers: [
                const CustomSliverAppBar(
                  title: "Resource Store",
                  subtitle: "Premium tests & bundles for your success.",
                  pinned: false,
                  showBack: false,
                ),
            
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyFilterDelegate(
                    child: _buildFilterBar(provider),
                  ),
                ),
            
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 120.h),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (provider.selectedCategory != null)
                        _buildActiveCategoryBadge(provider),
            
                      if (!provider.isLoading && provider.items.isNotEmpty)
                        _buildStatsRow(provider),
            
                      if (provider.isLoading)
                        ...List.generate(3, (_) => _shimmerCard()),
            
                      if (!provider.isLoading && provider.items.isEmpty)
                        _emptyState(),
            
                      if (!provider.isLoading && provider.items.isNotEmpty)
                        ...provider.items.asMap().entries.map(
                              (e) => _animatedCard(e.value, e.key, provider),
                            ),
            
                      if (provider.isPaginationLoading)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: Center(
                            child: SizedBox(
                              width: 24.w,
                              height: 24.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: drawerColor,
                              ),
                            ),
                          ),
                        ),
            
                      if (provider.hasMore && !provider.isPaginationLoading)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: CustomButton(
                            title: "Load More",
                            onTap: () => provider.loadMore(context),
                            backgroundColor: drawerColor,
                            textColor: Colors.white,
                          ),
                        ),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  FILTER BAR
  // ─────────────────────────────────────────────────────────────────

  Widget _buildFilterBar(StoreProvider provider) {
    return Container(
      color: const Color(0xFFF4F5F9),
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Type chips row
          SizedBox(
            height: 40.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filterLabels.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                return CustomFilterChip(
                  label: _filterLabels[index],
                  selected: _selectedTypeIndex == index,
                  onTap: () {
                    setState(() => _selectedTypeIndex = index);
                    // ✅ setType now sets _selectedType BEFORE fetching
                    provider.setType(context, _filterTypes[index]);
                    _animController.reset();
                    _animController.forward();
                  },
                );
              },
            ),
          ),
          SizedBox(height: 8.h),
          // Category chips row
          _buildCategoryRow(provider),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  CATEGORY ROW  ✅ Fixed: uses expandable sheet
  // ─────────────────────────────────────────────────────────────────

  Widget _buildCategoryRow(StoreProvider provider) {
    if (provider.isCategoryLoading) {
      return SizedBox(
        height: 40.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (_, __) => Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: 70.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 40.h,
      child: provider.categories.isEmpty
          ? ListView(
              scrollDirection: Axis.horizontal,
              children: [
                CustomFilterChip(
                  label: "All",
                  selected: true,
                  onTap: () => provider.clearCategory(context),
                ),
              ],
            )
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: provider.categories.length + 1,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return CustomFilterChip(
                    label: "All",
                    selected: provider.selectedCategoryId == null,
                    onTap: () => provider.clearCategory(context),
                  );
                }
                final cat = provider.categories[index - 1];
                final isSelected = provider.selectedCategoryId == cat.id;
                return GestureDetector(
                  onTap: () {
                    if (cat.hasChildren) {
                      // ✅ Opens full expandable tree sheet
                      _openExpandableCategorySheet(context, provider, cat);
                    } else {
                      provider.selectCategory(context, cat);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? drawerColor : Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color:
                            isSelected ? drawerColor : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText(
                          text: cat.name,
                          size: 13,
                          weight: FontWeight.w500,
                          color: isSelected ? Colors.white : drawerColor,
                          maxLines: 1,
                        ),
                        if (cat.hasChildren) ...[
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 13.sp,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade400,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  EXPANDABLE CATEGORY SHEET LAUNCHER
  // ─────────────────────────────────────────────────────────────────

  void _openExpandableCategorySheet(
    BuildContext context,
    StoreProvider provider,
    CategoryModel rootCat,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ExpandableCategorySheet(
        rootCategory: rootCat,
        allRootCategories: provider.categories,
        provider: provider,
        onSelect: (cat) {
          Navigator.pop(context);
          provider.selectCategory(context, cat);
        },
        onClear: () {
          Navigator.pop(context);
          provider.clearCategory(context);
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  ACTIVE CATEGORY BADGE
  // ─────────────────────────────────────────────────────────────────

  Widget _buildActiveCategoryBadge(StoreProvider provider) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: CustomCard(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: drawerColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: drawerColor.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(Icons.filter_alt_rounded, size: 15.sp, color: drawerColor),
            SizedBox(width: 8.w),
            Expanded(
              child: CustomText(
                text: "Category: ${provider.selectedCategory!.name}",
                size: 12,
                color: drawerColor,
                weight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () => provider.clearCategory(context),
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.close_rounded,
                      size: 11.sp,
                      color: Colors.red.shade400,
                    ),
                    SizedBox(width: 3.w),
                    CustomText(
                      text: "Clear",
                      size: 11,
                      color: Colors.red.shade400,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  STATS ROW
  // ─────────────────────────────────────────────────────────────────

  Widget _buildStatsRow(StoreProvider provider) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 13.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(width: 5.w),
          CustomText(
            text: "${provider.totalItems} items available",
            size: 12,
            color: Colors.grey.shade400,
            weight: FontWeight.w500,
          ),
          const Spacer(),
          GestureDetector(
            onTap: _loadData,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  size: 14.sp,
                  color: Colors.grey.shade400,
                ),
                SizedBox(width: 4.w),
                CustomText(
                  text: "Refresh",
                  size: 12,
                  color: Colors.grey.shade400,
                  weight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  ANIMATED CARD WRAPPER
  // ─────────────────────────────────────────────────────────────────

  Widget _animatedCard(Item item, int index, StoreProvider provider) {
    final clampedIndex = index.clamp(0, 9);
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(clampedIndex * 0.07, 1.0, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position:
            Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
                .animate(
          CurvedAnimation(
            parent: _animController,
            curve: Interval(
              clampedIndex * 0.07,
              1.0,
              curve: Curves.easeOut,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: _productCard(item, provider),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  PRODUCT CARD
  // ─────────────────────────────────────────────────────────────────

Widget _productCard(Item item, StoreProvider provider) {
  final title = item.title ?? item.name ?? '';
  final subtitle = item.description;
  final isBundle = item.itemType == 'testBundle';
  final isPurchased = item.purchased == true;

  // ✅ Derive label + accent color from itemType
  final typeInfo = _typeInfo(item.itemType);
  final String typeLabel = typeInfo.$1;
  final Color accentColor = typeInfo.$2;

  // Category name lookup (searches 2 levels deep)
  String? categoryName;
  if (item.category != null && item.category!.isNotEmpty) {
    outer:
    for (final root in provider.categories) {
      if (root.id == item.category) { categoryName = root.name; break; }
      for (final child in root.children) {
        if (child.id == item.category) { categoryName = child.name; break outer; }
        for (final grandchild in child.children) {
          if (grandchild.id == item.category) { categoryName = grandchild.name; break outer; }
        }
      }
    }
  }

  final int? totalDuration = isBundle && (item.tests?.isNotEmpty ?? false)
      ? item.tests!.fold<int>(0, (sum, t) => sum + (t.durationMinutes ?? 0))
      : item.durationMinutes;

  final originalPrice = item.price;
  final finalPrice = item.effectivePrice ?? item.price;
  final isFree = (finalPrice ?? 0) == 0;
  final hasDiscount = (finalPrice ?? 0) < (originalPrice ?? 0);
  final hasPoints = (item.rewardPoints ?? 0) > 0;

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      border: Border(left: BorderSide(color: accentColor, width: 4)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Padding(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  isBundle
                      ? Icons.layers_rounded
                      : Icons.assignment_rounded,
                  color: accentColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: CustomText(
                    text: typeLabel,   // ✅ dynamic label
                    size: 10,
                    weight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // ✅ Price column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (hasDiscount)
                    Text(
                      '₹$originalPrice',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    isPurchased
                        ? 'Owned'
                        : isFree
                            ? 'FREE'
                            : '₹$finalPrice',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: isPurchased
                          ? successColor
                          : isFree
                              ? successColor
                              : drawerColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Title
          CustomText(
            text: title,
            size: 15,
            weight: FontWeight.w700,
            maxLines: 2,
            height: 1.35,
            color: Colors.black87,
          ),

          // Category path
          if (item.categoryPath != null && item.categoryPath!.isNotEmpty) ...[
            SizedBox(height: 5.h),
            Row(
              children: [
                Icon(Icons.category_outlined, size: 11.sp, color: Colors.grey.shade400),
                SizedBox(width: 4.w),
                Expanded(
                  child: CustomText(
                    text: item.categoryPath!,
                    size: 11,
                    color: Colors.grey.shade500,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ],

          // Description
          if (subtitle != null && subtitle.isNotEmpty) ...[
            SizedBox(height: 5.h),
            CustomText(
              text: subtitle,
              size: 12,
              color: Colors.grey.shade500,
              maxLines: 2,
              height: 1.4,
            ),
          ],

          SizedBox(height: 12.h),

          // Meta chips
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: [
              if (categoryName != null)
                _metaChip(icon: Icons.category_outlined, label: categoryName),
              if (totalDuration != null && totalDuration > 0)
                _metaChip(
                  icon: Icons.timer_outlined,
                  label: _formatDuration(totalDuration),
                ),
              if (isBundle && (item.tests?.isNotEmpty ?? false))
                _metaChip(
                  icon: Icons.assignment_outlined,
                  label: '${item.tests!.length} Tests',
                ),
              // ✅ Reward points chip
              if (hasPoints)
                _metaChip(
                  icon: Icons.stars_rounded,
                  label: '+${item.rewardPoints} pts',
                  color: Colors.amber.shade700,
                ),
            ],
          ),

          SizedBox(height: 14.h),
          Divider(color: Colors.grey.shade100, height: 1),
          SizedBox(height: 12.h),

          // ✅ Action buttons — purchased check
          if (isPurchased)
            // Already purchased — show owned button
            Container(
              width: double.infinity,
              height: 44.h,
              decoration: BoxDecoration(
                color: successColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: successColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, color: successColor, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Purchased',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: successColor,
                    ),
                  ),
                ],
              ),
            )
          else if (isBundle)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showBundleDetail(context, item, provider),
                    icon: Icon(Icons.layers_outlined, size: 14.sp, color: drawerColor),
                    label: Text(
                      'View Tests',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: drawerColor,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: drawerColor.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      minimumSize: Size(0, 42.h),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: CustomButton(
                    title: isFree ? 'Get Free' : 'Buy Now',
                    onTap: () => showStorePaymentSheet(context, item: item),
                    height: 42.h,
                    backgroundColor: isFree ? successColor : accentOrange,
                    textColor: Colors.white,
                    icon: isFree
                        ? Icons.download_done_rounded
                        : Icons.shopping_cart_rounded,
                  ),
                ),
              ],
            )
          else
            CustomButton(
              title: isFree ? 'Get Free' : 'Buy Now — ₹$finalPrice',
              onTap: () => showStorePaymentSheet(context, item: item),
              height: 44.h,
              backgroundColor: isFree ? successColor : drawerColor,
              textColor: Colors.white,
              icon: isFree
                  ? Icons.download_done_rounded
                  : Icons.shopping_cart_rounded,
            ),
        ],
      ),
    ),
  );
}

// ✅ New helper — returns (label, color) for each itemType
(String, Color) _typeInfo(String? itemType) {
  switch (itemType?.toLowerCase()) {
    case 'testbundle': return ('BUNDLE',    accentOrange);
    // case 'olympiad':   return ('OLYMPIAD',  const Color(0xFF7B1FA2));
    case 'school':     return ('SCHOOL',    const Color(0xFF1565C0));
    case 'competitive':return ('COMPETITIVE', const Color(0xFFBF360C));
    case 'skill development': return ('SKILL DEV', const Color(0xFF2E7D32));
    // case 'tournament': return ('TOURNAMENT', const Color(0xFF00838F));
    case 'challenge':  return ('CHALLENGE', const Color(0xFFD81B60));
    default:           return ('TEST',      drawerColor);
  }
}

// ✅ Updated _metaChip to accept optional color
Widget _metaChip({required IconData icon, required String label, Color? color}) {
  final c = color ?? Colors.grey.shade500;
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
    decoration: BoxDecoration(
      color: color != null ? color.withOpacity(0.08) : const Color(0xFFF0F1F5),
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.sp, color: c),
        SizedBox(width: 4.w),
        CustomText(
          text: label,
          size: 11,
          color: c,
          weight: FontWeight.w600,
        ),
      ],
    ),
  );
}
  void _showBundleDetail(
    BuildContext context,
    Item item,
    StoreProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BundleDetailSheet(item: item),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  META CHIP
  // ─────────────────────────────────────────────────────────────────

  // Widget _metaChip({required IconData icon, required String label}) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFFF0F1F5),
  //       borderRadius: BorderRadius.circular(8.r),
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Icon(icon, size: 12.sp, color: Colors.grey.shade500),
  //         SizedBox(width: 4.w),
  //         CustomText(
  //           text: label,
  //           size: 11,
  //           color: Colors.grey.shade600,
  //           weight: FontWeight.w600,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  // ─────────────────────────────────────────────────────────────────
  //  SHIMMER CARD
  // ─────────────────────────────────────────────────────────────────

  Widget _shimmerCard() {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: Container(
          height: 200.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  EMPTY STATE
  // ─────────────────────────────────────────────────────────────────

  Widget _emptyState() {
    return CustomCard(
      padding: EdgeInsets.symmetric(vertical: 52.h, horizontal: 24.w),
      child: Column(
        children: [
          Container(
            width: 68.w,
            height: 68.w,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F1F5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 30.sp,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 14.h),
          CustomText(
            text: 'No items found',
            size: 15,
            weight: FontWeight.w700,
            color: Colors.grey.shade700,
          ),
          SizedBox(height: 5.h),
          CustomText(
            text: 'Try a different filter or category',
            size: 12,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  STICKY HEADER DELEGATE
// ─────────────────────────────────────────────────────────────────────────────

class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  const _StickyFilterDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: maxExtent, child: child);
  }

  @override
  double get maxExtent => 8.h + 40.h + 8.h + 40.h + 8.h;

  @override
  double get minExtent => maxExtent;

  @override
  bool shouldRebuild(covariant _StickyFilterDelegate oldDelegate) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
//  EXPANDABLE CATEGORY SHEET  ✅ New — shows full tree like screenshot
// ─────────────────────────────────────────────────────────────────────────────

class _ExpandableCategorySheet extends StatefulWidget {
  final CategoryModel rootCategory;
  final List<CategoryModel> allRootCategories;
  final StoreProvider provider;
  final void Function(CategoryModel) onSelect;
  final VoidCallback onClear;

  const _ExpandableCategorySheet({
    required this.rootCategory,
    required this.allRootCategories,
    required this.provider,
    required this.onSelect,
    required this.onClear,
  });

  @override
  State<_ExpandableCategorySheet> createState() =>
      _ExpandableCategorySheetState();
}

class _ExpandableCategorySheetState
    extends State<_ExpandableCategorySheet> {
  final Set<String> _expandedIds = {};

  @override
  void initState() {
    super.initState();
    // Auto-expand the root category that was tapped
    if (widget.rootCategory.id != null) {
      _expandedIds.add(widget.rootCategory.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
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

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(
                  child: CustomText(
                    text: "Explore Categories",
                    size: 16,
                    weight: FontWeight.w700,
                    color: drawerColor,
                  ),
                ),
                if (widget.provider.selectedCategory != null)
                  GestureDetector(
                    onTap: widget.onClear,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8.r),
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
            ),
          ),
          SizedBox(height: 12.h),
          Divider(height: 1, color: Colors.grey.shade100),

          // Scrollable tree
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: widget.allRootCategories.length,
              itemBuilder: (context, index) {
                return _buildCategoryNode(
                    widget.allRootCategories[index],
                    depth: 0);
              },
            ),
          ),

          SizedBox(
              height: MediaQuery.of(context).padding.bottom + 16.h),
        ],
      ),
    );
  }

  Widget _buildCategoryNode(CategoryModel cat, {required int depth}) {
    final isExpanded = _expandedIds.contains(cat.id);
    final isSelected =
        widget.provider.selectedCategoryId == cat.id;
    final hasChildren = cat.hasChildren;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            if (hasChildren) {
              setState(() {
                if (isExpanded) {
                  _expandedIds.remove(cat.id);
                } else {
                  _expandedIds.add(cat.id!);
                }
              });
            } else {
              widget.onSelect(cat);
            }
          },
          borderRadius: BorderRadius.circular(10.r),
          child: Container(
            padding: EdgeInsets.only(
              left: (16.0 * depth).w,
              right: 12.w,
              top: 12.h,
              bottom: 12.h,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? drawerColor.withOpacity(0.07)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                if (depth > 0) ...[
                  Container(
                    width: 6.w,
                    height: 6.w,
                    margin: EdgeInsets.only(right: 10.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? drawerColor
                          : Colors.grey.shade300,
                    ),
                  ),
                ],
                Expanded(
                  child: CustomText(
                    text: cat.name,
                    size: depth == 0 ? 14 : 13,
                    weight: depth == 0
                        ? FontWeight.w700
                        : isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                    color: isSelected
                        ? drawerColor
                        : depth == 0
                            ? Colors.black87
                            : Colors.grey.shade700,
                  ),
                ),
                if (hasChildren) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.w,
                      vertical: 2.h,
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
                  SizedBox(width: 4.w),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
                if (!hasChildren && isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: drawerColor,
                    size: 18.sp,
                  ),
              ],
            ),
          ),
        ),

        // Animated children expand/collapse
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: isExpanded && hasChildren
              ? Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: cat.children
                        .map((child) =>
                            _buildCategoryNode(child, depth: depth + 1))
                        .toList(),
                  ),
                )
              : const SizedBox.shrink(),
        ),

        if (depth == 0) Divider(height: 1, color: Colors.grey.shade100),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  BUNDLE DETAIL SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _BundleDetailSheet extends StatelessWidget {
  final Item item;

  const _BundleDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final tests = item.tests ?? [];
    final finalPrice = item.effectivePrice ?? item.price ?? 0;
    final isPurchased = item.purchased ?? false;

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
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
          SizedBox(height: 4.h),

          // Hero header
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A2E4A), Color(0xFF243B6B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'BUNDLE DETAILS',
                    size: 10,
                    weight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.55),
                  ),
                  SizedBox(height: 8.h),
                  CustomText(
                    text: item.title ?? item.name ?? '',
                    size: 20,
                    weight: FontWeight.w800,
                    color: Colors.white,
                    maxLines: 2,
                    height: 1.3,
                  ),
                  if (item.description != null &&
                      item.description!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    CustomText(
                      text: item.description!,
                      size: 12,
                      color: Colors.white.withOpacity(0.65),
                      maxLines: 2,
                      height: 1.4,
                    ),
                  ],
                  SizedBox(height: 14.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 6.h,
                    children: [
                      _headerChip(
                        Icons.layers_outlined,
                        '${tests.length} Test${tests.length == 1 ? '' : 's'}',
                      ),
                      _headerChip(
                        Icons.currency_rupee_rounded,
                        '\u20B9$finalPrice',
                      ),
                      _headerChip(
                        isPurchased
                            ? Icons.check_circle_outline_rounded
                            : Icons.lock_outline_rounded,
                        isPurchased ? 'Purchased' : 'Not Purchased',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Scrollable body
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isPurchased)
                    Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: successColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: successColor.withOpacity(0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: successColor,
                            size: 18.sp,
                          ),
                          SizedBox(width: 10.w),
                          CustomText(
                            text: 'You already own this bundle',
                            size: 13,
                            weight: FontWeight.w600,
                            color: successColor,
                          ),
                        ],
                      ),
                    ),

                  CustomText(
                    text: 'Tests in this Bundle',
                    size: 14,
                    weight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  SizedBox(height: 12.h),

                  if (tests.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Center(
                        child: CustomText(
                          text: 'No tests found in this bundle',
                          size: 13,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    )
                  else
                    ...tests.map((test) => _testCard(test)),

                  SizedBox(
                    height:
                        MediaQuery.of(context).padding.bottom + 24.h,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _testCard(Test test) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: test.title ?? '',
            size: 14,
            weight: FontWeight.w600,
            color: Colors.black87,
            maxLines: 2,
            height: 1.35,
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 4.h,
            children: [
              if (test.durationMinutes != null &&
                  test.durationMinutes! > 0)
                _testChip(Icons.timer_outlined,
                    '${test.durationMinutes} min'),
              _testChip(Icons.assignment_outlined, 'Test'),
              if (test.categoryPath != null &&
                  test.categoryPath!.isNotEmpty)
                _testChip(Icons.category_outlined, test.categoryPath!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _testChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F5),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: Colors.grey.shade500),
          SizedBox(width: 4.w),
          CustomText(
            text: label,
            size: 11,
            color: Colors.grey.shade600,
            weight: FontWeight.w600,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _headerChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: Colors.white),
          SizedBox(width: 4.w),
          CustomText(
            text: label,
            size: 11,
            weight: FontWeight.w600,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}