import 'package:firstedu/data/models/api_models/resourcestore/storemodels.dart';
import 'package:firstedu/data/models/api_models/resourcestore/storepaymentmodels.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view_models/razropaymanger/razorpayservices.dart';
import 'package:firstedu/view_models/resourcestoreprovider/resourcestoreprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

Future<void> showStorePaymentSheet(BuildContext context, {required Item item}) {
  final rootContext = context;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _StorePaymentSheet(item: item, rootContext: rootContext),
  );
}

class _StorePaymentSheet extends StatefulWidget {
  final Item item;
  final BuildContext rootContext;
  const _StorePaymentSheet({required this.item, required this.rootContext});

  @override
  State<_StorePaymentSheet> createState() => _StorePaymentSheetState();
}

class _StorePaymentSheetState extends State<_StorePaymentSheet> {
 // State variables — replace existing ones
StorePaymentMethod? _selected;
final TextEditingController _couponController = TextEditingController();
bool _couponApplied = false;
bool _isApplyingCoupon = false;
int _discountAmount = 0;       // e.g. 50
int _payableAmount = 0;        // e.g. 450 (after discount)
String? _couponError;

// Updated getter — reflects post-coupon price
double get _basePrice =>
    widget.item.effectivePrice ?? widget.item.price?.toDouble() ?? 0.0;

double get _finalPrice =>
    _couponApplied ? _payableAmount.toDouble() : _basePrice;

bool get _isFree => _finalPrice == 0;

