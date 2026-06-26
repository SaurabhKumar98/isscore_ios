// // ─────────────────────────────────────────────────────────────────────────────
// // categorypaymentsheet.dart
// //
// // Bottom sheet for purchasing a competition bundle.
// // Supports: free enrol · wallet · Razorpay
// // After success → opens SingleCompetitionSheet via rootContext.
// // ─────────────────────────────────────────────────────────────────────────────

// import 'package:firstedu/data/models/api_models/competetive/competetionbyid_models.dart';
// import 'package:firstedu/res/constants/colors/appcolors.dart';
// import 'package:firstedu/utils/apptoster/errortoaster.dart';
// import 'package:firstedu/view/competetive/singlecompetetionsheet.dart';
// import 'package:firstedu/view_models/competetiveprovider/competetionprovider.dart';
// import 'package:firstedu/view_models/razropaymanger/razorpayservices.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';

// class CategoryPaymentSheet extends StatefulWidget {
//   final Competition competition;
//   final String sectorId;

//   const CategoryPaymentSheet({
//     super.key,
//     required this.competition,
//     required this.sectorId,
//   });

//   @override
//   State<CategoryPaymentSheet> createState() => _CategoryPaymentSheetState();
// }

// class _CategoryPaymentSheetState extends State<CategoryPaymentSheet> {
//   bool _isLoading = false;
//   String? _error;
//   String _selectedMethod = 'razorpay';

//   final TextEditingController _couponCtrl = TextEditingController();
//   bool _couponApplied = false;
//   String? _couponError;

//   Competition get _comp => widget.competition;

//   @override
//   void dispose() {
//     _couponCtrl.dispose();
//     super.dispose();
//   }

//   // ── Build ─────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final offer = _comp.appliedOffer;
//     final hasDiscount = _comp.discountAmount > 0;
//     final isFreeOrZero = _comp.isFree || (_comp.effectivePrice ?? 0) == 0;

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//       ),
//       padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Drag handle
//             Center(
//               child: Container(
//                 width: 36.w,
//                 height: 4.h,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFDDDEE6),
//                   borderRadius: BorderRadius.circular(4.r),
//                 ),
//               ),
//             ),
//             SizedBox(height: 20.h),

//             Text(
//               'Buy Bundle',
//               style: TextStyle(
//                 fontSize: 18.sp,
//                 fontWeight: FontWeight.w800,
//                 color: const Color(0xFF1A1D26),
//               ),
//             ),
//             SizedBox(height: 4.h),
//             Text(
//               _comp.title,
//               style: TextStyle(fontSize: 13.sp, color: Colors.black45),
//             ),
//             SizedBox(height: 16.h),

//             // Included tests preview
//             if (_comp.tests.isNotEmpty) ...[
//               Text(
//                 'Includes ${_comp.tests.length} test${_comp.tests.length > 1 ? 's' : ''}',
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   fontWeight: FontWeight.w600,
//                   color: activeItemColor,
//                 ),
//               ),
//               SizedBox(height: 8.h),
//               ..._comp.tests.take(3).map(
//                     (t) => Padding(
//                       padding: EdgeInsets.only(bottom: 4.h),
//                       child: Row(
//                         children: [
//                           Icon(Icons.check_circle_outline_rounded,
//                               size: 14.sp, color: Colors.green),
//                           SizedBox(width: 6.w),
//                           Expanded(
//                             child: Text(
//                               t.title,
//                               style: TextStyle(
//                                   fontSize: 12.sp, color: Colors.black54),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//               if (_comp.tests.length > 3)
//                 Text(
//                   '+ ${_comp.tests.length - 3} more',
//                   style: TextStyle(fontSize: 11.sp, color: Colors.black38),
//                 ),
//               SizedBox(height: 16.h),
//             ],

//             // Price summary
//             _PriceSummary(comp: _comp, hasDiscount: hasDiscount, offer: offer),
//             SizedBox(height: 16.h),

//             // Coupon + method (hidden for free)
//             if (!isFreeOrZero) ...[
//               _CouponField(
//                 ctrl: _couponCtrl,
//                 applied: _couponApplied,
//                 error: _couponError,
//                 onApply: _applyOrRemoveCoupon,
//                 onChanged: (_) {
//                   if (_couponError != null) {
//                     setState(() => _couponError = null);
//                   }
//                 },
//               ),
//               SizedBox(height: 16.h),
//               _MethodSelector(
//                 selected: _selectedMethod,
//                 onChanged: (m) => setState(() => _selectedMethod = m),
//               ),
//               SizedBox(height: 20.h),
//             ],

