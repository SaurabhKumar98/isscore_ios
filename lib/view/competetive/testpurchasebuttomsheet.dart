// import 'package:firstedu/data/models/api_models/competetive/avilabletestcompetetionmodels.dart';
// import 'package:firstedu/data/models/api_models/competetive/purchasecompetetionmodels.dart'
//     show PurchaseData;
// import 'package:firstedu/res/constants/colors/appcolors.dart';
// import 'package:firstedu/utils/apptoster/errortoaster.dart';
// import 'package:firstedu/view_models/competetiveprovider/competetionprovider.dart';
// import 'package:firstedu/view_models/razropaymanger/razorpayservices.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';

// class TestPaymentSheet extends StatefulWidget {
//   final TestData test;
//   final VoidCallback? onPurchaseSuccess;

//   const TestPaymentSheet({
//     super.key,
//     required this.test,
//     this.onPurchaseSuccess,
//   });

//   @override
//   State<TestPaymentSheet> createState() => _TestPaymentSheetState();
// }

// class _TestPaymentSheetState extends State<TestPaymentSheet> {
//   String _paymentMethod = 'razorpay';
//   final _couponCtrl = TextEditingController();
//   bool _isPayLoading = false;

//   TestData get _test => widget.test;
//   int get _basePrice =>
//     _test.effectivePrice ?? _test.price ?? 0;

//   // ── Lifecycle ──────────────────────────────────────────────────────────────

//   @override
//   void initState() {
//     super.initState();
//     RazorpayManager.instance.init(
//       onSuccess: _onRazorpaySuccess,
//       onError: _onRazorpayError,
//     );
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) context.read<CompetitionProvider>().clearCoupon();
//     });
//   }

//   @override
//   void dispose() {
//     _couponCtrl.dispose();
//     RazorpayManager.instance.clear();
//     super.dispose();
//   }

//   // ── Razorpay Callbacks ─────────────────────────────────────────────────────

//   void _onRazorpaySuccess(PaymentSuccessResponse response) async {
//     debugPrint('✅ Razorpay test success: ${response.paymentId}');

//     final provider = context.read<CompetitionProvider>();
//     setState(() => _isPayLoading = true);

//     final ok = await provider.completeTestRazorpayPayment(
//       context,
//       testId: _test.id ?? '',
//       razorpayOrderId: response.orderId ?? '',
//       razorpayPaymentId: response.paymentId ?? '',
//       razorpaySignature: response.signature ?? '',
//     );

//     if (!mounted) return;
//     setState(() => _isPayLoading = false);

//     Navigator.pop(context);

//     if (ok) widget.onPurchaseSuccess?.call();

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           ok
//               ? 'Payment successful! Test unlocked 🎉'
//               : 'Verification failed. Contact support.',
//         ),
//         backgroundColor: ok ? Colors.green[700] : Colors.red[700],
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
  
//   }

//   void _onRazorpayError(PaymentFailureResponse response) {
//     debugPrint('❌ Razorpay test error: ${response.message}');
//     if (!mounted) return;
//     setState(() => _isPayLoading = false);

//     // ScaffoldMessenger.of(context).showSnackBar(
//     //   SnackBar(
//     //     content: Text('Payment cancelled or failed: ${response.message ?? ""}'),
//     //     backgroundColor: Colors.red[700],
//     //     behavior: SnackBarBehavior.floating,
//     //   ),
//     // );
//     AppToast.error(context, message:'Payment cancelled or failed: ${response.message ?? ""}' );
//   }

//   // ── Open Razorpay ──────────────────────────────────────────────────────────

//   void _openRazorpay(CompetitionProvider provider) {
//     final rawOrder = provider.pendingTestOrder;
//     if (rawOrder == null) {
//       debugPrint('❌ pendingTestOrder is null');
//       return;
//     }

//     final PurchaseData order = rawOrder as PurchaseData;

//     debugPrint('🚀 key=${order.key} amount=${order.amount} orderId=${order.orderId}');

