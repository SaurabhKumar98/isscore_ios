import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/data/models/api_models/auth/loginmdels.dart';
import 'package:firstedu/data/models/api_models/auth/otpverifymodels.dart';
import 'package:firstedu/data/models/api_models/auth/phoneloginmodels.dart';
import 'package:firstedu/data/models/api_models/auth/requestoptmodels.dart';
import 'package:firstedu/data/models/api_models/auth/resetpasswordmodels.dart';
import 'package:firstedu/data/models/api_models/auth/sendotpmodels.dart';
import 'package:firstedu/data/models/api_models/auth/signupmodels.dart';
import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/res/constants/configs/buildmultipart.dart';
import 'package:flutter/foundation.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);


  Future<SignupModel> register({
    required Map<String, Object?> body,
    File? profileImage,
  }) async {
    try {
      Response response;

      if (profileImage != null) {
        response = await _apiClient.post(
          ApiEndpoint.signup,
          data: buildMultipart(body, {"profileImage": profileImage}),
          isMultipart: true,
        );
      } else {
        response = await _apiClient.post(ApiEndpoint.signup, data: body);
      }

      if (response.data == null) {
        throw AppException("Empty response from server.");
      }

      final signupModel = SignupModel.fromJson(response.data);

      if (!signupModel.success) {
        throw AppException(signupModel.message);
      }

      return signupModel;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException("Something went wrong. Please try again.");
    }
  }


Future<LoginModel> login({
  required String email,
  required String password,
  String? fcmToken,
  bool forceLogin = false,
  String? deviceId,
}) async {
  try {
    final body = {
      "email": email,
      "password": password,
      if (fcmToken != null && fcmToken.isNotEmpty) "fcmToken": fcmToken,
      if (deviceId != null) "deviceId": deviceId,
      if (forceLogin) "forceLogin": true,
    };

    final response = await _apiClient.post(
      ApiEndpoint.login,
      data: body,
    );

    if (response.data == null) {
      throw AppException("Server returned an empty response. Please try again.");
    }

    final loginModel = LoginModel.fromJson(
      response.data as Map<String, dynamic>,
    );

    if (!loginModel.success) {
      throw AppException(
        loginModel.message.isNotEmpty
            ? loginModel.message
            : "Login failed. Please check your credentials and try again.",
      );
    }
    final isAlreadyElsewhere =
        loginModel.loginPayload?.alreadyLoggedInElsewhere == true;

    if (!isAlreadyElsewhere) {
      final token = loginModel.loginPayload?.accessToken;
      if (token == null || token.isEmpty) {
        throw AppException(
          "Login succeeded but no token was received. Please try again.",
        );
      }
    }

    return loginModel;
  } on AppException {
    rethrow;
  } catch (_) {
    throw AppException("An unexpected error occurred. Please try again.");
  }
}



Future<SendOtpModel> sendLoginOtp({required String phone}) async {
  try {
    final response = await _apiClient.post(
      ApiEndpoint.sendLoginOtp,
      data: {"phone": phone},
    );

    if (response.data == null) {
      throw AppException("Server returned an empty response.");
    }

    final model = SendOtpModel.fromJson(response.data as Map<String, dynamic>);

    if (!model.success) {
      throw AppException(
        model.message.isNotEmpty ? model.message : "Failed to send OTP.",
      );
    }

    return model;
  } on AppException {
    rethrow;
  } catch (_) {
    throw AppException("Something went wrong. Please try again.");
  }
}


Future<PhoneLoginModel> verifyLoginOtp({
  required String phone,
  required String otp,
  String? fcmToken,
  String? deviceId,
}) async {
  try {
    final body = {
      "phone": phone,
      "otp": otp,
      if (fcmToken != null && fcmToken.isNotEmpty) "fcmToken": fcmToken,
      if (deviceId != null) "deviceId": deviceId,
    };

    final response = await _apiClient.post(
      ApiEndpoint.verifyLoginOtp,
      data: body,
    );

    if (response.data == null) {
      throw AppException("Server returned an empty response.");
    }

    final model = PhoneLoginModel.fromJson(
      response.data as Map<String, dynamic>,
    );

    if (!model.success) {
      throw AppException(
        model.message.isNotEmpty
            ? model.message
            : "OTP verification failed.",
      );
    }

    return model;
  } on AppException {
    rethrow;
  } catch (_) {
    throw AppException("An unexpected error occurred. Please try again.");
  }
}
 
 
  Future<OtpRequestModel> requestOtp({
    required String email,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoint.requestotp,
        data: {"email": email},
      );

      if (response.data == null) {
        throw AppException("Server returned an empty response. Please try again.");
      }

      final model = OtpRequestModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!model.success) {
        throw AppException(
          model.message.isNotEmpty
              ? model.message
              : "Failed to send OTP. Please try again.",
        );
      }

      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException("Something went wrong. Please try again.");
    }
  }


  Future<OtpVerifyModel> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoint.verifyOtp,
        data: {"email": email, "otp": otp},
      );

      if (response.data == null) {
        throw AppException("Server returned an empty response. Please try again.");
      }

      final model = OtpVerifyModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!model.success) {
        throw AppException(
          model.message.isNotEmpty
              ? model.message
              : "OTP verification failed. Please check the code and try again.",
        );
      }

      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException("Something went wrong. Please try again.");
    }
  }


  Future<ResetPasswordModel> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoint.resetPassword,
        data: {
          "email": email,
          "otp": otp,
          "newPassword": newPassword,
          "confirmPassword": confirmPassword,
        },
      );

      if (response.data == null) {
        throw AppException("Server returned an empty response. Please try again.");
      }

      final model = ResetPasswordModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!model.success) {
        throw AppException(
          model.message.isNotEmpty
              ? model.message
              : "Password reset failed. Please try again.",
        );
      }

      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException("Something went wrong. Please try again.");
    }
  }


Future<void> logout() async {
  try {
    final response = await _apiClient.post(
      ApiEndpoint.logout,
      data: {},
    );

    if (kDebugMode) {
      debugPrint('✅ Logout response: ${response.data}');
    }
  } on AppException {
    rethrow;
  } catch (_) {
    // Silently fail — logout should always succeed locally
  }
}
}