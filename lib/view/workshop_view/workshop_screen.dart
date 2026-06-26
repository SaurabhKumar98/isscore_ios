import 'package:firstedu/res/widgets/custom_filter_chips.dart';
import 'package:firstedu/res/widgets/custom_silverappbar.dart';
import 'package:firstedu/view/workshop_view/workshop_card.dart';
import 'package:firstedu/view_models/workshopprovider/workshopsprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class RegisteredWorkshopScreen extends StatefulWidget {
  const RegisteredWorkshopScreen({super.key});

  @override
  State<RegisteredWorkshopScreen> createState() =>
      _RegisteredWorkshopScreenState();
}

class _RegisteredWorkshopScreenState extends State<RegisteredWorkshopScreen> {
  final _tabs = [
    _FilterTab(label: 'All', apiValue: 'All'),
    _FilterTab(label: 'Upcoming', apiValue: 'upcoming'),
    _FilterTab(label: 'Live', apiValue: 'live'),
    _FilterTab(label: 'Completed', apiValue: 'completed'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkshopProvider>().fetchWorkshops(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkshopProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: RefreshIndicator(
          onRefresh: () => context.read<WorkshopProvider>().fetchWorkshops(context),

        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    ),
          slivers: [
            const CustomSliverAppBar(
              title: 'Workshops',
              subtitle: 'Register and access your workshops.',
            ),
        
            // ── FILTERS ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                child: SizedBox(
                  height: 40.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _tabs.length,
                    separatorBuilder: (_, __) => SizedBox(width: 8.w),
                    itemBuilder: (context, i) => CustomFilterChip(
                      label: _tabs[i].label,
                      selected: provider.selectedFilterIndex == i,
                      // ── FIX: pass the correct lowercase apiValue ────────
                      onTap: () =>
                          provider.setFilter(context, i, _tabs[i].apiValue),
                    ),
                  ),
                ),
              ),
            ),
        
            // ── BODY ─────────────────────────────────────────────────────
            if (provider.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage.isNotEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          provider.errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        TextButton.icon(
                          onPressed: () => provider.fetchWorkshops(context),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (provider.workshops.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.event_busy_outlined,
                        size: 52,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'No workshops found',
                        style: TextStyle(color: Colors.black38, fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        WorkshopCard(data: provider.workshops[index]),
                    childCount: provider.workshops.length,
                  ),
                ),
              ),
        
              if (provider.isPaginationLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
        
              SliverToBoxAdapter(
                child: _LoadMoreTrigger(
                  onVisible: () => provider.loadMore(context),
                ),
              ),
        
              SliverToBoxAdapter(child: SizedBox(height: 100.h)),
            ],
          ],
        ),
      ),
    );
  }
}

// Holds both display label and API value separately
class _FilterTab {
  final String label;
  final String apiValue;
  const _FilterTab({required this.label, required this.apiValue});
}

class _LoadMoreTrigger extends StatefulWidget {
  final VoidCallback onVisible;
  const _LoadMoreTrigger({required this.onVisible});

  @override
  State<_LoadMoreTrigger> createState() => _LoadMoreTriggerState();
}

class _LoadMoreTriggerState extends State<_LoadMoreTrigger> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onVisible());
  }

  @override
  Widget build(BuildContext context) => const SizedBox(height: 1);
}