//     if ((order.key ?? '').isEmpty || (order.orderId ?? '').isEmpty) {
//       debugPrint('❌ key or orderId is empty — cannot open Razorpay');
//       // ScaffoldMessenger.of(context).showSnackBar(
//       //   SnackBar(
//       //     content: const Text('Payment setup failed. Try again.'),
//       //     backgroundColor: Colors.red[700],
//       //     behavior: SnackBarBehavior.floating,
//       //   ),
//       // );
//       AppToast.error(context, message: 'Payment setup failed. Try again.');
//       return;
//     }

//     RazorpayManager.instance.openCheckout(
//       key: order.key ?? '',
//       amount: order.amount ?? 0,
//       orderId: order.orderId ?? '',
//       currency: order.currency ?? 'INR',
//       title: _test.title ?? 'FirstEdu',
//       description: 'Test Purchase',
//     );
//   }

//   // ── Computed ───────────────────────────────────────────────────────────────

//  num _getFinalPrice(CompetitionProvider provider) {
//   final coupon = provider.appliedCoupon;
//   if (coupon?.discountedPrice != null) {
//     return coupon!.discountedPrice!;
//   }
//   return _basePrice;
// }

//   // ── Coupon ─────────────────────────────────────────────────────────────────

//   Future<void> _applyCoupon() async {
//     final code = _couponCtrl.text.trim();
//     if (code.isEmpty) return;
//     await context.read<CompetitionProvider>().applyCoupon(
//           context,
//           code: code,
//           amount: _basePrice,
//           itemType: 'test',
//         );
//     if (mounted) setState(() {});
//   }

//   void _removeCoupon() {
//     _couponCtrl.clear();
//     context.read<CompetitionProvider>().clearCoupon();
//     setState(() {});
//   }

//   // ── Pay ────────────────────────────────────────────────────────────────────

//   Future<void> _handlePay(CompetitionProvider provider) async {
//     final finalPrice = _getFinalPrice(provider);
//     final isFree = finalPrice == 0;
//     final method = isFree ? 'free' : _paymentMethod;
//     final couponCode =
//         provider.appliedCoupon != null ? _couponCtrl.text.trim() : null;

//     setState(() => _isPayLoading = true);

//     final result = await provider.initiateTestPayment(
//       context,
//       testId: _test.id ?? '',
//       paymentMethod: method,
//       couponCode: couponCode,
//     );

//     if (!mounted) return;

//     if (result == 'success') {
//       setState(() => _isPayLoading = false);
//       Navigator.pop(context);
//       widget.onPurchaseSuccess?.call();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content:
//               Text(isFree ? 'Enrolled successfully! 🎉' : 'Payment successful! 🎉'),
//           backgroundColor: Colors.green[700],
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } else if (result == 'razorpay') {
//       _openRazorpay(provider);
//       setState(() => _isPayLoading = false);
//     } else {
//       setState(() => _isPayLoading = false);
//     }
//   }

//   // ── Build ──────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<CompetitionProvider>(
//       builder: (context, provider, _) {
//         final couponData = provider.appliedCoupon;
//         final isCouponApplied = couponData != null;
//         final couponDiscount = couponData?.discount ?? 0;
//         final finalPrice = _getFinalPrice(provider);
//         final isFree = finalPrice == 0;

//         return Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//           ),
//           padding: EdgeInsets.fromLTRB(
//             20,
//             12,
//             20,
//             24 + MediaQuery.of(context).viewInsets.bottom,
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildHandle(),
//                 const SizedBox(height: 20),
//                 _buildHeader(isFree),
//                 const SizedBox(height: 20),
//                 _buildMetaChips(),
//                 const SizedBox(height: 20),
//                 _buildPriceSummary(
//                   isCouponApplied: isCouponApplied,
//                   couponDiscount: couponDiscount,
//                   finalPrice: finalPrice,
//                 ),
//                 const SizedBox(height: 20),
//                 _buildCouponField(
//                   isCouponApplied: isCouponApplied,
//                   isLoading: provider.isCouponLoading,
//                   error: provider.couponError,
//                   couponDiscount: couponDiscount,
//                 ),
//                 const SizedBox(height: 20),
//                 if (!isFree) ...[
//                   _buildPaymentMethod(),
//                   const SizedBox(height: 24),
//                 ] else
//                   const SizedBox(height: 4),
//                 _buildPayButton(
//                   isFree: isFree,
//                   finalPrice: finalPrice,
//                   provider: provider,
//                 ),
//                 const SizedBox(height: 12),
//                 _buildSecureNote(),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ── Drag Handle ────────────────────────────────────────────────────────────

//   Widget _buildHandle() => Center(
//         child: Container(
//           width: 40,
//           height: 4,
//           decoration: BoxDecoration(
//             color: Colors.grey[300],
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ),
//       );

