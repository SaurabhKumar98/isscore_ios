import 'package:firstedu/data/models/api_models/competetive/competetionbyid_models.dart';
import 'package:firstedu/data/models/api_models/olympiadcentermodel/olympiadcategory_models.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/view/competetive/competetiondetailscreen.dart';
import 'package:firstedu/view/competetive/purchasebuttomsheetscreen.dart';
import 'package:firstedu/view/competetive/singlecompetetiondetailsscreen.dart';
import 'package:firstedu/view/download_view/download_screen.dart';
import 'package:firstedu/view_models/competetiveprovider/competetionprovider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CompetitionScreen extends StatefulWidget {
  final String rootType;
  const CompetitionScreen({super.key, required this.rootType});

  @override
  State<CompetitionScreen> createState() => _CompetitionScreenState();
}

class _CompetitionScreenState extends State<CompetitionScreen> {
  final _scrollController = ScrollController();
  late VoidCallback _refreshCallback;

  @override
  void initState() {
    super.initState();
    final provider = context.read<CompetitionProvider>();
    provider.resetForRootType(widget.rootType);

    _refreshCallback = () {
      if (mounted) {
        context
            .read<CompetitionProvider>()
            .fetchCompetitions(context, widget.rootType);
      }
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CompetitionProvider>();
      provider.addPaymentSuccessListener(_refreshCallback);
      Future.wait([
        provider.fetchCategoryTree(widget.rootType),
        provider.fetchCompetitions(context, widget.rootType),
      ]);
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    context
        .read<CompetitionProvider>()
        .removePaymentSuccessListener(_refreshCallback);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CompetitionProvider>().loadMore(context);
    }
  }

  void _openCategorySheet(BuildContext context, CompetitionProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CompetitionCategorySheet(
        flatCategories: provider.flatCategoryList,
        selectedCategoryId: provider.selectedFilterCategoryId,
        isLoading: provider.isCategoryTreeLoading,
        onSelect: (node) {
          Navigator.pop(context);
          provider.setFilterCategory(context, node?.id, widget.rootType);
        },
        onClear: () {
          Navigator.pop(context);
          provider.setFilterCategory(context, null, widget.rootType);
        },
      ),
    );
  }

  String _selectedCategoryLabel(CompetitionProvider provider) {
    if (provider.isCategoryTreeLoading) return 'Loading...';
    if (provider.selectedFilterCategoryId == null) return 'All Categories';
    final match = provider.flatCategoryList.firstWhere(
      (c) => c.id == provider.selectedFilterCategoryId,
      orElse: () => OlympiadCategoryData(name: 'Category'),
    );
    return match.name ?? 'Category';
  }

  /// Map rootType → pillarName for the free materials API
  String get _pillarName => widget.rootType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: RefreshIndicator(
          onRefresh: () => context.read<CompetitionProvider>().fetchCompetitions(context, widget.rootType),

        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            _AppBar(
              rootType: widget.rootType,
              onFreeMaterials: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DownloadsScreen(
                      initialTab: DownloadsTab.freeMaterials,
                      pillarName: _pillarName,
                    ),
                  ),
                );
              },
            ),
        
            // ── CATEGORY FILTER SECTION ──────────────────────────────────
            Consumer<CompetitionProvider>(
              builder: (context, provider, _) {
                return SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: provider.isCategoryTreeLoading
                              ? null
                              : () => _openCategorySheet(context, provider),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: provider.selectedFilterCategoryId != null
                                  ? drawerBgColor.withOpacity(0.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    provider.selectedFilterCategoryId != null
                                        ? drawerBgColor
                                        : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (provider.isCategoryTreeLoading)
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: provider
                                                  .selectedFilterCategoryId !=
                                              null
                                          ? drawerBgColor
                                          : Colors.grey,
                                    ),
                                  )
                                else
                                  Icon(
                                    Icons.category_outlined,
                                    size: 16,
                                    color:
                                        provider.selectedFilterCategoryId !=
                                                null
                                            ? drawerBgColor
                                            : Colors.grey,
                                  ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedCategoryLabel(provider),
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: provider
                                                .selectedFilterCategoryId !=
                                            null
                                        ? drawerBgColor
                                        : Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color:
                                      provider.selectedFilterCategoryId != null
                                          ? drawerBgColor
                                          : Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
        
                        // Clear button
                        if (provider.selectedFilterCategoryId != null) ...[
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => provider.setFilterCategory(
                                context, null, widget.rootType),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.red.shade200),
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
                );
              },
            ),
        
            // ── LIST ─────────────────────────────────────────────────────
            Consumer<CompetitionProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
        
                if (provider.categories.isEmpty) {
                  return SliverFillRemaining(
                    child: _EmptyState(
                      hasActiveFilter:
                          provider.selectedFilterCategoryId != null,
                      onRetry: () => provider.fetchCompetitions(
                          context, widget.rootType),
                      onClearFilter: () => provider.setFilterCategory(
                          context, null, widget.rootType),
                    ),
                  );
                }
        
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        if (i == provider.categories.length) {
                          return provider.isPaginationLoading
                              ? const Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 24),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                )
                              : const SizedBox.shrink();
                        }
                        final item = provider.categories[i];
                        return _SectorCard(category: item, index: i);
                      },
                      childCount: provider.categories.length + 1,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── App Bar ──────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final String rootType;
  final VoidCallback onFreeMaterials;

  const _AppBar({
    required this.rootType,
    required this.onFreeMaterials,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: drawerBgColor,
      elevation: 0,
      expandedHeight: 140,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: Colors.white, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      // ── Free Materials button in actions ─────────────────────────────
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: onFreeMaterials,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white.withOpacity(0.4), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.folder_open_rounded,
                      color: Colors.white, size: 15),
                  const SizedBox(width: 6),
                  Text(
                    'Free Materials',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [drawerBgColor, const Color(0xFF1E3A8A)],
                ),
              ),
            ),
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                height: 160,
                width: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              right: 60,
              bottom: -20,
              child: Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.emoji_events_rounded,
                              color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rootType,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Select a category to browse mock tests',
                              style: GoogleFonts.poppins(
                                  fontSize: 11, color: Colors.white60),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── rest of widgets unchanged (copy from your original) ─────────────────────
