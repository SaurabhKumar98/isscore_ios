import 'package:firstedu/data/models/api_models/examhall/examhall_models.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_button.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_silverappbar.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/examinstructionscreen.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/questionscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class BundleDetailScreen extends StatefulWidget {
  final ExamHallItem bundleItem;

  const BundleDetailScreen({super.key, required this.bundleItem});

  @override
  State<BundleDetailScreen> createState() => _BundleDetailScreenState();
}

class _BundleDetailScreenState extends State<BundleDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final tests =
        widget.bundleItem.tests ?? widget.bundleItem.testBundle?.tests ?? [];
    final bundleName = widget.bundleItem.testBundle?.name ?? 'Test Bundle';
    final bundleDesc = widget.bundleItem.testBundle?.description;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            title: bundleName,
            subtitle: bundleDesc ?? "All tests in this bundle",
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 120.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(height: 20.h),
                _buildBundleInfoCard(tests.length),
                SizedBox(height: 20.h),
                CustomText(
                  text: "Tests in this Bundle",
                  size: 16,
                  weight: FontWeight.w700,
                  color: Colors.black87,
                ),
                SizedBox(height: 14.h),
                if (tests.isEmpty)
                  _buildEmptyState()
                else
                  ...tests.asMap().entries.map((entry) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: _buildTestCard(context, entry.value, entry.key),
                    );
                  }),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBundleInfoCard(int testCount) {
    return CustomCard(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [drawerColor, drawerColor.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: drawerColor.withValues(alpha: 0.25),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.collections_bookmark_outlined,
              color: Colors.white,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: widget.bundleItem.testBundle?.name ?? 'Test Bundle',
                  size: 16,
                  weight: FontWeight.w700,
                  color: Colors.white,
                  maxLines: 2,
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      Icons.layers_outlined,
                      size: 14.sp,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    SizedBox(width: 4.w),
                    CustomText(
                      text: "$testCount tests included",
                      size: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    SizedBox(width: 12.w),
                    Icon(
                      Icons.currency_rupee,
                      size: 13.sp,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    CustomText(
                      text: "${widget.bundleItem.purchasePrice ?? 0} paid",
                      size: 13,
                      color: Colors.white.withValues(alpha: 0.8),
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

  Widget _buildTestCard(BuildContext context, Test test, int index) {
    final String btnText = test.isCompleted
        ? 'View Results'
        : test.isInProgress
        ? 'Resume Exam'
        : 'Start Exam';

    final Color btnColor = test.isCompleted
        ? successColor
        : test.isInProgress
        ? accentOrange
        : drawerColor;

    final IconData btnIcon = test.isCompleted
        ? Icons.bar_chart_rounded
        : test.isInProgress
        ? Icons.play_arrow_rounded
        : Icons.play_circle_outline_rounded;

    return CustomCard(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: drawerColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: CustomText(
                  text: "Test ${index + 1}",
                  size: 12,
                  weight: FontWeight.w600,
                  color: drawerColor,
                ),
              ),
              _statusBadge(test),
            ],
          ),
          SizedBox(height: 16.h),
          CustomText(
            text: test.title ?? 'Untitled Test',
            size: 18,
            weight: FontWeight.w600,
            maxLines: 3,
          ),
          if (test.description != null && test.description!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            CustomText(
              text: test.description!,
              size: 13,
              color: Colors.grey.shade500,
              maxLines: 2,
            ),
          ],
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: "Duration",
                size: 13,
                color: Colors.grey.shade600,
              ),
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 14.sp,
                    color: Colors.grey.shade500,
                  ),
                  SizedBox(width: 4.w),
                  CustomText(
                    text: test.durationMinutes != null
                        ? "${test.durationMinutes} min"
                        : "—",
                    size: 13,
                    weight: FontWeight.w600,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 6.h),
          LinearProgressIndicator(
            value: test.isCompleted
                ? 1.0
                : test.isInProgress
                ? 0.5
                : 0.0,
            backgroundColor: Colors.grey.shade200,
            color: test.isCompleted ? successColor : accentOrange,
            minHeight: 6.h,
            borderRadius: BorderRadius.circular(6.r),
          ),
          SizedBox(height: 20.h),
          CustomButton(
            title: btnText,
            icon: btnIcon,
            backgroundColor: btnColor,
            textColor: Colors.white,
            onTap: () {
              context.read<ExamSessionProvider>().reset();

              // Completed → straight to results.
              if (test.isCompleted && test.sessionId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ExamResultsScreen(sessionId: test.sessionId!),
                  ),
                );
                return;
              }

              // In-progress → skip instructions, resume directly.
              if (test.isInProgress) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExamScreen(
                      testId: test.id ?? '',
                      examTitle: test.title ?? 'Exam',
                      isBundleTest: true,
                      existingSessionId: null,
                    ),
                  ),
                );
                return;
              }

              // Not started → show instructions first.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExamInstructionsScreen(
                    testId: test.id ?? '',
                    examTitle: test.title ?? 'Exam',
                    isBundleTest: true,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(Test test) {
    final String label = test.isCompleted
        ? 'Completed'
        : test.isInProgress
        ? 'In Progress'
        : 'Not Started';
    final Color color = test.isCompleted
        ? successColor
        : test.isInProgress
        ? accentOrange
        : Colors.grey;
    final IconData icon = test.isCompleted
        ? Icons.check_circle_rounded
        : test.isInProgress
        ? Icons.pending_rounded
        : Icons.radio_button_unchecked_rounded;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          CustomText(
            text: label,
            size: 11,
            weight: FontWeight.w600,
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 60.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16.h),
            CustomText(
              text: "No tests in this bundle",
              size: 16,
              weight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }
}
