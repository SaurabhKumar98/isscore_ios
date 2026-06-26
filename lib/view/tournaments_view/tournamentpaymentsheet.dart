// lib/res/widgets/tournament_payment_sheet.dart

import 'package:firstedu/data/models/api_models/tournament/tournamentdetailsbyid_models.dart';
import 'package:firstedu/data/models/api_models/tournament/tournamentpayment_models.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view_models/razropaymanger/razorpayservices.dart';
import 'package:firstedu/view_models/tournamentprovider/tournament_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  PUBLIC ENTRY POINT
// ─────────────────────────────────────────────────────────────────────────────

Future<void> showTournamentPaymentSheet(
  BuildContext context, {
  required Data tournament,
}) {
  final rootContext = context;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TournamentPaymentSheet(
      tournament: tournament,
      rootContext: rootContext,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _TournamentPaymentSheet extends StatefulWidget {
  final Data tournament;
  final BuildContext rootContext;

  const _TournamentPaymentSheet({
    required this.tournament,
    required this.rootContext,
  });

  @override
  State<_TournamentPaymentSheet> createState() =>
      _TournamentPaymentSheetState();
}

class _TournamentPaymentSheetState extends State<_TournamentPaymentSheet> {
  TournamentPaymentMethod? _selected;
  final TextEditingController _couponController = TextEditingController();

  bool _couponApplied = false;
  bool _isApplyingCoupon = false;
  int _discountAmount = 0;
  String? _couponError;

  // ── Derived ────────────────────────────────────────────────────
  int get _basePrice {
    final t = widget.tournament;
    return (t.effectivePrice ?? 0.0)
        .toInt(); // ← use effectivePrice, not discountedPrice
  }

  bool get _isFree => _basePrice == 0 && !_couponApplied;

  int get _finalPrice => (_basePrice - _discountAmount).clamp(0, _basePrice);

  @override
  void initState() {
    super.initState();
    if (_isFree) _selected = TournamentPaymentMethod.free;
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TournamentProvider>();

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
              // ── Drag Handle ──────────────────────────────────
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

              // ── Header ───────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'TOURNAMENT',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.deepOrange,
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
                'Complete Registration',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1D26),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                widget.tournament.title ?? "",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13.sp, color: Colors.black45),
              ),

              SizedBox(height: 20.h),

              // ── Price Summary ────────────────────────────────
              _priceSummaryCard(),

              SizedBox(height: 20.h),

              // ── Coupon ───────────────────────────────────────
              if (!_isFree) _redeemSection(),

              // ── Payment Methods ──────────────────────────────
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
                  selected: _selected == TournamentPaymentMethod.wallet,
                  onTap: () => setState(
                    () => _selected = TournamentPaymentMethod.wallet,
                  ),
                ),
                SizedBox(height: 10.h),

                _MethodTile(
                  icon: Icons.credit_card_rounded,
                  title: 'Razorpay',
                  subtitle: 'Pay via UPI, card, netbanking & more',
                  color: Colors.blue.shade700,
                  selected: _selected == TournamentPaymentMethod.razorpay,
                  onTap: () => setState(
                    () => _selected = TournamentPaymentMethod.razorpay,
                  ),
                ),
                SizedBox(height: 20.h),
              ] else
                SizedBox(height: 4.h),

              // ── Confirm Button ───────────────────────────────
              _confirmButton(provider),

              SizedBox(height: 8.h),

              // ── Security Note ────────────────────────────────
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
  //  PRICE SUMMARY
  // ─────────────────────────────────────────────────────────────────

  Widget _priceSummaryCard() {
    final t = widget.tournament;
    final originalPrice = t.originalPrice ?? 0;
    final serverDiscount = t.discountAmount ?? 0;
    final effectivePrice = t.effectivePrice ?? 0;

    final hasServerDiscount = serverDiscount > 0;

    final percent = originalPrice > 0
        ? ((serverDiscount / originalPrice) * 100).round()
        : 0;

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
                'Entry Fee',
                style: TextStyle(fontSize: 13.sp, color: Colors.black54),
              ),
              const Spacer(),
              // Show strikethrough original price if there's a discount
              if (hasServerDiscount) ...[
                Text(
                  '₹$originalPrice',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.black38,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: successColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '-$percent%',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: successColor,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
              ],
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

          // Offer discount row
          if (hasServerDiscount) ...[
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
                  '- ₹$serverDiscount',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: successColor,
                  ),
                ),
              ],
            ),
          ],

          // Coupon discount row (on top of server discount)
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
          ],

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
        ],
      ),
    );
  }
  // ─────────────────────────────────────────────────────────────────
  //  REDEEM SECTION
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

  Widget _confirmButton(TournamentProvider provider) {
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
                      _isFree ? Icons.how_to_reg_rounded : Icons.lock_rounded,
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
    if (_isFree) return 'Register for Free';
    if (_selected == TournamentPaymentMethod.wallet) return 'Pay from Wallet';
    if (_selected == TournamentPaymentMethod.razorpay)
      return 'Pay ₹$_finalPrice';
    return 'Confirm';
  }

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
    // TODO: replace with real coupon API
    await Future.delayed(const Duration(milliseconds: 900));
    if (code == 'SAVE100') {
      setState(() {
        _discountAmount = 100;
        _couponApplied = true;
        _couponError = null;
        if (_finalPrice == 0) _selected = TournamentPaymentMethod.free;
      });
    } else {
      setState(() => _couponError = 'Invalid or expired coupon code');
    }
    setState(() => _isApplyingCoupon = false);
  }

  void _removeCoupon() {
    setState(() {
      _couponApplied = false;
      _discountAmount = 0;
      _couponError = null;
      _couponController.clear();
      if (_selected == TournamentPaymentMethod.free && !_isFree) {
        _selected = null;
      }
    });
  }

  Future<void> _handleConfirm(BuildContext context) async {
    if (_selected == null) return;

    final provider = context.read<TournamentProvider>();
    final tournamentId = widget.tournament.id;
    final rootCtx = widget.rootContext;

    final result = await provider.initiatePayment(
      context,
      tournamentId: tournamentId ?? "",
      method: _selected!,
      couponCode: _couponApplied ? _couponController.text.trim() : null,
    );

    if (!context.mounted) return;

    // Free / Wallet → registered immediately
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

      debugPrint(
        '✅ Razorpay order: key=${order.key}, orderId=${order.orderId}, amount=${order.amount}',
      );

      Navigator.pop(context); // pop sheet before Razorpay opens

      RazorpayManager.instance.init(
        onSuccess: (res) async {
          debugPrint('✅ Razorpay success: ${res.paymentId}');
          await provider.completeRazorpayRegistration(
            rootCtx,
            tournamentId: tournamentId ?? "",
            razorpayOrderId: res.orderId!,
            razorpayPaymentId: res.paymentId!,
            razorpaySignature: res.signature!,
          );
        },
        onError: (res) {
          debugPrint('❌ Razorpay error: ${res.code} – ${res.message}');
          if (rootCtx.mounted) {
            // ScaffoldMessenger.of(rootCtx).showSnackBar(
            //   SnackBar(
            //     content: Text(res.message ?? 'Payment failed'),
            //     backgroundColor: Colors.red,
            //   ),
            // );
            AppToast.error(context, message:res.message ?? 'Payment failed' );
          }
        },
      );

      RazorpayManager.instance.openCheckout(
        key: order.key!,
        amount: order.amount!,
        orderId: order.orderId!,
        title: order.eventTitle ?? widget.tournament.title ?? "",
        description: 'Tournament Registration',
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  METHOD TILE
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