//             // Error
//             if (_error != null)
//               Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.all(12.w),
//                 margin: EdgeInsets.only(bottom: 12.h),
//                 decoration: BoxDecoration(
//                   color: Colors.red.shade50,
//                   borderRadius: BorderRadius.circular(10.r),
//                   border: Border.all(color: Colors.red.shade200),
//                 ),
//                 child: Text(
//                   _error!,
//                   style: TextStyle(
//                       fontSize: 12.sp, color: Colors.red.shade700),
//                 ),
//               ),

//             // Pay button
//             _PayButton(
//               isLoading: _isLoading,
//               isFreeOrZero: isFreeOrZero,
//               effectivePrice: _comp.effectivePrice ?? 0,
//               onTap: _isLoading ? null : () => _handleBuy(context),
//             ),
//             SizedBox(height: 8.h),

//             // Security note
//             Center(
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.shield_outlined,
//                       size: 12.sp, color: Colors.black26),
//                   SizedBox(width: 4.w),
//                   Text(
//                     'Secure & encrypted payment',
//                     style:
//                         TextStyle(fontSize: 11.sp, color: Colors.black26),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Coupon helpers ────────────────────────────────────────────────────────

//   void _applyOrRemoveCoupon() {
//     if (_couponApplied) {
//       setState(() {
//         _couponApplied = false;
//         _couponError = null;
//         _couponCtrl.clear();
//       });
//     } else {
//       final code = _couponCtrl.text.trim();
//       if (code.isEmpty) {
//         setState(() => _couponError = 'Enter a coupon code first.');
//       } else {
//         setState(() {
//           _couponApplied = true;
//           _couponError = null;
//         });
//       }
//     }
//   }

//   // ── Handle buy ────────────────────────────────────────────────────────────

//   Future<void> _handleBuy(BuildContext context) async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       final provider = context.read<CompetitionProvider>();

//       final method = (_comp.effectivePrice ?? 0) == 0
//           ? 'free'
//           : _selectedMethod;

//       final coupon =
//           _couponApplied && _couponCtrl.text.trim().isNotEmpty
//               ? _couponCtrl.text.trim()
//               : null;

//       final result = await provider.initiateCategoryPayment(
//         context,
//         categoryId: _comp.id,
//         paymentMethod: method,
//         couponCode: coupon,
//       );

//       if (!mounted) return;

//       // ── Wallet / Free ─────────────────────────────────────────────────
//       if (result == 'success') {
//         await provider.fetchSingleCompetition(context, _comp.id);
//         if (!mounted) return;

//         final rootCtx = provider.rootContext;
//         Navigator.of(context).pop();

//         await Future.delayed(const Duration(milliseconds: 300));

//         if (rootCtx != null && rootCtx.mounted) {
//           showModalBottomSheet(
//             context: rootCtx,
//             isScrollControlled: true,
//             backgroundColor: Colors.transparent,
//             builder: (_) => ChangeNotifierProvider.value(
//               value: provider,
//               child: SingleCompetitionSheet(competitionId: _comp.id),
//             ),
//           );
//         }
//         return;
//       }

//       // ── Razorpay ──────────────────────────────────────────────────────
//       if (result == 'razorpay' && method == 'razorpay') {
//         final order = provider.pendingCategoryOrder;
//         if (order == null) {
//           setState(() => _error = 'Could not get payment order.');
//           return;
//         }

//         Navigator.of(context).pop();

//         RazorpayManager.instance.init(
//           onSuccess: (res) async {
//             final ok = await provider.completeCategoryRazorpayPayment(
//               context,
//               categoryId: _comp.id,
//               razorpayOrderId: res.orderId!,
//               razorpayPaymentId: res.paymentId!,
//               razorpaySignature: res.signature!,
//             );
//             if (ok) {
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 final rootCtx = provider.rootContext;
//                 if (rootCtx != null && rootCtx.mounted) {
//                   showModalBottomSheet(
//                     context: rootCtx,
//                     isScrollControlled: true,
//                     backgroundColor: Colors.transparent,
//                     builder: (_) => ChangeNotifierProvider.value(
//                       value: provider,
//                       child:
//                           SingleCompetitionSheet(competitionId: _comp.id),
//                     ),
//                   );
//                 }
//               });
//             }
//           },
//           onError: (res) {
//             final isCancelled =
//                 res.code == Razorpay.PAYMENT_CANCELLED ||
//                     (res.message ?? '').toLowerCase().contains('cancel');
//             if (!isCancelled) {
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 final rootCtx = provider.rootContext;
//                 if (rootCtx != null && rootCtx.mounted) {
//                   AppToast.errorGlobal(
//                     message: res.message ?? 'Payment failed. Try again.',
//                   );
//                 }
//               });
//             }
//           },
//         );

