import 'dart:async';
import 'package:firstedu/data/models/api_models/competetive/competetionbyid_models.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view_models/competetiveprovider/competetionprovider.dart';
import 'package:firstedu/view_models/razropaymanger/razorpayservices.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  ENTRY POINTS
// ─────────────────────────────────────────────────────────────────────────────

Future<void> showCategoryPaymentSheet(
  BuildContext context, {
  required Child category,
  bool isUpgrade = false,
  int? upgradeAmount,
  VoidCallback? onPurchaseSuccess,
}) {
  final rootContext = context;
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (_) => _CategoryPaymentSheet(
      category: category,
      rootContext: rootContext,
      isUpgrade: isUpgrade,
      upgradeAmount: upgradeAmount,
      onPurchaseSuccess: onPurchaseSuccess,
    ),
  );
}

Future<void> showTestPaymentSheet(
  BuildContext context, {
  required Child testAsCategory,
  required String testId,
  VoidCallback? onPurchaseSuccess,
}) {
  final rootContext = context;
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (_) => _CategoryPaymentSheet(
      category: testAsCategory,
      rootContext: rootContext,
      isUpgrade: false,
      upgradeAmount: null,
      onPurchaseSuccess: onPurchaseSuccess,
      testId: testId,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  SHEET WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryPaymentSheet extends StatefulWidget {
  final Child category;
  final BuildContext rootContext;
  final bool isUpgrade;
  final int? upgradeAmount;
  final VoidCallback? onPurchaseSuccess;
  final String? testId;

  const _CategoryPaymentSheet({
    required this.category,
    required this.rootContext,
    this.isUpgrade = false,
    this.upgradeAmount,
    this.onPurchaseSuccess,
    this.testId,
  });

  @override
  State<_CategoryPaymentSheet> createState() => _CategoryPaymentSheetState();
}

class _CategoryPaymentSheetState extends State<_CategoryPaymentSheet> {
  String? _selected;
  final TextEditingController _couponController = TextEditingController();

  bool _couponApplied = false;
  int _discountAmount = 0;
  int _payableAmount = 0;
  String? _couponError;

  bool get _isTestMode => widget.testId != null;

  int get _price => widget.isUpgrade
      ? (widget.upgradeAmount ?? 0)
      : (widget.category.effectivePrice ?? widget.category.price ?? 0);

  int get _finalPrice => _couponApplied ? _payableAmount : _price;

  bool get _isFree => _finalPrice == 0;

  @override
  void initState() {
    super.initState();
    if (_price == 0) _selected = 'free';
  }

  @override
  void dispose() {
    _couponController.dispose();
    context.read<CompetitionProvider>().clearCoupon();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────
  //  SNACKBARS
  // ─────────────────────────────────────────────────────────────────

  void _showSuccessSnackbar(String itemName) {
    final ctx = widget.rootContext;
    if (!ctx.mounted) return;
    // ScaffoldMessenger.of(ctx).showSnackBar(
    //   SnackBar(
    //     content: Row(
    //       children: [
    //         const Icon(
    //           Icons.check_circle_rounded,
    //           color: Colors.white,
    //           size: 20,
    //         ),
    //         const SizedBox(width: 10),
    //         Expanded(
    //           child: Text(
    //             '"$itemName" purchased successfully!',
    //             style: const TextStyle(
    //               color: Colors.white,
    //               fontWeight: FontWeight.w600,
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //     backgroundColor: successColor,
    //     behavior: SnackBarBehavior.floating,
    //     duration: const Duration(seconds: 3),
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    //     margin: const EdgeInsets.all(12),
    //   ),
    // );
    AppToast.success(context, message: '$itemName' 'purchased successfully!');
  
  }

  void _showErrorSnackbar(String message) {
    final ctx = widget.rootContext;
    if (!ctx.mounted) return;
    // ScaffoldMessenger.of(ctx).showSnackBar(
    //   SnackBar(
    //     content: Text(message),
    //     backgroundColor: Colors.red.shade600,
    //     behavior: SnackBarBehavior.floating,
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    //     margin: const EdgeInsets.all(12),
    //   ),
    // );
    AppToast.warning(context, message: message);
  
  }


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompetitionProvider>();
    final isPaymentLoading = _isTestMode
        ? provider.isPaymentLoading
        : provider.isCategoryPaymentLoading;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDDEE6),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // ── Header row ───────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: _isTestMode
                          ? Colors.green.withOpacity(0.12)
                          : widget.isUpgrade
                          ? Colors.orange.withOpacity(0.12)
                          : drawerColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      _isTestMode
                          ? 'TEST'
                          : widget.isUpgrade
                          ? 'UPGRADE'
                          : 'COMPETITION',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: _isTestMode
                            ? Colors.green.shade700
                            : widget.isUpgrade
                            ? Colors.deepOrange
                            : drawerColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F3F7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16.sp,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 14.h),

              Text(
                _isTestMode
                    ? 'Purchase Test'
                    : widget.isUpgrade
                    ? 'Upgrade Plan'
                    : 'Complete Purchase',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1D26),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                widget.category.name ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13.sp, color: Colors.black45),
              ),

              SizedBox(height: 20.h),

              // ── Price summary ────────────────────────────────────
              _priceSummaryCard(),

              SizedBox(height: 20.h),

              // ── Coupon (hidden for upgrades) ─────────────────────
              if (!widget.isUpgrade && _price > 0) _redeemSection(provider),

              // ── Payment methods ──────────────────────────────────
              if (_price > 0 && !_isFree) ...[
                Text(
                  'Choose Payment Method',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1D26),
                  ),
                ),
                SizedBox(height: 12.h),

                _MethodTile(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Wallet',
                  subtitle: 'Pay instantly using your wallet balance',
                  color: Colors.purple,
                  selected: _selected == 'wallet',
                  onTap: () => setState(() => _selected = 'wallet'),
                ),
                SizedBox(height: 10.h),

                _MethodTile(
                  icon: Icons.credit_card_rounded,
                  title: 'Razorpay',
                  subtitle: 'Pay via UPI, card, netbanking & more',
                  color: Colors.blue.shade700,
                  selected: _selected == 'razorpay',
                  onTap: () => setState(() => _selected = 'razorpay'),
                ),
                SizedBox(height: 20.h),
              ] else
                SizedBox(height: 4.h),

              // ── Confirm button ───────────────────────────────────
              _confirmButton(provider, isPaymentLoading),

              SizedBox(height: 8.h),

              // ── Security note ────────────────────────────────────
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 12.sp,
                      color: Colors.black26,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Secure & encrypted payment',
                      style: TextStyle(fontSize: 11.sp, color: Colors.black26),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  PRICE SUMMARY CARD
  // ─────────────────────────────────────────────────────────────────