  @override
  void initState() {
    super.initState();
    if (_isFree) _selected = StorePaymentMethod.free;
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoreProvider>();

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

              Text(
                'Complete Purchase',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1D26),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                widget.item.title ?? widget.item.name ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13.sp, color: Colors.black45),
              ),

              SizedBox(height: 20.h),

              _priceSummaryCard(),

              SizedBox(height: 20.h),

              if (!_isFree) _redeemSection(),

              if (!_isFree) ...[
                Text(
                  'Choose Payment Method',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1D26),
                  ),
                ),
                SizedBox(height: 12.h),

                // Wallet
                _MethodTile(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Wallet',
                  subtitle: 'Pay instantly using your wallet balance',
                  color: Colors.purple,
                  selected: _selected == StorePaymentMethod.wallet,
                  onTap: () =>
                      setState(() => _selected = StorePaymentMethod.wallet),
                ),
                SizedBox(height: 10.h),

                // Razorpay
                _MethodTile(
                  icon: Icons.credit_card_rounded,
                  title: 'Razorpay',
                  subtitle: 'Pay via UPI, card, netbanking & more',
                  color: Colors.blue.shade700,
                  selected: _selected == StorePaymentMethod.razorpay,
                  onTap: () =>
                      setState(() => _selected = StorePaymentMethod.razorpay),
                ),
                SizedBox(height: 20.h),
              ] else
                SizedBox(height: 4.h),

              // ── Confirm Button ───────────────────────────
              _confirmButton(provider),

              SizedBox(height: 8.h),

              // ── Security Note ────────────────────────────
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
  final int originalPrice = widget.item.price ?? 0;
  final int effectivePrice = (widget.item.effectivePrice ?? widget.item.price ?? 0).toInt();
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
        // ── Item Price row (strikethrough if offer exists) ──
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
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: effectivePrice == 0 ? successColor : drawerColor,
                  ),
                ),
              ],
            ),
          ],
        ),

        // ── Offer discount row ──
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
                _finalPrice == 0 ? 'FREE' : '₹${_finalPrice.toInt()}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: _finalPrice == 0 ? successColor : drawerColor,
                ),
              ),
            ],
          ),
        ],

        // ── No discount at all ──
        if (!hasOfferDiscount && !_couponApplied && !_isFree) ...[
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
                '₹$originalPrice',
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

  Widget _redeemSection() {
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

            // Apply / Remove button
            GestureDetector(
              onTap: _isApplyingCoupon
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
                  child: _isApplyingCoupon
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: CircularProgressIndicator(
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

        // Error message
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

        // Success message
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

  Widget _confirmButton(StoreProvider provider) {
    final bool canProceed = _selected != null && !provider.isPaymentLoading;

    return GestureDetector(
      onTap: canProceed ? () => _handleConfirm(context) : null,
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
          child: provider.isPaymentLoading
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
                      _isFree ? Icons.shopping_bag_rounded : Icons.lock_rounded,
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
  if (_isFree) return 'Get for Free';
  if (_selected == StorePaymentMethod.wallet) return 'Pay from Wallet';
  if (_selected == StorePaymentMethod.razorpay) {
    return 'Pay ₹${_finalPrice.toInt()}';   // ✅ shows discounted price
  }
  return 'Confirm';
}
Future<void> _applyCoupon() async {
  final code = _couponController.text.trim();
  if (code.isEmpty) {
    setState(() => _couponError = 'Please enter a coupon code');
    return;
  }

  final provider = context.read<StoreProvider>();

  setState(() {
    _isApplyingCoupon = true;
    _couponError = null;
  });

  final rawType = widget.item.itemType ?? 'test';
  final module = rawType[0].toUpperCase() + rawType.substring(1);

  // ✅ Send effectivePrice (post-offer price) as the base amount, not original price
  final int baseAmount = (widget.item.effectivePrice ?? widget.item.price ?? 0).toInt();

  await provider.applyCoupon(
    context,
    code: code,
    amount: baseAmount,   // ✅ was: widget.item.price ?? 0
    module: module,
  );

  if (!mounted) return;

  final coupon = provider.appliedCoupon;

  if (coupon != null) {
    setState(() {
      _couponApplied = true;
      _discountAmount = (coupon.discount ?? 0).toInt();
      _payableAmount = (coupon.discountedPrice ?? 0).toInt();
      _couponError = null;

      if (_payableAmount <= 0) {
        _selected = StorePaymentMethod.free;
      }
    });
  } else {
    setState(() {
      _couponError = provider.couponError ?? 'Invalid or expired coupon code';
    });
  }

  setState(() => _isApplyingCoupon = false);
}

void _removeCoupon() {
  final provider = context.read<StoreProvider>();

  provider.clearCoupon(); // 🔥 important

  setState(() {
    _couponApplied = false;
    _discountAmount = 0;
    _couponError = null;
    _couponController.clear();

    if (_selected == StorePaymentMethod.free && !_isFree) {
      _selected = null;
    }
  });
}
 
 
  Future<void> _handleConfirm(BuildContext context) async {
    if (_selected == null) return;

    final provider = context.read<StoreProvider>();
    final itemId = widget.item.id;

    // ✅ Capture root context now — sheet context will be dead after pop
    final rootCtx = widget.rootContext;

    final methodToSend = _finalPrice == 0
        ? StorePaymentMethod.free
        : _selected!;

    final result = await provider.initiatePayment(
      context,
      itemId: itemId ?? "",
      itemType: widget.item.itemType ?? 'test',
      method: methodToSend,
      couponCode: _couponApplied ? _couponController.text.trim() : null,
    );

    if (!context.mounted) return;

    // Free or Wallet → directly purchased
    if (result == 'success') {
      Navigator.pop(context);
      return;
    }

    // Razorpay flow
    if (result == 'razorpay') {
      final order = provider.pendingRazorpayOrder;
      if (order == null) {
        debugPrint('❌ Razorpay: pendingRazorpayOrder is null');
        return;
      }

      // ✅ Log order details to verify API response parsed correctly
      debugPrint(
        '✅ Razorpay order: key=${order.key}, orderId=${order.orderId}, amount=${order.amount}',
      );

      // Pop sheet BEFORE opening Razorpay
      Navigator.pop(context);

      // ✅ Use rootCtx (not sheet context) for all post-pop operations
      RazorpayManager.instance.init(
        // context: rootCtx,
        onSuccess: (res) async {
          debugPrint('✅ Razorpay success: paymentId=${res.paymentId}');
          await provider.completeRazorpayPurchase(
            rootCtx,
            itemId: itemId ?? "",
            itemType: widget.item.itemType ?? 'test', // ✅ pass item type
            razorpayOrderId: res.orderId!,
            razorpayPaymentId: res.paymentId!,
            razorpaySignature: res.signature!,
          );
        },
        onError: (res) {
          debugPrint(
            '❌ Razorpay error: code=${res.code}, message=${res.message}',
          );
          if (rootCtx.mounted) {
            // ScaffoldMessenger.of(rootCtx).showSnackBar(
            //   SnackBar(
            //     content: Text(res.message ?? 'Payment failed'),
            //     backgroundColor: Colors.red,
            //   ),
            // );
            AppToast.error(context, message: res.message?? 'Payment failed');
          }
        },
      );
      RazorpayManager.instance.openCheckout(
        key: order.key!,
        amount: order.amount!,
        orderId: order.orderId!,
        title: order.eventTitle ?? widget.item.title ?? 'Purchase',
        description: 'Resource Store Purchase',
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PAYMENT METHOD TILE
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
            // Icon box
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

            // Labels
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

            // Radio indicator
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
