// import 'package:firstedu/core/localstorage/localstorage.dart';
// import 'package:firstedu/core/network/api_client.dart';
// import 'package:firstedu/core/navigatorkey/navigatorkey.dart';
// import 'package:firstedu/res/routes/approutesname.dart';
// import 'package:firstedu/utils/apptoster/errortoaster.dart';
// import 'package:firstedu/view_models/authprovider/authprovider.dart';
// import 'package:firstedu/view_models/authprovider/userSessionProvider.dart';
// import 'package:firstedu/view_models/dashboardprovider/dashboardprovider.dart';
// import 'package:firstedu/view_models/profile_provider/profile_provider.dart';
// import 'package:firstedu/view_models/refferandearnprovider/refferandearn_provider.dart';
// import 'package:firstedu/view_models/wallet_provider/wallet_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// /// ─────────────────────────────────────────────────────────────────────────────
// /// AppResetProvider
// ///
// /// The single logout orchestrator. Call [logout] from:
// ///   • The Sign Out button in ProfileScreen
// ///   • The 401 interceptor in ApiClient (via navigatorKey.currentContext)
// ///   • Anywhere else that needs to force a full session reset
// ///
// /// What it does (in order):
// ///   1. Calls the backend logout API (via Authprovider, fire-and-forget)
// ///   2. Clears SharedPreferences
// ///   3. Clears the Dio auth token
// ///   4. Calls reset() on every provider that holds user-specific state
// ///   5. Navigates to login, removing all routes
// /// ─────────────────────────────────────────────────────────────────────────────
// class AppResetProvider extends ChangeNotifier {
//   bool _isLoggingOut = false;
//   bool get isLoggingOut => _isLoggingOut;

//   /// Main logout — call this from anywhere in the app.
//   Future<void> logout(BuildContext context) async {
//     if (_isLoggingOut) return; // guard against double-calls (e.g. 401 + button tap)
//     _isLoggingOut = true;
//     notifyListeners();

//     try {
//       // ── 1. Backend logout (fire-and-forget — don't block UX on API failure) ──
//       try {
//         await context.read<Authprovider>().logout(context);
//       } catch (e) {
//         debugPrint('⚠️ Backend logout failed (ignored): $e');
//       }

//       // ── 2. Clear local storage ──────────────────────────────────────────────
//       await UserLocalStorage.clearUser();

//       // ── 3. Clear Dio token ──────────────────────────────────────────────────
//       if (context.mounted) {
//         context.read<ApiClient>().clearToken();
//       }

//       // ── 4. Reset all providers ──────────────────────────────────────────────
//       if (context.mounted) {
//         _resetAllProviders(context);
//       }
//     } catch (e) {
//       debugPrint('⚠️ AppResetProvider.logout error: $e');
//     } finally {
//       _isLoggingOut = false;
//       notifyListeners();

//       // ── 5. Navigate to login (always — even if something above failed) ──────
//       navigatorKey.currentState?.pushNamedAndRemoveUntil(
//         AppRoutesName.login,
//         (route) => false,
//       );
//     }
//   }

//   /// Called from the 401 interceptor where we have no BuildContext.
//   /// Uses navigatorKey.currentContext so it goes through the same flow.
//   Future<void> logoutFromInterceptor(String? serverMessage) async {
//     final ctx = navigatorKey.currentContext;
//     if (ctx == null) return;

//     AppToast.errorGlobal(
//       title: "Session Expired",
//       message: serverMessage ?? "Please log in again.",
//     );

//     await logout(ctx);
//   }

//   /// ── Add a reset() call here for every provider that holds user state. ──────
//   /// Each provider must expose a reset() method that nulls its data and
//   /// sets loading to false, then calls notifyListeners().
//   void _resetAllProviders(BuildContext context) {
//     context.read<Authprovider>().reset();
//     context.read<UserSessionProvider>().resetSession();
//     context.read<DashboardProvider>().reset();
//     context.read<ProfileProvider>().reset();
//     // context.read<HallOfFameProvider>().;
//     context.read<WalletProvider>().cleanup();
//     context.read<ReferAndEarnProvider>().reset();

//     // ✅ Add more providers here as your app grows:
//     // context.read<LeaderboardProvider>().reset();
//     // context.read<NotificationProvider>().reset();
//     // context.read<CertificateDownloadProvider>().reset();
//   }
// }