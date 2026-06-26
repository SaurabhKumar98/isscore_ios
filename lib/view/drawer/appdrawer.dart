import 'package:firstedu/data/models/drawermodel.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/routes/approutesname.dart';
import 'package:firstedu/view/drawer/drawermenulist.dart';
import 'package:firstedu/view_models/livecompetetionprovider/livecompetetionprovider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatefulWidget {
  final void Function(int index)? onTabSwitch;
  final Map<String, int>? routeToTabIndex;

  const AppDrawer({
    super.key,
    this.onTabSwitch,
    this.routeToTabIndex,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  int _expandedIndex = -1;

  // index 10 in the updated drawermenulist — the "Events" item
  static const int _eventsIndex = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LiveCompetitionDrawerProvider>().fetchLiveCompetitions(
            context,
          );
    });
  }

  void _navigate(BuildContext context, String route) {
    final tabIndex = widget.routeToTabIndex?[route];
    if (tabIndex != null && widget.onTabSwitch != null) {
      widget.onTabSwitch!(tabIndex);
    } else {
      Navigator.pop(context);
      Navigator.pushNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      backgroundColor: drawerBgColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              _header(),
              const SizedBox(height: 24),

              ...List.generate(drawerMenuItems.length, (index) {
                final item = drawerMenuItems[index];
                final isExpanded = _expandedIndex == index;
                final isActive = currentRoute == item.route || isExpanded;

                final bool isEventsItem = index == _eventsIndex;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 300 + index * 60),
                      tween: Tween(begin: 0, end: 1),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(-20 * (1 - value), 0),
                            child: child,
                          ),
                        );
                      },
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            if (item.hasArrow || isEventsItem) {
                              setState(() {
                                _expandedIndex = isExpanded ? -1 : index;
                              });
                            } else if (item.route != null) {
                              _navigate(context, item.route!);
                            }
                          },
                          child: _drawerItem(
                            icon: item.icon,
                            title: item.title,
                            isActive: isActive,
                            hasArrow: item.hasArrow || isEventsItem,
                            isExpanded: isExpanded,
                          ),
                        ),
                      ),
                    ),

                    // ── Events sub-menu (index 10) ───────────────────────
                    if (isEventsItem && isExpanded)
                      _EventsSubMenu(currentRoute: currentRoute),

                    // ── Static sub-items (Courses, Gamification, etc.) ───
                    if (!isEventsItem &&
                        item.subItems != null &&
                        item.subItems!.isNotEmpty &&
                        isExpanded)
                      Padding(
                        padding: const EdgeInsets.only(left: 48, bottom: 8),
                        child: Column(
                          children: item.subItems!.map((sub) {
                            final bool isSubActive = currentRoute == sub.route;
                            return _staticSubItem(sub, isSubActive, context);
                          }).toList(),
                        ),
                      ),
                  ],
                );
              }),

              const SizedBox(height: 16),

              // ── My Profile (always last) ─────────────────────────────
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    if (widget.onTabSwitch != null) {
                      widget.onTabSwitch!(4);
                    } else {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/profile");
                    }
                  },
                  child: _drawerItem(
                    icon: Icons.person_outline,
                    title: "My Profile",
                    isActive: currentRoute == "/profile",
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _staticSubItem(
    DrawerSubItem sub,
    bool isSubActive,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSubActive
            ? Colors.white.withOpacity(0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white.withOpacity(0.15),
          highlightColor: Colors.white.withOpacity(0.08),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(
              context,
              sub.route,
              arguments: sub.arguments,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(sub.icon, size: 18, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  sub.title,
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: activeItemColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              "I",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          "iScorre.",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required bool isActive,
    bool hasArrow = false,
    bool isExpanded = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? activeItemColor : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          color: isActive ? Colors.white : inactiveTextColor,
          size: 22,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : inactiveTextColor,
          ),
        ),
        trailing: hasArrow
            ? Icon(
                isExpanded ? Icons.keyboard_arrow_down : Icons.chevron_right,
                color: inactiveTextColor,
              )
            : null,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EVENTS SUB-MENU
// ═══════════════════════════════════════════════════════════════════════════

class _EventsSubMenu extends StatelessWidget {
  final String? currentRoute;

  const _EventsSubMenu({this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveCompetitionDrawerProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.only(left: 48, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Static "Live Competitions" entry ───────────────────────
              _subItem(
                context: context,
                icon: Icons.live_tv_outlined,
                title: "Live Competitions",
                isActive: currentRoute == AppRoutesName.liveCompetitionscreen,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    AppRoutesName.liveCompetitionscreen,
                  );
                },
              ),

              // ── Static "Workshop" entry ────────────────────────────────
              _subItem(
                context: context,
                icon: Icons.school_outlined,
                title: "Workshop",
                isActive: currentRoute == AppRoutesName.workshop,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutesName.workshop);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _subItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white.withOpacity(0.15),
          highlightColor: Colors.white.withOpacity(0.08),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 18, color: Colors.white70),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}