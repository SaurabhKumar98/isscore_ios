import 'package:firstedu/data/models/drawermodel.dart';
import 'package:firstedu/res/routes/approutesname.dart';
import 'package:flutter/material.dart';

final drawerMenuItems = [
  DrawerItemModel(
    // index 0
    title: "Dashboard",
    icon: Icons.dashboard_rounded,
    route: "/dashboard",
  ),
  DrawerItemModel(
    // index 1
    title: "Resource Store",
    icon: Icons.storefront_outlined,
    route: AppRoutesName.store,
  ),
  DrawerItemModel(
    // index 2
    title: "Exam Hall",
    icon: Icons.description_outlined,
    route: AppRoutesName.exam,
  ),
  DrawerItemModel(
    // index 3
    title: "Courses",
    icon: Icons.menu_book,
    hasArrow: true,
    subItems: [
      DrawerSubItem(
        title: "General Courses",
        icon: Icons.emoji_events,
        route: AppRoutesName.courses,
        arguments: false,
      ),
      DrawerSubItem(
        title: "Certification Courses",
        icon: Icons.flag_outlined,
        route: AppRoutesName.courses,
        arguments: true,
      ),
    ],
  ),
  DrawerItemModel(
    // index 4
    title: "Download",
    icon: Icons.download,
    route: AppRoutesName.download,
  ),
  DrawerItemModel(
    // index 5
    title: "Competitive",
    icon: Icons.emoji_events,
    route: AppRoutesName.competitionDetail,
  ),
  DrawerItemModel(
    // index 6
    title: "School",
    icon: Icons.school,
    route: AppRoutesName.school,
  ),
  DrawerItemModel(
    // index 7
    title: "Skill - development",
    icon: Icons.description_outlined,
    route: AppRoutesName.skilldevelopment,
  ),
  DrawerItemModel(
    // index 8
    title: "Olympiads",
    icon: Icons.emoji_events,
    route: AppRoutesName.olympiads,
  ),
  DrawerItemModel(
    // index 9
    title: "Gamification",
    icon: Icons.sports_esports,
    hasArrow: true,
    subItems: [
      DrawerSubItem(
        title: "Tournaments",
        icon: Icons.flag_outlined,
        route: AppRoutesName.tournaments,
      ),
      DrawerSubItem(
        title: "Challenge Yourself",
        icon: Icons.groups_outlined,
        route: AppRoutesName.challengeyourself,
      ),
      DrawerSubItem(
        title: "Challenge Your Friends",
        icon: Icons.emoji_events,
        route: AppRoutesName.challenges,
      ),
      DrawerSubItem(
        title: "Everyday Challenges",
        icon: Icons.sunny,
        route: AppRoutesName.everydaychallenge,
      ),
    ],
  ),
  DrawerItemModel(
    // index 10 ← _eventsIndex (do NOT insert anything before this item —
    // app_drawer.dart hardcodes this position)
    title: "Events",
    icon: Icons.event_rounded,
    hasArrow: true,
    // subItems is intentionally null — built dynamically via _EventsSubMenu
    // showing "Live Competitions" first, then "Workshop"
  ),
  DrawerItemModel(
    // index 11
    title: "Community",
    icon: Icons.groups_outlined,
    route: AppRoutesName.community,
  ),
  DrawerItemModel(
    // index 12
    title: "Teacher Connect",
    icon: Icons.support_agent_outlined,
    route: "/teacher",
  ),
 DrawerItemModel(
  title: "Reports",
  icon: Icons.assessment_outlined,
  hasArrow: true,
  subItems: [
    DrawerSubItem(
      title: "Chat Report",
      icon: Icons.chat_bubble_outline,
      route: AppRoutesName.chatReport,
    ),
    DrawerSubItem(
      title: "Call Report",
      icon: Icons.call_outlined,
      route: AppRoutesName.callReport,
    ),
  ],
),
  DrawerItemModel(
    // index 14
    title: "LeaderBoards",
    icon: Icons.leaderboard,
    route: AppRoutesName.leaderboard,
  ),
  DrawerItemModel(
    // index 15
    title: "Need To Improve",
    icon: Icons.trending_up,
    route: "/improve",
  ),
  DrawerItemModel(
    // index 16
    title: "Hall of Fame",
    icon: Icons.military_tech_outlined,
    route: AppRoutesName.hall,
  ),
  DrawerItemModel(
    // index 17
    title: "Cetificates",
    icon: Icons.workspace_premium,
    route: AppRoutesName.certificate,
  ),
  DrawerItemModel(
    // index 18
    title: "Wallet",
    icon: Icons.account_balance_wallet_outlined,
    route: "/wallet",
  ),
  DrawerItemModel(
    // index 19
    title: "Order History",
    icon: Icons.history,
    route: AppRoutesName.orderhistory,
  ),
  DrawerItemModel(
    // index 20
    title: "Merchandise Store",
    icon: Icons.shopping_cart_outlined,
    route: AppRoutesName.merchandise,
  ),
  DrawerItemModel(
    // index 21
    title: "Support Desk",
    icon: Icons.support,
    route: AppRoutesName.support,
  ),
];