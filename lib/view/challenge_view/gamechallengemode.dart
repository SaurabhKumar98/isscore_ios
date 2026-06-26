import 'package:firstedu/data/models/api_models/challengeyourself/challengeyourself_models.dart';
import 'package:firstedu/data/repo/examhall/examsessionrepositories.dart';
import 'package:firstedu/view/challenge_view/category_chip_selector.dart';
import 'package:firstedu/view/challenge_view/challenge_payment_sheet.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/questionscreen.dart';
import 'package:firstedu/view_models/challengeyourselfprovider/challengeyourself_provider.dart';
import 'package:firstedu/view_models/examhallprovider/examhallwebsocket.dart';
import 'package:firstedu/view_models/examhallprovider/examsessionprovider.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_silverappbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameModeScreen extends StatefulWidget {
  const GameModeScreen({super.key});

  @override
  State<GameModeScreen> createState() => _GameModeScreenState();
}

class _GameModeScreenState extends State<GameModeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChallengeYourselfProvider>().fetchCategories(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengeYourselfProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF0F2F8),
          body: RefreshIndicator(
            onRefresh: () => provider.refresh(context),
            color: activeItemColor,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                const CustomSliverAppBar(
                  title: 'Challenge Yourself',
                  subtitle:
                      'Progress through stages, earn XP & unlock new levels',
                ),

                if (provider.isCategoryLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (provider.error != null && provider.categories.isEmpty)
                  SliverFillRemaining(child: _ErrorState(provider: provider))
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (provider.categories.isNotEmpty)
                          const CategoryChipSelector(),

                        const SizedBox(height: 20),

                        if (provider.isStageLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 60),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (provider.error != null &&
                            provider.stages.isEmpty)
                          _SoftError(provider: provider)
                        else if (provider.stages.isEmpty &&
                            provider.selectedCategoryId == null)
                          _PickSubjectHint()
                        else if (provider.stages.isEmpty &&
                            provider.selectedCategoryId != null)
                          _EmptyStages(
                            categoryName: provider.selectedCategory?.name ?? '',
                          )
                        else if (provider.stages.isNotEmpty) ...[
                          _StageTabBar(provider: provider),
                          const SizedBox(height: 14),
                          if (provider.selectedStage != null)
                            _StageProgressCard(stage: provider.selectedStage!),
                          const SizedBox(height: 22),
                          if (provider.selectedStage != null)
                            _LevelCampaignPath(stage: provider.selectedStage!),
                          const SizedBox(height: 16),
                          _BottomTip(stage: provider.selectedStage),
                        ],
                      ]),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}


class _StageTabBar extends StatelessWidget {
  final ChallengeYourselfProvider provider;
  const _StageTabBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT STAGE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: provider.stages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final stage = provider.stages[i];
              final isSelected = provider.selectedStageIndex == i;
              final color = _stageColor(stage.name ?? '');

              return GestureDetector(
                onTap: () => provider.selectStage(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected ? color : Colors.grey.shade300,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _stageEmoji(stage.name ?? ''),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        stage.name ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StageProgressCard extends StatelessWidget {
  final Stage stage;
  const _StageProgressCard({required this.stage});

  @override
  Widget build(BuildContext context) {
    final levels = stage.levels;
    // ── count completed: either completedWithFullMarks OR hasCompletedAttempt
    final completed = levels
        .where(
          (l) =>
              l.completedWithFullMarks == true || l.hasCompletedAttempt == true,
        )
        .length;
    final total = stage.totalLevels ?? 0;
    final unlocked = levels.where((l) => l.unlocked == true).length;
    final easy = levels.where((l) => l.difficulty == 'easy').length;
    final medium = levels.where((l) => l.difficulty == 'medium').length;
    final hard = levels.where((l) => l.difficulty == 'hard').length;
    final progress = total > 0 ? completed / total : 0.0;
    final color = _stageColor(stage.name ?? '');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                _stageEmoji(stage.name ?? ''),
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage.name ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  Text(
                    '$completed of $total levels done',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (easy > 0) _chip('$easy Easy', Colors.green),
              if (easy > 0 && medium > 0) const SizedBox(width: 6),
              if (medium > 0) _chip('$medium Med', Colors.orange),
              if ((easy > 0 || medium > 0) && hard > 0)
                const SizedBox(width: 6),
              if (hard > 0) _chip('$hard Hard', Colors.red),
              if (easy == 0 && medium == 0 && hard == 0)
                _chip('${stage.totalLevels ?? 0} Levels', Colors.blue),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: activeItemColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_open_rounded,
                      size: 11,
                      color: activeItemColor,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '$unlocked unlocked',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: activeItemColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, MaterialColor color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color.shade700,
      ),
    ),
  );
}

class _LevelCampaignPath extends StatelessWidget {
  final Stage stage;
  const _LevelCampaignPath({required this.stage});

  @override
  Widget build(BuildContext context) {
    final levels = stage.levels;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: accentOrange,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stage.name ?? ''} Campaign',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  'Full marks = bonus XP!',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...levels.asMap().entries.map((entry) {
          final i = entry.key;
          final level = entry.value;
          return _LevelRow(
            level: level,
            stageName: stage.name ?? '',
            isLast: i == levels.length - 1,
          );
        }),
      ],
    );
  }
}

