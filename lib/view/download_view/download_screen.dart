import 'package:firstedu/data/models/api_models/coursedownload/purchasecourse.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_button.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_filter_chips.dart';
import 'package:firstedu/res/widgets/custom_silverappbar.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/view_models/coursedownloadprovider/downloadprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

enum DownloadsTab { generalCourses, certificationCourses, freeMaterials }

class DownloadsScreen extends StatefulWidget {
  final DownloadsTab initialTab;
  final String? pillarName;

  const DownloadsScreen({
    super.key,
    this.initialTab = DownloadsTab.generalCourses,
    this.pillarName,
  });

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Type filter (General / Certification) ─────────────────────────
  static const _typeFilters = [
    _FilterChip(value: null, label: 'All'),
    _FilterChip(value: 'pdf', label: 'PDF'),
    _FilterChip(value: 'audio', label: 'Audio'),
    _FilterChip(value: 'video', label: 'Video'),
  ];
  String? _selectedType;

  // ── Pillar filter (Free Materials) ────────────────────────────────
  static const _pillarFilters = [
    _FilterChip(value: null, label: 'All'),
    _FilterChip(value: 'Competitive', label: 'Competitive'),
    _FilterChip(value: 'School', label: 'School'),
    _FilterChip(value: 'Skill Development', label: 'Skill Dev'),
    _FilterChip(value: 'Olympiads', label: 'Olympiads'),
  ];
  String? _selectedPillar;

