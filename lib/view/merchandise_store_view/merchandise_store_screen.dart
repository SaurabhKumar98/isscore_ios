import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_silverappbar.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/view/merchandise_store_view/merchandise_store_card.dart';
import 'package:firstedu/view/merchandise_store_view/myclaimedscreen.dart';
import 'package:firstedu/view_models/merchandiseprovider/merchandise_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MerchandiseStoreScreen extends StatefulWidget {
  const MerchandiseStoreScreen({super.key});

  @override
  State<MerchandiseStoreScreen> createState() => _MerchandiseStoreScreenState();
}

class _MerchandiseStoreScreenState extends State<MerchandiseStoreScreen> {
  final _categories = ['All'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MerchandiseProvider>().fetchMerchandise(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MerchandiseProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: CustomScrollView(
        slivers: [
          const CustomSliverAppBar(
            title: 'Merchandise Store',
            subtitle: 'Redeem your points for exclusive rewards.',
          ),

          // ── BANNER + FILTERS ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              child: Column(
                children: [
                  // ── Balance banner ────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          drawerColor,
                          drawerColor.withOpacity(.85),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Row(
                      children: [
                        // Points
                        _balanceChip(
                          icon: Icons.workspace_premium,
                          iconColor: Colors.amber,
                          label: 'Points',
                          value: _formatInt(provider.totalPoints),
                          suffix: 'pts',
                        ),

                        SizedBox(width: 12.w),
                        Container(
                          width: 1,
                          height: 40.h,
                          color: Colors.white.withOpacity(.25),
                        ),
                        SizedBox(width: 12.w),

                        // Wallet balance
                        _balanceChip(
                          icon: Icons.account_balance_wallet_outlined,
                          iconColor: Colors.greenAccent.shade200,
                          label: 'Wallet',
                          value:
                              '₹${_formatDouble(provider.monetaryBalance)}',
                          suffix: '',
                        ),

                        const Spacer(),

                        // My Claims button
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const MyClaimsScreen()),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.15),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                  color: Colors.white.withOpacity(.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.receipt_long_outlined,
                                    size: 14.sp, color: Colors.white),
                                SizedBox(width: 5.w),
                                CustomText(
                                  text: 'My Claims',
                                  size: 12,
                                  weight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // ── Category chips ────────────────────────────────────
                  SizedBox(
                    height: 36.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => SizedBox(width: 8.w),
                      itemBuilder: (_, i) {
                        final cat = _categories[i];
                        final isSelected = i == 0
                            ? provider.selectedCategory.isEmpty
                            : provider.selectedCategory.toLowerCase() ==
                                cat.toLowerCase();

                        return GestureDetector(
                          onTap: () => provider.setCategory(
                            context,
                            i == 0 ? '' : cat.toLowerCase(),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? drawerColor : Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: isSelected
                                    ? drawerColor
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: CustomText(
                              text: cat,
                              size: 12,
                              weight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black54,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 14.h),
                ],
              ),
            ),
          ),

          // ── STATES ───────────────────────────────────────────────────
          if (provider.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.errorMessage.isNotEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48.sp, color: Colors.grey.shade400),
                      SizedBox(height: 12.h),
                      CustomText(
                        text: provider.errorMessage,
                        size: 14,
                        weight: FontWeight.w500,
                        color: Colors.black54,
                        align: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (provider.items.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.card_giftcard_outlined,
                        size: 56.sp, color: Colors.grey.shade300),
                    SizedBox(height: 12.h),
                    CustomText(
                      text: 'No merchandise available',
                      size: 14,
                      weight: FontWeight.w600,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    if (i == provider.items.length) {
                      if (provider.isPaginationLoading) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: const Center(
                              child: CircularProgressIndicator()),
                        );
                      }
                      if (provider.hasMore) {
                        return _LoadMoreTrigger(
                          onVisible: () => provider.loadMore(context),
                        );
                      }
                      return SizedBox(height: 60.h);
                    }
                    return MerchandiseCard(data: provider.items[i]);
                  },
                  childCount: provider.items.length + 1,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _balanceChip({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String suffix,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(7.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18.sp),
        ),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: label,
              size: 10,
              weight: FontWeight.w500,
              color: Colors.white70,
            ),
            CustomText(
              text: suffix.isEmpty ? value : '$value $suffix',
              size: 15,
              weight: FontWeight.w800,
              color: Colors.white,
            ),
          ],
        ),
      ],
    );
  }

  String _formatInt(int v) {
    if (v >= 1000) {
      return '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}k';
    }
    return '$v';
  }

  String _formatDouble(double v) {
    if (v >= 1000) {
      return (v / 1000).toStringAsFixed(1) + 'k';
    }
    return v.toStringAsFixed(0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _LoadMoreTrigger extends StatefulWidget {
  final VoidCallback onVisible;
  const _LoadMoreTrigger({required this.onVisible});

  @override
  State<_LoadMoreTrigger> createState() => _LoadMoreTriggerState();
}

class _LoadMoreTriggerState extends State<_LoadMoreTrigger> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onVisible());
  }

  @override
  Widget build(BuildContext context) => const SizedBox(height: 1);
}