class _LevelRow extends StatelessWidget {
  final Level level;
  final String stageName;
  final bool isLast;

  const _LevelRow({
    required this.level,
    required this.stageName,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Column(
              children: [
                _LevelNode(level: level),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: CustomPaint(painter: _DottedLinePainter()),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: _LevelCard(level: level, stageName: stageName),
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD0D4E8)
      ..strokeWidth = 2;
    const dash = 5.0, gap = 4.0;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + dash), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _LevelNode extends StatelessWidget {
  final Level level;
  const _LevelNode({required this.level});

  @override
  Widget build(BuildContext context) {
    final isCompleted = level.completedWithFullMarks == true;
    final hasAttempt = level.hasCompletedAttempt == true;
    final isAccessible =
        (level.unlocked == true) && (level.isPurchased == true);
    final needsPurchase = (level.isPurchased != true) && level.test != null;

    Color bg, border;
    Widget child;

    if (isCompleted) {
      // ── Full marks ✅
      bg = Colors.green.shade50;
      border = Colors.green.shade400;
      child = Icon(
        Icons.check_circle_rounded,
        size: 22,
        color: Colors.green.shade600,
      );
    } else if (hasAttempt && isAccessible) {
      // ── Attempted but not full marks — show retry icon 🔄
      bg = Colors.orange.shade50;
      border = Colors.orange.shade400;
      child = Icon(
        Icons.refresh_rounded,
        size: 20,
        color: Colors.orange.shade700,
      );
    } else if (isAccessible) {
      // ── Unlocked & purchased — ready to start
      bg = Colors.orange.shade50;
      border = Colors.orange.shade400;
      child = Text(
        '${level.level ?? ''}',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: Colors.orange.shade700,
        ),
      );
    } else if (needsPurchase) {
      // ── Needs purchase 💰
      bg = Colors.amber.shade50;
      border = Colors.amber.shade400;
      child = Icon(
        Icons.monetization_on_outlined,
        size: 20,
        color: Colors.amber.shade700,
      );
    } else {
      // ── Locked 🔒
      bg = const Color(0xFFF5F5F5);
      border = const Color(0xFFDDDDDD);
      child = Icon(Icons.lock_outline, size: 18, color: Colors.grey.shade400);
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: Border.all(color: border, width: 2.5),
      ),
      child: Center(child: child),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final Level level;
  final String stageName;

  const _LevelCard({required this.level, required this.stageName});

  @override
  Widget build(BuildContext context) {
    final isLocked = level.unlocked != true;
    final isCompleted = level.completedWithFullMarks == true;
    final hasAttempt = level.hasCompletedAttempt == true;
    final isPurchased = level.isPurchased == true;
    final hasTest = level.test != null;

    // ── Card background based on state ───────────────────────────────────
    Color cardBg, cardBorder;
    if (!isPurchased && hasTest) {
      cardBg = const Color(0xFFFFFDF0);
      cardBorder = const Color(0xFFFFE58F);
    } else if (isLocked) {
      cardBg = const Color(0xFFFAFAFA);
      cardBorder = const Color(0xFFF0F0F0);
    } else if (isCompleted) {
      cardBg = const Color(0xFFF2FFF4);
      cardBorder = const Color(0xFFC8E6C9);
    } else if (hasAttempt) {
      // ── Attempted but not full marks — warm yellow tint
      cardBg = const Color(0xFFFFFBF0);
      cardBorder = const Color(0xFFFFE0B2);
    } else {
      cardBg = const Color(0xFFFFFAF5);
      cardBorder = const Color(0xFFFFE0B2);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row ───────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  hasTest
                      ? (level.test?.title ?? 'Test')
                      : 'Level ${level.level ?? 0}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isLocked && isPurchased
                        ? Colors.grey.shade400
                        : const Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              // ── Show "Completed" badge if full marks ────────────────
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    '✓ Done',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.green.shade700,
                    ),
                  ),
                )
              else
                _DiffBadge(difficulty: level.difficulty ?? ''),
            ],
          ),

          // ── Buy to Unlock ────────────────────────────────────────────
          if (hasTest && !isPurchased) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _meta(
                  Icons.timer_outlined,
                  '${level.test?.durationMinutes ?? 0} min',
                ),
                const SizedBox(width: 10),
                _meta(
                  Icons.sell_outlined,
                  '₹${level.test?.price?.toString() ?? '0'}',
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade600,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(
                  Icons.lock_open_rounded,
                  size: 15,
                  color: Colors.white,
                ),
                label: const Text(
                  'Buy to Unlock',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                onPressed: () => _openPaymentSheet(context),
              ),
            ),

