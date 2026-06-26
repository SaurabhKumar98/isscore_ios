import 'package:firstedu/data/models/api_models/merchandise_models/merchandisedetailsmodels.dart';
import 'package:firstedu/data/models/api_models/merchandise_models/merchandisemodels.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_button.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view_models/merchandiseprovider/merchandise_provider.dart';
import 'package:firstedu/view_models/razropaymanger/razorpayservices.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class MerchandiseDetailScreen extends StatefulWidget {
  final MerchandiseItem item;
  const MerchandiseDetailScreen({super.key, required this.item});

  @override
  State<MerchandiseDetailScreen> createState() =>
      _MerchandiseDetailScreenState();
}

class _MerchandiseDetailScreenState extends State<MerchandiseDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MerchandiseProvider>().fetchDetail(context, widget.item.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MerchandiseProvider>();

    // Use full detail when loaded, fall back to list-item snapshot
    final MerchandiseItem display = provider.detail != null
        ? provider.detail!.toItem()
        : widget.item;

    final inStock = display.stockQuantity > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Hero image app bar ─────────────────────────────────────
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.45,
                pinned: true,
                stretch: true,
                backgroundColor: drawerColor,
                foregroundColor: Colors.white,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      display.imageUrl.isNotEmpty
                          ? Image.network(
                              display.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _imageFallback(),
                            )
                          : _imageFallback(),

                      // Bottom gradient
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              Color(0x99000000),
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),

                      // Badges
                      Positioned(
                        bottom: 16.h,
                        left: 16.w,
                        child: Wrap(
                          spacing: 6.w,
                          children: [
                            _badge(
                              display.isPhysical ? 'Physical' : 'Digital',
                              display.isPhysical ? drawerColor : accentOrange,
                            ),
                            if (display.category.isNotEmpty)
                              _badge(
                                display.category.toUpperCase(),
                                Colors.black54,
                              ),
                          ],
                        ),
                      ),

                      // Out-of-stock overlay
                      if (!inStock)
                        Container(
                          color: Colors.black.withOpacity(.45),
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade700,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: CustomText(
                                text: 'Out of Stock',
                                size: 18,
                                weight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Body content ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: provider.isDetailLoading
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    : Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 130.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name + stock
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: CustomText(
                                    text: display.name,
                                    size: 20,
                                    weight: FontWeight.w800,
                                    color: const Color(0xFF1A1A2E),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: inStock
                                        ? Colors.green.withOpacity(.1)
                                        : Colors.red.withOpacity(.1),
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color: inStock
                                          ? Colors.green.withOpacity(.3)
                                          : Colors.red.withOpacity(.3),
                                    ),
                                  ),
                                  child: CustomText(
                                    text: inStock
                                        ? '${display.stockQuantity} left'
                                        : 'Out of stock',
                                    size: 11,
                                    weight: FontWeight.w700,
                                    color: inStock
                                        ? Colors.green.shade700
                                        : Colors.red.shade600,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 16.h),

                            // ── Price + Points card ───────────────────────
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // ── Price column ──────────────────────────────────
    if (display.price > 0)
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: 'Price',
              size: 11,
              weight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
            SizedBox(height: 6.h),
            if (display.hasDiscount) ...[
              Row(
                children: [
                  Icon(Icons.currency_rupee,
                      size: 14.sp, color: Colors.grey.shade400),
                  Text(
                    '${display.originalPrice}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade400,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  Icons.currency_rupee,
                  size: 20.sp,
                  color: display.hasDiscount
                      ? Colors.green.shade700
                      : drawerColor,
                ),
                CustomText(
                  text: '${display.effectivePrice}',
                  size: 26,
                  weight: FontWeight.w800,
                  color: display.hasDiscount
                      ? Colors.green.shade700
                      : drawerColor,
                ),
                if (display.hasDiscount) ...[
                  SizedBox(width: 6.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: CustomText(
                      text:
                          '${((display.originalPrice - display.effectivePrice) / display.originalPrice * 100).round()}% OFF',
                      size: 10,
                      weight: FontWeight.w700,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),

    // ── Divider ───────────────────────────────────────
    if (display.price > 0) ...[
      SizedBox(width: 12.w),
      Container(
        width: 1,
        height: 55.h,
        color: Colors.grey.shade100,
      ),
      SizedBox(width: 12.w),
    ],

    // ── Points column ─────────────────────────────────
    Expanded(
      child: Column(
        crossAxisAlignment: display.price > 0
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'Points Required',
            size: 11,
            weight: FontWeight.w500,
            color: Colors.grey.shade500,
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: display.price > 0
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.workspace_premium,
                  size: 22.sp, color: Colors.amber.shade700),
              SizedBox(width: 4.w),
              CustomText(
                text: '${display.pointsRequired}',
                size: 26,
                weight: FontWeight.w800,
                color: Colors.amber.shade800,
              ),
            ],
          ),
          CustomText(
            text: 'points',
            size: 11,
            weight: FontWeight.w500,
            color: Colors.amber.shade600,
          ),
        ],
      ),
    ),
  ],
),
                            ),

                            SizedBox(height: 14.h),

                            // ── Description ───────────────────────────────
                            _sectionTitle('Description'),
                            SizedBox(height: 10.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: CustomText(
                                text: display.description.isNotEmpty
                                    ? display.description
                                    : 'No description available.',
                                size: 13,
                                weight: FontWeight.w400,
                                color: Colors.grey.shade700,
                                maxLines: 50,
                                height: 1.7,
                              ),
                            ),

                            SizedBox(height: 20.h),

                            // ── Item Details ──────────────────────────────
                            _sectionTitle('Item Details'),
                            SizedBox(height: 10.h),
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  if (display.category.isNotEmpty) ...[
                                    _detailRow(
                                      'Category',
                                      display.category.toUpperCase(),
                                    ),
                                    _divider(),
                                  ],
                                  _detailRow(
                                    'Type',
                                    display.isPhysical ? 'Physical' : 'Digital',
                                  ),
                                  _divider(),
                                  _detailRow(
                                    'Stock',
                                    inStock
                                        ? '${display.stockQuantity} available'
                                        : 'Out of stock',
                                  ),
                                  _divider(),
                                  _detailRow(
                                    'Status',
                                    display.isActive ? 'Active' : 'Inactive',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),

          // ── Bottom CTA bar ─────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                16.w,
                12.h,
                16.w,
                MediaQuery.of(context).padding.bottom + 12.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Consumer<MerchandiseProvider>(
                builder: (context, prov, _) {
                  final busy =
                      prov.isClaiming ||
                      prov.isPaymentLoading ||
                      prov.isConfirmingPayment;
                  return CustomButton(
                    title: !inStock
                        ? 'Out of Stock'
                        : busy
                        ? 'Processing...'
:display.hasDiscount
    ? 'Get Now  •  ${display.pointsRequired} pts  |  ₹${display.effectivePrice}'
    : display.price > 0
        ? 'Get Now  •  ${display.pointsRequired} pts  |  ₹${display.price}'
        : 'Get Now  •  ${display.pointsRequired} pts',                    onTap: () {
                      if (!inStock || busy) return;
                      _showPaymentSheet(context, prov, display);
                    },
                    enabled: inStock && !busy,
                    backgroundColor: inStock
                        ? drawerColor
                        : Colors.grey.shade400,
                    textColor: Colors.white,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentSheet(
    BuildContext context,
    MerchandiseProvider prov,
    MerchandiseItem item,
  ) {
    // In _showPaymentSheet, add useSafeArea:
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,           // ← ADD
  backgroundColor: Colors.transparent,
  builder: (_) => _PaymentSheet(item: item),
);
  }

  Widget _sectionTitle(String t) => CustomText(
    text: t,
    size: 15,
    weight: FontWeight.w800,
    color: const Color(0xFF1A1A2E),
  );

  Widget _detailRow(String label, String value) => Padding(
    padding: EdgeInsets.symmetric(vertical: 8.h),
    child: Row(
      children: [
        CustomText(
          text: label,
          size: 13,
          weight: FontWeight.w500,
          color: Colors.grey.shade500,
        ),
        const Spacer(),
        CustomText(
          text: value,
          size: 13,
          weight: FontWeight.w700,
          color: const Color(0xFF1A1A2E),
        ),
      ],
    ),
  );

  Widget _divider() =>
      Divider(color: Colors.grey.shade100, height: 1, thickness: 1);

  Widget _badge(String label, Color color) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6.r),
    ),
    child: CustomText(
      text: label,
      size: 10,
      weight: FontWeight.w700,
      color: Colors.white,
    ),
  );

  Widget _imageFallback() => Container(
    color: Colors.grey.shade200,
    child: Center(
      child: Icon(Icons.card_giftcard, size: 80, color: Colors.grey.shade400),
    ),
  );
}