//         RazorpayManager.instance.openCheckout(
//           key: order['key'] ?? '',
//           amount: order['amount'] ?? 0,
//           orderId: order['orderId'] ?? '',
//           title: _comp.title,
//           description: 'Competition Bundle',
//         );
//         return;
//       }

//       setState(() => _error = 'Unexpected payment state. Please try again.');
//     } catch (e) {
//       if (mounted) {
//         setState(
//             () => _error = e.toString().replaceFirst('Exception: ', ''));
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
// }

// // ── Price Summary ─────────────────────────────────────────────────────────────

// class _PriceSummary extends StatelessWidget {
//   final Competition comp;
//   final bool hasDiscount;
//   final CompetitionOffer? offer;

//   const _PriceSummary(
//       {required this.comp, required this.hasDiscount, required this.offer});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(14.w),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF6F7FB),
//         borderRadius: BorderRadius.circular(14.r),
//       ),
//       child: Column(
//         children: [
//           if (hasDiscount) ...[
//             Row(
//               children: [
//                 Text('Original Price',
//                     style:
//                         TextStyle(fontSize: 12.sp, color: Colors.black45)),
//                 const Spacer(),
//                 Text(
//                   '₹${comp.price}',
//                   style: TextStyle(
//                     fontSize: 13.sp,
//                     color: Colors.black38,
//                     decoration: TextDecoration.lineThrough,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 6.h),
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     offer != null
//                         ? '${offer!.offerName} (${offer!.discountValue}% off)'
//                         : 'Discount',
//                     style: TextStyle(
//                         fontSize: 12.sp, color: Colors.green[700]),
//                   ),
//                 ),
//                 Text(
//                   '- ₹${comp.discountAmount}',
//                   style: TextStyle(
//                       fontSize: 13.sp, color: Colors.green[700]),
//                 ),
//               ],
//             ),
//             Padding(
//               padding: EdgeInsets.symmetric(vertical: 8.h),
//               child: Divider(height: 1, color: Colors.grey[200]),
//             ),
//           ],
//           Row(
//             children: [
//               Text(
//                 'Total',
//                 style: TextStyle(
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w700,
//                   color: const Color(0xFF1A1D26),
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 (comp.effectivePrice ?? 0) == 0
//                     ? 'FREE'
//                     : '₹${comp.effectivePrice}',
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.w800,
//                   color: (comp.effectivePrice ?? 0) == 0
//                       ? Colors.green[700]!
//                       : drawerColor,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Coupon Field ──────────────────────────────────────────────────────────────

// class _CouponField extends StatelessWidget {
//   final TextEditingController ctrl;
//   final bool applied;
//   final String? error;
//   final VoidCallback onApply;
//   final ValueChanged<String> onChanged;

//   const _CouponField({
//     required this.ctrl,
//     required this.applied,
//     required this.error,
//     required this.onApply,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Have a coupon?',
//           style: TextStyle(
//             fontSize: 13.sp,
//             fontWeight: FontWeight.w700,
//             color: const Color(0xFF1A1D26),
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: ctrl,
//                 enabled: !applied,
//                 textCapitalization: TextCapitalization.characters,
//                 onChanged: onChanged,
//                 style: TextStyle(
//                   fontSize: 13.sp,
//                   fontWeight: FontWeight.w600,
//                   letterSpacing: 1.2,
//                 ),
//                 decoration: InputDecoration(
//                   hintText: 'Enter coupon code',
//                   hintStyle: TextStyle(
//                     fontSize: 12.sp,
//                     color: Colors.black38,
//                     fontWeight: FontWeight.normal,
//                     letterSpacing: 0,
//                   ),
//                   filled: true,
//                   fillColor: const Color(0xFFF6F7FB),
//                   contentPadding: EdgeInsets.symmetric(
//                       horizontal: 14.w, vertical: 12.h),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                     borderSide:
//                         BorderSide(color: Colors.grey.shade200),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                     borderSide:
//                         BorderSide(color: Colors.grey.shade200),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                     borderSide:
//                         BorderSide(color: activeItemColor, width: 1.5),
//                   ),
//                   suffixIcon: applied
//                       ? Icon(Icons.check_circle_rounded,
//                           color: Colors.green, size: 20.sp)
//                       : null,
//                 ),
//               ),
//             ),
//             SizedBox(width: 8.w),
//             GestureDetector(
//               onTap: onApply,
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 180),
//                 padding: EdgeInsets.symmetric(
//                     horizontal: 16.w, vertical: 13.h),
//                 decoration: BoxDecoration(
//                   color: applied
//                       ? Colors.green.withOpacity(0.1)
//                       : drawerColor,
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//                 child: Text(
//                   applied ? 'Remove' : 'Apply',
//                   style: TextStyle(
//                     fontSize: 13.sp,
//                     fontWeight: FontWeight.w700,
//                     color: applied ? Colors.green[700] : Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         if (error != null) ...[
//           SizedBox(height: 6.h),
//           Text(error!,
//               style: TextStyle(
//                   fontSize: 11.sp, color: Colors.red.shade600)),
//         ],
//         if (applied) ...[
//           SizedBox(height: 6.h),
//           Row(
//             children: [
//               Icon(Icons.local_offer_rounded,
//                   size: 13.sp, color: Colors.green[700]),
//               SizedBox(width: 5.w),
//               Expanded(
//                 child: Text(
//                   '"${ctrl.text.trim()}" will be applied at checkout',
//                   style: TextStyle(
//                     fontSize: 11.sp,
//                     color: Colors.green[700],
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ],
//     );
//   }
// }