// _CompetitionCategorySheet, _SectorCard, _EmptyState stay exactly the same
// ── Category Bottom Sheet ────────────────────────────────────────────────────

class _CompetitionCategorySheet extends StatelessWidget {
  final List<OlympiadCategoryData> flatCategories;
  final String? selectedCategoryId;
  final bool isLoading;
  final void Function(OlympiadCategoryData? node) onSelect;
  final VoidCallback onClear;

  const _CompetitionCategorySheet({
    required this.flatCategories,
    required this.selectedCategoryId,
    required this.isLoading,
    required this.onSelect,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),

          // Handle bar
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select Category',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: drawerBgColor,
                    ),
                  ),
                ),
                if (selectedCategoryId != null)
                  GestureDetector(
                    onTap: onClear,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              color: selectedCategoryId == null
                  ? drawerBgColor.withOpacity(0.05)
                  : Colors.transparent,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selectedCategoryId == null
                          ? drawerBgColor
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
                            ? drawerBgColor
                            : Colors.grey.shade800,
                      ),
                    ),
                  ),
                  if (selectedCategoryId == null)
                    Icon(Icons.check_circle_rounded,
                        color: drawerBgColor, size: 20),
                ],
              ),
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade100),

          // Category list
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
                            horizontal: 16, vertical: 8),
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
                                  horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? drawerBgColor.withOpacity(0.06)
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
                                          ? drawerBgColor
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
                                            ? drawerBgColor
                                            : Colors.grey.shade800,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(Icons.check_circle_rounded,
                                        color: drawerBgColor, size: 20),
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

// ── Sector Card ───────────────────────────────────────────────────────────────

class _SectorCard extends StatelessWidget {
  final Child category;
  final int index;

  const _SectorCard({required this.category, required this.index});

