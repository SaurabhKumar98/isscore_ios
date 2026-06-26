import 'package:firstedu/data/models/api_models/merchandise_models/merchandisefetchclaimedmodels.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/view_models/merchandiseprovider/merchandise_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyClaimsScreen extends StatefulWidget {
  const MyClaimsScreen({super.key});

  @override
  State<MyClaimsScreen> createState() => _MyClaimsScreenState();
}

class _MyClaimsScreenState extends State<MyClaimsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MerchandiseProvider>().fetchMyClaims(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MerchandiseProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: drawerColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Claims',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: provider.isClaimsLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.claimsError.isNotEmpty
          ? _errorState(provider.claimsError, provider)
          : provider.myClaims.isEmpty
          ? _emptyState()
          : RefreshIndicator(
              onRefresh: () => provider.fetchMyClaims(context),
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount:
                    provider.myClaims.length + (provider.hasMoreClaims ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == provider.myClaims.length) {
                    return provider.isClaimsPaginationLoading
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _LoadMoreTrigger(
                            onVisible: () => provider.loadMoreClaims(context),
                          );
                  }
                  return _ClaimCard(claim: provider.myClaims[i]);
                },
              ),
            ),
    );
  }

  Widget _errorState(String msg, MerchandiseProvider prov) => Center(
    child: Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48.sp, color: Colors.grey.shade400),
          SizedBox(height: 12.h),
          CustomText(
            text: msg,
            size: 14,
            weight: FontWeight.w500,
            color: Colors.black54,
            align: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () => prov.fetchMyClaims(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: drawerColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: CustomText(
                text: 'Retry',
                size: 13,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _emptyState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.inbox_outlined, size: 64.sp, color: Colors.grey.shade300),
        SizedBox(height: 12.h),
        CustomText(
          text: 'No claims yet',
          size: 16,
          weight: FontWeight.w700,
          color: Colors.black45,
        ),
        SizedBox(height: 4.h),
        CustomText(
          text: 'Go to the store and redeem your points!',
          size: 12,
          weight: FontWeight.w400,
          color: Colors.black38,
          align: TextAlign.center,
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// CLAIM CARD
// ─────────────────────────────────────────────────────────────────────────────

class _ClaimCard extends StatelessWidget {
  final ClaimItem claim;
  const _ClaimCard({required this.claim});

  @override
  Widget build(BuildContext context) {
    final meta = _statusMeta(claim.status);
    final fmt = DateFormat('dd MMM yyyy • hh:mm a');

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── STATUS BAR ──────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                color: meta.color.withOpacity(.1),
                child: Row(
                  children: [
                    Icon(meta.icon, size: 14.sp, color: meta.color),
                    SizedBox(width: 6.w),
                    CustomText(
                      text: meta.label,
                      size: 12,
                      weight: FontWeight.w700,
                      color: meta.color,
                    ),
                    const Spacer(),
                    if (claim.claimedAt != null)
                      CustomText(
                        text: fmt.format(claim.claimedAt!.toLocal()),
                        size: 10,
                        weight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                  ],
                ),
              ),

              // ── ITEM ROW ────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: SizedBox(
                        width: 68.w,
                        height: 68.w,
                        child: (claim.merchandise?.imageUrl ?? '').isNotEmpty
                            ? Image.network(
                                claim.merchandise!.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _ph(),
                              )
                            : _ph(),
                      ),
                    ),

                    SizedBox(width: 12.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: claim.merchandise?.name ?? '—',
                            size: 14,
                            weight: FontWeight.w700,
                            color: const Color(0xFF1A1A2E),
                            maxLines: 2,
                          ),
                          SizedBox(height: 3.h),
                          CustomText(
                            text: claim.merchandise?.description ?? '',
                            size: 11,
                            weight: FontWeight.w400,
                            color: Colors.grey.shade500,
                            maxLines: 2,
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Icon(
                                Icons.workspace_premium,
                                size: 13.sp,
                                color: Colors.amber.shade700,
                              ),
                              SizedBox(width: 3.w),
                              CustomText(
                                text: '${claim.pointsSpent} pts spent',
                                size: 11,
                                weight: FontWeight.w700,
                                color: Colors.amber.shade800,
                              ),
                              SizedBox(width: 10.w),
                              Icon(
                                claim.merchandise?.isPhysical == true
                                    ? Icons.local_shipping_outlined
                                    : Icons.download_outlined,
                                size: 13.sp,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(width: 3.w),
                              CustomText(
                                text: claim.merchandise?.isPhysical == true
                                    ? 'Physical'
                                    : 'Digital',
                                size: 11,
                                weight: FontWeight.w500,
                                color: Colors.grey.shade500,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── DELIVERY ADDRESS ────────────────────────────────────
              if (claim.merchandise?.isPhysical == true &&
                  claim.deliveryAddress != null) ...[
                Divider(color: Colors.grey.shade100, height: 1, thickness: 1),
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14.sp,
                        color: drawerColor,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: CustomText(
                          text: _formatAddress(claim.deliveryAddress!),
                          size: 11,
                          weight: FontWeight.w400,
                          color: Colors.grey.shade600,
                          maxLines: 3,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ── TRACKING ────────────────────────────────────────────
              if (claim.trackingNumber != null) ...[
                Divider(color: Colors.grey.shade100, height: 1, thickness: 1),
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_shipping,
                        size: 14.sp,
                        color: Colors.blue.shade600,
                      ),
                      SizedBox(width: 6.w),
                      CustomText(
                        text: 'Tracking: ${claim.trackingNumber}',
                        size: 12,
                        weight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ],
                  ),
                ),
              ],

              // ── STATUS TIMELINE ─────────────────────────────────────
              if (claim.status.toLowerCase() != 'cancelled')
                Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 14.h),
                  child: _StatusTimeline(status: claim.status),
                ),
              if (claim.status.toLowerCase() == 'cancelled')
                Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 14.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(.07),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cancel_outlined,
                          size: 14.sp,
                          color: Colors.red.shade600,
                        ),
                        SizedBox(width: 6.w),
                        CustomText(
                          text: 'Order Cancelled',
                          size: 12,
                          weight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAddress(ClaimItemAddress a) =>
      '${a.fullName}, ${a.addressLine1}'
      '${a.addressLine2.isNotEmpty ? ', ${a.addressLine2}' : ''}'
      ', ${a.city}, ${a.state} - ${a.postalCode}, ${a.country}';

  Widget _ph() => Container(
    color: Colors.grey.shade100,
    child: Center(
      child: Icon(Icons.card_giftcard, size: 24, color: Colors.grey.shade300),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// STATUS TIMELINE
// ─────────────────────────────────────────────────────────────────────────────

class _StatusTimeline extends StatelessWidget {
  final String status;
  const _StatusTimeline({required this.status});

  static const _steps = ['pending', 'processing', 'shipped', 'delivered'];

  int get _activeIndex {
    final i = _steps.indexOf(status.toLowerCase());
    return i == -1 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // connector line
          final stepIndex = i ~/ 2;
          final done = stepIndex < _activeIndex;
          return Expanded(
            child: Container(
              height: 2,
              color: done ? drawerColor : Colors.grey.shade200,
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final done = stepIndex <= _activeIndex;
        final active = stepIndex == _activeIndex;
        return Column(
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? drawerColor : Colors.grey.shade200,
                border: active
                    ? Border.all(color: drawerColor.withOpacity(.3), width: 3)
                    : null,
              ),
              child: Icon(
                done ? Icons.check : Icons.circle,
                size: done ? 12.sp : 5.sp,
                color: done ? Colors.white : Colors.grey.shade400,
              ),
            ),
            SizedBox(height: 4.h),
            CustomText(
              text:
                  _steps[stepIndex][0].toUpperCase() +
                  _steps[stepIndex].substring(1),
              size: 9,
              weight: active ? FontWeight.w700 : FontWeight.w400,
              color: active ? drawerColor : Colors.grey.shade400,
            ),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATUS META
// ─────────────────────────────────────────────────────────────────────────────

class _StatusMeta {
  final Color color;
  final IconData icon;
  final String label;
  const _StatusMeta({
    required this.color,
    required this.icon,
    required this.label,
  });
}

_StatusMeta _statusMeta(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return _StatusMeta(
        color: Colors.orange.shade700,
        icon: Icons.hourglass_top_rounded,
        label: 'Pending',
      );
    case 'processing':
      return _StatusMeta(
        color: Colors.blue.shade700,
        icon: Icons.settings_outlined,
        label: 'Processing',
      );
    case 'shipped':
      return _StatusMeta(
        color: Colors.indigo.shade600,
        icon: Icons.local_shipping_outlined,
        label: 'Shipped',
      );
    case 'delivered':
      return _StatusMeta(
        color: successColor,
        icon: Icons.check_circle_outline,
        label: 'Delivered',
      );
    case 'cancelled':
      return _StatusMeta(
        color: Colors.red.shade600,
        icon: Icons.cancel_outlined,
        label: 'Cancelled',
      );
    default:
      return _StatusMeta(
        color: Colors.grey,
        icon: Icons.info_outline,
        label: status,
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOAD MORE TRIGGER
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