// // ── Payment Method Selector ───────────────────────────────────────────────────

// class _MethodSelector extends StatelessWidget {
//   final String selected;
//   final ValueChanged<String> onChanged;

//   const _MethodSelector(
//       {required this.selected, required this.onChanged});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Payment Method',
//           style: TextStyle(
//             fontSize: 13.sp,
//             fontWeight: FontWeight.w700,
//             color: const Color(0xFF1A1D26),
//           ),
//         ),
//         SizedBox(height: 10.h),
//         MethodTile(
//           icon: Icons.account_balance_wallet_rounded,
//           title: 'Wallet',
//           subtitle: 'Pay using your wallet balance',
//           color: const Color(0xFF7C3AED),
//           selected: selected == 'wallet',
//           onTap: () => onChanged('wallet'),
//         ),
//         SizedBox(height: 8.h),
//         MethodTile(
//           icon: Icons.payment_rounded,
//           title: 'Razorpay',
//           subtitle: 'UPI, Cards, Net Banking & more',
//           color: const Color(0xFF0EA5E9),
//           selected: selected == 'razorpay',
//           onTap: () => onChanged('razorpay'),
//         ),
//       ],
//     );
//   }
// }

// // ── Pay Button ────────────────────────────────────────────────────────────────

// class _PayButton extends StatelessWidget {
//   final bool isLoading;
//   final bool isFreeOrZero;
//   final num effectivePrice;
//   final VoidCallback? onTap;

//   const _PayButton({
//     required this.isLoading,
//     required this.isFreeOrZero,
//     required this.effectivePrice,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         width: double.infinity,
//         height: 52.h,
//         decoration: BoxDecoration(
//           color: isLoading ? const Color(0xFFEEEFF3) : drawerColor,
//           borderRadius: BorderRadius.circular(14.r),
//           boxShadow: isLoading
//               ? null
//               : [
//                   BoxShadow(
//                     color: drawerColor.withOpacity(.3),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//         ),
//         child: Center(
//           child: isLoading
//               ? const SizedBox(
//                   width: 22,
//                   height: 22,
//                   child: CircularProgressIndicator(
//                       strokeWidth: 2, color: Colors.white),
//                 )
//               : Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.lock_open_rounded,
//                         size: 18.sp, color: Colors.white),
//                     SizedBox(width: 8.w),
//                     Text(
//                       isFreeOrZero
//                           ? 'Enrol Free'
//                           : 'Pay ₹$effectivePrice',
//                       style: TextStyle(
//                         fontSize: 15.sp,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }
// }

// // ── Method Tile ───────────────────────────────────────────────────────────────

// class MethodTile extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final Color color;
//   final bool selected;
//   final VoidCallback onTap;

//   const MethodTile({
//     super.key,
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.color,
//     required this.selected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         padding: EdgeInsets.all(14.w),
//         decoration: BoxDecoration(
//           color: selected ? color.withOpacity(.06) : Colors.white,
//           borderRadius: BorderRadius.circular(14.r),
//           border: Border.all(
//             color: selected ? color : const Color(0xFFE4E5EF),
//             width: selected ? 2 : 1.2,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 44.w,
//               height: 44.w,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(.1),
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               child: Icon(icon, color: color, size: 22.sp),
//             ),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 14.sp,
//                       fontWeight: FontWeight.w700,
//                       color: const Color(0xFF1A1D26),
//                     ),
//                   ),
//                   SizedBox(height: 2.h),
//                   Text(
//                     subtitle,
//                     style:
//                         TextStyle(fontSize: 11.sp, color: Colors.black38),
//                   ),
//                 ],
//               ),
//             ),
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 180),
//               width: 20.w,
//               height: 20.w,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color:
//                       selected ? color : const Color(0xFFCDD0DA),
//                   width: selected ? 6 : 2,
//                 ),
//                 color: selected ? color : Colors.transparent,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }