import 'package:shared_preferences/shared_preferences.dart';

class UserLocalStorage {
  static const _keyUserId       = 'user_id';
  static const _keyUserName     = 'user_name';
  static const _keyPhone        = 'user_phone';
  static const _keyEmail        = 'user_email';
  static const _keyProfileImage = 'user_profile_image';
  static const _keyAccessToken  = "access_token";
  static const _keyIsOtpVerified = "otp_verified";
  static const _keyIsPasswordSet = "password_set";
  static const _keyFcmToken     = "fcm_token";

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  static Future<void> saveUser({
    required String userId,
    required String name,
    required String phone,
    required String accessToken,
    String? email,
    String? profileImage,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(_keyUserId,      userId);
    await prefs.setString(_keyUserName,    name);
    await prefs.setString(_keyPhone,       phone);
    await prefs.setString(_keyAccessToken, accessToken);
    if (email        != null) await prefs.setString(_keyEmail,        email);
    if (profileImage != null) await prefs.setString(_keyProfileImage, profileImage);
  }

  static Future<void> setOtpVerified(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyIsOtpVerified, value);
  }

  static Future<void> setPasswordSet(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyIsPasswordSet, value);
  }

  static Future<String?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getString(_keyUserId);
  }

  static Future<String?> getUserName() async {
    final prefs = await _prefs;
    return prefs.getString(_keyUserName);
  }

  static Future<String?> getUserPhone() async {
    final prefs = await _prefs;
    return prefs.getString(_keyPhone);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await _prefs;
    return prefs.getString(_keyEmail);
  }

  static Future<String?> getProfileImage() async {
    final prefs = await _prefs;
    return prefs.getString(_keyProfileImage);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await _prefs;
    return prefs.getString(_keyAccessToken);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.containsKey(_keyUserId);
  }

  static Future<bool> isOtpVerified() async {
    final prefs = await _prefs;
    return prefs.containsKey(_keyIsOtpVerified);
  }

  static Future<bool> isPasswordSet() async {
    final prefs = await _prefs;
    return prefs.containsKey(_keyIsPasswordSet);
  }

  static Future<void> saveFcmToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_keyFcmToken, token);
  }

  static Future<String?> getFcmToken() async {
    final prefs = await _prefs;
    return prefs.getString(_keyFcmToken);
  }

  static Future<void> clearUser() async {
    final prefs = await _prefs;
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyProfileImage);
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyIsOtpVerified);
    await prefs.remove(_keyIsPasswordSet);
    await prefs.remove(_keyFcmToken);
  }
}