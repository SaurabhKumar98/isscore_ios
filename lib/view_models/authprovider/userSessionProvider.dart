import 'package:firstedu/core/localstorage/localstorage.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/res/routes/approutesname.dart';
import 'package:firstedu/view_models/authprovider/authprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserSessionProvider extends ChangeNotifier {
  bool isLoggedIn = false;
  bool isOtpVerified = false;
  bool isPasswordSet = false;
  bool hydrated = false;

  String? userId;
  String? fullname;
  String? phone;
  String? accessToken;

  bool get hasValidSession =>
      isLoggedIn && userId != null && userId!.isNotEmpty;

  Future<void> hydrate(BuildContext context) async {
    isLoggedIn = await UserLocalStorage.isLoggedIn();
    isOtpVerified = await UserLocalStorage.isOtpVerified();
    isPasswordSet = await UserLocalStorage.isPasswordSet();

    phone = await UserLocalStorage.getUserPhone();
    userId = await UserLocalStorage.getUserId();
    fullname = await UserLocalStorage.getUserName();
    accessToken = await UserLocalStorage.getAccessToken();

    if (accessToken != null && accessToken!.isNotEmpty) {
      context.read<ApiClient>().setAccessToken(accessToken);
      ApiEndpoint.cachedToken = accessToken;
    }

    hydrated = true;
    notifyListeners();
  }

  void setSession({
    required String userId,
    required String fullname,
    required String phone,
    required String accessToken,
    required bool isOtpVerified,
    required bool isPasswordSet,
  }) {
    this.userId = userId;
    this.fullname = fullname;
    this.phone = phone;
    this.accessToken = accessToken;

    isLoggedIn = true;
    this.isOtpVerified = isOtpVerified;
    this.isPasswordSet = isPasswordSet;

    notifyListeners();
  }

  void markOtpVerified() {
    isOtpVerified = true;
    notifyListeners();
  }

  void markPasswordSet() {
    isPasswordSet = true;
    notifyListeners();
  }

  Future<void> clearSession(BuildContext context) async {
    await UserLocalStorage.clearUser();

    isLoggedIn = false;
    isOtpVerified = false;
    isPasswordSet = false;
    hydrated = true;

    userId = null;
    fullname = null;
    phone = null;
    accessToken = null;
    final api = context.read<ApiClient>();
    api.clearToken();

    _clearDependentProviders(context);
    notifyListeners();
  }

  void resetSession() {
    isLoggedIn = false;
    isOtpVerified = false;
    isPasswordSet = false;
    hydrated = true;

    userId = null;
    fullname = null;
    phone = null;
    accessToken = null;

    notifyListeners();
  }

  void _clearDependentProviders(BuildContext context) {
    context.read<Authprovider>().reset();
  }

  String get initialRoute {
    if (!isLoggedIn) return AppRoutesName.login;
    // if (!isOtpVerified) return AppRoutes.otpPath;
    // if (!isPasswordSet) return AppRoutes.createPasswordPath;
    return AppRoutesName.entry;
  }
}