//   // ── Header ─────────────────────────────────────────────────────────────────

//   Widget _buildHeader(bool isFree) => Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: activeItemColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(Icons.assignment_rounded,
//                 color: activeItemColor, size: 22),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   isFree ? 'Enroll Free' : 'Purchase Test',
//                   style: GoogleFonts.poppins(
//                     fontSize: 17,
//                     fontWeight: FontWeight.w700,
//                     color: const Color(0xFF1A1D26),
//                   ),
//                 ),
//                 Text(
//                   _test.title ?? '',
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: GoogleFonts.poppins(
//                     fontSize: 12,
//                     color: Colors.grey[500],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       );

//   // ── Meta Chips ─────────────────────────────────────────────────────────────

//   Widget _buildMetaChips() => Row(
//         children: [
//           _chip(Icons.timer_outlined, '${_test.durationMinutes ?? 0} mins'),
//           const SizedBox(width: 8),
//           _chip(Icons.quiz_outlined,
//               '${_test.title ?? 0} questions'),
//         ],
//       );

//   Widget _chip(IconData icon, String label) => Container(
//         padding:
//             const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF6F7FB),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: const Color(0xFFE5E7EF)),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 13, color: Colors.grey[500]),
//             const SizedBox(width: 4),
//             Text(label,
//                 style: GoogleFonts.poppins(
//                     fontSize: 12, color: Colors.grey[600])),
//           ],
//         ),
//       );

//   // ── Price Summary ──────────────────────────────────────────────────────────

//   Widget _buildPriceSummary({
//     required bool isCouponApplied,
//     required num couponDiscount,
//     required num finalPrice,
//   }) {
//     final originalPrice = _test.originalPrice ?? _basePrice;
//     final offerDiscount = originalPrice - _basePrice;
//     final hasOfferDiscount = offerDiscount > 0;
//     final hasAnyDiscount = hasOfferDiscount || isCouponApplied;

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF6F7FB),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         children: [
//           if (hasAnyDiscount) ...[
//             _priceRow('Original Price', '₹$originalPrice',
//                 strikethrough: true, valueColor: Colors.grey[500]!),
//             const SizedBox(height: 6),
//           ],
//           if (hasOfferDiscount) ...[
//             _priceRow('Offer Discount', '- ₹$offerDiscount',
//                 valueColor: Colors.green[700]!),
//             const SizedBox(height: 6),
//           ],
//           if (isCouponApplied && couponDiscount > 0) ...[
//             _priceRow(
//               'Coupon (${_couponCtrl.text.trim()})',
//               '- ₹$couponDiscount',
//               valueColor: Colors.green[700]!,
//             ),
//             const SizedBox(height: 6),
//           ],
//           if (hasAnyDiscount)
//             const Divider(height: 12, color: Color(0xFFE5E7EF)),
//           Row(
//             children: [
//               Text(
//                 'Total',
//                 style: GoogleFonts.poppins(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w700,
//                   color: const Color(0xFF1A1D26),
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 finalPrice == 0 ? 'FREE' : '₹$finalPrice',
//                 style: GoogleFonts.poppins(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w800,
//                   color: finalPrice == 0
//                       ? Colors.green[700]
//                       : activeItemColor,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _priceRow(
//     String label,
//     String value, {
//     bool strikethrough = false,
//     Color? valueColor,
//   }) =>
//       Row(
//         children: [
//           Text(label,
//               style: GoogleFonts.poppins(
//                   fontSize: 13, color: Colors.grey[500])),
//           const Spacer(),
//           Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: 13,
//               fontWeight: FontWeight.w500,
//               color: valueColor ?? const Color(0xFF1A1D26),
//               decoration:
//                   strikethrough ? TextDecoration.lineThrough : null,
//             ),
//           ),
//         ],
//       );

//   // ── Coupon Field ───────────────────────────────────────────────────────────

//   Widget _buildCouponField({
//     required bool isCouponApplied,
//     required bool isLoading,
//     required String? error,
//     required num couponDiscount,
//   }) =>
//       Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Have a coupon?',
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: const Color(0xFF1A1D26),
//             ),
//           ),
//           const SizedBox(height: 10),
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _couponCtrl,
//                   enabled: !isCouponApplied,
//                   textCapitalization: TextCapitalization.characters,
//                   style: GoogleFonts.poppins(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     letterSpacing: 1.2,
//                   ),
//                   decoration: InputDecoration(
//                     hintText: 'Enter code',
//                     hintStyle: GoogleFonts.poppins(
//                       fontSize: 13,
//                       color: Colors.grey[400],
//                       fontWeight: FontWeight.normal,
//                       letterSpacing: 0,
//                     ),
//                     filled: true,
//                     fillColor: const Color(0xFFF6F7FB),
//                     contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 14, vertical: 14),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide:
//                           const BorderSide(color: Color(0xFFE5E7EF)),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide:
//                           const BorderSide(color: Color(0xFFE5E7EF)),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide:
//                           BorderSide(color: activeItemColor, width: 1.5),
//                     ),
//                     suffixIcon: isCouponApplied
//                         ? Icon(Icons.check_circle_rounded,
//                             color: Colors.green[600], size: 20)
//                         : null,
//                   ),
//                   onSubmitted: (_) =>
//                       isCouponApplied ? null : _applyCoupon(),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               isLoading
//                   ? const SizedBox(
//                       width: 52,
//                       height: 52,
//                       child: Center(
//                         child: SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         ),
//                       ),
//                     )
//                   : GestureDetector(
//                       onTap:
//                           isCouponApplied ? _removeCoupon : _applyCoupon,
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 180),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 18, vertical: 15),
//                         decoration: BoxDecoration(
//                           color: isCouponApplied
//                               ? Colors.green.withOpacity(0.1)
//                               : activeItemColor,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           isCouponApplied ? 'Remove' : 'Apply',
//                           style: GoogleFonts.poppins(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w700,
//                             color: isCouponApplied
//                                 ? Colors.green[700]
//                                 : Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//             ],
//           ),
//           if (error != null && error.isNotEmpty) ...[
//             const SizedBox(height: 6),
//             Row(
//               children: [
//                 Icon(Icons.error_outline, size: 14, color: Colors.red[400]),
//                 const SizedBox(width: 4),
//                 Expanded(
//                   child: Text(error,
//                       style: GoogleFonts.poppins(
//                           fontSize: 12, color: Colors.red[400])),
//                 ),
//               ],
//             ),
//           ],
//           if (isCouponApplied && couponDiscount > 0) ...[
//             const SizedBox(height: 6),
//             Row(
//               children: [
//                 Icon(Icons.local_offer_rounded,
//                     size: 13, color: Colors.green[600]),
//                 const SizedBox(width: 5),
//                 Text(
//                   'You save ₹$couponDiscount with this coupon!',
//                   style: GoogleFonts.poppins(
//                     fontSize: 12,
//                     color: Colors.green[700],
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ],
//       );

