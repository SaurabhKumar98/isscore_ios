// lib/view/olympiad/olympiad_payment_sheet.dart

import 'package:firstedu/data/models/api_models/olympiadcentermodel/olympiaddetailsmodels.dart';
import 'package:firstedu/data/models/api_models/olympiadcentermodel/olympiadpaymentmodels.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view_models/olympiadprovider/olympiadcenterprovider.dart';
import 'package:firstedu/view_models/razropaymanger/razorpayservices.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

Future<void> showOlympiadPaymentSheet(
  BuildContext context, {
  required OlympiadDetailsData olympiad,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<OlympiadProvider>(),
      child: _OlympiadPaymentSheet(olympiad: olympiad),
    ),
  );
}

class _OlympiadPaymentSheet extends StatefulWidget {
  final OlympiadDetailsData olympiad;
  const _OlympiadPaymentSheet({required this.olympiad});

  @override
  State<_OlympiadPaymentSheet> createState() => _OlympiadPaymentSheetState();
}

class _OlympiadPaymentSheetState extends State<_OlympiadPaymentSheet> {
  OlympiadPaymentMethod? _selected;

  final TextEditingController _couponCtrl = TextEditingController();
  bool _couponApplied = false;
  String? _couponError;

  bool get _isFree => (widget.olympiad.price ?? 0) == 0;

  @override
  void initState() {
    super.initState();
    if (_isFree) _selected = OlympiadPaymentMethod.free;
  }

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OlympiadProvider>();

