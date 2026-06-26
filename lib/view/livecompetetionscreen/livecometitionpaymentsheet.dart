// lib/view/live_competition/live_competition_payment_sheet.dart

import 'package:firstedu/data/models/api_models/livecompetetion/livecompetionmodels.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view_models/livecompetetionprovider/livecompetetiondetailsprovider.dart';
import 'package:firstedu/view_models/razropaymanger/razorpayservices.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class LiveCompetitionPaymentSheet extends StatefulWidget {
  final LiveCompetition competition;
  const LiveCompetitionPaymentSheet({required this.competition, super.key});

  @override
  State<LiveCompetitionPaymentSheet> createState() =>
      _LiveCompetitionPaymentSheetState();
}

class _LiveCompetitionPaymentSheetState
    extends State<LiveCompetitionPaymentSheet> {
  bool _isLoading = false;
  String? _error;
  String _selectedMethod = 'razorpay';
  final TextEditingController _couponCtrl = TextEditingController();
  bool _couponApplied = false;
  String? _couponError;

  LiveCompetition get _comp => widget.competition;

  // ─── FIX: always resolve fee/price from megaAudition first ───────────────
  // The top-level fee/submission fields are null when the API nests
  // everything inside megaAudition / grandFinale.

  LiveCompetitionFee? get _activeFee => _comp.megaAudition?.fee ?? _comp.fee;

  LiveCompetitionSubmission? get _activeSubmission =>
      _comp.megaAudition?.submission ?? _comp.submission;

  double get _originalPrice => _activeFee?.amount?.toDouble() ?? 0;

  double get _effectivePrice {
    final dp = _comp.megaAudition?.discountedPrice ?? _comp.discountedPrice;
    if (dp != null) return dp;
    return _originalPrice;
  }

  double get _discountAmount {
    final diff = _originalPrice - _effectivePrice;
    return diff > 0 ? diff : 0;
  }

  bool get _isFree => _activeFee?.isPaid == false || _originalPrice == 0;

  // Whether registration is actually open (reads from megaAudition)
  bool get _isRegOpen =>
      _comp.megaAudition?.isRegistrationOpen ??
      _comp.isRegistrationOpen ??
      false;

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LiveCompetitionProvider>();
    final coupon = provider.appliedCoupon;
    final finalPrice = coupon?.discountedPrice ?? _effectivePrice.toInt();
    final isFreeOrZero = _isFree || finalPrice == 0;

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

              // ── Header ──────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.live_tv,
                      color: Colors.red[700],
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Register for Live Event',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1D26),
                          ),
                        ),
                        Text(
                          _comp.title ?? '',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black45,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),

              // ── Info chips ───────────────────────────────────────────────
              _buildInfoChips(),
              SizedBox(height: 16.h),

              // ── Price summary ────────────────────────────────────────────
              _buildPriceSummary(
                couponDiscount: coupon?.discount,
                finalPrice: finalPrice,
              ),
              SizedBox(height: 16.h),

              // ── Coupon + method (hidden for free) ────────────────────────
              if (!isFreeOrZero) ...[
                _buildCouponField(provider),
                SizedBox(height: 16.h),
                _buildMethodSelector(),
                SizedBox(height: 20.h),
              ],

              // ── Error ────────────────────────────────────────────────────
              if (_error != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  margin: EdgeInsets.only(bottom: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),

              // ── Pay / Register button ─────────────────────────────────────
              _buildPayButton(
                isFreeOrZero: isFreeOrZero,
                finalPrice: finalPrice,
              ),
              SizedBox(height: 8.h),

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

  // ── Info Chips ────────────────────────────────────────────────────────────
  // FIX: reads from _activeSubmission (megaAudition.submission)

  Widget _buildInfoChips() {
    final chips = <_ChipData>[];

    if (_comp.category?.name != null)
      chips.add(
        _ChipData(
          icon: Icons.category_outlined,
          label: _comp.category!.name!,
          color: activeItemColor,
        ),
      );

    if ((_activeSubmission?.duration ?? 0) > 0)
      chips.add(
        _ChipData(
          icon: Icons.timer_outlined,
          label: '${_activeSubmission!.duration} min',
          color: Colors.orange,
        ),
      );

    if (_activeSubmission?.type != null)
      chips.add(
        _ChipData(
          icon: _activeSubmission!.type == 'TEXT'
              ? Icons.text_fields_outlined
              : Icons.attach_file_outlined,
          label: _activeSubmission!.type!,
          color: Colors.purple,
        ),
      );

    // Show round count
    final rounds =
        (_comp.megaAudition != null ? 1 : 0) +
        (_comp.grandFinale != null ? 1 : 0);
    if (rounds > 0)
      chips.add(
        _ChipData(
          icon: Icons.emoji_events_outlined,
          label: '$rounds Round${rounds > 1 ? 's' : ''}',
          color: Colors.teal,
        ),
      );

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: chips
          .map(
            (c) => Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: c.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: c.color.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(c.icon, size: 13.sp, color: c.color),
                  SizedBox(width: 4.w),
                  Text(
                    c.label,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: c.color,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // ── Price Summary ─────────────────────────────────────────────────────────
  // FIX: uses _originalPrice, _effectivePrice, _discountAmount from megaAudition

  Widget _buildPriceSummary({
    required num? couponDiscount,
    required num finalPrice,
  }) {
    final hasDiscount = _discountAmount > 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          // Original price row (shown when discount exists)
          if (hasDiscount) ...[
            Row(
              children: [
                Text(
                  'Original Price',
                  style: TextStyle(fontSize: 12.sp, color: Colors.black45),
                ),
                const Spacer(),
                Text(
                  '₹${_originalPrice.toStringAsFixed(0)}',
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
                Expanded(
                  child: Text(
                    _comp.megaAudition?.appliedOffer != null
                        ? '${_comp.megaAudition!.appliedOffer!.offerName} (${_comp.megaAudition!.appliedOffer!.discountValue?.toStringAsFixed(0)}% off)'
                        : 'Discount',
                    style: TextStyle(fontSize: 12.sp, color: Colors.green[700]),
                  ),
                ),
                Text(
                  '- ₹${_discountAmount.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 13.sp, color: Colors.green[700]),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Divider(height: 1, color: Colors.grey[200]),
            ),
          ],

          // Coupon discount row
          if ((couponDiscount ?? 0) > 0) ...[
            Row(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.confirmation_number_outlined,
                      size: 13.sp,
                      color: Colors.green[700],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Coupon "${_couponCtrl.text.trim()}"',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '- ₹$couponDiscount',
                  style: TextStyle(fontSize: 13.sp, color: Colors.green[700]),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Divider(height: 1, color: Colors.grey[200]),
            ),
          ],

          // Total row
          Row(
            children: [
              Text(
                'Total',
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
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: finalPrice == 0 ? Colors.green[700]! : drawerColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Coupon Field ──────────────────────────────────────────────────────────

  Widget _buildCouponField(LiveCompetitionProvider provider) {
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
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _couponApplied
                      ? Colors.green.withOpacity(0.06)
                      : const Color(0xFFF6F7FB),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _couponApplied
                        ? Colors.green
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
                    color: _couponApplied ? Colors.green[700] : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code',
                    hintStyle: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.black38,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 0,
                    ),
                    prefixIcon: Icon(
                      _couponApplied
                          ? Icons.check_circle_rounded
                          : Icons.confirmation_number_outlined,
                      size: 18.sp,
                      color: _couponApplied
                          ? Colors.green[700]
                          : Colors.black38,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 14.h,
                    ),
                  ),
                  onChanged: (_) {
                    if (_couponError != null)
                      setState(() => _couponError = null);
                  },
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: provider.isCouponLoading
                  ? null
                  : () async {
                      if (_couponApplied) {
                        provider.clearCoupon();
                        setState(() {
                          _couponApplied = false;
                          _couponError = null;
                          _couponCtrl.clear();
                        });
                        return;
                      }
                      final code = _couponCtrl.text.trim();
                      if (code.isEmpty) {
                        setState(
                          () => _couponError = 'Enter a coupon code first.',
                        );
                        return;
                      }

                      // FIX: pass _effectivePrice (from megaAudition), not _comp.effectivePrice
                      await provider.applyCoupon(
                        context,
                        code: code,
                        amount: _effectivePrice.toInt(),
                        itemType: 'LiveCompetition',
                      );
                      if (!mounted) return;
                      if (provider.appliedCoupon != null) {
                        setState(() {
                          _couponApplied = true;
                          _couponError = null;
                        });
                      } else {
                        setState(() {
                          _couponError =
                              provider.couponError ?? 'Invalid coupon code.';
                          _couponApplied = false;
                        });
                      }
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
                decoration: BoxDecoration(
                  color: _couponApplied ? Colors.red.shade50 : drawerColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
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
                style: TextStyle(fontSize: 11.sp, color: Colors.red.shade600),
              ),
            ],
          ),
        ],
        if (_couponApplied) ...[
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(
                Icons.celebration_rounded,
                size: 13.sp,
                color: Colors.green[700],
              ),
              SizedBox(width: 5.w),
              Expanded(
                child: Text(
                  'Coupon applied! You saved ₹${provider.appliedCoupon?.discount ?? 0}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ── Method Selector ───────────────────────────────────────────────────────

  Widget _buildMethodSelector() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Payment Method',
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1D26),
        ),
      ),
      SizedBox(height: 10.h),
      _MethodTile(
        icon: Icons.account_balance_wallet_rounded,
        title: 'Wallet',
        subtitle: 'Pay using your wallet balance',
        color: const Color(0xFF7C3AED),
        selected: _selectedMethod == 'wallet',
        onTap: () => setState(() => _selectedMethod = 'wallet'),
      ),
      SizedBox(height: 8.h),
      _MethodTile(
        icon: Icons.payment_rounded,
        title: 'Razorpay',
        subtitle: 'UPI, Cards, Net Banking & more',
        color: const Color(0xFF0EA5E9),
        selected: _selectedMethod == 'razorpay',
        onTap: () => setState(() => _selectedMethod = 'razorpay'),
      ),
    ],
  );

  // ── Pay Button ────────────────────────────────────────────────────────────

  Widget _buildPayButton({
    required bool isFreeOrZero,
    required num finalPrice,
  }) {
    return GestureDetector(
      onTap: _isLoading ? null : () => _handlePay(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          color: _isLoading ? const Color(0xFFEEEFF3) : drawerColor,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: _isLoading
              ? null
              : [
                  BoxShadow(
                    color: drawerColor.withOpacity(.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: _isLoading
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
                      Icons.lock_open_rounded,
                      size: 18.sp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      // FIX: show correct price from megaAudition
                      isFreeOrZero ? 'Register Free' : 'Pay ₹$finalPrice',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ── Handle Pay ────────────────────────────────────────────────────────────

  Future<void> _handlePay(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final provider = context.read<LiveCompetitionProvider>();

      // FIX: use _isFree (resolved from megaAudition), not _comp.isFree
      final method = _isFree ? 'free' : _selectedMethod;
      final coupon = _couponApplied && _couponCtrl.text.trim().isNotEmpty
          ? _couponCtrl.text.trim()
          : null;

      final result = await provider.initiatePayment(
        context,
        competitionId: _comp.id!,
        paymentMethod: method,
        couponCode: coupon,
      );

      if (!mounted) return;

      if (result == 'success') {
        Navigator.of(context).pop();
        _showSuccessSnack(context);
        return;
      }

      if (result == 'razorpay' && method == 'razorpay') {
        final order = provider.pendingOrder;
        if (order == null) {
          setState(() => _error = 'Could not get payment order.');
          return;
        }

        Navigator.of(context).pop();

        RazorpayManager.instance.init(
          onSuccess: (res) async {
            final ok = await provider.completeRazorpayPayment(
              context,
              competitionId: _comp.id!,
              razorpayOrderId: res.orderId!,
              razorpayPaymentId: res.paymentId!,
              razorpaySignature: res.signature!,
            );
            if (ok) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final rootCtx = provider.rootContext;
                if (rootCtx != null && rootCtx.mounted)
                  _showSuccessSnack(rootCtx);
              });
            }
          },
          onError: (res) {
            final isCancelled =
                res.code == Razorpay.PAYMENT_CANCELLED ||
                (res.message ?? '').toLowerCase().contains('cancel');
            if (!isCancelled) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final rootCtx = provider.rootContext;
                if (rootCtx != null && rootCtx.mounted)
                  AppToast.errorGlobal(
                    message: res.message ?? 'Payment failed. Try again.',
                  );
              });
            }
          },
        );

        RazorpayManager.instance.openCheckout(
          key: order.key ?? '',
          amount: order.amount ?? 0,
          orderId: order.orderId ?? '',
          title: _comp.title ?? 'Live Competition',
          description: 'Live Competition Registration',
        );
        return;
      }

      setState(() => _error = 'Unexpected payment state. Please try again.');
    } catch (e) {
      if (mounted)
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnack(BuildContext ctx) {
    // ScaffoldMessenger.of(ctx).showSnackBar(
    //   SnackBar(
    //     content: Row(
    //       children: [
    //         const Icon(Icons.check_circle, color: Colors.white),
    //         const SizedBox(width: 10),
    //         Text(
    //           'Registered successfully! 🎉',
    //           style: GoogleFonts.poppins(
    //             fontWeight: FontWeight.w600,
    //             color: Colors.white,
    //           ),
    //         ),
    //       ],
    //     ),
    //     backgroundColor: Colors.green[700],
    //     behavior: SnackBarBehavior.floating,
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    //     margin: const EdgeInsets.all(16),
    //   ),
    // );
  AppToast.success(context, message:'Registered successfully!' );
  
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _ChipData {
  final IconData icon;
  final String label;
  final Color color;
  _ChipData({required this.icon, required this.label, required this.color});
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
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