class _PaymentSheet extends StatefulWidget {
  final MerchandiseItem item;
  const _PaymentSheet({required this.item});

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  String _selectedMethod = 'points';

  final _couponCtrl = TextEditingController();
  bool _couponApplied = false;

  String _step = 'method';

  Map<String, dynamic>? _pendingAddress;

  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addr1Ctrl = TextEditingController();
  final _addr2Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'India');
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    RazorpayManager.instance.init(
      onSuccess: _onRazorpaySuccess,
      onError: _onRazorpayError,
    );
  }

  @override
  void dispose() {
    RazorpayManager.instance.clear();
    for (final c in [
      _couponCtrl,
      _fullNameCtrl,
      _phoneCtrl,
      _addr1Ctrl,
      _addr2Ctrl,
      _cityCtrl,
      _stateCtrl,
      _postalCtrl,
      _countryCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _needsAddress =>
      widget.item.isPhysical &&
      (_selectedMethod == 'wallet' ||
          _selectedMethod == 'razorpay' ||
          _selectedMethod == 'free');

 int get _effectivePrice {
  final prov = Provider.of<MerchandiseProvider>(context, listen: false);
  if (prov.appliedCoupon != null) return prov.appliedCoupon!.finalAmount;
  return widget.item.effectivePrice; // ← use effectivePrice not price
}

  Map<String, dynamic>? get _addressPayload {
    if (!widget.item.isPhysical) return null;
    return {
      'fullName': _fullNameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'addressLine1': _addr1Ctrl.text.trim(),
      'addressLine2': _addr2Ctrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'state': _stateCtrl.text.trim(),
      'postalCode': _postalCtrl.text.trim(),
      'country': _countryCtrl.text.trim(),
    };
  }

  @override
  Widget build(BuildContext context) {
   // REPLACE the entire DraggableScrollableSheet builder return:
return DraggableScrollableSheet(
  initialChildSize: 0.7,
  minChildSize: 0.5,
  maxChildSize: 0.95,
  builder: (_, scrollCtrl) => Padding(
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom, // ← keyboard inset
    ),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          _handle(),
          _sheetTitle(),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollCtrl,
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
              child: _step == 'method' ? _methodView() : _addressView(),
            ),
          ),
        ],
      ),
    ),
  ),
);
  }

  Widget _methodView() {
    final prov = context.watch<MerchandiseProvider>();
    final coupon = prov.appliedCoupon;
    final item = widget.item;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _itemSummaryTile(item),
        SizedBox(height: 20.h),

        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F7FB),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            children: [
              _balancePill(
                icon: Icons.workspace_premium,
                color: Colors.amber,
                label: 'Points',
                value: '${prov.totalPoints} pts',
              ),
              SizedBox(width: 12.w),
              _balancePill(
                icon: Icons.account_balance_wallet_outlined,
                color: Colors.green.shade600,
                label: 'Wallet',
                value: '₹${prov.monetaryBalance.toStringAsFixed(0)}',
              ),
            ],
          ),
        ),

        SizedBox(height: 20.h),

        CustomText(
          text: 'Choose Payment Method',
          size: 14,
          weight: FontWeight.w700,
          color: const Color(0xFF1A1A2E),
        ),
        SizedBox(height: 10.h),

        _methodTile(
          value: 'points',
          icon: Icons.workspace_premium,
          iconColor: Colors.amber.shade700,
          title: 'Redeem Points',
          subtitle:
              'Use ${item.pointsRequired} pts  •  You have ${prov.totalPoints} pts',
          enabled: prov.totalPoints >= item.pointsRequired,
          disabledReason: prov.totalPoints < item.pointsRequired
              ? 'Insufficient points'
              : null,
        ),

        SizedBox(height: 8.h),

        if (item.price > 0) ...[
          _methodTile(
            value: 'wallet',
            icon: Icons.account_balance_wallet_outlined,
            iconColor: Colors.green.shade600,
            title: 'Pay via Wallet',
            subtitle:
'₹${coupon?.finalAmount ?? item.effectivePrice}  •  Balance ₹${prov.monetaryBalance.toStringAsFixed(0)}',
enabled: prov.monetaryBalance >= (coupon?.finalAmount ?? item.effectivePrice),
            disabledReason: prov.monetaryBalance < (coupon?.finalAmount ?? item.effectivePrice)
    ? 'Insufficient wallet balance'
    : null,
          ),

          SizedBox(height: 8.h),

          _methodTile(
            value: 'razorpay',
            icon: Icons.credit_card_outlined,
            iconColor: Colors.blue.shade600,
            title: 'Pay via Card / UPI',
            subtitle:
'₹${coupon?.finalAmount ?? item.effectivePrice}  •  Cards, UPI, Net Banking',
            enabled: true,
          ),

          SizedBox(height: 20.h),

          CustomText(
            text: 'Have a Coupon?',
            size: 14,
            weight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
          SizedBox(height: 10.h),
          _couponRow(prov),

          if (coupon != null) ...[
            SizedBox(height: 10.h),
            _couponAppliedBanner(coupon),
          ],

          SizedBox(height: 20.h),
        ],

        // ── Price summary ─────────────────────────────────────────────────
        if (item.price > 0) _priceSummary(item, coupon),

        SizedBox(height: 20.h),

        // ── CTA ───────────────────────────────────────────────────────────
        Consumer<MerchandiseProvider>(
          builder: (context, p, _) {
            final busy =
                p.isClaiming || p.isPaymentLoading || p.isConfirmingPayment;
            return CustomButton(
              title: busy ? 'Processing...' : _ctaLabel(),
              onTap: _onMethodContinue,
              enabled: !busy,
              backgroundColor: drawerColor,
              textColor: Colors.white,
            );
          },
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  // ── Address view (for physical items + wallet/razorpay/free) ─────────────

  Widget _addressView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _step = 'method'),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18.sp,
                  color: drawerColor,
                ),
              ),
              SizedBox(width: 8.w),
              CustomText(
                text: 'Delivery Address',
                size: 15,
                weight: FontWeight.w800,
                color: const Color(0xFF1A1A2E),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          _field('Full Name', _fullNameCtrl, Icons.person_outline),
          SizedBox(height: 12.h),
          _field(
            'Phone',
            _phoneCtrl,
            Icons.phone_outlined,
            keyboard: TextInputType.phone,
          ),
          SizedBox(height: 12.h),
          _field('Address Line 1', _addr1Ctrl, Icons.home_outlined),
          SizedBox(height: 12.h),
          _field(
            'Address Line 2 (optional)',
            _addr2Ctrl,
            Icons.apartment_outlined,
            required: false,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: _field('City', _cityCtrl, Icons.location_city)),
              SizedBox(width: 12.w),
              Expanded(child: _field('State', _stateCtrl, Icons.map_outlined)),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _field(
                  'Postal Code',
                  _postalCtrl,
                  Icons.local_post_office_outlined,
                  keyboard: TextInputType.number,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _field('Country', _countryCtrl, Icons.flag_outlined),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          Consumer<MerchandiseProvider>(
            builder: (context, p, _) {
              final busy =
                  p.isClaiming || p.isPaymentLoading || p.isConfirmingPayment;
              return CustomButton(
                title: busy ? 'Processing...' : 'Confirm & Pay',
                onTap: _onAddressConfirm,
                enabled: !busy,
                backgroundColor: drawerColor,
                textColor: Colors.white,
              );
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _onMethodContinue() async {
    if (_selectedMethod == 'points') {
      // Points — address only needed if physical
      if (widget.item.isPhysical) {
        setState(() => _step = 'address');
      } else {
        await _claimWithPoints(null);
      }
    } else {
      // Wallet / razorpay
      if (_needsAddress) {
        setState(() => _step = 'address');
      } else {
        await _initiateMoneyPayment(null);
      }
    }
  }

  Future<void> _onAddressConfirm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final address = _addressPayload;

    if (_selectedMethod == 'points') {
      await _claimWithPoints(address);
    } else {
      await _initiateMoneyPayment(address);
    }
  }

  Future<void> _claimWithPoints(Map<String, dynamic>? address) async {
    final prov = context.read<MerchandiseProvider>();
    final ok = await prov.claimMerchandise(
      context,
      merchandiseId: widget.item.id,
      deliveryAddress: address,
    );
    if (ok && mounted) {
      Navigator.pop(context); // close sheet
      Navigator.pop(context); // close detail
    }
  }

  Future<void> _initiateMoneyPayment(Map<String, dynamic>? address) async {
    final prov = context.read<MerchandiseProvider>();
    final couponCode = _couponApplied ? _couponCtrl.text.trim() : null;

    final result = await prov.initiatePayment(
      context,
      merchandiseId: widget.item.id,
      paymentMethod: _selectedMethod,
      couponCode: couponCode,
      deliveryAddress: address,
    );

    if (!mounted) return;

    if (result == true) {
      // Wallet / free — done
      Navigator.pop(context);
      Navigator.pop(context);
    } else if (result == null) {
      // Razorpay — open gateway
      _openRazorpay(prov, address);
    }
    // result == false → error toast already shown by provider
  }

  void _openRazorpay(MerchandiseProvider prov, Map<String, dynamic>? address) {
    final pd = prov.pendingPaymentData;
    if (pd == null || pd.orderId == null || pd.key == null) return;

    // Stash address so the success callback can send it to confirm-payment
    _pendingAddress = address;

    RazorpayManager.instance.openCheckout(
      key: pd.key!,
      amount: pd.amount ?? 0,
      orderId: pd.orderId!,
      currency: pd.currency ?? 'INR',
      title: pd.title ?? widget.item.name,
      description: widget.item.description,
    );
  }

  // Called by RazorpayManager on payment success
  void _onRazorpaySuccess(PaymentSuccessResponse response) async {
    if (!mounted) return;
    final prov = context.read<MerchandiseProvider>();
    final ok = await prov.confirmPayment(
      context,
      merchandiseId: widget.item.id,
      razorpayPaymentId: response.paymentId ?? '',
      razorpayOrderId: response.orderId ?? '',
      razorpaySignature: response.signature ?? '',
      deliveryAddress: _pendingAddress,
    );
    _pendingAddress = null;
    if (ok && mounted) {
      Navigator.pop(context); // close sheet
      Navigator.pop(context); // close detail screen
    }
  }

  // Called by RazorpayManager on payment failure / dismissal
  void _onRazorpayError(PaymentFailureResponse response) {
    if (!mounted) return;
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(
    //       response.message?.isNotEmpty == true
    //           ? response.message!
    //           : 'Payment failed. Please try again.',
    //     ),
    //     backgroundColor: Colors.red.shade600,
    //     behavior: SnackBarBehavior.floating,
    //   ),
    // );
    AppToast.error(
      context,
      message: response.message?.isNotEmpty == true
          ? response.message!
          : 'Payment failed. Please try again.',
    );
  }

  Future<void> _applyCoupon() async {
    final code = _couponCtrl.text.trim();
    if (code.isEmpty) return;
    final prov = context.read<MerchandiseProvider>();
await prov.applyCoupon(context, code: code, amount: widget.item.effectivePrice);
    if (prov.appliedCoupon != null) {
      setState(() => _couponApplied = true);
    }
  }

  void _removeCoupon() {
    setState(() => _couponApplied = false);
    _couponCtrl.clear();
    context.read<MerchandiseProvider>().clearCoupon();
  }

  // ── Small widget helpers ──────────────────────────────────────────────────

  Widget _handle() => Padding(
    padding: EdgeInsets.symmetric(vertical: 12.h),
    child: Center(
      child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(4.r),
        ),
      ),
    ),
  );

  Widget _sheetTitle() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: drawerColor.withOpacity(.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.shopping_bag_outlined,
            color: drawerColor,
            size: 18.sp,
          ),
        ),
        SizedBox(width: 10.w),
        CustomText(
          text: 'Get Merchandise',
          size: 17,
          weight: FontWeight.w800,
          color: const Color(0xFF1A1A2E),
        ),
      ],
    ),
  );

  Widget _itemSummaryTile(MerchandiseItem item) => Container(
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: const Color(0xFFF6F7FB),
      borderRadius: BorderRadius.circular(14.r),
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: SizedBox(
            width: 56.w,
            height: 56.h,
            child: item.imageUrl.isNotEmpty
                ? Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _thumbFallback(),
                  )
                : _thumbFallback(),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: item.name,
                size: 14,
                weight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
                maxLines: 1,
              ),
              SizedBox(height: 4.h),
            Row(
  children: [
    Icon(Icons.currency_rupee, size: 12.sp,
        color: item.hasDiscount ? Colors.green.shade700 : drawerColor),
    if (item.hasDiscount) ...[
      Text(
        '${item.originalPrice}  ',
        style: TextStyle(
          fontSize: 11.sp,
          color: Colors.grey.shade400,
          decoration: TextDecoration.lineThrough,
        ),
      ),
    ],
    CustomText(
      text: '${item.effectivePrice}',
      size: 13,
      weight: FontWeight.w700,
      color: item.hasDiscount ? Colors.green.shade700 : drawerColor,
    ),
    SizedBox(width: 8.w),
    Icon(Icons.workspace_premium, size: 12.sp, color: Colors.amber),
    SizedBox(width: 2.w),
    CustomText(
      text: '${item.pointsRequired} pts',
      size: 12,
      weight: FontWeight.w600,
      color: Colors.amber.shade700,
    ),
  ],
),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _methodTile({
    required String value,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool enabled,
    String? disabledReason,
  }) {
    final selected = _selectedMethod == value && enabled;
    return GestureDetector(
      onTap: enabled ? () => setState(() => _selectedMethod = value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: selected ? drawerColor.withOpacity(.07) : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? drawerColor : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: enabled
                    ? iconColor.withOpacity(.12)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18.sp,
                color: enabled ? iconColor : Colors.grey.shade400,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: title,
                    size: 13,
                    weight: FontWeight.w700,
                    color: enabled
                        ? const Color(0xFF1A1A2E)
                        : Colors.grey.shade400,
                  ),
                  SizedBox(height: 2.h),
                  CustomText(
                    text: disabledReason ?? subtitle,
                    size: 11,
                    weight: FontWeight.w500,
                    color: disabledReason != null
                        ? Colors.red.shade400
                        : Colors.grey.shade500,
                  ),
                ],
              ),
            ),
            if (enabled)
              Container(
                width: 18.w,
                height: 18.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? drawerColor : Colors.grey.shade300,
                    width: 2,
                  ),
                  color: selected ? drawerColor : Colors.white,
                ),
                child: selected
                    ? Icon(Icons.check, size: 10.sp, color: Colors.white)
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  Widget _couponRow(MerchandiseProvider prov) => Row(
    children: [
      Expanded(
        child: TextFormField(
          controller: _couponCtrl,
          enabled: !_couponApplied,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'Enter coupon code',
            filled: true,
            fillColor: const Color(0xFFF8F9FB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: drawerColor, width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 12.h,
            ),
          ),
        ),
      ),
      SizedBox(width: 10.w),
      GestureDetector(
        onTap: _couponApplied
            ? _removeCoupon
            : prov.isCouponLoading
            ? null
            : _applyCoupon,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
          decoration: BoxDecoration(
            color: _couponApplied ? Colors.red.shade50 : drawerColor,
            borderRadius: BorderRadius.circular(12.r),
            border: _couponApplied
                ? Border.all(color: Colors.red.shade200)
                : null,
          ),
          child: prov.isCouponLoading
              ? SizedBox(
                  width: 18.w,
                  height: 18.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : CustomText(
                  text: _couponApplied ? 'Remove' : 'Apply',
                  size: 13,
                  weight: FontWeight.w700,
                  color: _couponApplied ? Colors.red.shade600 : Colors.white,
                ),
        ),
      ),
    ],
  );

  Widget _couponAppliedBanner(MerchandiseCouponData coupon) => Container(
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: Colors.green.withOpacity(.07),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: Colors.green.withOpacity(.2)),
    ),
    child: Row(
      children: [
        Icon(
          Icons.local_offer_rounded,
          size: 16.sp,
          color: Colors.green.shade700,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: CustomText(
            text:
                '${coupon.couponCode} applied — Save ₹${coupon.discountAmount}',
            size: 12,
            weight: FontWeight.w600,
            color: Colors.green.shade800,
          ),
        ),
      ],
    ),
  );