            // ── Purchased + Unlocked → Start / Retake / Try Again ────────
          ] else if (hasTest && !isLocked && isPurchased) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _meta(
                  Icons.timer_outlined,
                  '${level.test?.durationMinutes ?? 0} min',
                ),
                const SizedBox(width: 10),
                _meta(
                  Icons.quiz_outlined,
                  '${level.test?.questionBank?.totalQuestions ?? 0} Qs',
                ),
                if ((level.test?.questionBank?.totalMarks ?? 0) > 0) ...[
                  const SizedBox(width: 10),
                  _meta(
                    Icons.star_border_rounded,
                    '${level.test!.questionBank!.totalMarks} marks',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // Green = completed full marks, Orange = attempted/fresh
                  backgroundColor: isCompleted
                      ? Colors.green.shade600
                      : hasAttempt
                      ? Colors.deepOrange.shade400
                      : accentOrange,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _startTest(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCompleted
                          ? Icons
                                .replay_rounded 
                          : hasAttempt
                          ? Icons
                                .refresh_rounded // 🔄 attempted → retry
                          : Icons.play_arrow_rounded, // ▶ fresh → start
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isCompleted
                          ? 'Retake Test' 
                          : hasAttempt
                          ? 'Try Again' 
                          : 'Start Now', 
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ] else if (hasTest && isLocked && isPurchased) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 12,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    (level.level ?? 1) <= 1
                        ? 'Complete previous stage to unlock'
                        : 'Complete level ${(level.level ?? 1) - 1} to unlock',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ),
              ],
            ),

          ] else ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 12,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  'No Test Avialable',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _openPaymentSheet(BuildContext context) {
    showChallengePaymentSheet(
      context,
      level: level,
      onSuccess: () {
        if (context.mounted) {
          context.read<ChallengeYourselfProvider>().refresh(context);
        }
      },
    );
  }

  void _startTest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (ctx) => ExamSessionProvider(
            ctx.read<ExamSessionRepository>(),
            context.read<ExamSocketService>(),
          ),
          child: ExamScreen(
            testId: level.test?.id ?? '',
            examTitle: level.test?.title ?? '',
          ),
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 12, color: Colors.grey.shade500),
      const SizedBox(width: 3),
      Text(text, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
    ],
  );
}

class _DiffBadge extends StatelessWidget {
  final String difficulty;
  const _DiffBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    if (difficulty.isEmpty) return const SizedBox.shrink();

    MaterialColor color;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        color = Colors.green;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'hard':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        difficulty[0].toUpperCase() + difficulty.substring(1),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color.shade700,
        ),
      ),
    );
  }
}

class _BottomTip extends StatelessWidget {
  final Stage? stage;
  const _BottomTip({required this.stage});

  @override
  Widget build(BuildContext context) {
    final hasUnlocked = stage?.levels.any((l) => l.unlocked == true) ?? false;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.lightbulb_rounded,
              color: Colors.amber.shade700,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasUnlocked
                  ? 'Score full marks on each level to earn bonus XP!'
                  : 'Complete the previous stage first.\nBronze → Silver → Gold → Platinum → Diamond → Heroic ⚡',
              style: TextStyle(
                fontSize: 12,
                color: Colors.amber.shade900,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickSubjectHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: activeItemColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.touch_app_rounded,
                size: 30,
                color: activeItemColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a class & subject\nto view your campaign',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStages extends StatelessWidget {
  final String categoryName;
  const _EmptyStages({required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
        child: Column(
          children: [
            Icon(Icons.layers_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 14),
            Text(
              'No stages available yet\nfor ${categoryName.isEmpty ? 'this subject' : categoryName}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftError extends StatelessWidget {
  final ChallengeYourselfProvider provider;
  const _SoftError({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 36,
              color: Colors.redAccent.shade100,
            ),
            const SizedBox(height: 10),
            Text(
              provider.error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: activeItemColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => provider.refresh(context),
              icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
              label: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final ChallengeYourselfProvider provider;
  const _ErrorState({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 34,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: activeItemColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => provider.fetchCategories(context),
              icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
              label: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────

Color _stageColor(String name) {
  switch (name.toLowerCase()) {
    case 'bronze':
      return const Color(0xFFCD7F32);
    case 'silver':
      return const Color(0xFF78909C);
    case 'gold':
      return const Color(0xFFFFB300);
    case 'platinum':
      return const Color(0xFF546E7A);
    case 'diamond':
      return const Color(0xFF29B6F6);
    case 'heroic':
      return const Color(0xFF7C4DFF);
    default:
      return Colors.grey;
  }
}

String _stageEmoji(String name) {
  switch (name.toLowerCase()) {
    case 'bronze':
      return '🥉';
    case 'silver':
      return '🥈';
    case 'gold':
      return '🥇';
    case 'platinum':
      return '💎';
    case 'diamond':
      return '💠';
    case 'heroic':
      return '⚡';
    default:
      return '🏆';
  }
}
