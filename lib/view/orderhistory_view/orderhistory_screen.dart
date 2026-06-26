import 'package:firstedu/data/models/api_models/orderhistorymodels/orderhistory_models.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_filter_chips.dart';
import 'package:firstedu/res/widgets/custom_silverappbar.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/res/widgets/customheadercard.dart';
import 'package:firstedu/view_models/orderhistoryprovider/orderhistory_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  // ── Type filter chips ──────────────────────────────────────────────
  // value == null → no type param sent (All). Otherwise sent as-is to API.
  static const _typeFilters = [
    _TypeFilter(label: 'All', value: null),
    _TypeFilter(label: 'Courses', value: 'course'),
    _TypeFilter(label: 'School', value: 'school'),
    _TypeFilter(label: 'Competitive', value: 'competitive'),
    _TypeFilter(label: 'Skill Dev', value: 'skill development'),
    _TypeFilter(label: 'Tests', value: 'test'),
    _TypeFilter(label: 'Bundles', value: 'testbundle'),
    _TypeFilter(label: 'Olympiads', value: 'olympiads'),
    _TypeFilter(label: 'Tournaments', value: 'tournament'),
    _TypeFilter(label: 'Workshops', value: 'workshop'),
    _TypeFilter(label: 'Merchandise', value: 'merchandise'),
    _TypeFilter(label: 'Live Comps', value: 'live_competition'),
  ];

  int _selectedTypeIndex = 0;
  int? expandedOrderIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initial fetch — no filters
      context.read<OrderhistoryProvider>().fetchOrders(context);
    });
  }

  // ── Trigger a fresh server-side fetch when the chip changes ────────
  void _onTypeSelected(int index) {
    if (_selectedTypeIndex == index) return;
    setState(() {
      _selectedTypeIndex = index;
      expandedOrderIndex = null;
    });
    context.read<OrderhistoryProvider>().fetchOrders(
          context,
          type: _typeFilters[index].value, // null for "All"
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderhistoryProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: RefreshIndicator(
        onRefresh: () => provider.fetchOrders(
          context,
          type: _typeFilters[_selectedTypeIndex].value,
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            const CustomSliverAppBar(
              title: "Order History",
              subtitle:
                  "View your past purchases, transaction details, and purchase dates",
            ),

            // ── Header Banner ─────────────────────────────────────────
            const SliverToBoxAdapter(
              child: BubbleHeaderCard(
                title: "Order History",
                subtitle:
                    "View your past purchases, transaction details, and purchase dates",
                icon: Icons.shopping_bag_rounded,
                backgroundColor: drawerColor,
                iconColor: Color(0xFFFFD700),
              ),
            ),

            // ── Type Filter Chips ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
                child: SizedBox(
                  height: 42.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _typeFilters.length,
                    separatorBuilder: (_, __) => SizedBox(width: 8.w),
                    itemBuilder: (context, index) => CustomFilterChip(
                      label: _typeFilters[index].label,
                      selected: _selectedTypeIndex == index,
                      onTap: () => _onTypeSelected(index),
                    ),
                  ),
                ),
              ),
            ),

            // ── Count row ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                child: provider.isLoading
                    ? const SizedBox.shrink()
                    : CustomText(
                        text: "${provider.totalItems} orders found",
                        size: 13,
                        weight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
              ),
            ),

            // ── List / Loading / Empty ────────────────────────────────
            if (provider.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage.isNotEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 56.sp, color: Colors.red.shade300),
                      SizedBox(height: 12.h),
                      CustomText(
                        text: provider.errorMessage,
                        size: 13,
                        color: Colors.grey.shade600,
                        align: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      TextButton.icon(
                        onPressed: () => provider.fetchOrders(
                          context,
                          type: _typeFilters[_selectedTypeIndex].value,
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (provider.orders.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 56.sp, color: Colors.grey.shade300),
                      SizedBox(height: 12.h),
                      CustomText(
                        text: 'No orders found',
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 100.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // ── Load-more trigger ──────────────────────────
                      if (index == provider.orders.length - 1 &&
                          provider.hasMore) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          provider.loadMore(context);
                        });
                      }
                      return _buildOrderCard(provider.orders[index], index);
                    },
                    childCount: provider.orders.length +
                        (provider.isPaginationLoading ? 1 : 0),
                  ),
                ),
              ),

            // ── Pagination spinner ────────────────────────────────────
            if (provider.isPaginationLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Order Card ─────────────────────────────────────────────────────

  Widget _buildOrderCard(OrderHistoryItem order, int index) {
    final isExpanded = expandedOrderIndex == index;
    final typeInfo = _typeDisplay(order.type);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: CustomCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // ── Header row ────────────────────────────────────────────
            InkWell(
              onTap: () => setState(
                  () => expandedOrderIndex = isExpanded ? null : index),
              borderRadius: BorderRadius.circular(16.r),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: typeInfo.$2.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child:
                          Icon(typeInfo.$3, color: typeInfo.$2, size: 22.sp),
                    ),
                    SizedBox(width: 12.w),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: order.title ?? order.itemName ?? '',
                            size: 13,
                            weight: FontWeight.w700,
                            color: Colors.black87,
                            maxLines: 2,
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              // Type badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 7.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: typeInfo.$2.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: CustomText(
                                  text: typeInfo.$1,
                                  size: 10,
                                  weight: FontWeight.w700,
                                  color: typeInfo.$2,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Icon(Icons.calendar_today,
                                  size: 10.sp, color: Colors.grey.shade400),
                              SizedBox(width: 3.w),
                              CustomText(
                                text: order.date != null
                                    ? "${order.date!.day}/${order.date!.month}/${order.date!.year}"
                                    : '',
                                size: 11,
                                color: Colors.grey.shade500,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 8.w),

                    // Price + status
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _amountText(order, size: 16, weight: FontWeight.w800),
                        SizedBox(height: 4.h),
                        _statusBadge(order.status),
                        SizedBox(height: 4.h),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey.shade400,
                          size: 20.sp,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Expanded Details ──────────────────────────────────────
            if (isExpanded) ...[
              Divider(color: Colors.grey.shade100, height: 1),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 15.sp, color: Colors.grey.shade500),
                        SizedBox(width: 6.w),
                        CustomText(
                          text: 'ORDER DETAILS',
                          size: 11,
                          weight: FontWeight.w700,
                          color: Colors.grey.shade500,
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Item row
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: order.itemName ?? '',
                                  size: 13,
                                  weight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                SizedBox(height: 3.h),
                                CustomText(
                                  text: typeInfo.$1,
                                  size: 11,
                                  color: typeInfo.$2,
                                  weight: FontWeight.w600,
                                ),
                              ],
                            ),
                          ),
                          _amountText(order, size: 15, weight: FontWeight.w700,
                              color: drawerColor),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // Payment method row
                    if (order.paymentMethod != null) ...[
                      Row(
                        children: [
                          Icon(Icons.payment_rounded,
                              size: 14.sp, color: Colors.grey.shade500),
                          SizedBox(width: 6.w),
                          CustomText(
                            text: 'Payment: ',
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          CustomText(
                            text: _formatPaymentMethod(order.paymentMethod),
                            size: 12,
                            weight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                    ],

                    // Total
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: drawerColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10.r),
                        border:
                            Border.all(color: drawerColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CustomText(
                            text: "Total Paid",
                            size: 14,
                            weight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          _amountText(order,
                              size: 17, weight: FontWeight.w800,
                              color: drawerColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Amount display helper ──────────────────────────────────────────
  // Handles: FREE | ₹<amount> | <amount> pts

  Widget _amountText(
    OrderHistoryItem order, {
    required double size,
    required FontWeight weight,
    Color? color,
  }) {
    final String label;
    final Color resolvedColor;

    if (order.isFree) {
      label = 'FREE';
      resolvedColor = color ?? Colors.green.shade700;
    } else if (order.isPaidWithPoints) {
      label = '${order.amount ?? 0} pts';
      resolvedColor = color ?? Colors.deepPurple;
    } else {
      label = '₹${order.amount ?? 0}';
      resolvedColor = color ?? Colors.black87;
    }

    return CustomText(
      text: label,
      size: size,
      weight: weight,
      color: resolvedColor,
    );
  }

  // ── Payment method label ───────────────────────────────────────────

  String _formatPaymentMethod(String? method) {
    switch (method?.toLowerCase()) {
      case 'razorpay':
        return 'RAZORPAY';
      case 'wallet':
        return 'WALLET';
      case 'points':
        return 'POINTS';
      case 'free':
        return 'FREE';
      default:
        return (method ?? '').replaceAll('_', ' ').toUpperCase();
    }
  }

  // ── Status badge ──────────────────────────────────────────────────

  Widget _statusBadge(String? status) {
    final color = _statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: CustomText(
        text: status?.toUpperCase() ?? '',
        size: 10,
        weight: FontWeight.w700,
        color: color,
      ),
    );
  }

  Color _statusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'DELIVERED':
        return Colors.teal;
      case 'SHIPPED':
        return Colors.blue;
      case 'PROCESSING':
        return Colors.orange;
      case 'PENDING':
        return Colors.grey;
      case 'FAILED':
        return Colors.red.shade700;
      default:
        return Colors.blueGrey;
    }
  }

  // ── Type display (label, color, icon) ─────────────────────────────

  (String, Color, IconData) _typeDisplay(String? type) {
    switch (type?.toLowerCase()) {
      case 'course':
        return ('COURSE', Colors.deepOrange, Icons.menu_book_rounded);
      case 'school':
        return ('SCHOOL', const Color(0xFF1565C0), Icons.school_rounded);
      case 'competitive':
        return ('COMPETITIVE', const Color(0xFFBF360C),
            Icons.emoji_events_rounded);
      case 'skill development':
        return ('SKILL DEV', const Color(0xFF2E7D32), Icons.psychology_rounded);
      case 'test':
        return ('TEST', drawerColor, Icons.assignment_rounded);
      case 'testbundle':
        return ('BUNDLE', Colors.indigo, Icons.layers_rounded);
      case 'olympiads':
        return ('OLYMPIAD', const Color(0xFF7B1FA2),
            Icons.military_tech_rounded);
      case 'tournament':
        return ('TOURNAMENT', const Color(0xFF00838F),
            Icons.sports_esports_rounded);
      case 'workshop':
        return ('WORKSHOP', Colors.teal, Icons.event_rounded);
      case 'merchandise':
        return ('MERCH', Colors.brown, Icons.shopping_bag_rounded);
      case 'live_competition':
        return ('LIVE COMP', Colors.red, Icons.live_tv_rounded);
      default:
        return ('ORDER', Colors.blueGrey, Icons.inventory_2_outlined);
    }
  }
}

// ── Filter model ──────────────────────────────────────────────────────────────
class _TypeFilter {
  final String label;
  final String? value; // null = "All" (no type param)
  const _TypeFilter({required this.label, required this.value});
}