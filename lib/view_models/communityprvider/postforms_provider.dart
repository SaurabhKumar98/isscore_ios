import 'dart:io';
import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/community_models/newdisscussionmodels.dart';
import 'package:firstedu/data/repo/communityr/post_repositories.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

class PostProvider extends ChangeNotifier {
  final PostRepositories _repository;

  PostProvider(this._repository);

  // ─────────── STATE ───────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  PostModels? _postResult;
  PostModels? get postResult => _postResult;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // ─────────── HELPERS ───────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // ─────────── POST DISCUSSION ───────────

  Future<bool> postDiscussion(
    BuildContext context, {
    required String title,
    required String description,
    required String topic,
    required List<String> tags,   // with # e.g. ["#flutter", "#dart"]
    File? attachment,
  }) async {
    try {
      _setLoading(true);
      clearError();

      final result = await _repository.postDiscussion(
        title: title,
        description: description,
        topic: topic,
        tags: tags,
        attachment: attachment,
      );

      _postResult = result;
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      if (context.mounted) {
        AppToast.error(context, title: "Post Failed", message: e.message);
      }
      return false;
    } catch (_) {
      const msg = "Something went wrong. Please try again.";
      _setError(msg);
      if (context.mounted) {
        AppToast.error(context, title: "Error", message: msg);
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────── UPDATE DISCUSSION ───────────

  Future<bool> updateDiscussion(
    BuildContext context, {
    required String postId,
    required String title,
    required String description,
    required String topic,
    required List<String> tags,   // with # e.g. ["#flutter", "#dart"]
    File? attachment,
  }) async {
    try {
      _setLoading(true);
      clearError();

      await _repository.updateDiscussion(
        postId: postId,
        title: title,
        description: description,
        topic: topic,
        tags: tags,
        attachment: attachment,
      );

      return true;
    } on AppException catch (e) {
      _setError(e.message);
      if (context.mounted) {
        AppToast.error(context, title: "Update Failed", message: e.message);
      }
      return false;
    } catch (_) {
      const msg = "Something went wrong. Please try again.";
      _setError(msg);
      if (context.mounted) {
        AppToast.error(context, title: "Error", message: msg);
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────── RESET ───────────

  void reset() {
    _isLoading = false;
    _postResult = null;
    _errorMessage = '';
    notifyListeners();
  }
}