//   // ── Payment Method ─────────────────────────────────────────────────────────

//   Widget _buildPaymentMethod() => Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Payment Method',
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: const Color(0xFF1A1D26),
//             ),
//           ),
//           const SizedBox(height: 10),
//           _MethodTile(
//             icon: Icons.payment_rounded,
//             title: 'Razorpay',
//             subtitle: 'UPI, Cards, Net Banking & more',
//             color: const Color(0xFF0EA5E9),
//             selected: _paymentMethod == 'razorpay',
//             onTap: () => setState(() => _paymentMethod = 'razorpay'),
//           ),
//           const SizedBox(height: 8),
//           _MethodTile(
//             icon: Icons.account_balance_wallet_rounded,
//             title: 'Wallet',
//             subtitle: 'Pay using your wallet balance',
//             color: const Color(0xFF7C3AED),
//             selected: _paymentMethod == 'wallet',
//             onTap: () => setState(() => _paymentMethod = 'wallet'),
//           ),
//         ],
//       );

//   // ── Pay Button ─────────────────────────────────────────────────────────────

//   Widget _buildPayButton({
//     required bool isFree,
//     required num finalPrice,
//     required CompetitionProvider provider,
//   }) =>
//       GestureDetector(
//         onTap: _isPayLoading ? null : () => _handlePay(provider),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           width: double.infinity,
//           height: 54,
//           decoration: BoxDecoration(
//             color: _isPayLoading
//                 ? activeItemColor.withOpacity(0.5)
//                 : activeItemColor,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: _isPayLoading
//                 ? null
//                 : [
//                     BoxShadow(
//                       color: activeItemColor.withOpacity(0.3),
//                       blurRadius: 12,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//           ),
//           child: Center(
//             child: _isPayLoading
//                 ? const SizedBox(
//                     width: 22,
//                     height: 22,
//                     child: CircularProgressIndicator(
//                         strokeWidth: 2.5, color: Colors.white),
//                   )
//                 : Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         isFree
//                             ? Icons.lock_open_rounded
//                             : Icons.payment_rounded,
//                         color: Colors.white,
//                         size: 18,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         isFree ? 'Enroll Free' : 'Pay ₹$finalPrice',
//                         style: GoogleFonts.poppins(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//           ),
//         ),
//       );