Widget _priceSummaryCard() {
  final int originalPrice = widget.isUpgrade
      ? (widget.upgradeAmount ?? 0)
      : (widget.category.price ?? 0);

  final int effectivePrice = widget.isUpgrade
      ? (widget.upgradeAmount ?? 0)
      : (widget.category.effectivePrice ?? widget.category.price ?? 0);

  final bool hasOfferDiscount = effectivePrice < originalPrice;
  final int offerDiscountAmount = originalPrice - effectivePrice;

  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: const Color(0xFFF6F7FB),
      borderRadius: BorderRadius.circular(14.r),
    ),
    child: Column(
      children: [
        // ── Item Price row ──
        Row(
          children: [
            Text(
              'Item Price',
              style: TextStyle(fontSize: 13.sp, color: Colors.black54),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (hasOfferDiscount)
                  Text(
                    '₹$originalPrice',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                Text(
                  effectivePrice == 0 ? 'FREE' : '₹$effectivePrice',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: effectivePrice == 0
                        ? successColor
                        : const Color(0xFF1A1D26),
                  ),
                ),
              ],
            ),
          ],
        ),

        // ── Offer discount row (no coupon yet) ──
        if (hasOfferDiscount && !_couponApplied) ...[
          SizedBox(height: 8.h),
          Divider(color: Colors.grey.shade200, height: 1),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                'Offer Discount',
                style: TextStyle(fontSize: 13.sp, color: Colors.black54),
              ),
              const Spacer(),
              Text(
                '- ₹$offerDiscountAmount',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: successColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Divider(color: Colors.grey.shade200, height: 1),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                'Total to Pay',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1D26),
                ),
              ),
              const Spacer(),
              Text(
                effectivePrice == 0 ? 'FREE' : '₹$effectivePrice',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: effectivePrice == 0 ? successColor : drawerColor,
                ),
              ),
            ],
          ),
        ],

        // ── Coupon discount row ──
        if (_couponApplied && _discountAmount > 0) ...[
          SizedBox(height: 8.h),
          Divider(color: Colors.grey.shade200, height: 1),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                'Coupon Discount',
                style: TextStyle(fontSize: 13.sp, color: Colors.black54),
              ),
              const Spacer(),
              Text(
                '- ₹$_discountAmount',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: successColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Divider(color: Colors.grey.shade200, height: 1),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                'Total to Pay',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1D26),
                ),
              ),
              const Spacer(),
              Text(
                _payableAmount == 0 ? 'FREE' : '₹$_payableAmount',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: _payableAmount == 0 ? successColor : drawerColor,
                ),
              ),
            ],
          ),
        ],

        // ── No discount at all ──
        if (!hasOfferDiscount && !_couponApplied && effectivePrice > 0) ...[
          SizedBox(height: 8.h),
          Divider(color: Colors.grey.shade200, height: 1),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                'Total to Pay',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1D26),
                ),
              ),
              const Spacer(),
              Text(
                '₹$effectivePrice',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: drawerColor,
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}
  // ─────────────────────────────────────────────────────────────────
  //  REDEEM / COUPON SECTION
  // ─────────────────────────────────────────────────────────────────

  Widget _redeemSection(CompetitionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Redeem Code',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1D26),
          ),
        ),
        SizedBox(height: 8.h),

        Row(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _couponApplied
                      ? successColor.withOpacity(0.06)
                      : const Color(0xFFF6F7FB),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _couponApplied
                        ? successColor
                        : _couponError != null
                        ? Colors.red.shade300
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _couponController,
                  enabled: !_couponApplied,
                  textCapitalization: TextCapitalization.characters,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: _couponApplied ? successColor : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter code',
                    hintStyle: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.black38,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                    ),
                    prefixIcon: Icon(
                      _couponApplied
                          ? Icons.check_circle_rounded
                          : Icons.confirmation_number_outlined,
                      size: 18.sp,
                      color: _couponApplied ? successColor : Colors.black38,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 14.h,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: 10.w),

            GestureDetector(
              // ✅ provider.isCouponLoading — no local bool
              onTap: provider.isCouponLoading
                  ? null
                  : _couponApplied
                  ? _removeCoupon
                  : _applyCoupon,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 48.h,
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                decoration: BoxDecoration(
                  color: _couponApplied ? Colors.red.shade50 : drawerColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: provider.isCouponLoading
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _couponApplied ? 'Remove' : 'Apply',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: _couponApplied ? Colors.red : Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),

        if (_couponError != null) ...[
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 13.sp,
                color: Colors.red.shade400,
              ),
              SizedBox(width: 4.w),
              Text(
                _couponError!,
                style: TextStyle(fontSize: 12.sp, color: Colors.red.shade400),
              ),
            ],
          ),
        ],

        if (_couponApplied) ...[
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.celebration_rounded, size: 13.sp, color: successColor),
              SizedBox(width: 4.w),
              Text(
                'Coupon applied! You saved ₹$_discountAmount',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: successColor,
                ),
              ),
            ],
          ),
        ],

        SizedBox(height: 20.h),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  CONFIRM BUTTON
  // ─────────────────────────────────────────────────────────────────

  Widget _confirmButton(CompetitionProvider provider, bool isPaymentLoading) {
    final bool canProceed =
        (_price == 0 || _isFree || _selected != null) && !isPaymentLoading;

    return GestureDetector(
      onTap: canProceed ? _handleConfirm : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          color: canProceed ? drawerColor : const Color(0xFFEEEFF3),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: canProceed
              ? [
                  BoxShadow(
                    color: drawerColor.withOpacity(.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isPaymentLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _price == 0 || _isFree
                          ? Icons.shopping_bag_rounded
                          : Icons.lock_rounded,
                      size: 18.sp,
                      color: canProceed ? Colors.white : Colors.black38,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _confirmLabel(),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: canProceed ? Colors.white : Colors.black38,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────────────────────────

  String _confirmLabel() {
    if (_price == 0 || _isFree) return 'Get for Free';
    if (_selected == 'wallet') return 'Pay from Wallet';
    if (_selected == 'razorpay') return 'Pay ₹$_finalPrice';
    return 'Confirm';
  }

  // ─────────────────────────────────────────────────────────────────
  //  COUPON LOGIC — provider → repo → API
  // ─────────────────────────────────────────────────────────────────

 Future<void> _applyCoupon() async {
  final code = _couponController.text.trim();
  if (code.isEmpty) {
    setState(() => _couponError = 'Please enter a coupon code');
    return;
  }

  setState(() => _couponError = null);

  final provider = context.read<CompetitionProvider>();

  // ✅ Use effectivePrice as base, not original price
  final int baseAmount = widget.isUpgrade
      ? (widget.upgradeAmount ?? 0)
      : (widget.category.effectivePrice ?? widget.category.price ?? 0);

  await provider.applyCoupon(
    context,
    code: code,
    amount: baseAmount,   // ✅ was: _price (which was already correct actually)
    itemType: _isTestMode ? 'test' : 'competitionCategory',
  );

  final couponData = provider.appliedCoupon;
  final error = provider.couponError;

  if (couponData != null) {
    setState(() {
      _discountAmount = (couponData.discount ?? 0).toInt();
      _payableAmount = (couponData.discountedPrice ?? 0).toInt();
      _couponApplied = true;
      _couponError = null;
      if (_payableAmount <= 0) _selected = 'free';
    });
  } else {
    setState(() {
      _couponError = error ?? 'Invalid or expired coupon code';
      _couponApplied = false;
      _discountAmount = 0;
      _payableAmount = 0;
    });
  }
}
  void _removeCoupon() {
    context.read<CompetitionProvider>().clearCoupon();
    setState(() {
      _couponApplied = false;
      _discountAmount = 0;
      _payableAmount = 0;
      _couponError = null;
      _couponController.clear();
      if (_selected == 'free' && _price > 0) _selected = null;
    });
  }

  // ─────────────────────────────────────────────────────────────────
  //  HANDLE CONFIRM
  // ─────────────────────────────────────────────────────────────────

Future<void> _handleConfirm() async {
  HapticFeedback.mediumImpact();
  final provider = context.read<CompetitionProvider>();
  final method = (_price == 0 || _isFree) ? 'free' : _selected;
  if (method == null) return;

  final itemName = widget.category.name ?? 'Item';
  final onSuccess = widget.onPurchaseSuccess; // ✅ capture ONCE at the top
  final rootCtx = widget.rootContext;          // ✅ capture ONCE at the top

  // ── TEST MODE ────────────────────────────────────────────────────
  if (_isTestMode) {
    final testId = widget.testId!;

    final result = await provider.initiateTestPayment(
      context,
      testId: testId,
      paymentMethod: method,
      couponCode: _couponApplied ? _couponController.text.trim() : null,
    );

    if (!mounted) return;

    if (result == 'success') {
      Navigator.pop(context);
      if (rootCtx.mounted) AppToast.success(rootCtx, message: '$itemName purchased successfully!');
      onSuccess?.call();
      return;
    }

    if (result == 'razorpay') {
      final order = provider.pendingTestOrder;
      if (order == null ||
          order.key == null ||
          order.amount == null ||
          order.orderId == null) return;

      Navigator.pop(context); // ✅ pop once, no duplicate

      RazorpayManager.instance.init(
        onSuccess: (res) async {
          final ok = await provider.completeTestRazorpayPayment(
            rootCtx,
            testId: testId,
            razorpayOrderId: res.orderId!,
            razorpayPaymentId: res.paymentId!,
            razorpaySignature: res.signature!,
          );
          if (ok) {
            if (rootCtx.mounted) AppToast.success(rootCtx, message: '$itemName purchased successfully!');
            onSuccess?.call(); // ✅ safe — captured before pop
          }
        },
        onError: (res) {
          if (rootCtx.mounted) AppToast.warning(rootCtx, message: res.message ?? 'Payment Failed');
        },
      );

      RazorpayManager.instance.openCheckout(
        key: order.key!,
        amount: order.amount! * 100,
        orderId: order.orderId!,
        title: itemName,
        description: 'Test Purchase',
      );
    }
    return;
  }

  // ── CATEGORY / UPGRADE MODE ──────────────────────────────────────
  final result = widget.isUpgrade
      ? await provider.initiateUpgrade(
          context,
          categoryId: widget.category.id ?? '',
          paymentMethod: method,
        )
      : await provider.initiateCategoryPayment(
          context,
          categoryId: widget.category.id ?? '',
          paymentMethod: method,
          couponCode: _couponApplied ? _couponController.text.trim() : null,
        );

  if (!mounted) return;

  if (result == 'success') {
    Navigator.pop(context);
    if (rootCtx.mounted) AppToast.success(rootCtx, message: '$itemName purchased successfully!');
    onSuccess?.call();
    return;
  }

  if (result == 'razorpay') {
    final order = widget.isUpgrade
        ? provider.pendingUpgradeOrder
        : provider.pendingCategoryOrder;

    if (order == null ||
        order.key == null ||
        order.amount == null ||
        order.orderId == null) return;

    Navigator.pop(context);

    RazorpayManager.instance.init(
      onSuccess: (res) async {
        bool ok = false;
        if (widget.isUpgrade) {
          ok = await provider.confirmUpgrade(
            rootCtx, // ✅ rootCtx, not widget.rootContext
            categoryId: widget.category.id ?? '',
            razorpayOrderId: res.orderId!,
            razorpayPaymentId: res.paymentId!,
            razorpaySignature: res.signature!,
          );
        } else {
          ok = await provider.completeCategoryRazorpayPayment(
            rootCtx, // ✅ rootCtx, not widget.rootContext
            categoryId: widget.category.id ?? '',
            razorpayOrderId: res.orderId!,
            razorpayPaymentId: res.paymentId!,
            razorpaySignature: res.signature!,
          );
        }
        if (ok) {
          if (rootCtx.mounted) AppToast.success(rootCtx, message: '$itemName purchased successfully!');
          onSuccess?.call(); // ✅ safe
        }
      },
      onError: (res) {
        if (rootCtx.mounted) AppToast.warning(rootCtx, message: res.message ?? 'Payment Failed');
      },
    );

    RazorpayManager.instance.openCheckout(
      key: order.key!,
      amount: order.amount! * 100,
      orderId: order.orderId!,
      title: itemName,
      description: widget.isUpgrade ? 'Upgrade' : 'Purchase',
    );
  }
}
}

// ─────────────────────────────────────────────────────────────────────────────
//  PAYMENT METHOD TILE  (identical to store sheet)
// ─────────────────────────────────────────────────────────────────────────────

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _MethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(.06) : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? color : const Color(0xFFE4E5EF),
            width: selected ? 2 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: color.withOpacity(.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1D26),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11.sp, color: Colors.black38),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? color : const Color(0xFFCDD0DA),
                  width: selected ? 6 : 2,
                ),
                color: selected ? color : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
