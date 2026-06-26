import 'package:firstedu/data/models/api_models/olympiadcentermodel/olympiadcategory_models.dart';
import 'package:firstedu/data/models/api_models/olympiadcentermodel/olympiaddetailsmodels.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_filter_chips.dart';
import 'package:firstedu/res/widgets/custom_silverappbar.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/instantresultscreen.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/questionscreen.dart';
import 'package:firstedu/view/olympaid_view/olympiad_card.dart';
import 'package:firstedu/view/olympaid_view/olympiaddetailsscreen.dart';
import 'package:firstedu/view/olympaid_view/olympiadpaymentsheet.dart';
import 'package:firstedu/view_models/examhallprovider/examsessionprovider.dart';
import 'package:firstedu/view_models/olympiadprovider/olympiadcenterprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class OlympiadScreen extends StatefulWidget {
  const OlympiadScreen({super.key});

  @override
  State<OlympiadScreen> createState() => _OlympiadScreenState();
}

class _OlympiadScreenState extends State<OlympiadScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _statusFilters = [
    {"label": "All", "value": null},
    {"label": "Open", "value": "open"},
    {"label": "Live", "value": "live"},
    {"label": "Completed", "value": "completed"},
    {"label": "Closed", "value": "closed"},
    {"label": "Registered", "value": "registered"},
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final provider = context.read<OlympiadProvider>();
      await Future.wait([
        provider.fetchCategories(context),
        provider.fetchOlympiads(context),
      ]);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<OlympiadProvider>().loadMore(context);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── Open detail screen ────────────────────────────────────────────────────

  void _openDetail(String olympiadId) {
    context.read<OlympiadProvider>().clearDetail();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<OlympiadProvider>(),
          child: OlympiadDetailScreen(olympiadId: olympiadId),
        ),
      ),
      // ← ADD THIS: refresh list when user comes back
    ).then((_) {
      if (mounted) {
        context.read<OlympiadProvider>().fetchOlympiads(context);
      }
    });
  }
  // ── Open payment sheet ────────────────────────────────────────────────────

  void _openPaymentSheet(dynamic item) {
    final details = OlympiadDetailsData(
      id: item.id,
      title: item.title,
      description: item.description,
      categoryId: item.categoryId == null
          ? null
          : CategoryId(
              id: item.categoryId?.id,
              name: item.categoryId?.name,
              kind: item.categoryId?.kind,
              parent: item.categoryId?.parent == null
                  ? null
                  : Parent(
                      id: item.categoryId?.parent?.id,
                      name: item.categoryId?.parent?.name,
                    ),
            ),
      categoryName: item.categoryName,
      testId: item.testId == null
          ? null
          : TestId(id: item.testId?.id, title: item.testId?.title),
      price: item.price,
      originalPrice: item.originalPrice,
      discountedPrice: item.discountedPrice,
      discountAmount: item.discountAmount,
      effectivePrice: item.effectivePrice,
      status: item.status,
      isRegistered: item.isRegistered,
      isRegistrationOpen: item.isRegistrationOpen,
      isEventLive: item.isEventLive,
      registrationStartTime: item.registrationStartTime,
      registrationEndTime: item.registrationEndTime,
      startTime: item.startTime,
      endTime: item.endTime,
      resultDeclarationDate: item.resultDeclarationDate,
      firstPlacePoints: item.firstPlacePoints,
      secondPlacePoints: item.secondPlacePoints,
      thirdPlacePoints: item.thirdPlacePoints,
      testStatus: item.testStatus,
      testSessionId: item.testSessionId,
      appliedOffer: item.appliedOffer == null
          ? null
          : AppliedOffer(
              id: item.appliedOffer?.id,
              offerName: item.appliedOffer?.offerName,
              applicableOn: item.appliedOffer?.applicableOn,
              discountType: item.appliedOffer?.discountType,
              discountValue: item.appliedOffer?.discountValue,
              description: item.appliedOffer?.description,
              validTill: item.appliedOffer?.validTill,
            ),
    );

    showOlympiadPaymentSheet(context, olympiad: details).then((_) {
      if (mounted) {
        context.read<OlympiadProvider>().fetchOlympiads(context);
      }
    });
  }

  // ── Result screen ─────────────────────────────────────────────────────────

  Future<void> _openResultScreen(
    BuildContext context,
    String? sessionId,
  ) async {
    if (sessionId == null || sessionId.isEmpty) {
      AppToast.error(
        context,
        title: 'Unavailable',
        message: 'No result session found for this olympiad.',
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final provider = context.read<ExamSessionProvider>();
      await provider.fetchResults(sessionId);
      if (context.mounted) Navigator.of(context).pop();

      final resultsData = provider.results;
      final List<double> scoreProgression = [];
      if (resultsData?.questions != null) {
        int correct = 0;
        int total = 0;
        for (final q in resultsData!.questions ?? []) {
          total++;
          if (q.isCorrect == true) correct++;
          scoreProgression.add((correct / total) * 100);
        }
      }
      if (scoreProgression.isEmpty) scoreProgression.add(0.0);

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InstantResultsScreen(
              scoreProgression: scoreProgression,
              resultsData: resultsData,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted) {
        AppToast.error(
          context,
          title: 'Error',
          message: 'Could not load results. Please try again.',
        );
      }
    }
  }

  // ── Auto-refresh on countdown complete ────────────────────────────────────

  void _onCountdownComplete() {
    if (!mounted) return;
    context.read<OlympiadProvider>().fetchOlympiads(context);
  }

  // ── Category bottom sheet ─────────────────────────────────────────────────

  void _openCategorySheet(BuildContext context, OlympiadProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OlympiadCategorySheet(
        categories: provider.categories,
        selectedCategoryId: provider.selectedCategoryId,
        onSelect: (cat) {
          Navigator.pop(context);
          provider.setCategory(context, cat?.id);
        },
        onClear: () {
          Navigator.pop(context);
          provider.setCategory(context, null);
        },
      ),
    );
  }

  /// Label shown on the category button
  String _selectedCategoryLabel(OlympiadProvider provider) {
    if (provider.isCategoryLoading) return 'Loading...';
    if (provider.selectedCategoryId == null) return 'All Classes';
    final match = provider.categories.firstWhere(
      (c) => c.id == provider.selectedCategoryId,
      orElse: () => OlympiadCategoryData(name: 'Category'),
    );
    return match.name ?? 'Category';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OlympiadProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: RefreshIndicator(
         onRefresh: () async {
        await Future.wait([
          provider.fetchCategories(context),
          provider.fetchOlympiads(context),
        ]);
      },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            const CustomSliverAppBar(
              title: "Olympiad Center",
              subtitle: "Register for national and international competitions.",
            ),
        
            // ── FILTER SECTION ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.only(top: 12.h, bottom: 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Status chips ──────────────────────────────────────────
                    SizedBox(
                      height: 40.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: _statusFilters.length,
                        separatorBuilder: (_, __) => SizedBox(width: 8.w),
                        itemBuilder: (context, index) {
                          final String? statusValue =
                              _statusFilters[index]["value"] as String?;
                          final String label =
                              _statusFilters[index]["label"] as String;
                          return CustomFilterChip(
                            label: label,
                            selected: provider.selectedStatus == statusValue,
                            onTap: () => context
                                .read<OlympiadProvider>()
                                .setStatus(context, statusValue),
                          );
                        },
                      ),
                    ),
        
                    SizedBox(height: 10.h),
        
                    // ── Category button + Clear ───────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: provider.isCategoryLoading
                                ? null
                                : () => _openCategorySheet(context, provider),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: provider.selectedCategoryId != null
                                    ? drawerColor.withOpacity(0.08)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: provider.selectedCategoryId != null
                                      ? drawerColor
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (provider.isCategoryLoading)
                                    SizedBox(
                                      width: 14.w,
                                      height: 14.w,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        color: provider.selectedCategoryId != null
                                            ? drawerColor
                                            : Colors.grey,
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.category_outlined,
                                      size: 16.sp,
                                      color: provider.selectedCategoryId != null
                                          ? drawerColor
                                          : Colors.grey,
                                    ),
                                  SizedBox(width: 8.w),
                                  CustomText(
                                    text: _selectedCategoryLabel(provider),
                                    size: 13,
                                    color: provider.selectedCategoryId != null
                                        ? drawerColor
                                        : Colors.grey,
                                    weight: FontWeight.w500,
                                  ),
                                  SizedBox(width: 6.w),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 18.sp,
                                    color: provider.selectedCategoryId != null
                                        ? drawerColor
                                        : Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
        
                          // Clear button — only when a category is selected
                          if (provider.selectedCategoryId != null) ...[
                            SizedBox(width: 10.w),
                            GestureDetector(
                              onTap: () => context
                                  .read<OlympiadProvider>()
                                  .setCategory(context, null),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: CustomText(
                                  text: "Clear",
                                  size: 12,
                                  color: Colors.red,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        
            // ── LOADING ───────────────────────────────────────────────────────
            if (provider.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            // ── EMPTY ─────────────────────────────────────────────────────────
            else if (provider.items.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.search_off_rounded,
                        size: 56,
                        color: Colors.black26,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "No olympiads found",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black45,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        "Try changing the filter",
                        style: TextStyle(fontSize: 13.sp, color: Colors.black38),
                      ),
                    ],
                  ),
                ),
              )
            // ── LIST ──────────────────────────────────────────────────────────
            else
              SliverPadding(
                padding: EdgeInsets.all(16.w),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < provider.items.length) {
                        final item = provider.items[index];
                        final status = item.status?.toUpperCase() ?? '';
                        final isRegistered = item.isRegistered ?? false;
                        final isLive = status == 'LIVE';
                        final isOpen = status == 'OPEN';
                        final testStatus = item.testStatus?.toLowerCase() ?? '';
                        final isExamCompleted = testStatus == 'completed';
                        final sessionId = item.testId?.sessionId;
        
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: OlympiadCard(
                            title: item.title ?? "",
                            olympiadId: item.id ?? "",
                            organizer: item.categoryName ?? "",
                            subject: item.categoryId?.name ?? "General",
                            description: item.description ?? "",
                            date: item.startTime != null
                                ? "${item.startTime!.day}/${item.startTime!.month}/${item.startTime!.year}"
                                : "",
                            fee:
                                (item.discountedPrice != null &&
                                    item.discountAmount != null &&
                                    item.discountAmount! > 0)
                                ? item.discountedPrice.toString()
                                : item.price?.toString() ?? "0",
                            status: item.status ?? "",
                            isRegistered: isRegistered,
                            resultDeclarationDate: item.resultDeclarationDate,
                            startDate: item.startTime,
                            endDate: item.endTime,
                            registrationEndDate: item.registrationEndTime,
                            discountAmount: item.discountAmount,
                            originalPrice: item.originalPrice,
                            discountedPrice: item.discountedPrice,
                            goesLiveAt: item.startTime,
                            icon: Icons.emoji_events_outlined,
                            iconBgColor: const Color(0xFFE3F2FD),
                            iconColor: const Color(0xFF2196F3),
                            isExamCompleted: isExamCompleted,
                            examSessionId: sessionId,
                            onCountdownComplete: _onCountdownComplete,
                            onTap: () => _openDetail(item.id ?? ""),
                            onRegister: isOpen && !isRegistered
                                ? () => _openPaymentSheet(item)
                                : null,
                            onEnterExam:
                                isLive && isRegistered && !isExamCompleted
                                ? () {
                                    final testId = item.testId?.id;
                                    if (testId == null || testId.isEmpty) {
                                      AppToast.error(
                                        context,
                                        title: 'Unavailable',
                                        message:
                                            'No exam linked to this olympiad.',
                                      );
                                      return;
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ChangeNotifierProvider.value(
                                              value: context
                                                  .read<ExamSessionProvider>(),
                                              child: ExamScreen(
                                                testId: testId,
                                                examTitle:
                                                    item.title ?? 'Olympiad Exam',
                                                isBundleTest: false,
        
                                                // Add these
                                                showInstantResult: false,
                                                resultDeclaredAt:
                                                    item.resultDeclarationDate,
                                              ),
                                            ),
                                      ),
                                    );
                                  }
                                : null,
                            onViewResult: (isRegistered && isExamCompleted)
                                ? () => _openResultScreen(context, sessionId)
                                : null,
                          ),
                        );
                      }
        
                      if (provider.isPaginationLoading) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return const SizedBox();
                    },
                    childCount:
                        provider.items.length +
                        (provider.isPaginationLoading ? 1 : 0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Category bottom sheet ─────────────────────────────────────────────────────

class _OlympiadCategorySheet extends StatefulWidget {
  final List<OlympiadCategoryData> categories;
  final String? selectedCategoryId;
  final void Function(OlympiadCategoryData? cat) onSelect;
  final VoidCallback onClear;

  const _OlympiadCategorySheet({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelect,
    required this.onClear,
  });

  @override
  State<_OlympiadCategorySheet> createState() => _OlympiadCategorySheetState();
}

class _OlympiadCategorySheetState extends State<_OlympiadCategorySheet> {
  final Set<String> _expandedIds = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(
                  child: CustomText(
                    text: 'Select Class',
                    size: 16,
                    weight: FontWeight.w700,
                    color: drawerColor,
                  ),
                ),
                if (widget.selectedCategoryId != null)
                  GestureDetector(
                    onTap: widget.onClear,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: CustomText(
                        text: 'Clear',
                        size: 12,
                        color: Colors.red,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: 12.h),
          Divider(height: 1, color: Colors.grey.shade100),

          // "All Classes" row
          InkWell(
            onTap: () => widget.onSelect(null),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              color: widget.selectedCategoryId == null
                  ? drawerColor.withOpacity(0.05)
                  : Colors.transparent,
              child: Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.selectedCategoryId == null
                          ? drawerColor
                          : Colors.grey.shade300,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: CustomText(
                      text: 'All Classes',
                      size: 14,
                      weight: widget.selectedCategoryId == null
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: widget.selectedCategoryId == null
                          ? drawerColor
                          : Colors.grey.shade800,
                    ),
                  ),
                  if (widget.selectedCategoryId == null)
                    Icon(
                      Icons.check_circle_rounded,
                      color: drawerColor,
                      size: 20.sp,
                    ),
                ],
              ),
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade100),

          // Tree list
          Flexible(
            child: widget.categories.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(40.w),
                    child: CustomText(
                      text: 'No categories available',
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    itemCount: widget.categories.length,
                    itemBuilder: (context, index) {
                      return _buildNode(widget.categories[index], depth: 0);
                    },
                  ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
        ],
      ),
    );
  }

  Widget _buildNode(OlympiadCategoryData cat, {required int depth}) {
    final isSelected = widget.selectedCategoryId == cat.id;
    final hasChildren = cat.children != null && cat.children!.isNotEmpty;
    final isExpanded = _expandedIds.contains(cat.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            if (hasChildren) {
              setState(() {
                if (isExpanded) {
                  _expandedIds.remove(cat.id);
                } else {
                  _expandedIds.add(cat.id!);
                }
              });
            } else {
              widget.onSelect(cat);
            }
          },
          borderRadius: BorderRadius.circular(10.r),
          child: Container(
            padding: EdgeInsets.only(
              left: (12.0 + depth * 16.0).w,
              right: 12.w,
              top: 14.h,
              bottom: 14.h,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? drawerColor.withOpacity(0.06)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? drawerColor : Colors.grey.shade300,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: CustomText(
                    text: cat.name ?? '',
                    size: depth == 0 ? 14 : 13,
                    weight: depth == 0
                        ? FontWeight.w700
                        : isSelected
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: isSelected
                        ? drawerColor
                        : depth == 0
                        ? Colors.grey.shade800
                        : Colors.grey.shade700,
                  ),
                ),
                if (hasChildren) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: CustomText(
                      text: '${cat.children!.length}',
                      size: 11,
                      color: Colors.grey.shade600,
                      weight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ] else if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: drawerColor,
                    size: 20.sp,
                  ),
              ],
            ),
          ),
        ),

        // Animated children
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: isExpanded && hasChildren
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cat.children!
                      .map((child) => _buildNode(child, depth: depth + 1))
                      .toList(),
                )
              : const SizedBox.shrink(),
        ),

        if (depth == 0) Divider(height: 1, color: Colors.grey.shade100),
      ],
    );
  }
}
