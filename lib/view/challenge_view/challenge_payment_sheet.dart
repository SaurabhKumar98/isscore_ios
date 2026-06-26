import 'package:firstedu/data/models/api_models/challengeyourself/challengeyourself_models.dart';
import 'package:firstedu/data/models/api_models/resourcestore/storepaymentmodels.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view_models/challengeyourselfprovider/challengeyourself_provider.dart';
import 'package:firstedu/view_models/razropaymanger/razorpayservices.dart';
import 'package:firstedu/view_models/resourcestoreprovider/resourcestoreprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// Shows the payment bottom sheet for a challenge level.
/// [onSuccess] is called after the payment is confirmed so the caller can
/// refresh the stage list.
Future<void> showChallengePaymentSheet(
  BuildContext context, {
  required Level level,
  required VoidCallback onSuccess,
}) {
  assert(
    level.test != null,
    'Cannot open payment sheet for a level with no test',
  );

  final rootContext = context;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ChallengePaymentSheet(
      level: level,
      rootContext: rootContext,
      onSuccess: onSuccess,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _ChallengePaymentSheet extends StatefulWidget {
  final Level level;
  final BuildContext rootContext;
  final VoidCallback onSuccess;

  const _ChallengePaymentSheet({
    required this.level,
    required this.rootContext,
    required this.onSuccess,
  });

  @override
  State<_ChallengePaymentSheet> createState() => _ChallengePaymentSheetState();
}

class _ChallengePaymentSheetState extends State<_ChallengePaymentSheet> {
  StorePaymentMethod? _selected;
  final TextEditingController _couponController = TextEditingController();
  bool _couponApplied = false;
  bool _isApplyingCoupon = false;
  int _discountAmount = 0;
  String? _couponError;

  // ── FIX: was `challenge.Test`, now `ChallengeTest` ──────────────────────
  ChallengeTest get _test => widget.level.test!;

  int get _basePrice => (_test.price ?? 0).toInt();
  int get _finalPrice => (_basePrice - _discountAmount).clamp(0, _basePrice);
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
              // ── Drag handle ──────────────────────────────────────────────
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

              // ── Header ───────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: accentOrange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.lock_open_rounded,
                      color: accentOrange,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Unlock Level ${widget.level.level}',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1D26),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _test.title ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // ── Price summary ────────────────────────────────────────────
              _priceSummaryCard(),
              SizedBox(height: 20.h),

              // ── Coupon ───────────────────────────────────────────────────
              if (_basePrice > 0) _redeemSection(provider),

              // ── Payment methods ──────────────────────────────────────────
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

              // ── Confirm button ───────────────────────────────────────────
              _confirmButton(provider),
              SizedBox(height: 8.h),

              // ── Security note ────────────────────────────────────────────
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

  // ── Price summary ──────────────────────────────────────────────────────────

  Widget _priceSummaryCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Item Price',
                style: TextStyle(fontSize: 13.sp, color: Colors.black54),
              ),
              const Spacer(),
              Text(
                _basePrice == 0 ? 'FREE' : '₹$_basePrice',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: _basePrice == 0
                      ? successColor
                      : const Color(0xFF1A1D26),
                ),
              ),
            ],
          ),
          if (_couponApplied && _discountAmount > 0) ...[
            SizedBox(height: 8.h),
            Divider(color: Colors.grey.shade200, height: 1),
            SizedBox(height: 8.h),
            Row(
              children: [
                Text(
                  'Discount',
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
                  _finalPrice == 0 ? 'FREE' : '₹$_finalPrice',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: _finalPrice == 0 ? successColor : drawerColor,
                  ),
                ),
              ],
            ),
          ] else if (_basePrice > 0) ...[
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
                  '₹$_basePrice',
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

  // ── Redeem / coupon ────────────────────────────────────────────────────────

  Widget _redeemSection(StoreProvider provider) {
    final isLoading = _isApplyingCoupon || provider.isCouponLoading;

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
                  enabled: !_couponApplied && !isLoading,
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
              onTap: isLoading
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
                  child: isLoading
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
                            color:
                                _couponApplied ? Colors.red : Colors.white,
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
                style:
                    TextStyle(fontSize: 12.sp, color: Colors.red.shade400),
              ),
            ],
          ),
        ],
        if (_couponApplied) ...[
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.celebration_rounded,
                  size: 13.sp, color: successColor),
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

  // ── Confirm button ─────────────────────────────────────────────────────────

  Widget _confirmButton(StoreProvider provider) {
    final canProceed = _selected != null && !provider.isPaymentLoading;

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
                      _isFree
                          ? Icons.lock_open_rounded
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

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _confirmLabel() {
    if (_isFree) return 'Unlock for Free';
    if (_selected == StorePaymentMethod.wallet) return 'Pay from Wallet';
    if (_selected == StorePaymentMethod.razorpay) return 'Pay ₹$_finalPrice';
    return 'Confirm';
  }

  // ── Apply coupon via ChallengeYourselfProvider ─────────────────────────────

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) {
      setState(() => _couponError = 'Please enter a coupon code');
      return;
    }

    setState(() {
      _isApplyingCoupon = true;
      _couponError = null;
    });

    final provider = context.read<ChallengeYourselfProvider>();

    await provider.applyCoupon(
      context,
      code: code,
      amount: _basePrice,
      module: 'test',
    );

    if (!mounted) return;

    if (provider.couponError != null) {
      setState(() {
        _couponError = provider.couponError;
        _isApplyingCoupon = false;
      });
      return;
    }

    final discount = provider.appliedCoupon;
    if (discount != null) {
      setState(() {
        _discountAmount = (discount.discount ?? 0).toInt();
        _couponApplied = true;
        _couponError = null;
        if (_finalPrice == 0) _selected = StorePaymentMethod.free;
      });
    }

    setState(() => _isApplyingCoupon = false);
  }

  void _removeCoupon() {
    context.read<ChallengeYourselfProvider>().clearCoupon();
    setState(() {
      _couponApplied = false;
      _discountAmount = 0;
      _couponError = null;
      _couponController.clear();
      if (_selected == StorePaymentMethod.free && _basePrice > 0) {
        _selected = null;
      }
    });
  }

  // ── Handle confirm / payment ───────────────────────────────────────────────

  Future<void> _handleConfirm(BuildContext context) async {
    if (_selected == null) return;

    final provider = context.read<StoreProvider>();
    final rootCtx = widget.rootContext;
    final testId = _test.id;

    final methodToSend =
        _finalPrice == 0 ? StorePaymentMethod.free : _selected!;

    final result = await provider.initiatePayment(
      context,
      itemId: testId ?? '',
      itemType: 'test',
      method: methodToSend,
      couponCode: _couponApplied ? _couponController.text.trim() : null,
    );

    if (!context.mounted) return;

    // ── Free / Wallet → immediate success ─────────────────────────────────
    if (result == 'success') {
      Navigator.pop(context);
      widget.onSuccess();
      return;
    }

    if (result == 'razorpay') {
      final order = provider.pendingRazorpayOrder;
      if (order == null) return;

      Navigator.pop(context); // close sheet before Razorpay UI

      RazorpayManager.instance.init(
        onSuccess: (res) async {
          await provider.completeRazorpayPurchase(
            rootCtx,
            itemId: testId ?? '',
            itemType: 'test',
            razorpayOrderId: res.orderId!,
            razorpayPaymentId: res.paymentId!,
            razorpaySignature: res.signature!,
          );
          if (rootCtx.mounted) {
            // ── FIX: was fetchChallengeYourself(), now refresh() ──────────
            rootCtx
                .read<ChallengeYourselfProvider>()
                .refresh(rootCtx);
            widget.onSuccess();
          }
        },
        onError: (res) {
          if (rootCtx.mounted) {
          
            AppToast.error(context, message: res.message??'Payment failed');
          }
        },
      );

      RazorpayManager.instance.openCheckout(
        key: order.key!,
        amount: order.amount!,
        orderId: order.orderId!,
        title: order.eventTitle ?? _test.title ?? '',
        description:
            'Challenge Yourself — Level ${widget.level.level}',
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared method tile
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
                    style:
                        TextStyle(fontSize: 11.sp, color: Colors.black38),
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