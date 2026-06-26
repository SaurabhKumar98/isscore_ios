import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/localstorage/devicesinfo.dart';
import 'package:firstedu/core/localstorage/localstorage.dart';
import 'package:firstedu/core/navigatorkey/navigatorkey.dart';
import 'package:firstedu/data/models/api_models/auth/signupmodels.dart';
import 'package:firstedu/data/repo/auth/authrepositories.dart';
import 'package:firstedu/res/routes/approutesname.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view_models/authprovider/userSessionProvider.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class Authprovider extends ChangeNotifier {
  final AuthRepository _authRepository;

  Authprovider(this._authRepository);

  // ─────────────────── SHARED STATE ───────────────────

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // ─────────────────── REGISTER STATE ─────────────────

  bool _isRegisterLoading = false;
  bool get isRegisterLoading => _isRegisterLoading;

  SignupModel? _signupResponse;
  SignupModel? get signupResponse => _signupResponse;

  void _setRegisterLoading(bool value) {
    _isRegisterLoading = value;
    notifyListeners();
  }

  // ─────────────────── LOGIN STATE ────────────────────

  bool _isLoginLoading = false;
  bool get isLoginLoading => _isLoginLoading;

  void _setLoginLoading(bool value) {
    _isLoginLoading = value;
    notifyListeners();
  }

  // ─────────────────── PHONE LOGIN STATE ──────────────────────────

  bool _isSendOtpLoading = false;
  bool get isSendOtpLoading => _isSendOtpLoading;

  bool _isVerifyOtpLoading = false;
  bool get isVerifyOtpLoading => _isVerifyOtpLoading;

  bool _otpSent = false;
  bool get otpSent => _otpSent;

  void _setSendOtpLoading(bool value) {
    _isSendOtpLoading = value;
    notifyListeners();
  }

  void _setVerifyOtpLoading(bool value) {
    _isVerifyOtpLoading = value;
    notifyListeners();
  }

  void resetOtpState() {
    _otpSent = false;
    _isSendOtpLoading = false;
    _isVerifyOtpLoading = false;
    notifyListeners();
  }

  // ─────────────────── SEND LOGIN OTP ─────────────────────────────

  Future<bool> sendLoginOtp(
    BuildContext context, {
    required String phone,
  }) async {
    try {
      _setSendOtpLoading(true);
      clearError();

      await _authRepository.sendLoginOtp(phone: phone);

      _otpSent = true;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      if (context.mounted) {
        AppToast.error(
          context,
          title: "Failed to Send OTP",
          message: e.message,
        );
      }
      return false;
    } catch (e) {
      const friendly = "Something went wrong. Please try again.";
      _setError(friendly);
      if (context.mounted) {
        AppToast.error(context, title: "Error", message: friendly);
      }
      return false;
    } finally {
      _setSendOtpLoading(false);
    }
  }

  // ─────────────────── VERIFY LOGIN OTP ───────────────────────────

  Future<bool> verifyLoginOtp(
    BuildContext context, {
    required String phone,
    required String otp,
  }) async {
    try {
      _setVerifyOtpLoading(true);
      clearError();

      final String? fcmToken =
          await FirebaseMessaging.instance.getToken() ??
          await UserLocalStorage.getFcmToken();

      final String deviceId = await DeviceInfo.getDeviceId();

      final model = await _authRepository.verifyLoginOtp(
        phone: phone,
        otp: otp,
        fcmToken: fcmToken,
        deviceId: deviceId,
      );

      final payload = model.loginPayload;
      final user = payload?.user;
      final accessToken = payload?.accessToken;

      if (payload == null || user == null || accessToken == null) {
        throw AppException(
          "Login failed. Incomplete data received from server.",
        );
      }

      // ✅ Save all available user fields including email & profileImage
      await UserLocalStorage.saveUser(
        userId: user.id ?? '',
        name: user.name ?? '',
        phone: user.phone ?? '',
        accessToken: accessToken,
        email: user.email,
        profileImage: user.profileImage,
      );

      await UserLocalStorage.setOtpVerified(true);
      await UserLocalStorage.setPasswordSet(true);

      if (context.mounted) {
        context.read<ApiClient>().setAccessToken(accessToken);
      }

      if (context.mounted) {
        context.read<UserSessionProvider>().setSession(
          userId: user.id ?? '',
          fullname: user.name ?? '',
          phone: user.phone ?? '',
          accessToken: accessToken,
          isOtpVerified: true,
          isPasswordSet: true,
        );
      }

      return true;
    } on AppException catch (e) {
      _setError(e.message);
      if (context.mounted) {
        AppToast.error(
          context,
          title: "Verification Failed",
          message: e.message,
        );
      }
      return false;
    } catch (e, stack) {
      debugPrint("❌ VERIFY OTP ERROR: $e\n$stack");
      const friendly = "Something went wrong. Please try again.";
      _setError(friendly);
      if (context.mounted) {
        AppToast.error(context, title: "Error", message: friendly);
      }
      return false;
    } finally {
      _setVerifyOtpLoading(false);
    }
  }

  // ─────────────────── REGISTER ───────────────────────

  Future<bool> register(
    BuildContext context, {
    required String email,
    required String password,
    required String name,
    required String schoolOrCollege,
    required String classOrGrade,
    required String phone,
    String? referralCode,
    File? profileImage,
  }) async {
    try {
      _setRegisterLoading(true);
      clearError();

      final body = <String, dynamic>{
        "email": email,
        "password": password,
        "name": name,
        "schoolOrCollege": schoolOrCollege,
        "classOrGrade": classOrGrade,
        "phone": phone,
      };

      if (referralCode != null) body["referralCode"] = referralCode;

      final response = await _authRepository.register(
        body: body,
        profileImage: profileImage,
      );

      if (response.success) {
        _signupResponse = response;
        return true;
      } else {
        _setError(response.message);
        if (context.mounted) {
          AppToast.error(
            context,
            title: "Registration Failed",
            message: response.message,
          );
        }
        return false;
      }
    } on AppException catch (e) {
      _setError(e.message);
      if (context.mounted) {
        AppToast.error(
          context,
          title: "Registration Failed",
          message: e.message,
        );
      }
      return false;
    } catch (e, stack) {
      debugPrint("❌ REGISTER ERROR: $e\n$stack");
      const friendly = "Something went wrong. Please try again.";
      _setError(friendly);
      if (context.mounted) {
        AppToast.error(context, title: "Unexpected Error", message: friendly);
      }
      return false;
    } finally {
      _setRegisterLoading(false);
    }
  }

  // ─────────────────── LOGIN ──────────────────────────

  Future<bool> login(
    BuildContext context, {
    required String email,
    required String password,
    bool forceLogin = false,
  }) async {
    try {
      _setLoginLoading(true);
      clearError();

      final String? fcmToken =
          await FirebaseMessaging.instance.getToken() ??
          await UserLocalStorage.getFcmToken();

      final String deviceId = await DeviceInfo.getDeviceId();

      final loginModel = await _authRepository.login(
        email: email,
        password: password,
        forceLogin: forceLogin,
        fcmToken: fcmToken,
        deviceId: deviceId,
      );

      final payload = loginModel.loginPayload;

      // 🚨 Handle already logged in elsewhere
      if (payload?.alreadyLoggedInElsewhere == true && !forceLogin) {
        _setLoginLoading(false);
        if (context.mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              _showForceLoginDialog(context, email: email, password: password);
            }
          });
        }
        return false;
      }

      final user = payload?.user;
      final accessToken = payload?.accessToken;

      if (payload == null || user == null || accessToken == null) {
        throw AppException(
          "Login failed. Incomplete data received from server.",
        );
      }

      await UserLocalStorage.saveUser(
        userId: user.id ?? '',
        name: user.name ?? '',
        phone: user.phone ?? '',
        accessToken: accessToken,
        email: user.email,
        profileImage: user.profileImage,
      );

      await UserLocalStorage.setOtpVerified(true);
      await UserLocalStorage.setPasswordSet(true);

      if (context.mounted) {
        context.read<ApiClient>().setAccessToken(accessToken);
      }

      if (context.mounted) {
        context.read<UserSessionProvider>().setSession(
          userId: user.id ?? '',
          fullname: user.name ?? '',
          phone: user.phone ?? '',
          accessToken: accessToken,
          isOtpVerified: true,
          isPasswordSet: true,
        );
      }

      return true;
    } on AppException catch (e) {
      _setError(e.message);
      if (context.mounted) {
        AppToast.error(context, title: "Login Failed", message: e.message);
      }
      return false;
    } catch (e, stack) {
      debugPrint("❌ LOGIN ERROR: $e\n$stack");
      const friendly = "Something went wrong. Please try again.";
      _setError(friendly);
      if (context.mounted) {
        AppToast.error(context, title: "Login Failed", message: friendly);
      }
      return false;
    } finally {
      _setLoginLoading(false);
    }
  }

  void _showForceLoginDialog(
    BuildContext context, {
    required String email,
    required String password,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Icon(
                  Icons.devices_rounded,
                  color: Colors.orange.shade700,
                  size: 36.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "Already Logged In",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.orange.shade700,
                      size: 20.sp,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        "Your account is currently active on another device. "
                        "Logging in here will automatically log out the other device.",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.orange.shade900,
                          height: 1.5,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final success = await login(
                          context,
                          email: email,
                          password: password,
                          forceLogin: true,
                        );
                        if (success) {
                          navigatorKey.currentState?.pushNamedAndRemoveUntil(
                            AppRoutesName.entry,
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Login Here",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    try {
      await _authRepository.logout();
    } catch (e) {
      debugPrint('⚠️ Logout API failed (ignored): $e');
    }

    await UserLocalStorage.clearUser();

    if (context.mounted) {
      context.read<ApiClient>().clearToken();
    }

    if (context.mounted) {
      context.read<UserSessionProvider>().clearSession(context);
    }

    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutesName.login,
      (route) => false,
    );
  }

  // ─────────────────── RESET ──────────────────────────

  void reset() {
    _isRegisterLoading = false;
    _isLoginLoading = false;
    _isSendOtpLoading = false;
    _isVerifyOtpLoading = false;
    _otpSent = false;
    _errorMessage = '';
    _signupResponse = null;
    notifyListeners();
  }
}
