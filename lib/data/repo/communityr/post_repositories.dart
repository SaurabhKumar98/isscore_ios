import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/community_models/newdisscussionmodels.dart';

class PostRepositories {
  final ApiClient _apiClient;

  PostRepositories(this._apiClient);

  String _buildTags(List<String> tags) => tags.join(',');

  Future<PostModels> postDiscussion({
    required String title,
    required String description,
    required String topic,
    required List<String> tags,
    File? attachment,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title':       title,
        'description': description,
        'topic':       topic,
        'tags':        _buildTags(tags),   
        if (attachment != null)
          'attachment': await MultipartFile.fromFile(
            attachment.path,
            filename: attachment.path.split('/').last,
          ),
      });

      final response = await _apiClient.post(
        ApiEndpoint.userForums,   
        data: formData,
      );

      if (response.data == null) {
        throw AppException("Server returned empty response.");
      }

      final model = PostModels.fromJson(response.data as Map<String, dynamic>);

      if (!model.success) {
        throw AppException(model.message ?? "Failed to post discussion.");
      }

      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException("Something went wrong. Please try again.");
    }
  }

  Future<void> updateDiscussion({
    required String postId,
    required String title,
    required String description,
    required String topic,
    required List<String> tags,
    File? attachment,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title':       title,
        'description': description,
        'topic':       topic,
        'tags':        _buildTags(tags),   
        if (attachment != null)
          'attachment': await MultipartFile.fromFile(
            attachment.path,
            filename: attachment.path.split('/').last,
          ),
      });

      final response = await _apiClient.put(
        '${ApiEndpoint.userForums}/$postId',  // /user/forums/:postId
        data: formData,
      );

      if (response.data == null) {
        throw AppException("Server returned empty response.");
      }

      final raw = response.data as Map<String, dynamic>;
      final success = raw['success'] as bool? ?? false;
      if (!success) {
        throw AppException(raw['message'] as String? ?? "Failed to update discussion.");
      }
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException("Something went wrong. Please try again.");
    }
  }
}