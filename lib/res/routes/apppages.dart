import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/data/repo/coursedownload/coursedownload_repositores.dart';
import 'package:firstedu/data/repo/coursedownload/downloadcourse.dart';
import 'package:firstedu/view/auth_screen/loginscreen.dart';
import 'package:firstedu/view/auth_screen/otpscreen.dart';
import 'package:firstedu/view/auth_screen/signupscreen.dart';
import 'package:firstedu/view/auth_screen/splashscreen.dart';
import 'package:firstedu/view/challenge_view/challenge_screen.dart';
import 'package:firstedu/view/challenge_view/gamechallengemode.dart';
import 'package:firstedu/view/competetive/competetion_screen.dart';
import 'package:firstedu/view/courses/coursedetailbyid.dart';
import 'package:firstedu/view/courses/coursesscreen.dart';
import 'package:firstedu/view/download_view/download_screen.dart';
import 'package:firstedu/view/event_view/event_screen.dart';
import 'package:firstedu/view/everydaychallenge_view/everydaychallenge_screen.dart';
import 'package:firstedu/view/halloffame_view/hall_of_fame_screen.dart';
import 'package:firstedu/view/indexscreen/certificatedownload_screen.dart';
import 'package:firstedu/view/indexscreen/communityscreen/communityscreen.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/examhallscreen.dart';
import 'package:firstedu/view/indexscreen/leaderboard_view/leaderboard_screen.dart';
import 'package:firstedu/view/indexscreen/profile_view/profilescreen.dart';
import 'package:firstedu/view/indexscreen/store_view/storescreen.dart';
import 'package:firstedu/view/livecompetetionscreen/livecompetetion_screen.dart';
import 'package:firstedu/view/livecompetetionscreen/livecompetetiondetailsscreen.dart';
import 'package:firstedu/view/merchandise_store_view/merchandise_store_screen.dart';
import 'package:firstedu/view/needtoimprove_view/personalise_learningscreen.dart';
import 'package:firstedu/view/orderhistory_view/orderhistory_screen.dart';
import 'package:firstedu/view/report_screen/call_report_list_screen.dart';
import 'package:firstedu/view/report_screen/chat_report_list_screen.dart';
import 'package:firstedu/view/report_screen/report_hubscreen.dart';
import 'package:firstedu/view/supportdesk_view/supportdeskscreen.dart';
import 'package:firstedu/view/teacher_connect/teacher_connect_screen.dart';
import 'package:firstedu/view/tournaments_view/tournaments_screen.dart';
import 'package:firstedu/view/wallet_view/wallet_screen.dart';
import 'package:firstedu/view/workshop_view/workshop_screen.dart';
import 'package:firstedu/view_models/coursedownloadprovider/coursedownloadprovider.dart';
import 'package:firstedu/view_models/coursedownloadprovider/downloadprovider.dart';
import 'package:flutter/material.dart';
import 'package:firstedu/view/indexscreen/entryscreen.dart';
import 'package:firstedu/view/olympaid_view/olympiad_screen.dart';
import 'package:provider/provider.dart';
import 'approutesname.dart';

class AppPages {
  static final Map<String, WidgetBuilder> routes = {
    // Auth Routes
    AppRoutesName.splash: (context) => const SplashScreen(),
    AppRoutesName.login: (context) => const LoginScreen(),
    AppRoutesName.signup: (context) => const SignUpScreen(),

    // Main Routes
    AppRoutesName.entry: (context) => const EntryScreen(),
    AppRoutesName.olympiads: (context) => const OlympiadScreen(),
    AppRoutesName.tournaments: (context) => const TournamentScreen(),
    AppRoutesName.event: (context) => const EventsScreen(),
    AppRoutesName.challenges: (context) => const ChallengeScreen(),
    AppRoutesName.merchandise: (context) => const MerchandiseStoreScreen(),
    AppRoutesName.teacher: (context) => const TeacherConnectScreen(),
    AppRoutesName.wallets: (context) => const WalletScreen(),
    AppRoutesName.workshop: (context) => const RegisteredWorkshopScreen(),
    AppRoutesName.community: (context) => const CommunityScreen(),
    AppRoutesName.hall: (context) => const HallOfFameScreen(),
    AppRoutesName.exam: (context) => const ExamHallScreen(),
    AppRoutesName.store: (context) => const StoreScreen(),
    AppRoutesName.gamestore: (context) => const GameModeScreen(),
    AppRoutesName.download: (context) => ChangeNotifierProvider(
      create: (context) => DownloadCourseProvider(
        DownloadCourseRepositories(context.read<ApiClient>()),
      )..fetchDownloads(context),
      child: const DownloadsScreen(),
    ),
    AppRoutesName.improve: (context) => const PersonalizedLearningScreen(),
    AppRoutesName.support: (context) => const SupportDeskScreen(),
    AppRoutesName.orderhistory: (context) => const OrderHistoryScreen(),
    AppRoutesName.leaderboard: (context) => const LeaderboardsScreen(),
    AppRoutesName.profile: (context) => const ProfileScreen(),
    AppRoutesName.everydaychallenge: (context) => const DailyChallengesScreen(),
    AppRoutesName.challengeyourself: (context) => const GameModeScreen(),
    AppRoutesName.otp: (context) => const ForgotPasswordScreen(),
    AppRoutesName.certificate: (context) => const CertificatesEarnedScreen(),
    AppRoutesName.competitionDetail: (context) =>
        const CompetitionScreen(rootType: "Competitive"),
    AppRoutesName.school: (context) =>
        CompetitionScreen(rootType: RootType.school),
    AppRoutesName.skilldevelopment: (context) =>
        const CompetitionScreen(rootType: RootType.skillDevelopment),
    AppRoutesName.coursedetail: (context) => const CourseDetailsScreen(),
    AppRoutesName.chatReport: (context) => const ChatReportListScreen(),

    AppRoutesName.callReport: (context) => const CallReportListScreen(),
    // ── Live Competition Routes ──────────────────────────────────────────
    // List screen (no arguments needed)
    AppRoutesName.liveCompetitionscreen: (context) =>
        const LiveCompetitionsScreen(),

    // Detail screen (receives competitionId as argument)
    AppRoutesName.liveCompetitionDetail: (context) {
      final competitionId =
          ModalRoute.of(context)!.settings.arguments as String;
      return LiveCompetitionDetailScreen(competitionId: competitionId);
    },

    // ────────────────────────────────────────────────────────────────────
    AppRoutesName.courses: (context) => ChangeNotifierProvider(
      create: (context) => CourseDownloadProvider(
        CourseDownloadRepository(context.read<ApiClient>()),
      ),
      child: const CoursesScreen(),
    ),
  };
}

class RootType {
  static const competitive = "Competitive";
  static const school = "School";
  static const skillDevelopment =
      "Skill Development"; // ✅ space, correct casing
}
