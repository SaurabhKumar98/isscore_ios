import 'package:dio/dio.dart';
import 'package:firstedu/data/models/api_models/coursedownload/coursedetailsbyidmodels.dart';
import 'package:firstedu/data/models/api_models/coursedownload/coursedownloadallmodels.dart';
import 'package:firstedu/view/courses/coursepaymentsheet.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/examinstructionscreen.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/instantresultscreen.dart';
import 'package:firstedu/view_models/coursedownloadprovider/coursedownloadprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseDetailsScreen extends StatefulWidget {
  const CourseDetailsScreen({super.key});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  static const _navy = Color(0xFF1A2540);
  static const _accent = Color(0xFF4F8EF7);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final id = ModalRoute.of(context)?.settings.arguments as String?;
      if (id != null) {
        context.read<CourseDownloadProvider>().fetchCourseDetails(context, id);
      }
    });
  }

  // ─── Status helpers ───────────────────────────────────────────────────────

  Color _statusColor(String status) {
    switch (status) {
      case 'passed':
        return const Color(0xFF22C55E);
      case 'failed':
        return const Color(0xFFEF4444);
      case 'in_progress':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'passed':
        return const Color(0xFFDCFCE7);
      case 'failed':
        return const Color(0xFFFEE2E2);
      case 'in_progress':
        return const Color(0xFFFEF3C7);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'passed':
        return Icons.check_circle_rounded;
      case 'failed':
        return Icons.cancel_rounded;
      case 'in_progress':
        return Icons.hourglass_top_rounded;
      default:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'passed':
        return 'Passed';
      case 'failed':
        return 'Failed';
      case 'in_progress':
        return 'In Progress';
      default:
        return 'Not Started';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseDownloadProvider>();

    if (provider.isLoadingDetails) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final c = provider.courseDetails;
    if (c == null) {
      return const Scaffold(body: Center(child: Text("No Data")));
    }

    final bool isPurchased = c.isPurchased;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        slivers: [
          // ── HEADER ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F1C3F), Color(0xFF1E3A6E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (c.isCertification)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: _accent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.workspace_premium,
                                  color: Colors.white, size: 13),
                              SizedBox(width: 4),
                              Text(
                                "CERTIFICATION",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    c.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  if (c.categoryPath.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      c.categoryPath.join(" › "),
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12.5),
                    ),
                  ],
                  if (c.description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      c.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.55,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  // stat pills
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _statPill(
                        Icons.layers_rounded,
                        "${c.modules.length} Modules",
                      ),
                      _statPill(
                        Icons.quiz_rounded,
                        "${c.certificationTestCount} Tests",
                      ),
                      _statPill(
                        Icons.insert_drive_file_rounded,
                        "${c.contents.length + c.modules.fold<int>(0, (s, m) => s + m.contents.length)} Materials",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── PRICE + BUY ────────────────────────────────────────────
                _card(
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (c.originalPrice != c.effectivePrice)
                            Text(
                              "₹${c.originalPrice}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "₹${c.effectivePrice}",
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: _navy,
                                ),
                              ),
                              if (c.originalPrice != c.effectivePrice) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "${(((c.originalPrice - c.effectivePrice) / c.originalPrice) * 100).round()}% off",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (isPurchased)
                        _actionButton(
                          label: "ENROLLED",
                          icon: Icons.check_circle_outline_rounded,
                          color: const Color(0xFF22C55E),
                          onPressed: () {},
                        )
                      else
                        _actionButton(
                          label: "Buy Now",
                          icon: Icons.shopping_bag_outlined,
                          color: const Color(0xFFFF5A00),
                          onPressed: () => showCoursePaymentSheet(
                            context,
                            course: CourseData(
                              id: c.id,
                              title: c.title,
                              price: c.price,
                              effectivePrice: c.effectivePrice,
                              originalPrice: c.originalPrice,
                              contentType: "course",
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── SYLLABUS ───────────────────────────────────────────────
                if (c.syllabus.isNotEmpty) ...[
                  _sectionHeader("Syllabus", Icons.list_alt_rounded,
                      count: c.syllabus.length),
                  _card(
                    child: Column(
                      children: c.syllabus.asMap().entries.map((e) {
                        final isLast = e.key == c.syllabus.length - 1;
                        return Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: _accent.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${e.key + 1}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _accent,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      e.value.toString(),
                                      style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast)
                              const Divider(height: 1, thickness: 0.5),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── MODULES ────────────────────────────────────────────────
                if (c.modules.isNotEmpty) ...[
                  _sectionHeader("Modules", Icons.book_rounded,
                      count: c.modules.length),
                  ...c.modules.asMap().entries.map((entry) {
                    final index = entry.key;
                    final module = entry.value;
                    return _moduleCard(
                      context: context,
                      index: index,
                      module: module,
                      isPurchased: isPurchased,
                      courseId: c.id,
                    );
                  }),
                  const SizedBox(height: 4),
                ],

                // ── STUDY MATERIALS ────────────────────────────────────────
                if (c.contents.isNotEmpty) ...[
                  _sectionHeader("Study Materials", Icons.folder_open_rounded,
                      count: c.contents.length),
                  _card(
                    child: Column(
                      children: c.contents.asMap().entries.map((e) {
                        return _contentRow(
                          content: e.value,
                          isPurchased: isPurchased,
                          isLast: e.key == c.contents.length - 1,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── CERTIFICATION TESTS ────────────────────────────────────
                if (c.certificationTests.isNotEmpty) ...[
                  _sectionHeader(
                      "Certification Tests", Icons.workspace_premium_rounded,
                      count: c.certificationTests.length),
                  ...c.certificationTests.asMap().entries.map((entry) {
                    final index = entry.key;
                    final ct = entry.value;
                    return _certTestCard(
                      index: index,
                      ct: ct,
                      isPurchased: isPurchased,
                      context: context,
                      courseId: c.id,
                    );
                  }),
                ],

                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Module card ──────────────────────────────────────────────────────────

  Widget _moduleCard({
    required BuildContext context,
    required int index,
    required Module module,
    required bool isPurchased,
    required String courseId,
  }) {
    final status = module.testStatus;
    final statusColor = _statusColor(status);
    final statusBg = _statusBg(status);
    final statusLabel = _statusLabel(status);
    final statusIcon = _statusIcon(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Module header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _accent,
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
                        "MODULE ${index + 1}",
                        style: TextStyle(
                          fontSize: 10.5,
                          letterSpacing: 1.2,
                          color: Colors.blueGrey.shade400,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        module.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _navy,
                        ),
                      ),
                      if (module.description.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          module.description,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.blueGrey.shade400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Status chip
                if (module.test != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 12, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ── Contents ──
          if (module.contents.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Column(
                children: module.contents.asMap().entries.map((e) {
                  return _contentRow(
                    content: e.value,
                    isPurchased: isPurchased,
                    isLast: e.key == module.contents.length - 1,
                  );
                }).toList(),
              ),
            ),
          ],

          // ── Test section ──
          if (module.test != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  // test info row
                  Row(
                    children: [
                      _infoChip(
                        Icons.timer_outlined,
                        "${module.test!.durationMinutes} min",
                        Colors.indigo,
                      ),
                      const SizedBox(width: 8),
                      _infoChip(
                        Icons.percent_rounded,
                        "Pass: ${module.test!.passingPercentage}%",
                        Colors.teal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // action button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: !isPurchased
                            ? Colors.grey.shade300
                            : module.testCompleted
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFFF5A00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: !isPurchased
                          ? null
                          : () {
                              if (module.testCompleted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => InstantResultsScreen(
                                      scoreProgression: const [],
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ExamInstructionsScreen(
                                      testId: module.test!.id,
                                      examTitle: module.test!.title,
                                      categoryId: courseId,
                                      pillarType: courseId,
                                      isBundleTest: false,
                                    ),
                                  ),
                                );
                              }
                            },
                      icon: Icon(
                        !isPurchased
                            ? Icons.lock_outline_rounded
                            : module.testCompleted
                                ? Icons.analytics_outlined
                                : Icons.play_circle_outline_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        !isPurchased
                            ? "Unlock to Start Test"
                            : module.testCompleted
                                ? "View Result"
                                : "Start Module Test",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else
            const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─── Certification test card ──────────────────────────────────────────────

  Widget _certTestCard({
    required BuildContext context,
    required int index,
    required CertificationTest ct,
    required bool isPurchased,
    required String courseId,
  }) {
    final status = ct.status;
    final statusColor = _statusColor(status);
    final statusBg = _statusBg(status);
    final statusLabel = _statusLabel(status);
    final statusIcon = _statusIcon(status);
    final isCompleted = status == 'passed' || status == 'failed';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(Icons.workspace_premium_rounded,
                        color: Colors.orange.shade600, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "CERT TEST ${index + 1}",
                        style: TextStyle(
                          fontSize: 10.5,
                          letterSpacing: 1.2,
                          color: Colors.blueGrey.shade400,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ct.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _navy,
                        ),
                      ),
                      if (ct.description.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          ct.description,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.blueGrey.shade400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // info chips row
            Row(
              children: [
                _infoChip(
                  Icons.timer_outlined,
                  "${ct.durationMinutes} min",
                  Colors.indigo,
                ),
                const SizedBox(width: 8),
                _infoChip(
                  Icons.percent_rounded,
                  "Pass: ${ct.passingPercentage}%",
                  Colors.teal,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // action button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: !isPurchased
                      ? Colors.grey.shade300
                      : isCompleted
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFFF5A00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: !isPurchased
                    ? null
                    : () {
                        if (isCompleted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InstantResultsScreen(
                                scoreProgression: const [],
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExamInstructionsScreen(
                                testId: ct.id,
                                examTitle: ct.title,
                                categoryId: courseId,
                                pillarType: courseId,
                                isBundleTest: false,
                              ),
                            ),
                          );
                        }
                      },
                icon: Icon(
                  !isPurchased
                      ? Icons.lock_outline_rounded
                      : isCompleted
                          ? Icons.analytics_outlined
                          : Icons.play_circle_outline_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  !isPurchased
                      ? "Unlock to Attempt"
                      : isCompleted
                          ? "View Result"
                          : "Start Certification Test",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Shared helpers ───────────────────────────────────────────────────────

  Widget _contentRow({
    required Content content,
    required bool isPurchased,
    required bool isLast,
  }) {
    final isPdf = content.type == "pdf";
    final isVideo = content.type == "video";

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isPdf
                      ? Colors.red.withOpacity(0.08)
                      : isVideo
                          ? Colors.blue.withOpacity(0.08)
                          : Colors.grey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isPdf
                      ? Icons.picture_as_pdf_rounded
                      : isVideo
                          ? Icons.video_file_rounded
                          : Icons.insert_drive_file_rounded,
                  color: isPdf
                      ? Colors.red
                      : isVideo
                          ? Colors.blue
                          : Colors.grey,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  content.originalName,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (isPurchased)
                GestureDetector(
                  onTap: () async {
                    if (content.url != null && content.url!.isNotEmpty) {
                      await _handleDownload(content.url!, content.originalName);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.download_rounded,
                        color: Colors.green, size: 18),
                  ),
                )
              else
                const Icon(Icons.lock_outline_rounded,
                    size: 16, color: Colors.grey),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, thickness: 0.5),
      ],
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      );

  Widget _statPill(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 13),
            const SizedBox(width: 5),
            Text(label,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      );

  Widget _sectionHeader(String title, IconData icon, {int? count}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: _navy),
            const SizedBox(width: 7),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: _navy,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$count",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _accent,
                  ),
                ),
              ),
            ],
          ],
        ),
      );

  Widget _card({required Widget child}) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: child,
      );

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) =>
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      );

  Future<void> _handleDownload(String url, String fileName) async {
    try {
      final response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      const platform = MethodChannel('download_channel');
      await platform.invokeMethod('saveFile', {
        "fileName": fileName,
        "bytes": bytes,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Saved in Downloads")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Download failed")));
    }
  }
}