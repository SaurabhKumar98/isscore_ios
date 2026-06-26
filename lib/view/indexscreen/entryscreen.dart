import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/routes/approutesname.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view/drawer/appdrawer.dart';
import 'package:firstedu/view/indexscreen/communityscreen/communityscreen.dart';
import 'package:firstedu/view/indexscreen/dashboardscreen.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/examhallscreen.dart';
import 'package:firstedu/view/indexscreen/profile_view/profilescreen.dart';
import 'package:firstedu/view/indexscreen/store_view/storescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EntryScreen extends StatefulWidget {
  final int initialIndex;
  const EntryScreen({super.key, this.initialIndex = 0});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late final List<Widget> _pages;
  DateTime? _lastBackPressed;

  // Routes that map directly to bottom nav tab indexes instead of pushing new screens
  // index 0 = Dashboard, 1 = Store, 2 = ExamHall, 3 = Community, 4 = Profile
  late final Map<String, int> _routeToTabIndex = {
    '/dashboard': 0,
    AppRoutesName.store: 1,
    AppRoutesName.exam: 2,       // ← Exam Hall drawer tap → FAB tab (index 2)
    AppRoutesName.community: 3,  // ← Community drawer tap → tab (index 3)
    '/profile': 4,
  };

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _pages = [
      DashboardScreen(onMenuTap: () => scaffoldKey.currentState?.openDrawer()),
      const StoreScreen(),
      const ExamHallScreen(),
      const CommunityScreen(),
      const ProfileScreen(),
    ];
  }

  /// Called by AppDrawer to switch bottom bar tabs
  void _switchTab(int index) {
    setState(() => _currentIndex = index);
    scaffoldKey.currentState?.closeDrawer();
  }

  final List<int> _navIndexes = const [0, 1, 3, 4];

  final List<IconData> _icons = const [
    Icons.home_rounded,
    Icons.storefront_outlined,
    Icons.groups_outlined,
    Icons.person_outline,
  ];

  final List<String> _labels = const ["Home", "Store", "Community", "Profile"];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();

        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          _lastBackPressed = now;
          AppToast.infoGlobal(message: "Press again to exit");
          return false;
        }

        return true;
      },
      child: Scaffold(
        key: scaffoldKey,
        drawer: AppDrawer(
          onTabSwitch: _switchTab,
          routeToTabIndex: _routeToTabIndex,
        ),
        backgroundColor: const Color(0xFFF6F7FB),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              _pages[_currentIndex],

              /// Floating Bottom Bar
              Positioned(
                left: 12.w,
                right: 12.w,
                bottom: 16.h,
                child: _floatingBottomBar(),
              ),

              /// Center Exam FAB
              Positioned(bottom: 36.h, child: _examFab()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _floatingBottomBar() {
    return Container(
      height: 68.h,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_navItem(0), _navItem(1)],
            ),
          ),
          SizedBox(width: 56.w),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_navItem(2), _navItem(3)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(int visualIndex) {
    final pageIndex = _navIndexes[visualIndex];
    final isActive = _currentIndex == pageIndex;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = pageIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive
              ? accentOrange.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icons[visualIndex],
              size: 22.sp,
              color: isActive ? accentOrange : Colors.grey,
            ),
            SizedBox(height: 4.h),
            Text(
              _labels[visualIndex],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? accentOrange : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _examFab() {
    final isActive = _currentIndex == 2;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 64.w,
        width: 64.w,
        decoration: BoxDecoration(
          color: isActive ? accentOrange : drawerColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Icon(
          Icons.assignment_outlined,
          size: 28.sp,
          color: Colors.white,
        ),
      ),
    );
  }
}