    // Resolve live price after coupon
    final coupon = provider.appliedCoupon;
    final basePrice = widget.olympiad.discountedPrice ?? widget.olympiad.price ?? 0;
    final finalPrice = coupon?.discountedPrice ?? basePrice;
    final isFreeOrZero = _isFree || finalPrice == 0;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
              // Drag handle
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
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.emoji_events_rounded,
                        color: Colors.orange[700], size: 22.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete Registration',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1D26),
                          ),
                        ),
                        Text(
                          widget.olympiad.title ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12.sp, color: Colors.black45),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // ── Price summary ─────────────────────────────────────────────
              _buildPriceSummary(
                basePrice: basePrice,
                couponDiscount: coupon?.discount,
                finalPrice: finalPrice,
              ),

              SizedBox(height: 16.h),

              // ── Coupon + method (paid only) ───────────────────────────────
              if (!_isFree) ...[
                _buildCouponField(provider, basePrice),
                SizedBox(height: 16.h),
                _buildMethodSelector(),
                SizedBox(height: 20.h),
              ] else
                SizedBox(height: 4.h),

              // ── Confirm button ────────────────────────────────────────────
              _buildConfirmButton(
                provider: provider,
                isFreeOrZero: isFreeOrZero,
                finalPrice: finalPrice,
              ),

              SizedBox(height: 8.h),

              // ── Security note ─────────────────────────────────────────────
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined,
                        size: 12.sp, color: Colors.black26),
                    SizedBox(width: 4.w),
                    Text(
                      'Secure & encrypted payment',
                      style:
                          TextStyle(fontSize: 11.sp, color: Colors.black26),
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

  // ── Price Summary ─────────────────────────────────────────────────────────

  Widget _buildPriceSummary({
    required num basePrice,
    required num? couponDiscount,
    required num finalPrice,
  }) {
    final hasOlympiadDiscount =
        widget.olympiad.discountedPrice != null &&
        widget.olympiad.price != null &&
        widget.olympiad.discountedPrice! < widget.olympiad.price!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          // Original price strikethrough (olympiad-level discount)
          if (hasOlympiadDiscount) ...[
            Row(
              children: [
                Text('Original Price',
                    style:
                        TextStyle(fontSize: 12.sp, color: Colors.black45)),
                const Spacer(),
                Text(
                  '₹${widget.olympiad.price}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.black38,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Text('Olympiad Discount',
                    style: TextStyle(
                        fontSize: 12.sp, color: Colors.green[700])),
                const Spacer(),
                Text(
                  '- ₹${widget.olympiad.price! - widget.olympiad.discountedPrice!}',
                  style:
                      TextStyle(fontSize: 13.sp, color: Colors.green[700]),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Divider(height: 1, color: Colors.grey[200]),
            ),
          ],

          // Olympiad Fee row
          Row(
            children: [
              Text('Olympiad Fee',
                  style: TextStyle(fontSize: 13.sp, color: Colors.black54)),
              const Spacer(),
              Text(
                _isFree ? 'FREE' : '₹$basePrice',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: _isFree ? successColor : const Color(0xFF1A1D26),
                ),
              ),
            ],
          ),

          // Coupon discount row
          if (couponDiscount != null && couponDiscount > 0) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Divider(height: 1, color: Colors.grey[200]),
            ),
            Row(
              children: [
                Row(
                  children: [
                    Icon(Icons.confirmation_number_outlined,
                        size: 13.sp, color: Colors.green[700]),
                    SizedBox(width: 4.w),
                    Text(
                      'Coupon "${_couponCtrl.text.trim()}"',
                      style: TextStyle(
                          fontSize: 12.sp, color: Colors.green[700]),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '- ₹$couponDiscount',
                  style:
                      TextStyle(fontSize: 13.sp, color: Colors.green[700]),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Divider(height: 1, color: Colors.grey[200]),
            ),

            // Total to pay
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
                  finalPrice == 0 ? 'FREE' : '₹$finalPrice',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: finalPrice == 0 ? successColor : drawerColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Coupon Field ──────────────────────────────────────────────────────────

  Widget _buildCouponField(OlympiadProvider provider, int basePrice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Have a coupon?',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1D26),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            // Text field
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
                            : Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _couponCtrl,
                  enabled: !_couponApplied,
                  textCapitalization: TextCapitalization.characters,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: _couponApplied ? successColor : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code',
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
                        horizontal: 14.w, vertical: 14.h),
                  ),
                  onChanged: (_) {
                    if (_couponError != null) {
                      setState(() => _couponError = null);
                    }
                  },
                ),
              ),
            ),

            SizedBox(width: 10.w),

            // Apply / Remove button
            GestureDetector(
              onTap: provider.isCouponLoading
                  ? null
                  : () async {
                      if (_couponApplied) {
                        // ── REMOVE ────────────────────────────────────────
                        provider.clearCoupon();
                        setState(() {
                          _couponApplied = false;
                          _couponError = null;
                          _couponCtrl.clear();
                          // Reset to null if was auto-freed by coupon
                          if (_selected == OlympiadPaymentMethod.free &&
                              !_isFree) {
                            _selected = null;
                          }
                        });
                        return;
                      }

                      // ── APPLY ─────────────────────────────────────────
                      final code = _couponCtrl.text.trim();
                      if (code.isEmpty) {
                        setState(() =>
                            _couponError = 'Please enter a coupon code.');
                        return;
                      }

                      await provider.applyCoupon(
                        context,
                        code: code,
                        amount: basePrice,
                        itemType: "Olympiads",
                      );

                      if (!mounted) return;

                      if (provider.appliedCoupon != null) {
                        setState(() {
                          _couponApplied = true;
                          _couponError = null;
                          // Auto-select free if coupon fully covers price
                          final discounted =
                              provider.appliedCoupon!.discountedPrice ?? 0;
                          if (discounted <= 0) {
                            _selected = OlympiadPaymentMethod.free;
                          }
                        });
                      } else {
                        setState(() {
                          _couponError = provider.couponError ??
                              'Invalid coupon code.';
                          _couponApplied = false;
                        });
                      }
                    },
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
                            color:
                                _couponApplied ? Colors.red : Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),

        // Error
        if (_couponError != null) ...[
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 13.sp, color: Colors.red.shade400),
              SizedBox(width: 4.w),
              Text(
                _couponError!,
                style:
                    TextStyle(fontSize: 12.sp, color: Colors.red.shade400),
              ),
            ],
          ),
        ],

        // Success
        if (_couponApplied) ...[
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.celebration_rounded,
                  size: 13.sp, color: successColor),
              SizedBox(width: 4.w),
              Text(
                'Coupon applied! You saved ₹${provider.appliedCoupon?.discount ?? 0}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: successColor,
                ),
              ),
            ],
          ),
        ],

        SizedBox(height: 4.h),
      ],
    );
  }

  // ── Method Selector ───────────────────────────────────────────────────────

  Widget _buildMethodSelector() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            selected: _selected == OlympiadPaymentMethod.wallet,
            onTap: () => setState(() => _selected = OlympiadPaymentMethod.wallet),
          ),
          SizedBox(height: 10.h),
          _MethodTile(
            icon: Icons.credit_card_rounded,
            title: 'Razorpay',
            subtitle: 'Pay via UPI, card, netbanking & more',
            color: Colors.blue.shade700,
            selected: _selected == OlympiadPaymentMethod.razorpay,
            onTap: () =>
                setState(() => _selected = OlympiadPaymentMethod.razorpay),
          ),
        ],
      );

  // ── Confirm Button ────────────────────────────────────────────────────────

  Widget _buildConfirmButton({
    required OlympiadProvider provider,
    required bool isFreeOrZero,
    required num finalPrice,
  }) {
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
                      isFreeOrZero
                          ? Icons.how_to_reg_rounded
                          : Icons.lock_rounded,
                      size: 18.sp,
                      color: canProceed ? Colors.white : Colors.black38,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _confirmLabel(isFreeOrZero, finalPrice),
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

  String _confirmLabel(bool isFreeOrZero, num finalPrice) {
    if (isFreeOrZero) return 'Register for Free';
    if (_selected == OlympiadPaymentMethod.wallet) return 'Pay from Wallet';
    if (_selected == OlympiadPaymentMethod.razorpay) return 'Pay ₹$finalPrice';
    return 'Confirm';
  }

  // ── Handle Confirm ────────────────────────────────────────────────────────

  Future<void> _handleConfirm(BuildContext context) async {
    if (_selected == null) return;

    final provider = context.read<OlympiadProvider>();
    final olympiadId = widget.olympiad.id ?? '';

    final result = await provider.initiatePayment(
      context,
      olympiadId: olympiadId,
      method: _selected!,
      couponCode: _couponApplied ? _couponCtrl.text.trim() : null,
    );

    if (!context.mounted) return;

    // Free / Wallet → done
    if (result == 'success') {
      Navigator.pop(context);
      return;
    }

    // Razorpay → open checkout
    if (result == 'razorpay') {
      final order = provider.pendingRazorpayOrder;
      if (order == null) return;

      Navigator.pop(context);

      RazorpayManager.instance.init(
        onSuccess: (res) async {
          await provider.completeRazorpayRegistration(
            context,
            olympiadId: olympiadId,
            razorpayOrderId: res.orderId!,
            razorpayPaymentId: res.paymentId!,
            razorpaySignature: res.signature!,
          );
        },
        onError: (res) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(res.message ?? 'Payment failed'),
          //     backgroundColor: Colors.red,
          //   ),
          // );
          AppToast.error(context, message:res.message ?? 'Payment failed' );
        },
      );

      RazorpayManager.instance.openCheckout(
        key: order.key ?? '',
        amount: order.amount ?? 0,
        orderId: order.orderId ?? '',
        title: order.eventTitle ?? (widget.olympiad.title ?? 'Olympiad'),
        description: 'Olympiad Registration',
      );
    }
  }
}

// ─── Method Tile ──────────────────────────────────────────────────────────────

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
                  Text(subtitle,
                      style:
                          TextStyle(fontSize: 11.sp, color: Colors.black38)),
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