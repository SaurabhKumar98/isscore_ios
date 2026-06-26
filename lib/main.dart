import 'package:firstedu/core/localstorage/firbaseservices.dart';
import 'package:firstedu/core/navigatorkey/navigatorkey.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/data/repo/auth/authrepositories.dart';
import 'package:firstedu/data/repo/cetficatedownload/certificatedownload_repo.dart';
import 'package:firstedu/data/repo/challengeyourfriend/challengewebsocket.dart';
import 'package:firstedu/data/repo/challengeyourfriend/challengeyourfriend_repo.dart';
import 'package:firstedu/data/repo/challengeyourself/challengeyourself_repo.dart';
import 'package:firstedu/data/repo/communityr/commentrepositories.dart';
import 'package:firstedu/data/repo/communityr/communityrepositories.dart';
import 'package:firstedu/data/repo/communityr/post_repositories.dart';
import 'package:firstedu/data/repo/competetive/competetion_repo.dart';
import 'package:firstedu/data/repo/coursedownload/coursedownload_repositores.dart';
import 'package:firstedu/data/repo/coursedownload/downloadcourse.dart';
import 'package:firstedu/data/repo/dashboard/dashboardboard_repo.dart';
import 'package:firstedu/data/repo/everydaychallenge/everydaychallenge_repo.dart';
import 'package:firstedu/data/repo/examhall/examhall_repositories.dart';
import 'package:firstedu/data/repo/examhall/examsessionrepositories.dart';
import 'package:firstedu/data/repo/halloffame/halloffame_repo.dart';
import 'package:firstedu/data/repo/leaderboard/laderboard_repo.dart';
import 'package:firstedu/data/repo/livecompetetion/livecompetetion_repo.dart';
import 'package:firstedu/data/repo/livecompetetion/livecompetetionrepository.dart';
import 'package:firstedu/data/repo/mentors/call_repositories.dart';
import 'package:firstedu/data/repo/mentors/mentors_repositories.dart';
import 'package:firstedu/data/repo/merchandise/merchandise_repo.dart';
import 'package:firstedu/data/repo/needtoimprove/needtoimprove_repo.dart';
import 'package:firstedu/data/repo/notificationrepo/notificationrepo.dart';
import 'package:firstedu/data/repo/olympiad/olympiadcenter_repositories.dart';
import 'package:firstedu/data/repo/orderhistory/orderhistory_repo.dart';
import 'package:firstedu/data/repo/profile/profile_repositories.dart';
import 'package:firstedu/data/repo/refferandearn/refferandearn_repo.dart';
import 'package:firstedu/data/repo/report/report_repo.dart';
import 'package:firstedu/data/repo/resourcestore/store_repositories.dart';
import 'package:firstedu/data/repo/supportdesk/supportdesk_repo.dart';
import 'package:firstedu/data/repo/tournament/tournament_repo.dart';
import 'package:firstedu/data/repo/wallet_repo/wallet_repo.dart';
import 'package:firstedu/data/repo/workshops/workshops_repositories.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/routes/apppages.dart';
import 'package:firstedu/res/routes/approutesname.dart';
import 'package:firstedu/view_models/authprovider/authprovider.dart';
import 'package:firstedu/view_models/authprovider/forgotpassword.dart';
import 'package:firstedu/view_models/authprovider/userSessionProvider.dart';
import 'package:firstedu/view_models/certificatedownloadprovider/certificatedownload_provider.dart';
import 'package:firstedu/view_models/challengeyourgfriendprovider/challengeyourfriend_provider.dart';
import 'package:firstedu/view_models/challengeyourselfprovider/challengeyourself_provider.dart';
import 'package:firstedu/view_models/communityprvider/commentprovider.dart';
import 'package:firstedu/view_models/communityprvider/communityprovider.dart';
import 'package:firstedu/view_models/communityprvider/postforms_provider.dart';
import 'package:firstedu/view_models/competetiveprovider/competetionprovider.dart';
import 'package:firstedu/view_models/coursedownloadprovider/coursedownloadprovider.dart';
import 'package:firstedu/view_models/coursedownloadprovider/downloadprovider.dart';
import 'package:firstedu/view_models/dashboardprovider/dashboardprovider.dart';
import 'package:firstedu/view_models/everydaychallengeprovider/everydaychallengeprovider.dart';
import 'package:firstedu/view_models/examhallprovider/examhallprovider.dart';
import 'package:firstedu/view_models/examhallprovider/examhallwebsocket.dart';
import 'package:firstedu/view_models/examhallprovider/examinstrationprovider.dart';
import 'package:firstedu/view_models/examhallprovider/examsessionprovider.dart';
import 'package:firstedu/view_models/halloffameprovider/halloffame_provider.dart';
import 'package:firstedu/view_models/leaderboardprovider/leaderboard_provider.dart';
import 'package:firstedu/view_models/livecompetetionprovider/livecompetetiondetailsprovider.dart';
import 'package:firstedu/view_models/livecompetetionprovider/livecompetetionprovider.dart';
import 'package:firstedu/view_models/merchandiseprovider/merchandise_provider.dart';
import 'package:firstedu/view_models/needtoimproveprovider/needtoimprove_provider.dart';
import 'package:firstedu/view_models/notificationprovider/notificationprovider.dart';
import 'package:firstedu/view_models/olympiadprovider/olympiadcenterprovider.dart';
import 'package:firstedu/view_models/orderhistoryprovider/orderhistory_provider.dart';
import 'package:firstedu/view_models/profile_provider/profile_provider.dart';
import 'package:firstedu/view_models/refferandearnprovider/refferandearn_provider.dart';
import 'package:firstedu/view_models/report/call_report_provider.dart';
import 'package:firstedu/view_models/report/chat_report_provider.dart';
import 'package:firstedu/view_models/resourcestoreprovider/resourcestoreprovider.dart';
import 'package:firstedu/view_models/supportdesk/supportdeskprovider.dart';
import 'package:firstedu/view_models/teacherconnectprovider/agoracall_servies.dart';
import 'package:firstedu/view_models/teacherconnectprovider/callprovider.dart';
import 'package:firstedu/view_models/teacherconnectprovider/callsocket_services.dart';
import 'package:firstedu/view_models/teacherconnectprovider/chatprovider.dart';
import 'package:firstedu/view_models/teacherconnectprovider/chatsocket_services.dart';
import 'package:firstedu/view_models/teacherconnectprovider/mentors_provider.dart';
import 'package:firstedu/view_models/tournamentprovider/tournament_provider.dart';
import 'package:firstedu/view_models/wallet_provider/wallet_provider.dart';
import 'package:firstedu/view_models/workshopprovider/workshopsprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initMessaging();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(create: (_) => ApiClient()),
        Provider<AuthRepository>(
          create: (context) => AuthRepository(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider<UserSessionProvider>(
          create: (_) => UserSessionProvider(),
        ),

        ChangeNotifierProvider<Authprovider>(
          create: (context) => Authprovider(context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider<ForgotPasswordProvider>(
          create: (context) =>
              ForgotPasswordProvider(context.read<AuthRepository>()),
        ),
        Provider<StoreRepository>(
          create: (context) => StoreRepository(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider<StoreProvider>(
          create: (context) => StoreProvider(context.read<StoreRepository>()),
        ),
        Provider<ReportRepository>(
          create: (context) =>
              ReportRepository(apiClient: context.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ChatReportProvider(repo: context.read<ReportRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              CallReportProvider(repo: context.read<ReportRepository>()),
        ),
        Provider<PostRepositories>(
          create: (context) => PostRepositories(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider<PostProvider>(
          create: (context) =>
              PostProvider(PostRepositories(context.read<ApiClient>())),
        ),
        Provider<CommunityRepository>(
          create: (context) => CommunityRepository(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              CommunityProvider(CommunityRepository(context.read<ApiClient>())),
        ),
        Provider<CommentRepository>(
          create: (context) => CommentRepository(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              CommentProvider(CommentRepository(context.read<ApiClient>())),
        ),
        Provider<ProfileRepository>(
          create: (context) => ProfileRepository(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ProfileProvider(ProfileRepository(context.read<ApiClient>())),
        ),
        Provider<MentorsRepositories>(
          create: (context) => MentorsRepositories(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              MentorsProvider(MentorsRepositories(context.read<ApiClient>())),
        ),
        Provider<WorkshopRepository>(
          create: (context) => WorkshopRepository(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              WorkshopProvider(WorkshopRepository(context.read<ApiClient>())),
        ),
        ChangeNotifierProvider(
          create: (context) => DownloadCourseProvider(
            DownloadCourseRepositories(context.read<ApiClient>()),
          ),
        ),

        Provider<OlympiadCenterRepositories>(
          create: (context) =>
              OlympiadCenterRepositories(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (context) => OlympiadProvider(
            OlympiadCenterRepositories(context.read<ApiClient>()),
          ),
        ),
        Provider<ExamHallRepository>(
          create: (context) => ExamHallRepository(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ExamHallProvider(ExamHallRepository(context.read<ApiClient>())),
        ),
        Provider<ExamSocketService>(create: (_) => ExamSocketService()),
        Provider<ExamSessionRepository>(
          create: (context) => ExamSessionRepository(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (context) => ExamSessionProvider(
            context.read<ExamSessionRepository>(),
            context.read<ExamSocketService>(),
          ),
        ),
        Provider<WalletRepository>(
          create: (context) => WalletRepository(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (context) => WalletProvider(context.read<WalletRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              CompetitionProvider(context.read<CompetitionRepository>()),
        ),
        Provider<MerchandiseRepository>(
          create: (context) => MerchandiseRepository(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              MerchandiseProvider(context.read<MerchandiseRepository>()),
        ),

        ChangeNotifierProvider(
          create: (ctx) =>
              SupportDeskProvider(SupportDeskRepository(ctx.read<ApiClient>())),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              HallOfFameProvider(HallOfFameRepositories(ctx.read<ApiClient>())),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              OrderhistoryProvider(OrderhistoryRepo(ctx.read<ApiClient>())),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CourseDownloadProvider(
            CourseDownloadRepository(ctx.read<ApiClient>()),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              LeaderboardProvider(LeaderboardRepository(ctx.read<ApiClient>())),
        ),
        ChangeNotifierProvider(
          create: (context) => TournamentProvider(
            TournamentRepository(context.read<ApiClient>()),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => Everydaychallengeprovider(
            EverydaychallengeRepo(context.read<ApiClient>()),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CertificateDownloadProvider(
            CertificatedownloadRepo(context.read<ApiClient>()),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CompetitionProvider(
            CompetitionRepository(context.read<ApiClient>()),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ChallengeYourselfProvider(
            ChallengeYourselfRepository(context.read<ApiClient>()),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => NeedToImproveProvider(
            NeedToImproveRepo(context.read<ApiClient>()),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ReferAndEarnProvider(ReferAndEarnRepo(context.read<ApiClient>())),
        ),
        ChangeNotifierProvider(
          create: (context) => ChallengeProvider(
            ChallengeRepo(context.read<ApiClient>()),
            ChallengeSocketService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              DashboardProvider(DashBoardRepo(context.read<ApiClient>())),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              NotificationProvider(NotificationRepo(context.read<ApiClient>())),
        ),
        Provider<ChatSocketService>(create: (_) => ChatSocketService()),

        ChangeNotifierProxyProvider<ChatSocketService, ChatProvider>(
          create: (context) => ChatProvider(context.read<ChatSocketService>()),
          update: (context, socketService, previous) =>
              previous ?? ChatProvider(socketService),
        ),
        ChangeNotifierProvider(
          create: (context) => LiveCompetitionDrawerProvider(
            LiveCompetitionDrawerRepository(context.read<ApiClient>()),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => LiveCompetitionProvider(
            LiveCompetitionRepository(context.read<ApiClient>()),
          ),
        ),

        ChangeNotifierProvider(create: (_) => Examinstrationprovider()),
        ChangeNotifierProvider(
          create: (context) => CallProvider(
            CallRepository(context.read<ApiClient>()),
            CallSocketService(),
            AgoraCallService(),
          ),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(411.42857142857144, 867.4285714285714),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            initialRoute: AppRoutesName.splash,
            routes: AppPages.routes,
            title: 'FirstEdu - Education App',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: drawerColor,
                primary: drawerColor,
                secondary: primaryButtonColor,
                surface: containerColor,
              ),
              textTheme: GoogleFonts.poppinsTextTheme().copyWith(
                titleLarge: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: drawerColor,
                ),
                bodyMedium: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryButtonColor,
                  foregroundColor: Colors.white,
                  textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  foregroundColor: drawerColor,
                  side: const BorderSide(color: drawerColor),
                  textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              cardTheme: CardThemeData(
                color: containerColor,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              drawerTheme: const DrawerThemeData(backgroundColor: drawerColor),
              appBarTheme: AppBarTheme(
                backgroundColor: drawerColor,
                foregroundColor: Colors.white,
                titleTextStyle: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
