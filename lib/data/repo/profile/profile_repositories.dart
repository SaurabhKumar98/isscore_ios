// lib/data/repo/profile/profile_repository.dart

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/profile/profileandeditmodels.dart';

class ProfileRepository {
  final ApiClient _apiClient;
  ProfileRepository(this._apiClient);

  // ── helpers ────────────────────────────────────────────────────────────────
  void _check(dynamic raw) {
    if (raw == null) throw AppException("Empty response from server.");
    final map = raw as Map<String, dynamic>;
    if (!(map['success'] as bool? ?? false)) {
      throw AppException(
          (map['message'] as String?)?.isNotEmpty == true
              ? map['message'] as String
              : 'Request failed.');
    }
  }

  Map<String, dynamic> _data(dynamic raw) =>
      (raw as Map<String, dynamic>)['data'] as Map<String, dynamic>;

  // ── GET /user/profile ──────────────────────────────────────────────────────
  Future<ProfileModel> getProfile() async {
    try {
      final res = await _apiClient.get(ApiEndpoint.userProfile);
      _check(res.data);
      return ProfileModel.fromJson(_data(res.data));
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException("Failed to fetch profile.");
    }
  }

  // ── PUT /user/update-profile ───────────────────────────────────────────────
Future<ProfileModel> updateProfile({
  String? name,
  String? email,
  String? phone,
  String? schoolOrCollege,
  String? classOrGrade,
  File? profileImage, // ✅ ADD THIS
}) async {
  try {
    final formData = FormData.fromMap({
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (schoolOrCollege != null) 'schoolOrCollege': schoolOrCollege,
      if (classOrGrade != null) 'classOrGrade': classOrGrade,

      // ✅ IMAGE UPLOAD
      if (profileImage != null)
        'profileImage': await MultipartFile.fromFile(
          profileImage.path,
          filename: profileImage.path.split('/').last,
        ),
    });
print("IMAGE PATH: ${profileImage?.path}");
    final res = await _apiClient.put(
      ApiEndpoint.updateProfile,
      data: formData,
 isMultipart: true,    );

    _check(res.data);
    return ProfileModel.fromJson(_data(res.data));
  } on AppException {
    rethrow;
  } catch (_) {
    throw AppException("Failed to update profile.");
  }
}
  // ── PUT /user/change-password ──────────────────────────────────────────────
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final res = await _apiClient.put(
        ApiEndpoint.changePassword,
        data: {
          'oldPassword':     oldPassword,
          'newPassword':     newPassword,
          'confirmPassword': confirmPassword,
        },
      );
      _check(res.data);
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException("Failed to change password.");
    }
  }
    Future<void> deleteAccount({required String password}) async {
    try {
      final res = await _apiClient.delete(
        ApiEndpoint.deleteAccount, // add this to ApiEndpoint constants
        data: {'password': password},
      );
      _check(res.data);
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException("Failed to delete account.");
    }
  }

}