//   // ── Secure Note ────────────────────────────────────────────────────────────

//   Widget _buildSecureNote() => Center(
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.shield_outlined, size: 13, color: Colors.grey[400]),
//             const SizedBox(width: 4),
//             Text(
//               'Secure & encrypted payment',
//               style: GoogleFonts.poppins(
//                   fontSize: 11, color: Colors.grey[400]),
//             ),
//           ],
//         ),
//       );
// }

// // ══════════════════════════════════════════════════════════════════════════════
// // METHOD TILE
// // ══════════════════════════════════════════════════════════════════════════════

// class _MethodTile extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final Color color;
//   final bool selected;
//   final VoidCallback onTap;

//   const _MethodTile({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.color,
//     required this.selected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) => GestureDetector(
//         onTap: onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 180),
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             color: selected ? color.withOpacity(0.06) : Colors.white,
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(
//               color: selected ? color : const Color(0xFFE4E5EF),
//               width: selected ? 2 : 1.2,
//             ),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 width: 42,
//                 height: 42,
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(11),
//                 ),
//                 child: Icon(icon, color: color, size: 20),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(title,
//                         style: GoogleFonts.poppins(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: const Color(0xFF1A1D26),
//                         )),
//                     Text(subtitle,
//                         style: GoogleFonts.poppins(
//                             fontSize: 11, color: Colors.grey[500])),
//                   ],
//                 ),
//               ),
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 180),
//                 width: 20,
//                 height: 20,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: selected ? color : const Color(0xFFCDD0DA),
//                     width: selected ? 6 : 2,
//                   ),
//                   color: selected ? color : Colors.transparent,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
// }