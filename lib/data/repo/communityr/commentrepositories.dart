
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/community_models/commentauthor.dart';

class CommentRepository {
  final ApiClient _apiClient;
  CommentRepository(this._apiClient);

  List<PostComment> _parseComments(dynamic data) =>
      ((data?['comments'] as List?) ?? [])
          .map((e) => PostComment.fromJson(e))
          .toList();

  List<dynamic> _parseLikes(dynamic data) => (data?['likes'] as List?) ?? [];

  Future<Map<String, dynamic>> _postEmpty(String url) async {
    final res = await _apiClient.post(url);
    _check(res.data);
    return res.data['data'] as Map<String, dynamic>;
  }

  void _check(dynamic raw) {
    if (raw == null) throw AppException("Empty response.");
    final map = raw as Map<String, dynamic>;
    if (!(map['success'] as bool? ?? false))
      throw AppException(map['message'] ?? 'Request failed.');
  }

  Future<List<PostComment>> addComment(
      {required String postId, required String content}) async {
    try {
      final res = await _apiClient.post('${ApiEndpoint.appBaseUrl}/forums/$postId/comments',
          data: {'content': content});
      _check(res.data);
      return _parseComments(res.data['data']);
    } on AppException { rethrow; }
    catch (_) { throw AppException("Something went wrong."); }
  }

  Future<List<PostComment>> addReply(
      {required String postId, required String commentId,
       required String content}) async {
    try {
      final res = await _apiClient.post(
          '${ApiEndpoint.appBaseUrl}/forums/$postId/comments/$commentId/replies',
          data: {'content': content});
      _check(res.data);
      return _parseComments(res.data['data']);
    } on AppException { rethrow; }
    catch (_) { throw AppException("Something went wrong."); }
  }

  Future<void> deleteComment(
      {required String postId, required String commentId}) async {
    try {
      final res = await _apiClient.delete(
          '${ApiEndpoint.appBaseUrl}/forums/$postId/comments/$commentId');
      _check(res.data);
    } on AppException { rethrow; }
    catch (_) { throw AppException("Could not delete comment."); }
  }

  Future<void> deleteReply(
      {required String postId, required String commentId,
       required String replyId}) async {
    try {
      final res = await _apiClient.delete(
          '${ApiEndpoint.appBaseUrl}/forums/$postId/comments/$commentId/replies/$replyId');
      _check(res.data);
    } on AppException { rethrow; }
    catch (_) { throw AppException("Could not delete reply."); }
  }

  Future<void> deleteForum({required String postId}) async {
    try {
      final res = await _apiClient.delete('${ApiEndpoint.appBaseUrl}/forums/$postId');
      _check(res.data);
    } on AppException { rethrow; }
    catch (_) { throw AppException("Could not delete post."); }
  }

  Future<void> updateForum({
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
        'tags':        tags,
        if (attachment != null)
          'attachment': await MultipartFile.fromFile(attachment.path),
      });
      final res = await _apiClient.put('${ApiEndpoint.appBaseUrl}/forums/$postId', data: formData);
      _check(res.data);
    } on AppException { rethrow; }
    catch (_) { throw AppException("Could not update post."); }
  }

  Future<List<dynamic>> toggleForumLike({required String postId}) async {
    try {
      final data = await _postEmpty('${ApiEndpoint.appBaseUrl}/forums/$postId/like');
      return _parseLikes(data);
    } on AppException { rethrow; }
    catch (_) { throw AppException("Something went wrong."); }
  }

  Future<List<PostComment>> toggleCommentLike(
      {required String postId, required String commentId}) async {
    try {
      final data = await _postEmpty(
          '${ApiEndpoint.appBaseUrl}/forums/$postId/comments/$commentId/like');
      return _parseComments(data);
    } on AppException { rethrow; }
    catch (_) { throw AppException("Something went wrong."); }
  }

  Future<List<PostComment>> toggleReplyLike(
      {required String postId, required String commentId,
       required String replyId}) async {
    try {
      final data = await _postEmpty(
          '${ApiEndpoint.appBaseUrl}/forums/$postId/comments/$commentId/replies/$replyId/like');
      return _parseComments(data);
    } on AppException { rethrow; }
    catch (_) { throw AppException("Something went wrong."); }
  }
}