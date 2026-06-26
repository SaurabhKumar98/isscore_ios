import 'package:firstedu/data/models/api_models/competetive/competetionbyid_models.dart';
import 'package:firstedu/data/models/api_models/olympiadcentermodel/olympiadcategory_models.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/view/competetive/purchasebuttomsheetscreen.dart';
import 'package:firstedu/view/competetive/singlecompetetiondetailsscreen.dart';
import 'package:firstedu/view_models/competetiveprovider/competetionprovider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CompetitionDetailScreen extends StatefulWidget {
  final String path;
  final String currentPath;

  const CompetitionDetailScreen({
    super.key,
    required this.path,
    required this.currentPath,
  });

  @override
  State<CompetitionDetailScreen> createState() =>
      _CompetitionDetailScreenState();
}

class _CompetitionDetailScreenState extends State<CompetitionDetailScreen> {
  // ── LOCAL STATE ───────────────────────────────────────────────────────────
  CompetationDetailData? _localDetail;
  bool _isLocalLoading = true;
  String? _localError;

  // Category tree (loaded once per screen)
  List<OlympiadCategoryData> _localCategoryTree = [];
  bool _isCategoryLoading = false;

  // The selected filter — used for CLIENT-SIDE filtering only
  String? _selectedFilterCategoryId;

  late VoidCallback _refreshCallback;

  @override
  void initState() {
    super.initState();
    _refreshCallback = () {
      if (mounted) _loadDetail();
    };
    Future.microtask(() {
      final provider = context.read<CompetitionProvider>();
      provider.addPaymentSuccessListener(_refreshCallback);
      _loadCategoryTree();
      _loadDetail();
    });
  }

  @override
  void dispose() {
    context.read<CompetitionProvider>().removePaymentSuccessListener(
      _refreshCallback,
    );
    super.dispose();
  }

  // ── Load detail into LOCAL state — NO categoryId sent to API ─────────────
  // The backend resolve-path endpoint does not filter children by categoryId.
  // We do that entirely client-side via _filteredChildren.
  Future<void> _loadDetail() async {
    if (!mounted) return;
    setState(() {
      _isLocalLoading = true;
      _localError = null;
    });
    try {
      final provider = context.read<CompetitionProvider>();
      final res = await provider.fetchByPathLocal(
        context,
        widget.path,
        // ← categoryId intentionally omitted; filtering is done client-side
      );
      if (mounted) {
        setState(() {
          _localDetail = res;
          _isLocalLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _localError = e.toString();
          _isLocalLoading = false;
        });
      }
    }
  }

