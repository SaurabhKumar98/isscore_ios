import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/view/halloffame_view/hall_of_fame_card.dart';
import 'package:firstedu/view_models/halloffameprovider/halloffame_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HallOfFameScreen extends StatefulWidget {
  const HallOfFameScreen({super.key});

  @override
  State<HallOfFameScreen> createState() => _HallOfFameScreenState();
}

class _HallOfFameScreenState extends State<HallOfFameScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HallOfFameProvider>().fetchHallOfFame(refresh: true);
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<HallOfFameProvider>().fetchHallOfFame();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Consumer<HallOfFameProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.status == HallOfFameStatus.error) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    CustomText(
                      text: provider.errorMessage,
                      size: 14,
                      color: Colors.black54,
                      align: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.fetchHallOfFame(refresh: true),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final items = provider.hallOfFame?.data ?? [];
            final meta = provider.hallOfFame?.meta;

            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    CustomText(
                      text: 'No champions yet.',
                      size: 16,
                      color: Colors.black45,
                    ),
                  ],
                ),
              );
            }

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeroHeader(
                    totalChampions: meta?.total ?? items.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildFilterBar(provider), // 🔥 NEW
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: HallOfFameEventCard(item: items[index]),
                      ),
                      childCount: items.length,
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

                if (!provider.hasMore && items.isNotEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CustomText(
                          text: "You've seen all events 🏆",
                          size: 13,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroHeader({required int totalChampions}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [drawerColor, Color(0xFF2A4494)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: drawerColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events, size: 14, color: Color(0xFFFFD700)),
                  SizedBox(width: 6),
                  CustomText(
                    text: "CHAMPIONS CIRCLE",
                    size: 11,
                    weight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const CustomText(
              text: "Hall of Fame",
              size: 24,
              weight: FontWeight.w900,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            CustomText(
              text: "Celebrating the dedication of our top performers.",
              size: 13,
              weight: FontWeight.w500,
              color: Colors.white.withOpacity(0.85),
              align: TextAlign.center,
              maxLines: 2,
              height: 1.4,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatItem(
                    icon: Icons.military_tech,
                    value: "$totalChampions",
                    label: "Champions",
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const _StatItem(
                    icon: Icons.calendar_month,
                    value: "2026",
                    label: "Current Year",
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const _StatItem(
                    icon: Icons.emoji_events_outlined,
                    value: "3",
                    label: "Medals",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildFilterBar(HallOfFameProvider provider) {
  final filters = ['all', 'olympiad', 'tournament', 'general'];

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = provider.selectedFilter == f;

          return GestureDetector(
            onTap: () => provider.setFilter(f),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? drawerColor
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                f.toUpperCase(),
                style: TextStyle(
                  color:
                      isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );
}
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFFD700), size: 20),
        const SizedBox(height: 6),
        CustomText(
          text: value,
          size: 18,
          weight: FontWeight.w800,
          color: Colors.white,
        ),
        const SizedBox(height: 2),
        CustomText(
          text: label,
          size: 10,
          weight: FontWeight.w500,
          color: Colors.white.withOpacity(0.7),
        ),
      ],
    );
  }
}
