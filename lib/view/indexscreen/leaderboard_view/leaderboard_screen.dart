// lib/view/leaderboardscreen/leaderboards_screen.dart

import 'package:firstedu/data/models/api_models/leaderboard/leaderboard_models.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_silverappbar.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/res/widgets/customheadercard.dart';
import 'package:firstedu/view_models/leaderboardprovider/leaderboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class LeaderboardsScreen extends StatefulWidget {
  const LeaderboardsScreen({super.key});

  @override
  State<LeaderboardsScreen> createState() => _LeaderboardsScreenState();
}

class _LeaderboardsScreenState extends State<LeaderboardsScreen> {
@override
void initState() {
  super.initState();
  Future.microtask(() {
    final provider = context.read<LeaderboardProvider>();
    provider.fetchCategories(context);   // ← fetch categories
    provider.fetchEvents(context);
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: CustomScrollView(
        slivers: [
          const CustomSliverAppBar(
            title: "Leaderboards",
            subtitle: "View rankings by performance, participation, and scores",
          ),

          SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const BubbleHeaderCard(
                  title: "Leaderboards",
                  subtitle:
                      "View rankings by performance, participation, and scores",
                  icon: Icons.emoji_events_rounded,
                  backgroundColor: drawerColor,
                  iconColor: Colors.amber,
                ),

                SizedBox(height: 20.h),

                // ── Type Tabs ──────────────────────────────────────
                _TypeTabs(),
SizedBox(height: 12.h),
_CategoryChips(),          // ← add this
// SizedBox(height: 12.h),
                SizedBox(height: 20.h),

                // ── Event Selector Button ──────────────────────────
                _EventSelectorButton(),

                SizedBox(height: 20.h),

                // ── Leaderboard Content ────────────────────────────
                _LeaderboardContent(),

                SizedBox(height: 80.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TYPE TABS  (Olympiads / Tournaments)
// ─────────────────────────────────────────────────────────────────────────────

class _TypeTabs extends StatelessWidget {
  final tabs = const [
    {
      'label': 'Olympiads',
      'icon': Icons.emoji_events_outlined,
      'type': 'olympiad',
    },
    {
      'label': 'Tournaments',
      'icon': Icons.sports_esports_outlined,
      'type': 'tournament',
    },
    {
      'label': 'Test',
      'icon': Icons.sports_esports_outlined,
      'type': 'standalone_test',
    },
    {
      'label': 'Challenge',
      'icon': Icons.sports_esports_outlined,
      'type': 'challenge',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaderboardProvider>();

    return SizedBox(
      height: 48.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = provider.selectedType == tab['type'];
          return GestureDetector(
            onTap: () => provider.setType(context, tab['type'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isSelected ? drawerColor : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? drawerColor : Colors.grey.shade300,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: drawerColor.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tab['icon'] as IconData,
                    size: 18.sp,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                  ),
                  SizedBox(width: 8.w),
                  CustomText(
                    text: tab['label'] as String,
                    size: 13,
                    weight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  EVENT SELECTOR BUTTON  (opens bottom sheet)
// ─────────────────────────────────────────────────────────────────────────────

class _EventSelectorButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaderboardProvider>();
    final event = provider.selectedEvent;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: provider.isListLoading
            ? null
            : () => _showEventPicker(context, provider),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: drawerColor.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(9.w),
                decoration: BoxDecoration(
                  color: drawerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.ballot_outlined,
                  size: 18.sp,
                  color: drawerColor,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: provider.isListLoading
                    ? Text(
                        "Loading events...",
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                      )
                    : event == null
                    ? Text(
                        "Select an event",
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title ?? '',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (event.stage != null) ...[
                            SizedBox(height: 2.h),
                            Text(
                              'Stage: ${event.stage}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: drawerColor,
                size: 22.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventPicker(BuildContext context, LeaderboardProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EventPickerSheet(
        events: provider.events,
        selectedEventId: provider.selectedEvent?.eventId,
        onSelect: (event) {
          Navigator.pop(context);
          provider.selectEvent(context, event);
        },
        onLoadMore: provider.hasMore ? () => provider.loadMore(context) : null,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  EVENT PICKER BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _EventPickerSheet extends StatelessWidget {
  final List<LeaderboardEvent> events;
  final String? selectedEventId;
  final Function(LeaderboardEvent) onSelect;
  final VoidCallback? onLoadMore;

  const _EventPickerSheet({
    required this.events,
    required this.selectedEventId,
    required this.onSelect,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 70.sh),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          SizedBox(height: 12.h),
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDEE6),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Icon(
                  Icons.emoji_events_rounded,
                  color: drawerColor,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Select Event',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1D26),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),
          Divider(color: Colors.grey.shade100, height: 1),

          // List
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
              itemCount: events.length + (onLoadMore != null ? 1 : 0),
              separatorBuilder: (_, __) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                if (index == events.length) {
                  return Center(
                    child: TextButton.icon(
                      onPressed: onLoadMore,
                      icon: const Icon(Icons.expand_more),
                      label: const Text('Load more'),
                    ),
                  );
                }
                final event = events[index];
                final isSelected = event.eventId == selectedEventId;
                return GestureDetector(
                  onTap: () => onSelect(event),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? drawerColor.withOpacity(0.07)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isSelected ? drawerColor : Colors.grey.shade200,
                        width: isSelected ? 1.8 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38.w,
                          height: 38.w,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? drawerColor
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            event.type == 'tournament'
                                ? Icons.sports_esports_outlined
                                : Icons.emoji_events_outlined,
                            size: 18.sp,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title ?? '',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (event.stage != null)
                                Text(
                                  'Stage: ${event.stage}',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              if (event.totalParticipants != null)
                                Text(
                                  '${event.totalParticipants} participants',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: drawerColor,
                            size: 20.sp,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  LEADERBOARD CONTENT  (podium + rows)
// ─────────────────────────────────────────────────────────────────────────────

class _LeaderboardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaderboardProvider>();

    if (provider.isDetailLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.selectedEvent == null || provider.entries.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 40.h),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.leaderboard_outlined,
                size: 48.sp,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 12.h),
              Text(
                'No leaderboard data yet',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    final entries = provider.entries;
    final top3 = entries.take(3).toList();
    final rest = entries.skip(3).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event title
          Text(
            provider.selectedEvent!.title ?? '',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1D26),
            ),
          ),
          if (provider.selectedEvent!.stage != null) ...[
            SizedBox(height: 4.h),
            Text(
              'Stage: ${provider.selectedEvent!.stage}',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
            ),
          ],

          SizedBox(height: 24.h),

          // ── PODIUM (top 3) ───────────────────────────────────
          if (top3.isNotEmpty) PodiumWidget(top3: top3),

          SizedBox(height: 20.h),

          // ── RANKED LIST (4th onwards) ────────────────────────
          if (rest.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Table header
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.r),
                      ),
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40.w,
                          child: Text(
                            'RANK',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'STUDENT',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 55.w,
                          child: Text(
                            'SCORE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 55.w,
                          child: Text(
                            'PERF.',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Rows
                  ...rest.asMap().entries.map(
                    (e) => _RankedRow(
                      entry: e.value,
                      isLast: e.key == rest.length - 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PODIUM  (1st, 2nd, 3rd)
// ─────────────────────────────────────────────────────────────────────────────

// lib/view/leaderboardscreen/widgets/podium_widget.dart

class PodiumWidget extends StatelessWidget {
  final List<LeaderboardEntry> top3;
  const PodiumWidget({super.key, required this.top3});

  @override
  Widget build(BuildContext context) {
    final first = top3.isNotEmpty ? top3[0] : null;
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
      decoration: BoxDecoration(
        // Deep navy gradient background
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF0F1B3C), const Color(0xFF162556)],
        ),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          // ── Header ───────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _starIcon(size: 14.sp, color: const Color(0xFFFFD700)),
              SizedBox(width: 6.w),
              Text(
                'Top Performers',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(width: 6.w),
              _starIcon(size: 14.sp, color: const Color(0xFFFFD700)),
            ],
          ),

          SizedBox(height: 24.h),

          // ── Podium Row: 2nd | 1st | 3rd ──────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd
              Expanded(
                child: _PodiumSlot(
                  entry: second,
                  rank: 2,
                  avatarSize: 52.w,
                  podiumHeight: 64.h,
                ),
              ),
              // 1st (center, taller)
              Expanded(
                child: _PodiumSlot(
                  entry: first,
                  rank: 1,
                  avatarSize: 64.w,
                  podiumHeight: 90.h,
                  isFirst: true,
                ),
              ),
              // 3rd
              Expanded(
                child: _PodiumSlot(
                  entry: third,
                  rank: 3,
                  avatarSize: 52.w,
                  podiumHeight: 50.h,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _starIcon({required double size, required Color color}) {
    return Icon(Icons.auto_awesome_rounded, size: size, color: color);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PODIUM SLOT
// ─────────────────────────────────────────────────────────────────────────────

class _PodiumSlot extends StatelessWidget {
  final LeaderboardEntry? entry;
  final int rank;
  final double avatarSize;
  final double podiumHeight;
  final bool isFirst;

  const _PodiumSlot({
    required this.entry,
    required this.rank,
    required this.avatarSize,
    required this.podiumHeight,
    this.isFirst = false,
  });

  // ── Medal colors ──────────────────────────────────────────────

  Color get _medalGold => const Color(0xFFFFD700);
  Color get _medalSilver => const Color(0xFFCDD0DA);
  Color get _medalBronze => const Color(0xFFCD7F32);

  Color get _primaryColor {
    if (rank == 1) return _medalGold;
    if (rank == 2) return _medalSilver;
    return _medalBronze;
  }

  Color get _podiumLight {
    if (rank == 1) return const Color(0xFF2A3F7A);
    if (rank == 2) return const Color(0xFF1E2D5A);
    return const Color(0xFF1A2650);
  }

  Color get _podiumDark {
    if (rank == 1) return const Color(0xFF1A2B60);
    if (rank == 2) return const Color(0xFF162250);
    return const Color(0xFF121E46);
  }

  String get _rankLabel {
    if (rank == 1) return '1ST';
    if (rank == 2) return '2ND';
    return '3RD';
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    return parts
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
  }

  @override
  Widget build(BuildContext context) {
    if (entry == null) return const SizedBox.shrink();

    final name = entry!.name ?? '—';
    final score = entry!.score ?? 0;
    final maxScore = entry!.maxScore ?? 100;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // ── Crown for 1st ──────────────────────────────────────
        if (isFirst) ...[
          _CrownIcon(color: _medalGold),
          SizedBox(height: 4.h),
        ] else
          SizedBox(height: isFirst ? 0 : 28.h),

        // ── Avatar ─────────────────────────────────────────────
        Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _primaryColor.withOpacity(0.4),
                    _primaryColor.withOpacity(0.15),
                  ],
                ),
                border: Border.all(
                  color: _primaryColor,
                  width: isFirst ? 2.5 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.35),
                    blurRadius: isFirst ? 16 : 10,
                    spreadRadius: isFirst ? 1 : 0,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _initials(name),
                  style: TextStyle(
                    fontSize: isFirst ? 18.sp : 14.sp,
                    fontWeight: FontWeight.w800,
                    color: _primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            // Rank badge on avatar bottom
            Positioned(
              bottom: -8.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withOpacity(0.5),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _rankLabel,
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w900,
                    color: rank == 1
                        ? const Color(0xFF1A1500)
                        : const Color(0xFF1A1D26),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 14.h),

        // ── Name ───────────────────────────────────────────────
        Text(
          name.split(' ').first,
          style: TextStyle(
            fontSize: isFirst ? 12.sp : 11.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 3.h),

        // ── Score ──────────────────────────────────────────────
        Text(
          '$score/$maxScore',
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: _primaryColor.withOpacity(0.85),
          ),
        ),

        SizedBox(height: 10.h),

        // ── Podium block ───────────────────────────────────────
        Container(
          width: double.infinity,
          height: podiumHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_podiumLight, _podiumDark],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isFirst ? 10.r : 8.r),
              topRight: Radius.circular(isFirst ? 10.r : 8.r),
            ),
            // ✅ Uniform color — no crash
            border: Border.all(
              color: _primaryColor.withOpacity(0.4),
              width: isFirst ? 2 : 1.5,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_MedalIcon(rank: rank, size: isFirst ? 22.sp : 18.sp)],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CROWN  (1st place only)
// ─────────────────────────────────────────────────────────────────────────────

class _CrownIcon extends StatelessWidget {
  final Color color;
  const _CrownIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.workspace_premium_rounded,
      color: color,
      size: 26.sp,
      shadows: [Shadow(color: color.withOpacity(0.6), blurRadius: 10)],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  MEDAL ICON
// ─────────────────────────────────────────────────────────────────────────────

class _MedalIcon extends StatelessWidget {
  final int rank;
  final double size;
  const _MedalIcon({required this.rank, required this.size});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    if (rank == 1) {
      icon = Icons.emoji_events_rounded;
      color = const Color(0xFFFFD700);
    } else if (rank == 2) {
      icon = Icons.emoji_events_rounded;
      color = const Color(0xFFCDD0DA);
    } else {
      icon = Icons.emoji_events_rounded;
      color = const Color(0xFFCD7F32);
    }

    return Icon(icon, color: color, size: size);
  }
}
// ─────────────────────────────────────────────────────────────────────────────
//  RANKED ROW  (4th onwards)
// ─────────────────────────────────────────────────────────────────────────────

class _RankedRow extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isLast;

  const _RankedRow({required this.entry, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final rank = entry.rank ?? 0;
    final score = entry.score ?? 0;
    final maxScore = entry.maxScore ?? 100;
    final perf = maxScore > 0
        ? '${(score / maxScore * 100).toStringAsFixed(0)}%'
        : '—';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isLast
            ? BorderRadius.vertical(bottom: Radius.circular(16.r))
            : BorderRadius.zero,
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 28.w,
            height: 28.w,
            margin: EdgeInsets.only(right: 12.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),

          // Name
          Expanded(
            child: Text(
              entry.name ?? '—',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Score
          SizedBox(
            width: 55.w,
            child: Text(
              '$score/$maxScore',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),

          // Performance %
          SizedBox(
            width: 55.w,
            child: Text(
              perf,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: drawerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────────
//  CATEGORY CHIPS  (with subcategory expansion)
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
//  CATEGORY CHIPS  (matches Store screen pattern)
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaderboardProvider>();

    if (provider.isCategoryLoading) {
      return SizedBox(
        height: 36.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: 5,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (_, __) => Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: 70.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          ),
        ),
      );
    }

    if (provider.categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Active category badge ─────────────────────────────────
        if (provider.selectedCategory != null)
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: drawerColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: drawerColor.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_alt_rounded, size: 15.sp, color: drawerColor),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      "Category: ${provider.selectedCategory!.name ?? ''}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: drawerColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => provider.clearCategoryFilter(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.close_rounded,
                              size: 11.sp, color: Colors.red.shade400),
                          SizedBox(width: 3.w),
                          Text(
                            "Clear",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.red.shade400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ── Chips row ─────────────────────────────────────────────
        SizedBox(
          height: 36.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: provider.categories.length + 1,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              // "All" chip
              if (index == 0) {
                final isSelected = provider.selectedCategory == null;
                return _chip(
                  label: 'All',
                  isSelected: isSelected,
                  hasChildren: false,
                  onTap: () => provider.clearCategoryFilter(context),
                );
              }

              final cat = provider.categories[index - 1];
              // A parent is highlighted if it or any of its children is selected
              final isSelected = provider.selectedCategory?.id == cat.id ||
                  cat.children.any((c) => c.id == provider.selectedCategory?.id);

              return _chip(
                label: cat.name ?? '',
                isSelected: isSelected,
                hasChildren: cat.children.isNotEmpty,
                onTap: () {
                  if (cat.children.isNotEmpty) {
                    _openCategorySheet(context, provider, cat);
                  } else {
                    provider.selectCategory(context, cat);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _chip({
    required String label,
    required bool isSelected,
    required bool hasChildren,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? drawerColor : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? drawerColor : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: drawerColor.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : drawerColor,
              ),
            ),
            if (hasChildren) ...[
              SizedBox(width: 2.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 13.sp,
                color: isSelected ? Colors.white : Colors.grey.shade400,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openCategorySheet(
    BuildContext context,
    LeaderboardProvider provider,
    CategoryNode rootCat,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LeaderboardCategorySheet(
        rootCategory: rootCat,
        allCategories: provider.categories,
        provider: provider,
        onSelect: (cat) {
          Navigator.pop(context);
          provider.selectCategory(context, cat);
        },
        onClear: () {
          Navigator.pop(context);
          provider.clearCategoryFilter(context);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  LEADERBOARD CATEGORY SHEET  (expandable tree — same as store)
// ─────────────────────────────────────────────────────────────────────────────

class _LeaderboardCategorySheet extends StatefulWidget {
  final CategoryNode rootCategory;
  final List<CategoryNode> allCategories;
  final LeaderboardProvider provider;
  final void Function(CategoryNode) onSelect;
  final VoidCallback onClear;

  const _LeaderboardCategorySheet({
    required this.rootCategory,
    required this.allCategories,
    required this.provider,
    required this.onSelect,
    required this.onClear,
  });

  @override
  State<_LeaderboardCategorySheet> createState() =>
      _LeaderboardCategorySheetState();
}

class _LeaderboardCategorySheetState
    extends State<_LeaderboardCategorySheet> {
  final Set<String> _expandedIds = {};

  @override
  void initState() {
    super.initState();
    // Auto-expand the tapped root category
    if (widget.rootCategory.id != null) {
      _expandedIds.add(widget.rootCategory.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          SizedBox(height: 12.h),
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Header row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Icon(Icons.category_rounded, color: drawerColor, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    "Explore Categories",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: drawerColor,
                    ),
                  ),
                ),
                if (widget.provider.selectedCategory != null)
                  GestureDetector(
                    onTap: widget.onClear,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        "Clear",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Divider(height: 1, color: Colors.grey.shade100),

          // Tree list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: widget.allCategories.length,
              itemBuilder: (_, i) =>
                  _buildNode(widget.allCategories[i], depth: 0),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
        ],
      ),
    );
  }

  Widget _buildNode(CategoryNode cat, {required int depth}) {
    final isExpanded = _expandedIds.contains(cat.id);
    final isSelected = widget.provider.selectedCategory?.id == cat.id;
    final hasChildren = cat.children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            if (hasChildren) {
              setState(() {
                isExpanded
                    ? _expandedIds.remove(cat.id)
                    : _expandedIds.add(cat.id!);
              });
            } else {
              widget.onSelect(cat);
            }
          },
          borderRadius: BorderRadius.circular(10.r),
          child: Container(
            padding: EdgeInsets.only(
              left: (16.0 * depth).w,
              right: 12.w,
              top: 12.h,
              bottom: 12.h,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? drawerColor.withOpacity(0.07)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                // Bullet for children
                if (depth > 0) ...[
                  Container(
                    width: 6.w,
                    height: 6.w,
                    margin: EdgeInsets.only(right: 10.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? drawerColor
                          : Colors.grey.shade300,
                    ),
                  ),
                ],
                Expanded(
                  child: Text(
                    cat.name ?? '',
                    style: TextStyle(
                      fontSize: depth == 0 ? 14.sp : 13.sp,
                      fontWeight: depth == 0
                          ? FontWeight.w700
                          : isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                      color: isSelected
                          ? drawerColor
                          : depth == 0
                              ? Colors.black87
                              : Colors.grey.shade700,
                    ),
                  ),
                ),
                if (hasChildren) ...[
                  // Children count badge
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 7.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '${cat.children.length}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
                if (!hasChildren && isSelected)
                  Icon(Icons.check_circle_rounded,
                      color: drawerColor, size: 18.sp),
              ],
            ),
          ),
        ),

        // Animated expand/collapse children
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: isExpanded && hasChildren
              ? Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: cat.children
                        .map((child) =>
                            _buildNode(child, depth: depth + 1))
                        .toList(),
                  ),
                )
              : const SizedBox.shrink(),
        ),

        if (depth == 0)
          Divider(height: 1, color: Colors.grey.shade100),
      ],
    );
  }
}