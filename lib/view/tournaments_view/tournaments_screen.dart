import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/view/tournaments_view/tournaments_card.dart';
import 'package:firstedu/view_models/tournamentprovider/tournament_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

final RouteObserver<ModalRoute<void>> tournamentRouteObserver =
    RouteObserver<ModalRoute<void>>();

class TournamentScreen extends StatefulWidget {
  const TournamentScreen({super.key});

  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> with RouteAware {
  final _filterLabels = ['All', 'Open', 'Live', 'Upcoming', 'Completed', 'Closed'];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TournamentProvider>().fetchTournaments(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    tournamentRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    tournamentRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // ✅ Auto-refresh when returning from detail/exam screen
    if (mounted) {
      context.read<TournamentProvider>().fetchTournaments(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: RefreshIndicator(
         onRefresh: () => context.read<TournamentProvider>().fetchTournaments(context),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(), 
          ),
          
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildFilters()),
            Consumer<TournamentProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
        
                if (provider.tournaments.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emoji_events_outlined,
                              size: 48.sp, color: Colors.grey.shade400),
                          SizedBox(height: 12.h),
                          Text(
                            'No tournaments found',
                            style: TextStyle(
                                fontSize: 14.sp, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  );
                }
        
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 120.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == provider.tournaments.length) {
                          return provider.isPaginationLoading
                              ? Padding(
                                  padding: EdgeInsets.all(16.h),
                                  child: const Center(
                                      child: CircularProgressIndicator()),
                                )
                              : const SizedBox.shrink();
                        }
                        if (index == provider.tournaments.length - 2) {
                          Future.microtask(() => provider.loadMore(context));
                        }
                        return TournamentCard(
                            tournament: provider.tournaments[index]);
                      },
                      childCount: provider.tournaments.length + 1,
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

  Widget _buildHeader() {
    return Consumer<TournamentProvider>(
      builder: (context, provider, _) {
        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(color: Color(0xFF1A2340)),
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Positioned(right: -20.w, top: 10.h, child: _bubble(120.w, 0.07)),
                Positioned(right: 60.w, bottom: -30.h, child: _bubble(90.w, 0.05)),
                Positioned(right: 10.w, bottom: 10.h, child: _bubble(50.w, 0.08)),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44.w,
                            height: 44.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(Icons.emoji_events_rounded,
                                color: Colors.amber, size: 26.sp),
                          ),
                          SizedBox(width: 12.w),
                          CustomText(
                            text: "Tournaments",
                            size: 24,
                            weight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.h,
                            decoration: const BoxDecoration(
                                color: Colors.orange, shape: BoxShape.circle),
                          ),
                          SizedBox(width: 6.w),
                          CustomText(
                            text: "Multi-stage events: Qualifier → Semi-Final → Final.",
                            size: 12,
                            color: Colors.white70,
                            maxLines: 2,
                            height: 1.4,
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      _statChip(
                        label: "Total",
                        value: provider.tournaments.length.toString(),
                        bgColor: Colors.white.withOpacity(0.12),
                        valueColor: Colors.white,
                        labelColor: Colors.white70,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bubble(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      );

  Widget _statChip({
    required String label,
    required String value,
    required Color bgColor,
    required Color valueColor,
    required Color labelColor,
  }) =>
      Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(text: label, size: 11, color: labelColor),
            SizedBox(height: 2.h),
            CustomText(
                text: value, size: 16, weight: FontWeight.w800, color: valueColor),
          ],
        ),
      );

  Widget _buildFilters() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 0, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: "FILTER BY STATUS",
            size: 11,
            weight: FontWeight.w700,
            color: Colors.grey.shade500,
            letterSpacing: 1.1,
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_filterLabels.length, (index) {
                final label = _filterLabels[index];
                final isSelected = _selectedIndex == index;
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedIndex = index);
                      String? status;
                      switch (label) {
                        case 'Live':
                        case 'Open':
                          status = 'live';
                          break;
                        case 'Upcoming':
                          status = 'upcoming';
                          break;
                        case 'Completed':
                        case 'Closed':
                          status = 'completed';
                          break;
                        default:
                          status = null;
                      }
                      context.read<TournamentProvider>().setStatus(context, status);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
                      decoration: BoxDecoration(
                        color: isSelected ? drawerColor : Colors.white,
                        borderRadius: BorderRadius.circular(50.r),
                        border: Border.all(
                          color: isSelected ? drawerColor : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: drawerColor.withOpacity(0.25),
                                  blurRadius: 8.r,
                                  offset: Offset(0, 3.h),
                                ),
                              ]
                            : [],
                      ),
                      child: CustomText(
                        text: label,
                        size: 13,
                        weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}