import 'package:firstedu/data/models/api_models/merchandise_models/merchandisemodels.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/view/merchandise_store_view/merchandisedetailsscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MerchandiseCard extends StatelessWidget {
  final MerchandiseItem data;
  const MerchandiseCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final inStock = data.stockQuantity > 0;

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MerchandiseDetailScreen(item: data),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── IMAGE ─────────────────────────────────────────────
                Stack(
                  children: [
                    SizedBox(
                      width: 110.w,
                      height: 130.h,
                      child: data.imageUrl.isNotEmpty
                          ? Image.network(
                              data.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder(),
                            )
                          : _placeholder(),
                    ),
                    // Physical / Digital badge
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: _badge(
                        data.isPhysical ? 'Physical' : 'Digital',
                        data.isPhysical ? drawerColor : accentOrange,
                      ),
                    ),
                    // Out-of-stock dim overlay
                    if (!inStock)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(.35),
                          alignment: Alignment.center,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: Colors.red.shade700,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: CustomText(
                              text: 'Out of Stock',
                              size: 9,
                              weight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // ── DETAILS ───────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category chip (only if non-empty)
                        if (data.category.isNotEmpty) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: accentOrange.withOpacity(.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: CustomText(
                              text: data.category.toUpperCase(),
                              size: 9,
                              weight: FontWeight.w700,
                              color: accentOrange,
                            ),
                          ),
                          SizedBox(height: 6.h),
                        ],

                        // Name
                        CustomText(
                          text: data.name,
                          size: 14,
                          weight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E),
                          maxLines: 2,
                        ),

                        SizedBox(height: 4.h),

                        // Description
                        CustomText(
                          text: data.description,
                          size: 11,
                          weight: FontWeight.w400,
                          color: Colors.grey.shade500,
                          maxLines: 2,
                        ),

                        SizedBox(height: 8.h),

                        // Price row
                        Row(
                          children: [
                            // ₹ Price
                            // Price row — REPLACE the existing price section with this:
if (data.price > 0) ...[
  Icon(Icons.currency_rupee, size: 13.sp, color: drawerColor),
  if (data.hasDiscount) ...[
    // Strikethrough original price
    Text(
      '${data.originalPrice}',
      style: TextStyle(
        fontSize: 11.sp,
        color: Colors.grey.shade400,
        decoration: TextDecoration.lineThrough,
      ),
    ),
    SizedBox(width: 4.w),
    // Discounted price
    CustomText(
      text: '${data.effectivePrice}',
      size: 14,
      weight: FontWeight.w800,
      color: Colors.green.shade700,
    ),
  ] else
    CustomText(
      text: '${data.price}',
      size: 14,
      weight: FontWeight.w800,
      color: drawerColor,
    ),
  SizedBox(width: 6.w),
  Container(width: 1, height: 14.h, color: Colors.grey.shade300),
  SizedBox(width: 6.w),
],
                            // Points badge
                            Icon(Icons.workspace_premium,
                                size: 12.sp, color: Colors.amber),
                            SizedBox(width: 2.w),
                            CustomText(
                              text: '${data.pointsRequired} pts',
                              size: 11,
                              weight: FontWeight.w700,
                              color: Colors.amber.shade700,
                            ),
                          ],
                        ),

                        SizedBox(height: 6.h),

                        // Stock status
                        Row(
                          children: [
                            Icon(
                              inStock
                                  ? Icons.check_circle_outline
                                  : Icons.cancel_outlined,
                              size: 12.sp,
                              color: inStock ? Colors.green : Colors.red,
                            ),
                            SizedBox(width: 3.w),
                            CustomText(
                              text: inStock
                                  ? '${data.stockQuantity} in stock'
                                  : 'Out of stock',
                              size: 10,
                              weight: FontWeight.w600,
                              color: inStock
                                  ? Colors.green.shade600
                                  : Colors.red.shade400,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(right: 10.w, top: 50.h),
                  child: Icon(Icons.chevron_right,
                      size: 20.sp, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) => Container(
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: CustomText(
          text: label,
          size: 9,
          weight: FontWeight.w700,
          color: Colors.white,
        ),
      );

  Widget _placeholder() => Container(
        color: Colors.grey.shade100,
        child: Center(
          child: Icon(Icons.card_giftcard,
              size: 36, color: Colors.grey.shade300),
        ),
      );
}