// REPLACE the entire _priceSummary method:
Widget _priceSummary(MerchandiseItem item, MerchandiseCouponData? coupon) =>
    Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          _summaryRow('Item Price', '₹${item.originalPrice}', isTotal: false),

          // Show offer/auto-discount if present
          if (item.hasDiscount) ...[
            SizedBox(height: 6.h),
            _summaryRow(
              'Offer Discount',
              '-₹${item.originalPrice - item.effectivePrice}',
              isDiscount: true,
              isTotal: false,
            ),
          ],

          // Show coupon discount if applied
          if (coupon != null) ...[
            SizedBox(height: 6.h),
            _summaryRow(
              'Coupon (${coupon.couponCode})',
              '-₹${coupon.discountAmount}',
              isDiscount: true,
              isTotal: false,
            ),
          ],

          Divider(color: Colors.grey.shade200, height: 16.h),
          _summaryRow(
            'Total Payable',
            '₹${coupon?.finalAmount ?? item.effectivePrice}',
            isTotal: true,
          ),
        ],
      ),
    );
  Widget _summaryRow(
    String label,
    String value, {
    required bool isTotal,
    bool isDiscount = false,
  }) => Row(
    children: [
      CustomText(
        text: label,
        size: isTotal ? 13 : 12,
        weight: isTotal ? FontWeight.w700 : FontWeight.w500,
        color: isTotal ? const Color(0xFF1A1A2E) : Colors.grey.shade600,
      ),
      const Spacer(),
      CustomText(
        text: value,
        size: isTotal ? 15 : 12,
        weight: isTotal ? FontWeight.w800 : FontWeight.w600,
        color: isDiscount
            ? Colors.green.shade700
            : isTotal
            ? drawerColor
            : const Color(0xFF1A1A2E),
      ),
    ],
  );

  Widget _balancePill({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16.sp, color: color),
      SizedBox(width: 6.w),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: label,
            size: 10,
            weight: FontWeight.w500,
            color: Colors.grey.shade500,
          ),
          CustomText(
            text: value,
            size: 13,
            weight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ],
      ),
    ],
  );

  Widget _field(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
    bool required = true,
  }) => TextFormField(
    controller: ctrl,
    keyboardType: keyboard,
    validator: required
        ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
        : null,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18.sp, color: Colors.grey.shade500),
      filled: true,
      fillColor: const Color(0xFFF8F9FB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: drawerColor, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
    ),
  );

  Widget _thumbFallback() => Container(
    color: Colors.grey.shade100,
    child: Icon(Icons.card_giftcard, size: 24, color: Colors.grey.shade300),
  );

  String _ctaLabel() {
    switch (_selectedMethod) {
      case 'points':
        return 'Claim with ${widget.item.pointsRequired} pts';
      case 'wallet':
        return 'Pay ₹$_effectivePrice from Wallet';
      case 'razorpay':
        return 'Pay ₹$_effectivePrice via Card / UPI';
      default:
        return 'Continue';
    }
  }
}
