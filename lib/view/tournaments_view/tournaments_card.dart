import 'package:firstedu/data/models/api_models/tournament/tournament_models.dart';
import 'package:firstedu/data/repo/examhall/examsessionrepositories.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/questionscreen.dart';
import 'package:firstedu/view/tournaments_view/tournamentdetails_screen.dart';
import 'package:firstedu/view/tournaments_view/tournamentpaymentsheet.dart';
import 'package:firstedu/view_models/examhallprovider/examhallwebsocket.dart';
import 'package:firstedu/view_models/examhallprovider/examsessionprovider.dart';
import 'package:firstedu/view_models/tournamentprovider/tournament_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TournamentCard extends StatelessWidget {
  final Tournament tournament;
  const TournamentCard({super.key, required this.tournament});

  Color get _statusColor {
    if (tournament.isEventLive) return const Color(0xFFF97316);
    if (tournament.isRegistrationOpen) return const Color(0xFF16A34A);
    switch (tournament.status.toLowerCase()) {
      case 'upcoming':
        return const Color(0xFF2563EB);
      case 'completed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String get _statusLabel {
    if (tournament.isEventLive) return 'LIVE NOW';
    if (tournament.isRegistrationOpen) return 'REGISTRATION OPEN';
    switch (tournament.status.toLowerCase()) {
      case 'upcoming':
        return 'UPCOMING';
      case 'completed':
        return 'COMPLETED';
      default:
        return tournament.status.toUpperCase();
    }
  }

  /// Only show a button if there's something meaningful to do
  bool get _hasAction =>
      tournament.isRegistrationOpen ||
      tournament.canJoin ||
      tournament.isRegistered;

  String get _buttonLabel {
    if (!tournament.isRegistered) {
      if (!tournament.isRegistrationOpen) return 'Registration Closed';
      return 'Register';
    }

    if (tournament.canJoin) {
      final activeIndex = tournament.stages.indexWhere((s) {
        final status = s.test?.testStatus ?? '';
        return status == 'not_started' ||
            status == 'in_progress' ||
            status == 'resume';
      });
      if (activeIndex == -1) return 'View Details';

      final activeStage = tournament.stages[activeIndex];
      final status = activeStage.test?.testStatus ?? 'not_started';
      final stageNum = activeIndex + 1;

      if (status == 'resume' || status == 'in_progress') {
        return 'Resume Stage $stageNum · ${activeStage.name}';
      }
      return 'Join Stage $stageNum · ${activeStage.name}';
    }

    return 'View Details';
  }

  bool get _buttonEnabled =>
      tournament.isRegistrationOpen || tournament.canJoin;

  Color get _buttonColor {
    if (tournament.canJoin) return const Color(0xFF16A34A);
    if (!tournament.isRegistrationOpen) return Colors.grey.shade400;
    return Colors.orange;
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'pm' : 'am';
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $h:$m $ampm';
  }

  void _handleTap(BuildContext context) async {
    if (!tournament.isRegistered) {
      if (tournament.isRegistrationOpen) {
        final provider = context.read<TournamentProvider>();
        final details =
            await provider.fetchTournamentById(context, tournament.id);
        if (details != null && context.mounted) {
          showTournamentPaymentSheet(context, tournament: details);
        }
      }
      return;
    }

    if (tournament.canJoin) {
      final activeIndex = tournament.stages.indexWhere((s) {
        final status = s.test?.testStatus ?? '';
        return status == 'not_started' ||
            status == 'in_progress' ||
            status == 'resume';
      });

      if (activeIndex == -1) {
        _goToDetails(context);
        return;
      }

      final activeStage = tournament.stages[activeIndex];
      final testId = activeStage.test?.id;
      final sessionId = activeStage.test?.sessionId;
      final testStatus = activeStage.test?.testStatus ?? 'not_started';
      final testTitle = activeStage.test?.title ?? activeStage.name;

      if (testId == null || testId.isEmpty) return;

      final effectiveSessionId =
          (sessionId == null || sessionId.isEmpty) ? null : sessionId;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (ctx) => ExamSessionProvider(
              ctx.read<ExamSessionRepository>(),
              ExamSocketService(),
            ),
            child: (testStatus == 'in_progress' || testStatus == 'resume')
                ? ExamScreen(
                    testId: testId,
                    examTitle: testTitle,
                    existingSessionId: effectiveSessionId,
                  )
                : ExamScreen(testId: testId, examTitle: testTitle),
          ),
        ),
      );
      return;
    }

    _goToDetails(context);
  }

  void _goToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TournamentDetailScreen(
          tournamentId: tournament.id,
          tournamentTitle: tournament.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stages = tournament.stages;
    final effectivePrice = tournament.effectivePrice;
    final isFree = effectivePrice == 0;
    final hasDiscount = tournament.discountAmount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () => _goToDetails(context),
        child: Container(
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top accent bar
              Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16.r)),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge + title + price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: _statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6.r),
                                  border: Border.all(
                                      color: _statusColor.withOpacity(0.3)),
                                ),
                                child: Text(
                                  _statusLabel,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                    color: _statusColor,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                tournament.title,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                tournament.description,
                                style: TextStyle(
                                    fontSize: 12.sp, color: Colors.black45),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Price tag
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasDiscount && tournament.originalPrice > 0)
                              Text(
                                '₹${tournament.originalPrice}',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.black38,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Colors.black38,
                                ),
                              ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: isFree
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                isFree ? 'FREE' : '₹$effectivePrice',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                  color: isFree
                                      ? const Color(0xFF2E7D32)
                                      : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),
                    Divider(color: Colors.grey.shade100, height: 1),
                    SizedBox(height: 14.h),

                    _infoRow(
                      icon: Icons.app_registration_rounded,
                      label: 'Reg Ends',
                      value: _formatDate(tournament.registrationEndTime),
                    ),
                    if (tournament.goesLiveAt != null) ...[
                      SizedBox(height: 8.h),
                      _infoRow(
                        icon: Icons.play_circle_outline_rounded,
                        label: 'Goes Live',
                        value: _formatDate(
                          DateTime.tryParse(
                                  tournament.goesLiveAt.toString()) ??
                              tournament.registrationEndTime,
                        ),
                      ),
                    ],
                    SizedBox(height: 8.h),
                    _infoRow(
                      icon: Icons.layers_rounded,
                      label: 'Stages',
                      value: '${stages.length}',
                    ),

                    SizedBox(height: 16.h),

                    // Stage pills
                    if (stages.isNotEmpty) ...[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: stages.map((s) {
                            return Container(
                              margin: EdgeInsets.only(right: 6.w),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F7FB),
                                borderRadius: BorderRadius.circular(6.r),
                                border:
                                    Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(
                                s.name,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],

                    // Registered badge
                    if (tournament.isRegistered) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: const Color(0xFF16A34A), size: 14.sp),
                            SizedBox(width: 6.w),
                            Text(
                              'You are registered for this tournament',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],

                    // ✅ Action button — only show if there's something to do
                    if (_hasAction)
                      SizedBox(
                        width: double.infinity,
                        height: 46.h,
                        child: ElevatedButton.icon(
                          onPressed: _buttonEnabled
                              ? () => _handleTap(context)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _buttonEnabled
                                ? _buttonColor
                                : Colors.grey.shade200,
                            foregroundColor:
                                _buttonEnabled ? Colors.white : Colors.grey,
                            disabledBackgroundColor: Colors.grey.shade200,
                            disabledForegroundColor: Colors.grey,
                            elevation: _buttonEnabled ? 2 : 0,
                            shadowColor: _buttonColor.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          icon: Icon(
                            tournament.canJoin
                                ? Icons.play_arrow_rounded
                                : tournament.isRegistrationOpen
                                    ? Icons.flash_on_rounded
                                    : Icons.info_outline_rounded,
                            size: 18.sp,
                          ),
                          label: Text(
                            _buttonLabel,
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: Colors.black38),
        SizedBox(width: 8.w),
        Text('$label:',
            style: TextStyle(fontSize: 12.sp, color: Colors.black45)),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}