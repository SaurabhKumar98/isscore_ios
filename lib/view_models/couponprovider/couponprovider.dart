// // lib/view_models/coupon/coupon_mixin.dart

// import 'package:firstedu/core/error/app_exception.dart';
// import 'package:firstedu/data/models/api_models/competetive/applycoupanmodels.dart';
// import 'package:firstedu/data/repo/coupanrepo/coupon_repo.dart';
// import 'package:firstedu/utils/apptoster/errortoaster.dart';
// import 'package:flutter/material.dart';

// mixin CouponMixin on ChangeNotifier {
//   // ── Must be provided by the host provider ──
//   CouponRepo get couponRepo;

//   // ── State ──────────────────────────────────
//   bool _isCouponLoading = false;
//   bool get isCouponLoading => _isCouponLoading;

//   String? _couponError;
//   String? get couponError => _couponError;

//   CouponData? _appliedCoupon;
//   CouponData? get appliedCoupon => _appliedCoupon;

//   // ── Apply ──────────────────────────────────
//   Future<void> applyCoupon(
//     BuildContext context, {
//     required String code,
//     required int amount,
//     required String itemType,
//   }) async {
//     try {
//       _isCouponLoading = true;
//       _couponError = null;
//       _appliedCoupon = null;
//       notifyListeners();

//       final res = await couponRepo.applyCoupon(
//         code: code,
//         amount: amount,
//         itemType: itemType,
//       );

//       _appliedCoupon = res.data;
//     } on AppException catch (e) {
//       _couponError = e.message;
//       if (context.mounted) {
//         AppToast.error(context, title: 'Coupon Error', message: e.message);
//       }
//     } finally {
//       _isCouponLoading = false;
//       notifyListeners();
//     }
//   }

//   // ── Clear ──────────────────────────────────
//   void clearCoupon() {
//     _appliedCoupon = null;
//     _couponError = null;
//     notifyListeners();
//   }
// }