  @override
  Widget build(BuildContext context) {
    final isActive = category.isActive ?? false;
    final hasAccess = category.hasAccess == true;
    final upgradable = category.upgradable == true;
    final isFree = (category.effectivePrice ?? 0) == 0;
    final effectivePrice = category.effectivePrice ?? category.price ?? 0;
    final originalPrice = category.originalPrice ?? category.price ?? 0;
    final discountAmount = category.discountAmount ?? 0;
    final upgradeCost = category.upgradeCost ?? 0;
    final paidSoFar = category.paidSoFar ?? 0;
    final childCount = category.childCount ?? 0;
    final isLeaf = category.isLeaf ?? false;

    Color accentColor = hasAccess
        ? const Color(0xFF16A34A)
        : upgradable
            ? const Color(0xFFEA580C)
            : activeItemColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasAccess
              ? Colors.green.shade200
              : upgradable
                  ? Colors.orange.shade200
                  : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top accent strip
          Container(
            height: 5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: hasAccess
                    ? [const Color(0xFF16A34A), const Color(0xFF22C55E)]
                    : upgradable
                        ? [const Color(0xFFEA580C), const Color(0xFFF97316)]
                        : [drawerBgColor, const Color(0xFF1E3A8A)],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Icon(
                          hasAccess
                              ? Icons.lock_open_rounded
                              : upgradable
                                  ? Icons.upgrade_rounded
                                  : Icons.school_rounded,
                          color: accentColor,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _dotChip(
                                isActive ? 'Active' : 'Inactive',
                                isActive ? Colors.green : Colors.grey,
                              ),
                              if (!isLeaf) ...[
                                const SizedBox(width: 6),
                                _dotChip(
                                    '$childCount Bundles', Colors.blueGrey),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (hasAccess)
                      _buildBadge('Purchased', const Color(0xFF16A34A),
                          Icons.check_circle_rounded)
                    else if (upgradable)
                      _buildBadge('Upgradable', const Color(0xFFEA580C),
                          Icons.upgrade_rounded),
                  ],
                ),

                if ((category.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    category.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey[600], height: 1.4),
                  ),
                ],

                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if ((category.appliedOffer?.offerName ?? '').isNotEmpty)
                      _infoChip(
                        Icons.local_offer_rounded,
                        category.appliedOffer!.offerName!,
                        Colors.amber.shade700,
                        Colors.amber.shade50,
                      ),
                    if (discountAmount > 0)
                      _infoChip(
                        Icons.discount_rounded,
                        '₹$discountAmount off',
                        Colors.green.shade700,
                        Colors.green.shade50,
                      ),
                    if (hasAccess && category.purchaseDate != null)
                      _infoChip(
                        Icons.calendar_today_rounded,
                        'Bought ${_formatDate(category.purchaseDate!)}',
                        Colors.blueGrey.shade600,
                        Colors.blueGrey.shade50,
                      ),
                    if (paidSoFar > 0)
                      _infoChip(
                        Icons.payment_rounded,
                        'Paid ₹$paidSoFar',
                        Colors.indigo.shade600,
                        Colors.indigo.shade50,
                      ),
                  ],
                ),

                const SizedBox(height: 14),
                Divider(height: 1, color: Colors.grey.shade100),
                const SizedBox(height: 14),

                Row(
                  children: [
                    if (!isFree) ...[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasAccess) ...[
                              Text(
                                '₹$paidSoFar paid',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF16A34A),
                                ),
                              ),
                              if (upgradeCost > 0)
                                Text(
                                  'Upgrade: ₹$upgradeCost',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ] else if (upgradable) ...[
                              Text(
                                'Upgrade: ₹$upgradeCost',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFEA580C),
                                ),
                              ),
                              Text(
                                'Paid: ₹$paidSoFar',
                                style: GoogleFonts.poppins(
                                    fontSize: 11, color: Colors.grey[500]),
                              ),
                            ] else ...[
                              Row(
                                children: [
                                  Text(
                                    '₹$effectivePrice',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: accentColor,
                                    ),
                                  ),
                                  if (originalPrice > effectivePrice) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      '₹$originalPrice',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        decoration:
                                            TextDecoration.lineThrough,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (discountAmount > 0)
                                Text(
                                  'You save ₹$discountAmount',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.green.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ] else ...[
                     const Expanded(child: SizedBox()),
                  
                    ],

                    Row(
                      children: [
                        if (!hasAccess && !isFree && !upgradable)
                          _actionButton(
                            label: 'Buy Now',
                            color: accentColor,
                            icon: Icons.shopping_cart_rounded,
                            onTap: () => showCategoryPaymentSheet(
                              context,
                              category: category,
                            ),
                          ),
                        if (upgradable && !hasAccess)
                          _actionButton(
                            label: 'Upgrade',
                            color: const Color(0xFFEA580C),
                            icon: Icons.upgrade_rounded,
                            onTap: () => showCategoryPaymentSheet(
                              context,
                              category: category,
                              isUpgrade: true,
                              upgradeAmount: upgradeCost,
                            ),
                          ),
                        if (hasAccess && upgradeCost > 0 && upgradable)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _actionButton(
                              label: 'Upgrade',
                              color: const Color(0xFFEA580C),
                              icon: Icons.upgrade_rounded,
                              onTap: () => showCategoryPaymentSheet(
                                context,
                                category: category,
                                isUpgrade: true,
                                upgradeAmount: upgradeCost,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        _outlineButton(
                          label: 'View',
                          icon: Icons.arrow_forward_rounded,
                          color: accentColor,
                          onTap: () => _navigateToDetail(context),
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

  Widget _buildBadge(String label, Color color, IconData icon) {
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
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
                fontSize: 10, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _dotChip(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
              fontSize: 11,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _infoChip(
      IconData icon, String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
                fontSize: 11, fontWeight: FontWeight.w600, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 13),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _outlineButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
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
                  color: color),
            ),
            const SizedBox(width: 4),
            Icon(icon, color: color, size: 13),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  void _navigateToDetail(BuildContext context) {
    final slug = (category.name ?? '')
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), '-');
    final isLeaf = category.isLeaf ?? false;

    if (isLeaf) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              Singlecompetetiondetailsscreen(id: category.id ?? ''),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CompetitionDetailScreen(path: slug, currentPath: slug),
        ),
      );
    }
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onClearFilter;
  final bool hasActiveFilter;

  const _EmptyState({
    required this.onRetry,
    required this.onClearFilter,
    required this.hasActiveFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 14),
          Text(
            hasActiveFilter
                ? 'No results for this filter'
                : 'No competitions available',
            style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[500]),
          ),
          const SizedBox(height: 20),
          if (hasActiveFilter)
            TextButton.icon(
              onPressed: onClearFilter,
              icon: const Icon(Icons.filter_alt_off),
              label: Text(
                'Clear Filter',
                style: GoogleFonts.poppins(color: activeItemColor),
              ),
            )
          else
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(
                'Retry',
                style: GoogleFonts.poppins(color: activeItemColor),
              ),
            ),
        ],
      ),
    );
  }
}