  // ── Load category tree for the filter sheet ───────────────────────────────
  Future<void> _loadCategoryTree() async {
    if (!mounted) return;
    setState(() => _isCategoryLoading = true);
    try {
      final provider = context.read<CompetitionProvider>();
      final res = await provider.fetchCategoryTreeLocal(
        provider.currentRootType,
      );
      if (mounted) {
        setState(() {
          _localCategoryTree = res;
          _isCategoryLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isCategoryLoading = false);
    }
  }

  // ── Flat list of all categories (for the sheet list + label lookup) ───────
  List<OlympiadCategoryData> get _flatCategories {
    final flat = <OlympiadCategoryData>[];
    for (final node in _localCategoryTree) {
      flat.addAll(node.flatten());
    }
    return flat;
  }

  // ── CLIENT-SIDE FILTER ────────────────────────────────────────────────────
  // The API always returns ALL children. We filter them here so the UI only
  // shows the bundle(s) that match the selected category.
  //
  // Strategy:
  //   1. Direct _id match → fastest, most reliable.
  //   2. Name match (case-insensitive) → fallback when the child's _id is the
  //      same object as the category node (e.g. JEE child _id == JEE category _id).
  List<dynamic> get _filteredChildren {
    final children = _localDetail?.children ?? [];
    if (_selectedFilterCategoryId == null) return children;

    // 1. Try direct ID match
    final directMatch = children
        .where(
          (item) =>
              (item.id ?? item.isLeaf ?? '').toString() ==
              _selectedFilterCategoryId,
        )
        .toList();
    if (directMatch.isNotEmpty) return directMatch;

    // 2. Fallback: match by category name
    final selectedCat = _flatCategories.firstWhere(
      (c) => c.id == _selectedFilterCategoryId,
      orElse: () => OlympiadCategoryData(name: ''),
    );
    final selectedName = (selectedCat.name ?? '').toLowerCase().trim();
    if (selectedName.isEmpty) return children;

    return children.where((item) {
      final itemName = ((item.name ?? '') as String).toLowerCase().trim();
      return itemName == selectedName;
    }).toList();
  }

  // ── Label shown on the filter chip ───────────────────────────────────────
  String get _selectedCategoryLabel {
    if (_isCategoryLoading) return 'Loading...';
    if (_selectedFilterCategoryId == null) return 'All Categories';
    final match = _flatCategories.firstWhere(
      (c) => c.id == _selectedFilterCategoryId,
      orElse: () => OlympiadCategoryData(name: 'Category'),
    );
    return match.name ?? 'Category';
  }

  // ── Open bottom sheet — selection only updates state, NO API call ─────────
  void _openCategorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailCategorySheet(
        flatCategories: _flatCategories,
        selectedCategoryId: _selectedFilterCategoryId,
        isLoading: _isCategoryLoading,
        onSelect: (node) {
          Navigator.pop(context);
          setState(() => _selectedFilterCategoryId = node?.id);
          // No _loadDetail() — filter is applied client-side
        },
        onClear: () {
          Navigator.pop(context);
          setState(() => _selectedFilterCategoryId = null);
          // No _loadDetail() — filter is cleared client-side
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _localDetail;
    final filtered = _filteredChildren;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: _isLocalLoading
          ? const Center(child: CircularProgressIndicator())
          : _localError != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 56,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _localError!,
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _loadDetail,
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      'Retry',
                      style: GoogleFonts.poppins(color: activeItemColor),
                    ),
                  ),
                ],
              ),
            )
          : data == null
          ? const Center(child: Text('No Data'))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── App Bar ─────────────────────────────────────────
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 220,
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
                        if ((data.node?.bannerImg ?? '').isNotEmpty)
                          Image.network(
                            data.node!.bannerImg!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _bannerPlaceholder(),
                          )
                        else
                          _bannerPlaceholder(),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xFF162556).withOpacity(0.9),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (data.node?.hasAccess == true)
                                _badgePill(
                                  'PURCHASED',
                                  Colors.green,
                                  Icons.check_circle_rounded,
                                )
                              else if (data.node?.upgradable == true)
                                _badgePill(
                                  'UPGRADABLE',
                                  Colors.orange.shade700,
                                  Icons.upgrade_rounded,
                                ),
                              const SizedBox(height: 6),
                              Text(
                                data.node?.name ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              if ((data.node?.effectivePrice ?? 0) > 0) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (data.node?.hasAccess == true) ...[
                                      Icon(
                                        Icons.lock_open_rounded,
                                        color: Colors.green.shade300,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Full access granted',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.green.shade300,
                                        ),
                                      ),
                                    ] else if (data.node?.upgradable ==
                                        true) ...[
                                      Text(
                                        'Upgrade: ₹${data.node?.upgradeCost}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.orange.shade300,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ] else ...[
                                      Text(
                                        '₹${data.node?.effectivePrice}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if ((data.node?.price ?? 0) >
                                          (data.node?.effectivePrice ?? 0)) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          '₹${data.node?.price}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.white54,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Category Filter ────────────────────────
                        Container(
                          color: Colors.transparent,
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: _isCategoryLoading
                                    ? null
                                    : _openCategorySheet,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedFilterCategoryId != null
                                        ? const Color(
                                            0xFF162556,
                                          ).withOpacity(0.08)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _selectedFilterCategoryId != null
                                          ? const Color(0xFF162556)
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_isCategoryLoading)
                                        const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1.5,
                                          ),
                                        )
                                      else
                                        Icon(
                                          Icons.category_outlined,
                                          size: 16,
                                          color:
                                              _selectedFilterCategoryId != null
                                              ? const Color(0xFF162556)
                                              : Colors.grey,
                                        ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _selectedCategoryLabel,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color:
                                              _selectedFilterCategoryId != null
                                              ? const Color(0xFF162556)
                                              : Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 18,
                                        color: _selectedFilterCategoryId != null
                                            ? const Color(0xFF162556)
                                            : Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_selectedFilterCategoryId != null) ...[
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    // Client-side clear only — no API call
                                    setState(
                                      () => _selectedFilterCategoryId = null,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.red.shade200,
                                      ),
                                    ),
                                    child: Text(
                                      'Clear',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // ── Node description ───────────────────────
                        if ((data.node?.description ?? '').isNotEmpty) ...[
                          Text(
                            data.node!.description!,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // ── Offer banner ───────────────────────────
                        if (data.node?.appliedOffer != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.local_offer_rounded,
                                  color: Colors.amber.shade700,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${data.node!.appliedOffer!.offerName} — ₹${data.node!.appliedOffer!.discountValue} off',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // ── Section header ─────────────────────────
                        Row(
                          children: [
                            Text(
                              'Available Bundles',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const Spacer(),
                            if (filtered.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: activeItemColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${filtered.length} bundle${filtered.length == 1 ? '' : 's'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: activeItemColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ── Sub-category cards ─────────────────────
                        if (filtered.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 52,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _selectedFilterCategoryId != null
                                        ? 'No bundles found for\n"$_selectedCategoryLabel"'
                                        : 'No bundles available',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[400],
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (_selectedFilterCategoryId != null) ...[
                                    const SizedBox(height: 14),
                                    GestureDetector(
                                      onTap: () => setState(
                                        () => _selectedFilterCategoryId = null,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: activeItemColor.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          'Clear filter',
                                          style: GoogleFonts.poppins(
                                            color: activeItemColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          )
                        else
                          ...filtered.map(
                            (item) => _SubCategoryCard(
                              item: item,
                              parentPath: widget.currentPath,
                              rootType: context
                                  .read<CompetitionProvider>()
                                  .currentRootType,
                            ),
                          ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _badgePill(String label, Color color, IconData icon) {
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
            style: GoogleFonts.poppins(
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

  Widget _bannerPlaceholder() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFF162556), Color(0xFF1E3A8A)]),
    ),
    child: Center(
      child: Icon(
        Icons.emoji_events_rounded,
        size: 72,
        color: Colors.white.withOpacity(0.15),
      ),
    ),
  );
}

// ── Category Filter Bottom Sheet ──────────────────────────────────────────────

class _DetailCategorySheet extends StatelessWidget {
  final List<OlympiadCategoryData> flatCategories;
  final String? selectedCategoryId;
  final bool isLoading;
  final void Function(OlympiadCategoryData? node) onSelect;
  final VoidCallback onClear;

  const _DetailCategorySheet({
    required this.flatCategories,
    required this.selectedCategoryId,
    required this.isLoading,
    required this.onSelect,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF162556);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Filter by Category',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
                if (selectedCategoryId != null)
                  GestureDetector(
                    onTap: onClear,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Clear',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey.shade100),

          // "All Categories" row
          InkWell(
            onTap: () => onSelect(null),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              color: selectedCategoryId == null
                  ? accent.withOpacity(0.05)
                  : Colors.transparent,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selectedCategoryId == null
                          ? accent
                          : Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'All Categories',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: selectedCategoryId == null
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selectedCategoryId == null
                            ? accent
                            : Colors.grey.shade800,
                      ),
                    ),
                  ),
                  if (selectedCategoryId == null)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: accent,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade100),

          Flexible(
            child: isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : flatCategories.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text(
                      'No categories available',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: flatCategories.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey.shade100),
                    itemBuilder: (context, index) {
                      final cat = flatCategories[index];
                      final isSelected = selectedCategoryId == cat.id;
                      return InkWell(
                        onTap: () => onSelect(cat),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? accent.withOpacity(0.06)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? accent
                                      : Colors.grey.shade300,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  cat.name ?? '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? accent
                                        : Colors.grey.shade800,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: accent,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUB-CATEGORY CARD
// ─────────────────────────────────────────────────────────────────────────────

class _SubCategoryCard extends StatelessWidget {
  final dynamic item;
  final String parentPath;
  final String rootType;

  const _SubCategoryCard({
    required this.item,
    required this.parentPath,
    required this.rootType,
  });

  @override
  Widget build(BuildContext context) {
    final int price = (item.effectivePrice ?? 0) as int;
    final int originalPrice = (item.price ?? 0) as int;
    final bool isLeaf = (item.isLeaf ?? false) as bool;
    final bool isFree = price == 0;
    final bool hasAccess = item.hasAccess == true;
    final bool isUpgradable = item.upgradable == true;
    final int upgradeCost = (item.upgradeCost ?? 0) as int;
    final int discountAmount = (item.discountAmount ?? 0) as int;
    final int paidSoFar = (item.paidSoFar ?? 0) as int;
    final String? purchaseDate = item.purchaseDate?.toString();
    final dynamic appliedOffer = item.appliedOffer;

    Color accentColor = hasAccess
        ? const Color(0xFF16A34A)
        : isUpgradable
        ? const Color(0xFFEA580C)
        : activeItemColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasAccess
              ? Colors.green.shade200
              : isUpgradable
              ? Colors.orange.shade200
              : Colors.grey.shade100,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top colour bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: hasAccess
                    ? [const Color(0xFF16A34A), const Color(0xFF22C55E)]
                    : isUpgradable
                    ? [const Color(0xFFEA580C), const Color(0xFFF97316)]
                    : [const Color(0xFF162556), const Color(0xFF1E3A8A)],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        hasAccess
                            ? Icons.lock_open_rounded
                            : isUpgradable
                            ? Icons.upgrade_rounded
                            : isLeaf
                            ? Icons.assignment_rounded
                            : Icons.folder_rounded,
                        color: accentColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (item.name ?? '') as String,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              if (isLeaf)
                                _dotTag('Leaf Bundle', Colors.blue.shade600)
                              else
                                _dotTag(
                                  'Has Sub-bundles',
                                  Colors.purple.shade600,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (hasAccess)
                      _statusBadge(
                        'Purchased',
                        const Color(0xFF16A34A),
                        Icons.check_circle_rounded,
                      )
                    else if (isUpgradable)
                      _statusBadge(
                        'Upgradable',
                        const Color(0xFFEA580C),
                        Icons.upgrade_rounded,
                      ),
                  ],
                ),

                // Description
                if ((item.description ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    (item.description ?? '') as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                      height: 1.4,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Chips
                Wrap(
                  spacing: 7,
                  runSpacing: 6,
                  children: [
                    if (appliedOffer != null &&
                        (appliedOffer.offerName ?? '').isNotEmpty)
                      _chip(
                        Icons.local_offer_rounded,
                        appliedOffer.offerName ?? '',
                        Colors.amber.shade700,
                        Colors.amber.shade50,
                      ),
                    if (discountAmount > 0)
                      _chip(
                        Icons.discount_rounded,
                        '₹$discountAmount off',
                        Colors.green.shade700,
                        Colors.green.shade50,
                      ),
                    if (paidSoFar > 0)
                      _chip(
                        Icons.payment_rounded,
                        'Paid ₹$paidSoFar',
                        Colors.indigo.shade600,
                        Colors.indigo.shade50,
                      ),
                    if (hasAccess && purchaseDate != null)
                      _chip(
                        Icons.calendar_today_rounded,
                        'Bought ${_formatDate(purchaseDate)}',
                        Colors.blueGrey.shade600,
                        Colors.blueGrey.shade50,
                      ),
                  ],
                ),

                const SizedBox(height: 14),
                Divider(height: 1, color: Colors.grey.shade100),
                const SizedBox(height: 14),

                // Price + Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildPriceSection(
                        hasAccess: hasAccess,
                        isUpgradable: isUpgradable,
                        isFree: isFree,
                        price: price,
                        originalPrice: originalPrice,
                        discountAmount: discountAmount,
                        paidSoFar: paidSoFar,
                        upgradeCost: upgradeCost,
                        accentColor: accentColor,
                      ),
                    ),
                    Row(
                      children: [
                        if (!hasAccess && !isFree && !isUpgradable)
                          _actionBtn(
                            'Buy',
                            accentColor,
                            Icons.shopping_cart_rounded,
                            () {
                              showCategoryPaymentSheet(context, category: item);
                            },
                          ),
                        if (isUpgradable)
                          _actionBtn(
                            'Upgrade',
                            const Color(0xFFEA580C),
                            Icons.upgrade_rounded,
                            () {
                              showCategoryPaymentSheet(
                                context,
                                category: item,
                                isUpgrade: true,
                                upgradeAmount: upgradeCost,
                              );
                            },
                          ),
                        const SizedBox(width: 8),
                        _outlineBtn(
                          'View',
                          accentColor,
                          Icons.arrow_forward_rounded,
                          () {
                            _navigateToDetail(context, isLeaf);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection({
    required bool hasAccess,
    required bool isUpgradable,
    required bool isFree,
    required int price,
    required int originalPrice,
    required int discountAmount,
    required int paidSoFar,
    required int upgradeCost,
    required Color accentColor,
  }) {
    if (isFree) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'FREE',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.green.shade700,
            fontSize: 14,
          ),
        ),
      );
    }
    if (hasAccess) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '₹$paidSoFar paid',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF16A34A),
            ),
          ),
          if (isUpgradable && upgradeCost > 0)
            Text(
              'Upgrade: ₹$upgradeCost',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      );
    }
    if (isUpgradable) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upgrade: ₹$upgradeCost',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFEA580C),
            ),
          ),
          if (paidSoFar > 0)
            Text(
              'Paid so far: ₹$paidSoFar',
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
            ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '₹$price',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: accentColor,
              ),
            ),
            if (originalPrice > price) ...[
              const SizedBox(width: 6),
              Text(
                '₹$originalPrice',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ],
        ),
        if (discountAmount > 0)
          Text(
            'Save ₹$discountAmount',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.green.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _statusBadge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dotTag(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _chip(IconData icon, String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: textColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
    String label,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
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
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 13),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _outlineBtn(
    String label,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(width: 3),
            Icon(icon, color: color, size: 13),
          ],
        ),
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

  void _navigateToDetail(BuildContext context, bool isLeaf) {
    final slug = ((item.name ?? '') as String).toLowerCase().trim().replaceAll(
      RegExp(r'\s+'),
      '-',
    );
    final fullPath = '$parentPath/$slug';

    if (isLeaf) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Singlecompetetiondetailsscreen(
            id: (item.id ?? item.sId ?? '') as String,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CompetitionDetailScreen(path: fullPath, currentPath: fullPath),
        ),
      );
    }
  }
}