  @override
  void initState() {
    super.initState();

    // Pre-select pillar if passed from parent
    if (widget.pillarName != null) {
      _selectedPillar = _pillarFilters
          .firstWhere(
            (p) =>
                p.value?.toLowerCase() ==
                widget.pillarName!.toLowerCase(),
            orElse: () => _pillarFilters.first,
          )
          .value;
    }

    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.index,
    );
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCurrentTab());
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    _loadCurrentTab();
  }

  void _loadCurrentTab() {
    final p = context.read<DownloadCourseProvider>();
    switch (_tabController.index) {
      case 0:
        p.fetchGeneralCourses(context);
        break;
      case 1:
        p.fetchCertificationCourses(context);
        break;
      case 2:
        p.fetchFreeMaterials(context, pillarName: _selectedPillar);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: CustomScrollView(
        slivers: [
          // ── App Bar ─────────────────────────────────────────────────
          CustomSliverAppBar(
            title: 'Downloads',
            subtitle: 'Your courses, materials & free resources.',
          ),

          // ── Tab Bar ──────────────────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: drawerColor,
                indicatorWeight: 3,
                labelColor: drawerColor,
                unselectedLabelColor: Colors.grey,
                labelStyle: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: TextStyle(fontSize: 13.sp),
                labelPadding:
                    EdgeInsets.symmetric(horizontal: 16.w),
                tabs: const [
                  Tab(text: 'General'),
                  Tab(text: 'Certification'),
                  Tab(text: 'Free Materials'),
                ],
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _CourseTab(
                  isGeneral: true,
                  selectedType: _selectedType,
                  typeFilters: _typeFilters,
                  onTypeChanged: (val) {
                    setState(() => _selectedType = val);
                    context
                        .read<DownloadCourseProvider>()
                        .setType(context, val);
                  },
                ),
                _CourseTab(
                  isGeneral: false,
                  selectedType: _selectedType,
                  typeFilters: _typeFilters,
                  onTypeChanged: (val) {
                    setState(() => _selectedType = val);
                    context
                        .read<DownloadCourseProvider>()
                        .setType(context, val);
                  },
                ),
                _FreeMaterialsTab(
                  selectedPillar: _selectedPillar,
                  pillarFilters: _pillarFilters,
                  onPillarChanged: (val) {
                    setState(() => _selectedPillar = val);
                    context
                        .read<DownloadCourseProvider>()
                        .fetchFreeMaterials(context, pillarName: val);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Simple data class for filter chips ───────────────────────────────────────
class _FilterChip {
  final String? value;
  final String label;
  const _FilterChip({required this.value, required this.label});
}

// ── Pinned TabBar delegate ────────────────────────────────────────────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(
        color: Colors.white,
        child: tabBar,
      );

  @override
  bool shouldRebuild(_TabBarDelegate old) => false;
}

// ── Course Tab ────────────────────────────────────────────────────────────────
class _CourseTab extends StatelessWidget {
  final bool isGeneral;
  final String? selectedType;
  final List<_FilterChip> typeFilters;
  final void Function(String?) onTypeChanged;

  const _CourseTab({
    required this.isGeneral,
    required this.selectedType,
    required this.typeFilters,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadCourseProvider>(
      builder: (context, provider, _) {
        final isLoading = isGeneral
            ? provider.isGeneralLoading
            : provider.isCertificationLoading;
        final courses = isGeneral
            ? provider.generalCourses
            : provider.certificationCourses;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Type filter chips — same as ExamHallScreen ─────────────
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 12.h),
                child: SizedBox(
                  height: 42.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: typeFilters.length,
                    separatorBuilder: (_, __) => SizedBox(width: 10.w),
                    itemBuilder: (_, i) {
                      final chip = typeFilters[i];
                      return CustomFilterChip(
                        label: chip.label,
                        selected: selectedType == chip.value,
                        onTap: () => onTypeChanged(chip.value),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ── List ──────────────────────────────────────────────────
            if (isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (courses.isEmpty)
              SliverFillRemaining(
                child: _EmptyState(
                  message: isGeneral
                      ? 'No general courses found'
                      : 'No certification courses found',
                  onRetry: () => isGeneral
                      ? provider.fetchGeneralCourses(context)
                      : provider.fetchCertificationCourses(context),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 80.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) =>
                        _DownloadItemCard(purchased: courses[i]),
                    childCount: courses.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── Free Materials Tab ────────────────────────────────────────────────────────
class _FreeMaterialsTab extends StatelessWidget {
  final String? selectedPillar;
  final List<_FilterChip> pillarFilters;
  final void Function(String?) onPillarChanged;

  const _FreeMaterialsTab({
    required this.selectedPillar,
    required this.pillarFilters,
    required this.onPillarChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadCourseProvider>(
      builder: (context, provider, _) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Pillar filter chips — same pattern ────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 12.h),
                child: SizedBox(
                  height: 42.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: pillarFilters.length,
                    separatorBuilder: (_, __) => SizedBox(width: 10.w),
                    itemBuilder: (_, i) {
                      final chip = pillarFilters[i];
                      return CustomFilterChip(
                        label: chip.label,
                        selected: selectedPillar == chip.value,
                        onTap: () => onPillarChanged(chip.value),
                      );
                    },
                  ),
                ),
              ),
            ),

            if (provider.isFreeMaterialsLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.freeMaterials.isEmpty)
              SliverFillRemaining(
                child: _EmptyState(
                  message: selectedPillar == null
                      ? 'No free materials available'
                      : 'No $selectedPillar materials found',
                  onRetry: () => provider.fetchFreeMaterials(
                    context,
                    pillarName: selectedPillar,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 80.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _DownloadItemCard(
                        purchased: provider.freeMaterials[i]),
                    childCount: provider.freeMaterials.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _EmptyState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_rounded,
              size: 56.sp, color: Colors.grey.shade300),
          SizedBox(height: 14.h),
          CustomText(
            text: message,
            size: 14,
            color: Colors.grey.shade500,
            align: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: drawerColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Download Item Card ────────────────────────────────────────────────────────
class _DownloadItemCard extends StatelessWidget {
  final PurchasedCourse purchased;
  const _DownloadItemCard({required this.purchased});

  @override
  Widget build(BuildContext context) {
    final course = purchased.course;
    final title = course?.title ?? 'Untitled';
    final description = course?.description ?? '';
    final contents = course?.contents ?? [];
    final isFree = (course?.price ?? 0) == 0;
    final firstType =
        contents.isNotEmpty ? contents.first.type ?? '' : '';

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: CustomCard(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top accent strip ─────────────────────────────────────
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: _typeColor(firstType),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16.r)),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title + type badge row ────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: CustomText(
                          text: title,
                          size: 15,
                          weight: FontWeight.w700,
                          color: Colors.black87,
                          maxLines: 2,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _badge(
                        isFree ? 'FREE' : 'PAID',
                        isFree ? Colors.green : drawerColor,
                      ),
                    ],
                  ),

                  if (description.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    CustomText(
                      text: description,
                      size: 12,
                      color: Colors.grey.shade500,
                      maxLines: 2,
                    ),
                  ],

                  SizedBox(height: 12.h),
                  Divider(height: 1, color: Colors.grey.shade100),
                  SizedBox(height: 12.h),

                  // ── Meta row ─────────────────────────────────────
                  Row(
                    children: [
                      Icon(_typeIcon(firstType),
                          size: 14.sp, color: _typeColor(firstType)),
                      SizedBox(width: 6.w),
                      CustomText(
                        text: firstType.isEmpty
                            ? 'Mixed'
                            : firstType.toUpperCase(),
                        size: 12,
                        weight: FontWeight.w600,
                        color: _typeColor(firstType),
                      ),
                      const Spacer(),
                      Icon(Icons.attach_file_rounded,
                          size: 14.sp, color: Colors.grey.shade400),
                      SizedBox(width: 4.w),
                      CustomText(
                        text:
                            '${contents.length} file${contents.length != 1 ? 's' : ''}',
                        size: 12,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ),

                  if (purchased.paymentStatus != null) ...[
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          purchased.paymentStatus == 'completed'
                              ? Icons.check_circle_rounded
                              : Icons.pending_rounded,
                          size: 13.sp,
                          color: purchased.paymentStatus == 'completed'
                              ? Colors.green
                              : Colors.orange,
                        ),
                        SizedBox(width: 5.w),
                        CustomText(
                          text: purchased.paymentStatus == 'completed'
                              ? 'Purchase completed'
                              : 'Payment pending',
                          size: 11,
                          color: purchased.paymentStatus == 'completed'
                              ? Colors.green
                              : Colors.orange,
                          weight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ],

                  SizedBox(height: 14.h),

                  // ── Download button ───────────────────────────────
                  CustomButton(
                    title: contents.isEmpty
                        ? 'No files available'
                        : 'Download All  •  ${contents.length} file${contents.length != 1 ? 's' : ''}',
                    icon: Icons.download_rounded,
                    onTap: contents.isNotEmpty
                        ? () => _downloadAll(context, contents)
                        : () {},
                    backgroundColor: contents.isNotEmpty
                        ? drawerColor
                        : Colors.grey.shade300,
                    textColor: Colors.white,
                    height: 44.h,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadAll(
      BuildContext context, List<CourseContent> contents) async {
    // keep your existing download logic here
  }

  Color _typeColor(String? type) {
    switch (type?.toUpperCase()) {
      case 'PDF':
        return const Color(0xFFE53935);
      case 'AUDIO':
        return const Color(0xFF8E24AA);
      case 'VIDEO':
        return const Color(0xFF1976D2);
      default:
        return Colors.grey.shade400;
    }
  }

  IconData _typeIcon(String? type) {
    switch (type?.toUpperCase()) {
      case 'PDF':
        return Icons.picture_as_pdf_rounded;
      case 'AUDIO':
        return Icons.music_note_rounded;
      case 'VIDEO':
        return Icons.videocam_rounded;
      default:
        return Icons.folder_rounded;
    }
  }

  Widget _badge(String label, Color color) => Container(
        padding:
            EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: CustomText(
          text: label,
          size: 10,
          weight: FontWeight.w700,
          color: color,
        ),
      );
}