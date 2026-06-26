import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/repo/auth/authrepositories.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  ForgotPasswordProvider(this._authRepository);

  // ─────────────────── STATE ───────────────────────────

  bool _isRequestOtpLoading = false;
  bool get isRequestOtpLoading => _isRequestOtpLoading;

  bool _isVerifyOtpLoading = false;
  bool get isVerifyOtpLoading => _isVerifyOtpLoading;

  bool _isResetPasswordLoading = false;
  bool get isResetPasswordLoading => _isResetPasswordLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // ─────────────────── HELPERS ─────────────────────────

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // ─────────────────── STEP 1 — Request OTP ────────────

  Future<bool> requestOtp(BuildContext context, {required String email}) async {
    try {
      _isRequestOtpLoading = true;
      clearError();
      notifyListeners();

      await _authRepository.requestOtp(email: email);

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
    } catch (e, stack) {
      debugPrint("❌ REQUEST OTP ERROR: $e\n$stack");
      const friendly = "Something went wrong. Please try again.";
      _setError(friendly);
      if (context.mounted) {
        AppToast.error(context, title: "Error", message: friendly);
      }
      return false;
    } finally {
      _isRequestOtpLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────── STEP 2 — Verify OTP ─────────────

  Future<bool> verifyOtp(
    BuildContext context, {
    required String email,
    required String otp,
  }) async {
    try {
      _isVerifyOtpLoading = true;
      clearError();
      notifyListeners();

      await _authRepository.verifyOtp(email: email, otp: otp);

      return true;
    } on AppException catch (e) {
      _setError(e.message);
      if (context.mounted) {
        AppToast.error(
          context,
          title: "OTP Verification Failed",
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
      _isVerifyOtpLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────── STEP 3 — Reset Password ─────────

  Future<bool> resetPassword(
    BuildContext context, {
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      _isResetPasswordLoading = true;
      clearError();
      notifyListeners();

      await _authRepository.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      return true;
    } on AppException catch (e) {
      _setError(e.message);
      if (context.mounted) {
        AppToast.error(
          context,
          title: "Password Reset Failed",
          message: e.message,
        );
      }
      return false;
    } catch (e, stack) {
      debugPrint("❌ RESET PASSWORD ERROR: $e\n$stack");
      const friendly = "Something went wrong. Please try again.";
      _setError(friendly);
      if (context.mounted) {
        AppToast.error(context, title: "Error", message: friendly);
      }
      return false;
    } finally {
      _isResetPasswordLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────── RESET ───────────────────────────

  void reset() {
    _isRequestOtpLoading = false;
    _isVerifyOtpLoading = false;
    _isResetPasswordLoading = false;
    _errorMessage = '';
    notifyListeners();
  }
}
