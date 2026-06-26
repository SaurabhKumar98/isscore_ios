import 'dart:async';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/data/models/api_models/olympiadcentermodel/olympiaddetailsmodels.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/instantresultscreen.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/questionscreen.dart';
import 'package:firstedu/view/olympaid_view/olympiadpaymentsheet.dart';
import 'package:firstedu/view_models/examhallprovider/examsessionprovider.dart';
import 'package:firstedu/view_models/olympiadprovider/olympiadcenterprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class OlympiadDetailScreen extends StatefulWidget {
  final String olympiadId;
  const OlympiadDetailScreen({super.key, required this.olympiadId});

  @override
  State<OlympiadDetailScreen> createState() => _OlympiadDetailScreenState();
}

class _OlympiadDetailScreenState extends State<OlympiadDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // _countdownTimer and _remaining were unused — removed
  DateTime? _liveTarget;

  Duration _startRemaining = Duration.zero;
  Duration _resultRemaining = Duration.zero;

  Timer? _startTimer;
  Timer? _resultTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() async {
      await context.read<OlympiadProvider>().fetchDetail(
        context,
        widget.olympiadId,
      );
      final data = context.read<OlympiadProvider>().detail;
      _startExamCountdown(data?.startTime);
      _startResultCountdown(data?.resultDeclarationDate);
    });
  }

  void _startExamCountdown(DateTime? startTime) {
    if (startTime == null) return;
    final target = startTime.toLocal();

    // ── critical: assign _liveTarget so _effectiveStatus can use it ──
    _liveTarget = target;
    _startTimer?.cancel();

    // If already past, don't bother ticking
    final initialDiff = target.difference(DateTime.now());
    if (initialDiff.isNegative) return;

    setState(() => _startRemaining = initialDiff);

    _startTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final diff = target.difference(DateTime.now());
      setState(() => _startRemaining = diff.isNegative ? Duration.zero : diff);
      if (diff.isNegative) _startTimer?.cancel();
    });
  }

  void _startResultCountdown(DateTime? resultTime) {
    if (resultTime == null) return;
    final target = resultTime.toLocal();
    _resultTimer?.cancel();

    final initialDiff = target.difference(DateTime.now());
    if (initialDiff.isNegative) {
      setState(() => _resultRemaining = Duration.zero);
      return;
    }

    setState(() => _resultRemaining = initialDiff);

    _resultTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final diff = target.difference(DateTime.now());
      setState(() => _resultRemaining = diff.isNegative ? Duration.zero : diff);
      if (diff.isNegative) _resultTimer?.cancel();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _startTimer?.cancel(); // ── was missing ──
    _resultTimer?.cancel(); // ── was missing ──
    super.dispose();
  }

  String _effectiveStatus(OlympiadDetailsData data) {
    final api = data.status?.toUpperCase() ?? '';
    final now = DateTime.now();

    if (api == 'LIVE') return 'LIVE';

    // Locally flip to LIVE if startTime has passed and backend hasn't caught up
    if (_liveTarget != null &&
        now.isAfter(_liveTarget!) &&
        (api == 'OPEN' || api == 'CLOSE' || api == 'UPCOMING')) {
      return 'LIVE';
    }

    return api;
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  String get _countdownText {
    final h = _pad(_startRemaining.inHours);
    final m = _pad(_startRemaining.inMinutes % 60);
    final s = _pad(_startRemaining.inSeconds % 60);
    return '$h:$m:$s';
  }

  // ── uses _resultRemaining (timer-driven, ticks every second) ──
  String get _resultCountdownText {
    final h = _pad(_resultRemaining.inHours);
    final m = _pad(_resultRemaining.inMinutes % 60);
    final s = _pad(_resultRemaining.inSeconds % 60);
    return '$h:$m:$s';
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '—';
    final local = dt.toLocal();
    const months = [
      '',
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
    final h = local.hour > 12
        ? local.hour - 12
        : local.hour == 0
        ? 12
        : local.hour;
    final amPm = local.hour >= 12 ? 'PM' : 'AM';
    return '${local.day} ${months[local.month]} ${local.year}, '
        '${_pad(h)}:${_pad(local.minute)} $amPm';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OlympiadProvider>();

    if (provider.isDetailLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F7FB),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.detail == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1A2E),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: CustomText(
            text: 'Olympiad Details',
            size: 18,
            weight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: Colors.black26,
              ),
              SizedBox(height: 16.h),
              CustomText(
                text: provider.errorMessage ?? 'Something went wrong',
                size: 15,
                weight: FontWeight.w500,
                color: Colors.black45,
              ),
              SizedBox(height: 20.h),
              TextButton.icon(
                onPressed: () => context.read<OlympiadProvider>().fetchDetail(
                  context,
                  widget.olympiadId,
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final data = provider.detail!;
    final status = _effectiveStatus(data);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          _buildHeader(data, status),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(data),
                _buildDetailsTab(data),
                _buildRulesTab(data),
              ],
            ),
          ),
          _buildBottomBar(context, provider, data, status),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HEADER
  // ─────────────────────────────────────────────

  Widget _buildHeader(OlympiadDetailsData data, String status) {
    final showCountdown =
        _startRemaining > Duration.zero &&
        status != 'LIVE' &&
        status != 'COMPLETED' &&
        status != 'CLOSED';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomText(
                      text: 'Olympiad Details',
                      size: 18,
                      weight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  showCountdown
                      ? _HeaderCountdownBadge(text: 'Live in $_countdownText')
                      : _StatusBadge(status: status),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      size: 32,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((data.categoryId?.name ?? '').isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: CustomText(
                              text: data.categoryId?.name ?? '',
                              size: 11,
                              weight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        CustomText(
                          text: data.title ?? 'Olympiad',
                          size: 17,
                          weight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline_rounded,
                              size: 13,
                              color: Colors.black38,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: CustomText(
                                text: data.categoryName ?? 'Olympiad',
                                size: 12,
                                weight: FontWeight.w500,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── COUNTDOWN BANNER ──────────────────────────────────────────
            if (showCountdown)
              Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [drawerColor.withOpacity(0.88), drawerColor],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Starts in',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.white60,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _countdownText,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.5,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TimeBox(
                          value: _pad(_startRemaining.inHours),
                          label: 'HH',
                        ),
                        const _TimeSep(),
                        _TimeBox(
                          value: _pad(_startRemaining.inMinutes % 60),
                          label: 'MM',
                        ),
                        const _TimeSep(),
                        _TimeBox(
                          value: _pad(_startRemaining.inSeconds % 60),
                          label: 'SS',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // ── LIVE BANNER ───────────────────────────────────────────────
            if (status == 'LIVE')
              Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF1565C0).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const _PulsingDot(color: Color(0xFF1565C0)),
                    const SizedBox(width: 10),
                    Text(
                      'This olympiad is now LIVE',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1565C0),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  TAB BAR
  // ─────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: drawerColor,
        unselectedLabelColor: Colors.black45,
        indicatorColor: drawerColor,
        indicatorWeight: 3,
        labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Details'),
          Tab(text: 'Rules'),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Navigate to InstantResultsScreen
  // ─────────────────────────────────────────────

  Future<void> _navigateToResult(
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
          scoreProgression.add(total > 0 ? (correct / total) * 100 : 0.0);
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

  // ─────────────────────────────────────────────
  //  OVERVIEW TAB
  // ─────────────────────────────────────────────

  Widget _buildOverviewTab(OlympiadDetailsData data) {
    final int price = data.price ?? 0;
    final int? discountAmount = data.discountAmount;
    final int? discountedPrice = data.discountedPrice;
    final bool hasDiscount =
        discountAmount != null && discountAmount > 0 && price > 0;
    final int? discountPercent = hasDiscount
        ? ((discountAmount! / price) * 100).round()
        : null;
    final int displayPrice = (hasDiscount && discountedPrice != null)
        ? discountedPrice
        : price;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.calendar_today_rounded,
                  iconColor: Colors.blue,
                  label: 'Exam Date',
                  value: data.startTime != null
                      ? '${data.startTime!.day}/${data.startTime!.month}/${data.startTime!.year}'
                      : '—',
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _StatCard(
                  icon: Icons.group_rounded,
                  iconColor: Colors.orange.shade700,
                  label: 'Seats',
                  value: 'Open',
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _FeeCard(
            price: price,
            displayPrice: displayPrice,
            discountAmount: discountAmount,
            discountPercent: discountPercent,
            hasDiscount: hasDiscount,
          ),
          SizedBox(height: 16.h),
          if ((data.description ?? '').isNotEmpty) ...[
            _SectionCard(
              title: 'About This Olympiad',
              icon: Icons.info_outline_rounded,
              child: CustomText(
                text: data.description!,
                size: 14,
                weight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16.h),
          ],
          _SectionCard(
            title: 'Prize Points',
            icon: Icons.emoji_events_rounded,
            child: Column(
              children: [
                _PrizeRow(
                  rank: '1st Place',
                  points: data.firstPlacePoints,
                  color: const Color(0xFFFFD700),
                  icon: Icons.looks_one_rounded,
                ),
                const SizedBox(height: 10),
                _PrizeRow(
                  rank: '2nd Place',
                  points: data.secondPlacePoints,
                  color: const Color(0xFFB0BEC5),
                  icon: Icons.looks_two_rounded,
                ),
                const SizedBox(height: 10),
                _PrizeRow(
                  rank: '3rd Place',
                  points: data.thirdPlacePoints,
                  color: const Color(0xFFCD7F32),
                  icon: Icons.looks_3_rounded,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          _SectionCard(
            title: 'Registration Window',
            icon: Icons.app_registration_rounded,
            child: Column(
              children: [
                _DetailRow(
                  label: 'Opens',
                  value: _formatDateTime(data.registrationStartTime),
                  icon: Icons.login_rounded,
                ),
                const SizedBox(height: 10),
                _DetailRow(
                  label: 'Closes',
                  value: _formatDateTime(data.registrationEndTime),
                  icon: Icons.logout_rounded,
                ),
                if (data.isRegistrationOpen == true) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 15,
                          color: Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Registration is currently open',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  DETAILS TAB
  // ─────────────────────────────────────────────

  Widget _buildDetailsTab(OlympiadDetailsData data) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _SectionCard(
            title: 'Exam Schedule',
            icon: Icons.access_time_rounded,
            child: Column(
              children: [
                _DetailRow(
                  label: 'Start Time',
                  value: _formatDateTime(data.startTime),
                  icon: Icons.play_circle_outline_rounded,
                ),
                const SizedBox(height: 10),
                _DetailRow(
                  label: 'End Time',
                  value: _formatDateTime(data.endTime),
                  icon: Icons.stop_circle_outlined,
                ),
                if (data.testId?.durationMinutes != null) ...[
                  const SizedBox(height: 10),
                  _DetailRow(
                    label: 'Duration',
                    value: '${data.testId!.durationMinutes} minutes',
                    icon: Icons.timer_outlined,
                  ),
                ],
                if (data.startTime != null) ...[
                  const SizedBox(height: 10),
                  _DetailRow(
                    label: 'Goes Live At',
                    value: _formatDateTime(data.startTime),
                    icon: Icons.live_tv_rounded,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 16.h),
          if (data.testId != null)
            _SectionCard(
              title: 'Test Information',
              icon: Icons.quiz_outlined,
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Test Name',
                    value: data.testId?.title ?? '—',
                    icon: Icons.description_outlined,
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(
                    label: 'Duration',
                    value: '${data.testId?.durationMinutes ?? 0} minutes',
                    icon: Icons.hourglass_empty_rounded,
                  ),
                ],
              ),
            ),
          SizedBox(height: 16.h),
          _SectionCard(
            title: 'Additional Info',
            icon: Icons.info_outline_rounded,
            child: Column(
              children: [
                _DetailRow(
                  label: 'Max Participants',
                  value: 'Unlimited',
                  icon: Icons.group_outlined,
                ),
                const SizedBox(height: 10),
                _DetailRow(
                  label: 'Subject',
                  value: data.categoryId?.name ?? 'General',
                  icon: Icons.book_outlined,
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  RULES TAB
  // ─────────────────────────────────────────────

  Widget _buildRulesTab(OlympiadDetailsData data) {
    final rules = data.description ?? '';
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: rules.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.only(top: 60.h),
                child: Column(
                  children: [
                    const Icon(
                      Icons.gavel_rounded,
                      size: 48,
                      color: Colors.black26,
                    ),
                    SizedBox(height: 12.h),
                    CustomText(
                      text: 'No rules specified',
                      size: 15,
                      weight: FontWeight.w500,
                      color: Colors.black38,
                    ),
                  ],
                ),
              ),
            )
          : _SectionCard(
              title: 'Competition Rules',
              icon: Icons.gavel_rounded,
              child: Text(
                rules,
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.7,
                  color: Colors.black87,
                ),
              ),
            ),
    );
  }

  // ─────────────────────────────────────────────
  //  BOTTOM BAR
  // ─────────────────────────────────────────────

  Widget _buildBottomBar(
    BuildContext context,
    OlympiadProvider provider,
    OlympiadDetailsData data,
    String status,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: _bottomButton(context, provider, data, status),
    );
  }

  Widget _bottomButton(
    BuildContext context,
    OlympiadProvider provider,
    OlympiadDetailsData data,
    String status,
  ) {
    final isRegistered = data.isRegistered ?? false;
    final isExamCompleted =
        (data.testStatus?.toLowerCase() ?? '') == 'completed';
    final sessionId = data.testSessionId;
    final now = DateTime.now();

    // ── Reusable View Result button ───────────────────────────────────────
    Widget viewResultBtn() => GestureDetector(
      onTap: () => _navigateToResult(context, sessionId),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              'View Result',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );

    // ── COMPLETED ─────────────────────────────────────────────────────────
    if (status == 'COMPLETED') {
      final resultTime = data.resultDeclarationDate?.toLocal();
      final bool isResultAvailable =
          resultTime != null && now.isAfter(resultTime);

      if (isExamCompleted && !isResultAvailable) {
        // ── uses _resultRemaining (timer-driven, ticks every second) ──
        return _BottomChip(
          color: const Color(0xFF1565C0),
          bgColor: const Color(0xFFE3F2FD),
          icon: Icons.schedule_rounded,
          label: 'Result in $_resultCountdownText',
        );
      }

      if (isExamCompleted && isResultAvailable) {
        return viewResultBtn();
      }

      return _BottomChip(
        color: Colors.grey.shade600,
        bgColor: Colors.grey.shade100,
        icon: Icons.verified_rounded,
        label: 'Olympiad Completed',
        bordered: false,
      );
    }

    // ── LIVE ──────────────────────────────────────────────────────────────
    if (status == 'LIVE') {
      final resultTime = data.resultDeclarationDate?.toLocal();
      final bool isResultAvailable =
          resultTime != null && now.isAfter(resultTime);

      // Exam done, result not yet declared
      // ── uses _resultRemaining (timer-driven, ticks every second) ──
      if (isExamCompleted && !isResultAvailable) {
        return _BottomChip(
          color: const Color(0xFF1565C0),
          bgColor: const Color(0xFFE3F2FD),
          icon: Icons.schedule_rounded,
          label: 'Result in $_resultCountdownText',
        );
      }

      // Exam done, result available
      if (isExamCompleted && isResultAvailable) {
        return viewResultBtn();
      }

      // Registered, exam not done → Enter Exam
      if (isRegistered) {
        return GestureDetector(
          onTap: () {
            final testId = data.testId?.id;
            if (testId == null || testId.isEmpty) {
              AppToast.error(
                context,
                title: 'Unavailable',
                message: 'No exam linked to this olympiad.',
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: context.read<ExamSessionProvider>(),
                  child:ExamScreen(
  testId: testId,
  examTitle: data.title ?? 'Olympiad Exam',
  isBundleTest: false,
  showInstantResult: false,
  resultDeclaredAt: data.resultDeclarationDate,
)
                ),
              ),
              // ── refresh detail when coming back from exam ──
            ).then((_) {
              if (mounted) {
                context.read<OlympiadProvider>().fetchDetail(
                  context,
                  widget.olympiadId,
                );
              }
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1565C0).withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_circle_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  'Enter Exam',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Not registered but exam is live
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_rounded,
              color: Colors.grey.shade500,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              'Live — Not Registered',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    // ── OPEN ──────────────────────────────────────────────────────────────
    if (status == 'OPEN') {
      if (isRegistered) {
        return const _BottomChip(
          color: Color(0xFF2E7D32),
          bgColor: Color(0xFFE8F5E9),
          icon: Icons.check_circle_rounded,
          label: "You're Registered!",
        );
      }
      return GestureDetector(
        onTap: provider.isPaymentLoading
            ? null
            : () => showOlympiadPaymentSheet(context, olympiad: data),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: provider.isPaymentLoading
                ? drawerColor.withOpacity(0.7)
                : drawerColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: drawerColor.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: provider.isPaymentLoading
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.how_to_reg_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      (data.price ?? 0) == 0
                          ? 'Register for Free'
                          : 'Register Now  •  ₹${data.price}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      );
    }

    // ── CLOSE / UPCOMING ──────────────────────────────────────────────────
    if (status == 'CLOSE' || status == 'UPCOMING') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _BottomChip(
            color: Color(0xFFE65100),
            bgColor: Color(0xFFFFF3E0),
            icon: Icons.schedule_rounded,
            label: 'Opens Soon',
          ),
          if (data.registrationStartTime != null) ...[
            SizedBox(height: 8.h),
            Text(
              'Registration opens on ${_formatDateTime(data.registrationStartTime)}',
              style: TextStyle(fontSize: 12.sp, color: Colors.black45),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      );
    }

    // ── CLOSED ────────────────────────────────────────────────────────────
    return _BottomChip(
      color: Colors.grey.shade500,
      bgColor: Colors.grey.shade100,
      icon: Icons.cancel_rounded,
      label: 'Registration Closed',
      bordered: false,
    );
  }
}

// ─────────────────────────────────────────────────────
//  FEE CARD
// ─────────────────────────────────────────────────────

class _FeeCard extends StatelessWidget {
  final int price;
  final int displayPrice;
  final int? discountAmount;
  final int? discountPercent;
  final bool hasDiscount;

  const _FeeCard({
    required this.price,
    required this.displayPrice,
    required this.discountAmount,
    required this.discountPercent,
    required this.hasDiscount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.currency_rupee_rounded,
              size: 20,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Entry Fee',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (hasDiscount)
                Row(
                  children: [
                    Text(
                      '₹$price',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (discountPercent != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF2E7D32).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '$discountPercent% OFF',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    displayPrice == 0 ? 'FREE' : '₹$displayPrice',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: drawerColor,
                    ),
                  ),
                  if (hasDiscount && discountAmount != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF2E7D32).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Save ₹$discountAmount',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
//  COUNTDOWN WIDGETS
// ─────────────────────────────────────────────────────

class _TimeBox extends StatelessWidget {
  final String value;
  final String label;
  const _TimeBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 8.sp,
            color: Colors.white54,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _TimeSep extends StatelessWidget {
  const _TimeSep();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10, left: 2, right: 2),
    child: Text(
      ':',
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w800,
        color: Colors.white70,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────
//  HEADER COUNTDOWN BADGE
// ─────────────────────────────────────────────────────

class _HeaderCountdownBadge extends StatelessWidget {
  final String text;
  const _HeaderCountdownBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1565C0).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1565C0),
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
//  SHARED PRIVATE WIDGETS
// ─────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case 'OPEN':
        return const Color(0xFF2E7D32);
      case 'LIVE':
        return const Color(0xFF1565C0);
      case 'CLOSE':
      case 'UPCOMING':
        return const Color(0xFFE65100);
      case 'COMPLETED':
        return Colors.grey.shade600;
      case 'CLOSED':
        return const Color(0xFFC62828);
      default:
        return Colors.grey;
    }
  }

  IconData get _icon {
    switch (status) {
      case 'OPEN':
        return Icons.check_circle_rounded;
      case 'LIVE':
        return Icons.circle;
      case 'CLOSE':
      case 'UPCOMING':
        return Icons.schedule_rounded;
      case 'COMPLETED':
        return Icons.verified_rounded;
      case 'CLOSED':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: _color),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomChip extends StatelessWidget {
  final Color color;
  final Color bgColor;
  final IconData icon;
  final String label;
  final bool bordered;

  const _BottomChip({
    required this.color,
    required this.bgColor,
    required this.icon,
    required this.label,
    this.bordered = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: bordered
            ? Border.all(color: color.withOpacity(0.3), width: 1.5)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
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
          Row(
            children: [
              Icon(icon, size: 17, color: drawerColor),
              const SizedBox(width: 8),
              CustomText(
                text: title,
                size: 14,
                weight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: Colors.black54),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black38,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A1A2E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black38,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1A1A2E),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrizeRow extends StatelessWidget {
  final String rank;
  final int? points;
  final Color color;
  final IconData icon;
  const _PrizeRow({
    required this.rank,
    required this.points,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            rank,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${points ?? 0} pts',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color.withOpacity(0.85),
            ),
          ),
        ),
      ],
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _anim,
    child: Icon(Icons.circle, size: 10, color: widget.color),
  );
}
