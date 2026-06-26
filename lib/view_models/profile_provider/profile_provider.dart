
import 'dart:io';

import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/profile/profileandeditmodels.dart';
import 'package:firstedu/data/repo/profile/profile_repositories.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repo;
  ProfileProvider(this._repo);

  // ── State ──────────────────────────────────────────────────────────────────
  ProfileModel? _profile;
  ProfileModel? get profile => _profile;

  bool _isLoading    = false;
  bool _isUpdating   = false;
  bool _isChangingPw = false;

  bool get isLoading    => _isLoading;
  bool get isUpdating   => _isUpdating;
  bool get isChangingPw => _isChangingPw;

  String _error = '';
  String get error => _error;

  bool get hasProfile => _profile != null;
  bool _isDeleting     = false; 
bool get isDeleting   => _isDeleting;
  // ── Fetch profile ──────────────────────────────────────────────────────────
  Future<void> fetchProfile(BuildContext ctx) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      _profile = await _repo.getProfile();
    } on AppException catch (e) {
      _error = e.message;
      if (ctx.mounted) AppToast.error(ctx, title: "Error", message: e.message);
    } catch (_) {
      _error = "Something went wrong.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Update profile — returns true on success ───────────────────────────────
  Future<bool> updateProfile(
    BuildContext ctx, {
    String? name,
    String? email,
    String? phone,
    String? schoolOrCollege,
    String? classOrGrade,
      File? profileImage,
  }) async {
    _isUpdating = true;
    notifyListeners();
    try {
      _profile = await _repo.updateProfile(
        name:            name,
        email:           email,
        phone:           phone,
        schoolOrCollege: schoolOrCollege,
        classOrGrade:    classOrGrade,
        profileImage: profileImage
      );
      if (ctx.mounted) {
        AppToast.success(ctx, title: "Saved", message: "Profile updated successfully.");
      }
      return true;
    } on AppException catch (e) {
      if (ctx.mounted) AppToast.error(ctx, title: "Update Failed", message: e.message);
      return false;
    } catch (_) {
      if (ctx.mounted) {
        AppToast.error(ctx, title: "Error", message: "Something went wrong.");
      }
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // ── Change password — returns true on success ──────────────────────────────
  Future<bool> changePassword(
    BuildContext ctx, {
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isChangingPw = true;
    notifyListeners();
    try {
      await _repo.changePassword(
        oldPassword:     oldPassword,
        newPassword:     newPassword,
        confirmPassword: confirmPassword,
      );
      if (ctx.mounted) {
        AppToast.success(ctx,
            title: "Done", message: "Password changed successfully.");
      }
      return true;
    } on AppException catch (e) {
      if (ctx.mounted) AppToast.error(ctx, title: "Failed", message: e.message);
      return false;
    } catch (_) {
      if (ctx.mounted) {
        AppToast.error(ctx, title: "Error", message: "Something went wrong.");
      }
      return false;
    } finally {
      _isChangingPw = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount(
    BuildContext ctx, {
    required String password,
  }) async {
    _isDeleting = true;
    notifyListeners();
    try {
      await _repo.deleteAccount(password: password);
      if (ctx.mounted) {
        AppToast.successGlobal(message: "Account deleted successfully.");
      }
      return true;
    } on AppException catch (e) {
      if (ctx.mounted) {
        AppToast.error(ctx, title: "Failed", message: e.message);
      }
      return false;
    } catch (_) {
      if (ctx.mounted) {
        AppToast.error(ctx, title: "Error", message: "Something went wrong.");
      }
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  // ── Local optimistic update (e.g. after edit screen pops) ─────────────────
  void updateLocal(ProfileModel updated) {
    _profile = updated;
    notifyListeners();
  }

  void reset() {
    _profile     = null;
    _isLoading   = false;
    _isUpdating  = false;
    _isChangingPw = false;
    _error       = '';
    _isDeleting   = false;
    notifyListeners();
  }
}