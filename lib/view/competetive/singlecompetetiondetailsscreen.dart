import 'package:firstedu/data/models/api_models/competetive/avilabletestcompetetionmodels.dart';
import 'package:firstedu/data/models/api_models/competetive/competetionbyid_models.dart';
import 'package:firstedu/data/models/api_models/examhall/resultmodels.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/view/competetive/testpurchasebuttomsheet.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/examinstructionscreen.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/instantresultscreen.dart';
import 'package:firstedu/view_models/examhallprovider/examsessionprovider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firstedu/view_models/competetiveprovider/competetionprovider.dart';
import 'package:firstedu/view/competetive/purchasebuttomsheetscreen.dart';

class Singlecompetetiondetailsscreen extends StatefulWidget {
  final String id;

  const Singlecompetetiondetailsscreen({super.key, required this.id});

  @override
  State<Singlecompetetiondetailsscreen> createState() =>
      _SinglecompetetiondetailsscreenState();
}

class _SinglecompetetiondetailsscreenState
    extends State<Singlecompetetiondetailsscreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);

    Future.microtask(() async {
      final provider = context.read<CompetitionProvider>();
      await provider.fetchCategoryDetail(context, widget.id);
      await provider.fetchTests(
        context,
        widget.id,
        provider.categoryDetail?.rootType,
      );
      _animCtrl.forward();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CompetitionProvider>(
      builder: (context, provider, _) {
        final data = provider.categoryDetail;
        final tests = provider.tests;
        final isLoading = provider.isLoading;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6FB),
          body: isLoading
              ? _buildSkeleton()
              : data == null
              ? _buildError(provider)
              : FadeTransition(
                  opacity: _fadeAnim,
                  child: _buildContent(context, provider, data, tests),
                ),
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _shimmer(height: 260, width: double.infinity, radius: 0),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _shimmer(height: 28, width: 260),
                const SizedBox(height: 12),
                _shimmer(height: 16, width: 200),
                const SizedBox(height: 24),
                _shimmer(height: 120, width: double.infinity),
                const SizedBox(height: 16),
                _shimmer(height: 80, width: double.infinity),
                _shimmer(height: 80, width: double.infinity),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmer({
    required double height,
    required double width,
    double radius = 12,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildError(CompetitionProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Failed to load',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              provider.fetchCategoryDetail(context, widget.id);
              provider.fetchTests(context, widget.id, null);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    CompetitionProvider provider,
    dynamic data,
    List tests,
  ) {
    final meta = provider.testMeta;

    // ── Access logic from categoryDetail (/:id/detail) ──────────────────────
    // The detail endpoint returns hasAccess and upgradable directly on data.
    // meta.hasAccess and meta.upgradable are from test listing.
    // Use meta for test-level access, data for bundle-level access.
    final bool bundleHasAccess = data.hasAccess == true;
    final bool isUpgradable = data.upgradable == true;
    final int upgradeCost = (data.upgradeCost as int?) ?? 0;
    final bool isFreeUpgrade = data.isFreeUpgrade == true;

    final int price = (data.effectivePrice as int?) ?? 0;
    final int originalPrice = (data.originalPrice as int?) ?? price;
    final int discountAmount = (data.discountAmount as int?) ?? 0;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── SLIVER APP BAR ──────────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          backgroundColor: const Color(0xFF162556),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: Stack(
              fit: StackFit.expand,
              children: [
                if ((data.bannerImg ?? '').isNotEmpty)
                  Image.network(
                    data.bannerImg!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _bannerPlaceholder(),
                  )
                else
                  _bannerPlaceholder(),
                // Gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xFF162556).withOpacity(0.95),
                      ],
                    ),
                  ),
                ),
                // Banner content
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status pill
                      if (bundleHasAccess)
                        _bannerPill(
                          'PURCHASED',
                          Colors.green,
                          Icons.check_circle_rounded,
                        )
                      else if (isUpgradable)
                        _bannerPill(
                          'UPGRADE AVAILABLE',
                          Colors.orange.shade700,
                          Icons.upgrade_rounded,
                        ),
                      const SizedBox(height: 6),
                      Text(
                        data.name ?? '',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Price / upgrade info in banner
                      Row(
                        children: [
                          if (bundleHasAccess) ...[
                            _bannerChip(
                              Icons.lock_open_rounded,
                              'Full Access',
                              Colors.green.shade300,
                            ),
                            const SizedBox(width: 8),
                            if (isUpgradable && upgradeCost > 0)
                              _bannerChip(
                                Icons.upgrade_rounded,
                                'Upgrade ₹$upgradeCost',
                                Colors.orange.shade300,
                              ),
                          ] else if (isUpgradable) ...[
                            _bannerChip(
                              Icons.upgrade_rounded,
                              isFreeUpgrade
                                  ? 'FREE Upgrade'
                                  : 'Upgrade ₹$upgradeCost',
                              Colors.orange.shade300,
                            ),
                          ] else if (price > 0) ...[
                            _bannerChip(
                              Icons.currency_rupee_rounded,
                              '₹$price',
                              Colors.white70,
                            ),
                            if (originalPrice > price) ...[
                              const SizedBox(width: 8),
                              Text(
                                '₹$originalPrice',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: Colors.white38,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ] else ...[
                            _bannerChip(
                              Icons.lock_open_rounded,
                              'Free Access',
                              Colors.green.shade300,
                            ),
                          ],
                          if (discountAmount > 0) ...[
                            const SizedBox(width: 8),
                            _bannerChip(
                              Icons.local_offer_rounded,
                              '₹$discountAmount off',
                              Colors.amber.shade300,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── QUICK STATS ─────────────────────────────────────────────
                _QuickStatsRow(
                  data: data,
                  tests: tests,
                  meta: meta,
                  bundleHasAccess: bundleHasAccess,
                  isUpgradable: isUpgradable,
                  upgradeCost: upgradeCost,
                ),

                const SizedBox(height: 20),

                // ── OFFER BANNER ─────────────────────────────────────────────
                if (data.appliedOffer != null ||
                    data.overrideOffer != null) ...[
                  _OfferBanner(data: data),
                  const SizedBox(height: 20),
                ],

                // ── DESCRIPTION ──────────────────────────────────────────────
                if ((data.description ?? '').isNotEmpty) ...[
                  _SectionTitle('About'),
                  const SizedBox(height: 8),
                  Text(
                    data.description!,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── SYLLABUS ─────────────────────────────────────────────────
                if ((data.syllabus ?? '').isNotEmpty) ...[
                  _SectionTitle('Syllabus'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Text(
                      data.syllabus!,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: Colors.blue.shade800,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── WHAT'S INCLUDED ──────────────────────────────────────────
                _WhatsIncludedCard(),
                const SizedBox(height: 20),

                // ── ACCESS / PURCHASE CARD ────────────────────────────────────
                _AccessCard(
                  data: data,
                  price: price,
                  originalPrice: originalPrice,
                  discountAmount: discountAmount,
                  hasAccess: bundleHasAccess,
                  isUpgradable: isUpgradable,
                  upgradeCost: upgradeCost,
                  isFreeUpgrade: isFreeUpgrade,
                  meta: meta,
                  categoryId: widget.id,
                ),

                const SizedBox(height: 28),

                // ── AVAILABLE TESTS ───────────────────────────────────────────
                Row(
                  children: [
                    _SectionTitle('Available Tests'),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF162556).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${tests.length} tests',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF162556),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (tests.isEmpty)
                  _EmptyTests()
                else
                  ...tests.asMap().entries.map(
                    (e) => _TestCard(
                      test: e.value as TestData,
                      index: e.key,
                      bundleHasAccess: bundleHasAccess,
                      isUpgradable: isUpgradable,
                      upgradeCost: upgradeCost,
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bannerPlaceholder() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF162556), Color(0xFF1E3A8A)],
      ),
    ),
    child: Center(
      child: Icon(
        Icons.emoji_events_rounded,
        size: 72,
        color: Colors.white.withOpacity(0.2),
      ),
    ),
  );

  Widget _bannerPill(String label, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bannerChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// OFFER BANNER
// ─────────────────────────────────────────────────────────────

class _OfferBanner extends StatelessWidget {
  final dynamic data;
  const _OfferBanner({required this.data});

  @override
  Widget build(BuildContext context) {
    // Prefer overrideOffer, fallback to appliedOffer / globalOffer
    final offer = data.overrideOffer ?? data.appliedOffer ?? data.globalOffer;
    if (offer == null) return const SizedBox.shrink();

    final String name = offer.offerName ?? '';
    final int discount = offer.discountValue ?? 0;
    final String type = offer.discountType ?? 'fixed';
    final DateTime? validTill = offer.validTill;
    final String desc = offer.description ?? '';

    final String discountStr = type == 'percent' ? '$discount%' : '₹$discount';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade100, Colors.orange.shade50],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.shade300, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.amber.shade600,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_offer_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.amber.shade900,
                  ),
                ),
                if (desc.isNotEmpty)
                  Text(
                    desc,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.amber.shade800,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$discountStr off',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              if (validTill != null)
                Text(
                  'Till ${_formatDate(validTill.toString())}',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: Colors.amber.shade800,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]}';
    } catch (_) {
      return '';
    }
  }
}

// ─────────────────────────────────────────────────────────────
// QUICK STATS ROW
// ─────────────────────────────────────────────────────────────

class _QuickStatsRow extends StatelessWidget {
  final dynamic data;
  final List tests;
  final dynamic meta;
  final bool bundleHasAccess;
  final bool isUpgradable;
  final int upgradeCost;

  const _QuickStatsRow({
    required this.data,
    required this.tests,
    required this.meta,
    required this.bundleHasAccess,
    required this.isUpgradable,
    required this.upgradeCost,
  });

  @override
  Widget build(BuildContext context) {
    final purchasedCount = tests
        .cast<TestData>()
        .where((t) => t.isPurchased ?? false)
        .length;
    final completedCount = tests
        .cast<TestData>()
        .where((t) => t.testStatus?.toString().toLowerCase() == 'completed')
        .length;

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        _StatPill(
          icon: Icons.assignment_outlined,
          label: '${tests.length} Tests',
          color: const Color(0xFF3B5BDB),
        ),
        _StatPill(
          icon: Icons.lock_open_rounded,
          label: '$purchasedCount Unlocked',
          color: Colors.green.shade600,
        ),
        if (completedCount > 0)
          _StatPill(
            icon: Icons.check_circle_outline_rounded,
            label: '$completedCount Done',
            color: Colors.purple.shade600,
          ),
        if ((data.discountAmount ?? 0) > 0)
          _StatPill(
            icon: Icons.local_offer_rounded,
            label: '₹${data.discountAmount} off',
            color: Colors.orange.shade700,
          ),
        if (bundleHasAccess && isUpgradable && upgradeCost > 0)
          _StatPill(
            icon: Icons.upgrade_rounded,
            label: 'Upgrade ₹$upgradeCost',
            color: Colors.deepOrange.shade600,
          ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// WHAT'S INCLUDED CARD
// ─────────────────────────────────────────────────────────────

class _WhatsIncludedCard extends StatelessWidget {
  final _features = const [
    ('All mock tests', Icons.assignment_turned_in_outlined),
    ('Detailed analytics', Icons.bar_chart_rounded),
    ('Leaderboard ranking', Icons.leaderboard_rounded),
    ('Unlimited attempts', Icons.all_inclusive_rounded),
    ('Instant access', Icons.flash_on_rounded),
    ('Score breakdown', Icons.pie_chart_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF162556).withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF162556).withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFF162556),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                "What's Included",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: const Color(0xFF162556),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 3.2,
            children: _features
                .map(
                  (f) => Row(
                    children: [
                      Icon(f.$2, size: 15, color: const Color(0xFF3B5BDB)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          f.$1,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ACCESS CARD
// ─────────────────────────────────────────────────────────────

class _AccessCard extends StatelessWidget {
  final dynamic data;
  final int price;
  final int originalPrice;
  final int discountAmount;
  final bool hasAccess;
  final bool isUpgradable;
  final int upgradeCost;
  final bool isFreeUpgrade;
  final dynamic meta;
  final String categoryId;

  const _AccessCard({
    required this.data,
    required this.price,
    required this.originalPrice,
    required this.discountAmount,
    required this.hasAccess,
    required this.isUpgradable,
    required this.upgradeCost,
    required this.isFreeUpgrade,
    required this.meta,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    if (hasAccess && !isUpgradable) {
      return _buildFullyPurchasedCard(context);
    }
    if (hasAccess && isUpgradable) {
      return _buildPurchasedWithUpgradeCard(context);
    }
    if (isUpgradable) {
      return _buildUpgradeCard(context);
    }
    return _buildBuyCard(context);
  }

  // ── Fully purchased, nothing to upgrade ────────────────────────────────────
  Widget _buildFullyPurchasedCard(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF16A34A), Color(0xFF15803D)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 10),
            Text(
              'Bundle Purchased!',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'All tests are unlocked for you',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PurchasedStat(
                  icon: Icons.assignment_turned_in_rounded,
                  label: 'Full Access',
                ),
                _PurchasedStat(
                  icon: Icons.bar_chart_rounded,
                  label: 'Analytics',
                ),
                _PurchasedStat(
                  icon: Icons.leaderboard_rounded,
                  label: 'Leaderboard',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Purchased but upgrade available ───────────────────────────────────────
  Widget _buildPurchasedWithUpgradeCard(BuildContext context) {
    return Column(
      children: [
        // Purchased confirmation bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.green.shade600,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Bundle Purchased — Upgrade Available',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        // Upgrade section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade600, Colors.deepOrange.shade600],
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.upgrade_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'New content added! Upgrade to unlock',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isFreeUpgrade ? 'FREE UPGRADE' : '₹$upgradeCost',
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'to unlock new content',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final convertedCategory = Child(
                        id: data.id,
                        name: data.name,
                        price: data.effectivePrice,
                        originalPrice: data.originalPrice,
                        upgradeCost: upgradeCost,
                        isFreeUpgrade: isFreeUpgrade,
                      );
                      showCategoryPaymentSheet(
                        context,
                        category: convertedCategory,
                        isUpgrade: true,
                        upgradeAmount: upgradeCost,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orange.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      isFreeUpgrade ? 'Upgrade Free' : 'Upgrade Now',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Not purchased, upgrade available (shouldn't normally happen) ──────────
  Widget _buildUpgradeCard(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEA580C), Color(0xFFDC2626)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.upgrade_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Upgrade Available',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isFreeUpgrade ? 'FREE UPGRADE' : '₹$upgradeCost',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<CompetitionProvider>().initiateUpgrade(
                  context,
                  categoryId: categoryId,
                  paymentMethod: 'razorpay',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFEA580C),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                isFreeUpgrade
                    ? 'Get Free Upgrade'
                    : 'Upgrade Now — ₹$upgradeCost',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Not purchased ──────────────────────────────────────────────────────────
  Widget _buildBuyCard(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          const Icon(Icons.lock_rounded, color: Color(0xFF162556), size: 42),
          const SizedBox(height: 10),
          Text(
            'Unlock this Bundle',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF162556),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Purchase to access all tests',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (price > 0) ...[
                Text(
                  '₹$price',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF162556),
                  ),
                ),
                if (originalPrice > price) ...[
                  const SizedBox(width: 10),
                  Text(
                    '₹$originalPrice',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (discountAmount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '₹$discountAmount off',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                ],
              ] else
                Text(
                  'FREE',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.green.shade600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final convertedCategory = Child(
                id: data.id,
                name: data.name,
                price: data.effectivePrice,
                originalPrice: data.originalPrice,
              );
              showCategoryPaymentSheet(context, category: convertedCategory);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF162556),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              price == 0 ? 'Get Free Access' : 'Buy Bundle Now',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Purchased stat mini widget ─────────────────────────────────────────────
class _PurchasedStat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PurchasedStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TEST CARD
// ─────────────────────────────────────────────────────────────

class _TestCard extends StatefulWidget {
  final TestData test;
  final int index;
  final bool bundleHasAccess;
  final bool isUpgradable;
  final int upgradeCost;

  const _TestCard({
    required this.test,
    required this.index,
    required this.bundleHasAccess,
    required this.isUpgradable,
    required this.upgradeCost,
  });

  @override
  State<_TestCard> createState() => _TestCardState();
}

class _TestCardState extends State<_TestCard> {
  bool _locallyPurchased = false;

  bool get _isUnlocked {
    final testPurchased =
        _locallyPurchased || (widget.test.isPurchased ?? false);
    if (testPurchased) return true;
    if (widget.bundleHasAccess && widget.test.isNewLocked != true) {
  return true;
}
    return false;
  }

  String get _status {
    final raw = widget.test.testStatus;
    if (raw == null) return 'not_started';
    return raw.toString().toLowerCase();
  }

  ({String label, IconData icon, Color color}) get _actionConfig {
    switch (_status) {
      case 'completed':
        return (
          label: 'Result',
          icon: Icons.bar_chart_rounded,
          color: Colors.purple.shade600,
        );
      case 'in_progress':
      case 'paused':
        return (
          label: 'Resume',
          icon: Icons.play_arrow_rounded,
          color: Colors.orange.shade700,
        );
      default:
        return (
          label: 'Start',
          icon: Icons.play_circle_rounded,
          color: Colors.green.shade600,
        );
    }
  }

  void _onActionTap(BuildContext context) async {
    final examProvider = context.read<ExamSessionProvider>();
    if (!_isUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please purchase this test first")),
      );
      return;
    }

    switch (_status) {
      case 'completed':
        try {
          await examProvider.fetchResults(widget.test.testSessionId ?? '');
          final result = examProvider.results;
          if (result == null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Result not found")));
            return;
          }
          final progression = _buildProgression(result);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InstantResultsScreen(
                scoreProgression: progression.isEmpty ? [0.0] : progression,
                resultsData: result,
              ),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
        break;

      default:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExamInstructionsScreen(
              testId: widget.test.id ?? '',
              examTitle: widget.test.title ?? 'Exam',
              categoryId: widget.test.categoryId,
              pillarType: widget.test.applicableFor,
            ),
          ),
        );
    }
  }

List<double> _buildProgression(ExamResultsData data) {
  final questions = data.questions;
  if (questions == null || questions.isEmpty) return [0.0];

  double runningScore = 0;
  final maxScore = data.results.maxScore; // already double now

  return questions.map((q) {
    if (q.isCorrect == true) {
      runningScore += (q.marksEarned ?? q.question.marks.toDouble());
    }
    return maxScore > 0
        ? (runningScore / maxScore * 100).clamp(0.0, 100.0)
        : 0.0;
  }).toList();
}

  @override
  Widget build(BuildContext context) {
    final isPurchased = _isUnlocked;
    final int testPrice = widget.test.price ?? 0;
    final int originalPrice = widget.test.originalPrice ?? 0;
    final int effectivePrice = widget.test.effectivePrice ?? testPrice;
    final int discountAmount = widget.test.discountAmount ?? 0;
    final bool isFree = effectivePrice == 0;
    final action = _actionConfig;
    final bool isCompleted = _status == 'completed';
    final bool isInProgress = _status == 'in_progress' || _status == 'paused';
   final bool isNewLocked = widget.test.isNewLocked == true;

    Color borderColor;
    Color cardBg;
    if (isPurchased && isCompleted) {
      borderColor = Colors.purple.shade100;
      cardBg = Colors.purple.shade50.withOpacity(0.3);
    } else if (isPurchased && isInProgress) {
      borderColor = Colors.orange.shade100;
      cardBg = Colors.orange.shade50.withOpacity(0.3);
    } else if (isPurchased) {
      borderColor = Colors.green.shade100;
      cardBg = Colors.green.shade50.withOpacity(0.2);
    } else {
      borderColor = Colors.grey.shade200;
      cardBg = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: InkWell(
          onTap: isPurchased ? () => _onActionTap(context) : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top Row ──────────────────────────────────────────────────
                Row(
                  children: [
                    // Index / status icon
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: isPurchased
                            ? action.color.withOpacity(0.1)
                            : const Color(0xFF162556).withOpacity(0.06),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Center(
                        child: isPurchased
                            ? Icon(action.icon, color: action.color, size: 22)
                            : Text(
                                '${widget.index + 1}',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF162556),
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.test.title ?? 'Test ${widget.index + 1}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              if (isPurchased)
                                _StatusBadge(status: _status)
                              else if (isNewLocked)
                                _badge('New - Locked', Colors.orange.shade600)
                              else if (!isPurchased)
                                _badge('Locked', Colors.grey.shade500),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Action button
                    if (isPurchased)
                      _ActionButton(
                        label: action.label,
                        icon: action.icon,
                        color: action.color,
                        onTap: () => _onActionTap(context),
                      )
                    else
                      _TestBuyButton(
                        test: widget.test,
                        testPrice: effectivePrice,
                        isFree: isFree,
                        isUpgradable: widget.isUpgradable,
                        upgradeCost: widget.upgradeCost,
                        onPurchaseSuccess: () {
                          setState(() => _locallyPurchased = true);
                        },
                      ),
                  ],
                ),

                const SizedBox(height: 10),
                Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200),
                const SizedBox(height: 10),

                // ── Meta Row ─────────────────────────────────────────────────
                Wrap(
                   spacing: 8,
  runSpacing: 6,
  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _MetaChip(
                      icon: Icons.timer_outlined,
                      label: '${widget.test.durationMinutes ?? 0} mins',
                      color: Colors.blueGrey.shade500,
                    ),
                    const SizedBox(width: 8),
                    if (!isPurchased) ...[
                      if (isFree)
                        _MetaChip(
                          icon: Icons.lock_open_rounded,
                          label: 'Free',
                          color: Colors.green.shade600,
                        )
                      else ...[
                        _MetaChip(
                          icon: Icons.currency_rupee_rounded,
                          label: '$effectivePrice',
                          color: const Color(0xFF162556),
                        ),
                        if (originalPrice > effectivePrice) ...[
                          const SizedBox(width: 6),
                          Text(
                            '₹$originalPrice',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                        if (discountAmount > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '₹$discountAmount off',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                    // Upgrade hint
                    if (!isPurchased &&
                        widget.isUpgradable &&
                        widget.upgradeCost > 0) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.orange.shade200,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.upgrade_rounded,
                              size: 11,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Bundle ₹${widget.upgradeCost}',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                // ── Offer ────────────────────────────────────────────────────
                if (widget.test.appliedOffer != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.amber.shade200,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_offer_rounded,
                          size: 12,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.test.appliedOffer!.offerName ??
                              'Offer applied',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label,
      style: GoogleFonts.outfit(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    ),
  );
}

// ── Helpers ────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = switch (status) {
      'completed' => (label: 'Completed', color: Colors.purple.shade600),
      'in_progress' ||
      'paused' => (label: 'In Progress', color: Colors.orange.shade700),
      _ => (label: 'Unlocked', color: Colors.green.shade600),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        config.label,
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: config.color,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestBuyButton extends StatelessWidget {
  final TestData test;
  final int testPrice;
  final bool isFree;
  final bool isUpgradable;
  final int upgradeCost;
  final VoidCallback onPurchaseSuccess;

  const _TestBuyButton({
    required this.test,
    required this.testPrice,
    required this.isFree,
    required this.isUpgradable,
    required this.upgradeCost,
    required this.onPurchaseSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor =
        isFree ? Colors.green.shade600 : const Color(0xFF162556);
    final buttonIcon =
        isFree ? Icons.lock_open_rounded : Icons.shopping_cart_rounded;
    final buttonLabel = isFree ? 'Free' : '₹$testPrice';

    return GestureDetector(
      onTap: () {
        // Map TestData fields into a Child so the shared sheet can display them
        final testAsCategory = Child(
          id: test.id,
          name: test.title,
          price: test.price,
          originalPrice: test.originalPrice,
        );

        showTestPaymentSheet(
          context,
          testAsCategory: testAsCategory,
          testId: test.id ?? '',
          onPurchaseSuccess: onPurchaseSuccess,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(buttonIcon, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              buttonLabel,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Title ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF1E293B),
      ),
    );
  }
}

class _EmptyTests extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 48,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 10),
          Text(
            'No tests available yet',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
