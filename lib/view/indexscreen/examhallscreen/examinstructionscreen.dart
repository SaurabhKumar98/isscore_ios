import 'package:firstedu/data/models/api_models/examhall/examinstractionmodel.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_button.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/questionscreen.dart';
import 'package:firstedu/view_models/examhallprovider/examsessionprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';


class ExamInstructionsScreen extends StatefulWidget {
  final String testId;
  final String examTitle;
  final bool isBundleTest;
  final String? categoryId; // 🔥 ADD THIS
  final String? pillarType;
  const ExamInstructionsScreen({
    super.key,
    required this.testId,
    required this.examTitle,
    this.categoryId, // ✅ ADD
    this.pillarType,
    this.isBundleTest = false,
  });

  @override
  State<ExamInstructionsScreen> createState() => _ExamInstructionsScreenState();
}

class _ExamInstructionsScreenState extends State<ExamInstructionsScreen> {
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExamSessionProvider>().loadInstructions(
        widget.testId,
        categoryId: _shouldSendCategoryId() ? widget.categoryId : null,
      );
    });
  }

  bool _shouldSendCategoryId() {
    final type = widget.pillarType?.toLowerCase();

    return type == 'school' ||
       type == 'competitive' ||
       type == 'skill development';
  }
  // ── Start exam ────────────────────────────────────────────────────────────

  Future<void> _onStartExam() async {
    if (_isStarting) return;

    final provider = context.read<ExamSessionProvider>();
    final eligibility = provider.instructionsData?.data?.eligibility;

    final isFree = provider.instructionsData?.data?.test?.isFree ?? false;

    if (eligibility != null && !eligibility.canStart && !isFree) {
      AppToast.error(
        context,
        title: 'Cannot Start',
        message: eligibility.blockReason ?? 'You are not eligible to start.',
      );
      return;
    }

    setState(() => _isStarting = true);

    provider.reset();

    if (!mounted) return;

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ExamScreen(
          testId: widget.testId,
          examTitle: widget.examTitle,
          isBundleTest: widget.isBundleTest,
          existingSessionId: null, 
          showPauseButton: true,
          // fromExamHall: true,
            categoryId: _shouldSendCategoryId() ? widget.categoryId : null,

        ),
      ),
    );

    if (mounted) setState(() => _isStarting = false);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Consumer<ExamSessionProvider>(
          builder: (context, provider, _) {
            return Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: provider.instructionsLoading
                      ? _buildLoading()
                      : provider.instructionsError.isNotEmpty ||
                            provider.instructionsData == null
                      ? _buildError(provider)
                      : _buildContent(provider.instructionsData!.data!)
                ),
                if (!provider.instructionsLoading &&
                    provider.instructionsError.isEmpty &&
                    provider.instructionsData != null)
                  _buildBottomBar(provider.instructionsData!.data!),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [drawerColor, drawerColor.withOpacity(0.9)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: widget.examTitle,
                  size: 16,
                  weight: FontWeight.w700,
                  color: Colors.white,
                  maxLines: 1,
                ),
                SizedBox(height: 2.h),
                CustomText(
                  text: 'Exam Instructions',
                  size: 12,
                  color: Colors.white70,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book_rounded, size: 14.sp, color: Colors.white),
                SizedBox(width: 4.w),
                CustomText(
                  text: 'Read carefully',
                  size: 11,
                  weight: FontWeight.w600,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildLoading() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: drawerColor),
        SizedBox(height: 16.h),
        CustomText(
          text: 'Loading instructions…',
          size: 14,
          color: Colors.grey.shade500,
        ),
      ],
    ),
  );


  Widget _buildError(ExamSessionProvider provider) => Center(
    child: Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60.sp, color: Colors.red.shade300),
          SizedBox(height: 16.h),
          CustomText(
            text: provider.instructionsError,
            size: 14,
            color: Colors.grey.shade600,
            align: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          CustomButton(
            title: 'Retry',
            onTap: () => provider.loadInstructions(
              widget.testId,
              categoryId: _shouldSendCategoryId() ? widget.categoryId : null,
            ),
            backgroundColor: drawerColor,
            textColor: Colors.white,
            icon: Icons.refresh_rounded,
          ),
        ],
      ),
    ),
  );

  // ── Main content ──────────────────────────────────────────────────────────

  Widget _buildContent(Data data) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroCard(data),
          SizedBox(height: 20.h),
          _buildStatsGrid(data),
          SizedBox(height: 20.h),
          if ((data.instructions?.proctoringText?.isNotEmpty ?? false) ||
    (data.test?.proctoringInstructions?.isNotEmpty ?? false)) ...[
            SizedBox(height: 20.h),
            _buildProctoringCard(
              (data.instructions?.proctoringText?.isNotEmpty ?? false)
                  ?data.instructions?.proctoringText ?? ''
                  : data.test?.proctoringInstructions ?? '',
            ),
          ],

          SizedBox(height: 20.h),

          _buildInstructionPoints(data.instructions?.points ?? []),
        ],
      ),
    );
  }

  Widget _buildHeroCard(Data data) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [drawerColor, drawerColor.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: drawerColor.withOpacity(0.3),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.quiz_rounded,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: data.test?.title ?? '',
                      size: 17,
                      weight: FontWeight.w700,
                      color: Colors.white,
                      maxLines: 2,
                    ),
                   if (data.test?.questionBankName?.isNotEmpty ?? false) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.library_books_outlined,
                            size: 12.sp,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: CustomText(
                              text: data.test?.questionBankName??'',
                              size: 12,
                              color: Colors.white.withOpacity(0.7),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (data.test?.description?.isNotEmpty ?? false) ...[
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: CustomText(
                text: data.test?.description ??'',
                size: 13,
                color: Colors.white.withOpacity(0.85),
                maxLines: 4,
                height: 1.5,
              ),
            ),
          ],
          if ((data.test?.durationMinutes ?? 0) > 0) ...[
            SizedBox(height: 14.h),
            Row(
              children: [
                _pill(
                  Icons.timer_rounded,
                  '${data.test?.durationMinutes ?? 0} minutes',
                ),
                SizedBox(width: 10.w),
                _pill(
                 data.test?.isFree ?? false
                      ? Icons.lock_open_rounded
                      : Icons.lock_rounded,
                  (data.test?.isFree ?? false) ? 'Free' : 'Paid',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String label) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13.sp, color: Colors.white),
        SizedBox(width: 4.w),
        CustomText(
          text: label,
          size: 12,
          weight: FontWeight.w600,
          color: Colors.white,
        ),
      ],
    ),
  );

  // ── Stats grid ────────────────────────────────────────────────────────────

  Widget _buildStatsGrid(Data stats) {
    final items = [
      _StatItem(
        icon: Icons.help_outline_rounded,
        label: 'Questions',
        value: '${stats.stats?.totalQuestions ?? 0}',
        color: Colors.blue.shade600,
      ),
      _StatItem(
        icon: Icons.star_rounded,
        label: 'Total Marks',
        value: '${stats.stats?.totalMarks??0}',
        color: Colors.green.shade600,
      ),
      _StatItem(
        icon: Icons.remove_circle_outline_rounded,
        label: 'Negative Marks',
        value: '-${stats.stats?.totalNegativeMarks??0}',
        color: (stats.stats?.totalNegativeMarks ?? 0) > 0
            ? Colors.red.shade500
            : Colors.grey.shade400,
      ),
      _StatItem(
        icon: Icons.timer_outlined,
        label: 'Avg / Question',
        value: _formatSeconds(stats.stats?.averageTimePerQuestionSeconds??0),
        color: Colors.orange.shade600,
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 2.2,
      children: items.map(_buildStatCard).toList(),
    );
  }

  Widget _buildStatCard(_StatItem item) => Container(
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10.r,
          offset: Offset(0, 4.h),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: item.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(item.icon, size: 18.sp, color: item.color),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: item.value,
                size: 16,
                weight: FontWeight.w800,
                color: item.color,
              ),
              CustomText(
                text: item.label,
                size: 10,
                color: Colors.grey.shade500,
                weight: FontWeight.w500,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ── Instruction points ────────────────────────────────────────────────────

  Widget _buildInstructionPoints(List<String> points) {
    if (points.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: drawerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: drawerColor,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),
              CustomText(
                text: 'Exam Details',
                size: 15,
                weight: FontWeight.w700,
                color: Colors.black87,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...points.asMap().entries.map((e) {
            final isLast = e.key == points.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: drawerColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: CustomText(
                      text: '${e.key + 1}',
                      size: 11,
                      weight: FontWeight.w700,
                      color: drawerColor,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: CustomText(
                      text: e.value,
                      size: 13,
                      color: Colors.black87,
                      height: 1.5,
                      maxLines: 5,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Proctoring card ───────────────────────────────────────────────────────

  Widget _buildProctoringCard(String text) => Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: Colors.red.withOpacity(0.04),
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: Colors.red.withOpacity(0.2), width: 1.5),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.remove_red_eye_rounded,
            color: Colors.red,
            size: 18.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: 'Proctoring Notice',
                size: 14,
                weight: FontWeight.w700,
                color: Colors.red.shade700,
              ),
              SizedBox(height: 6.h),
              CustomText(
                text: text,
                size: 13,
                color: Colors.grey.shade700,
                height: 1.5,
                maxLines: 8,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ── Bottom action bar ─────────────────────────────────────────────────────

  Widget _buildBottomBar(Data data) {
    final isFree = data.test?.isFree ?? false;
    final canStart = (data.eligibility?.canStart ?? false) || isFree;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!canStart && (data.eligibility?.blockReason?.isNotEmpty ?? false))
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.block_rounded, size: 16.sp, color: Colors.red),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: CustomText(
                        text: data.eligibility?.blockReason??'',
                        size: 12,
                        color: Colors.red.shade700,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 14.sp,
                  color: Colors.green.shade600,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: CustomText(
                    text: 'By starting, you agree to follow all exam rules.',
                    size: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          _isStarting
              ? Container(
                  height: 52.h,
                  decoration: BoxDecoration(
                    color: canStart ? successColor : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : CustomButton(
                  title: canStart ? 'Start Exam' : 'Not Eligible',
                  onTap: canStart
                      ? () async {
                          await _onStartExam();
                        }
                      : null,
                  backgroundColor: canStart
                      ? successColor
                      : Colors.grey.shade300,
                  textColor: Colors.white,
                  icon: canStart
                      ? Icons.play_circle_outline_rounded
                      : Icons.block_rounded,
                  height: 52.h,
                ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatSeconds(int seconds) {
    if (seconds <= 0) return '—';
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s > 0 ? '${m}m ${s}s' : '${m}m';
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}
