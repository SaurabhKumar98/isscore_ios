import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/community_models/commentauthor.dart';
import 'package:firstedu/data/repo/communityr/commentrepositories.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

class CommentProvider extends ChangeNotifier {
  final CommentRepository _repo;
  CommentProvider(this._repo);

  // ── Per-post comment lists ────────────────────────────────────────────────
  final Map<String, List<PostComment>> _comments = {};
  List<PostComment> commentsFor(String postId) => _comments[postId] ?? [];

  // ── Per-post forum like state (optimistic)  ───────────────────────────────
  final Map<String, List<dynamic>> _forumLikes = {};
  List<dynamic> forumLikesFor(String postId) => _forumLikes[postId] ?? [];

  // ── Submitting / liking / deleting in-flight tracking ────────────────────
  final Set<String> _submitting = {}; // postId
  final Set<String> _likingForum = {}; // postId
  final Set<String> _likingComment = {}; // commentId
  final Set<String> _likingReply = {}; // replyId
  final Set<String> _deletingComment = {}; // commentId
  final Set<String> _deletingReply = {}; // replyId
  final Set<String> _deletingForum = {}; // postId

  bool isSubmitting(String postId) => _submitting.contains(postId);
  bool isLikingForum(String postId) => _likingForum.contains(postId);
  bool isLikingComment(String cid) => _likingComment.contains(cid);
  bool isLikingReply(String rid) => _likingReply.contains(rid);
  bool isDeletingComment(String cid) => _deletingComment.contains(cid);
  bool isDeletingReply(String rid) => _deletingReply.contains(rid);
  bool isDeletingForum(String postId) => _deletingForum.contains(postId);

  // ── Seed from post list API ───────────────────────────────────────────────
  void seedComments(String postId, List<PostComment> comments) {
    if (!_comments.containsKey(postId)) {
      _comments[postId] = List.from(comments);
      notifyListeners();
    }
  }

  /// Seeds forum likes from the API.
  /// Always overwrites UNLESS a like toggle is currently in-flight for this post
  /// (to avoid overwriting an optimistic update mid-request).
  void seedForumLikes(String postId, List<dynamic> likes) {
    // Don't overwrite while the user is actively toggling this like
    if (_likingForum.contains(postId)) return;
    _forumLikes[postId] = List.from(likes);
    // Only notify if this post is visible (avoid unnecessary rebuilds during init)
    notifyListeners();
  }

  // ── Add comment ───────────────────────────────────────────────────────────
  Future<bool> addComment(
    BuildContext ctx, {
    required String postId,
    required String content,
  }) async {
    if (content.trim().isEmpty) return false;
    _submitting.add(postId);
    notifyListeners();
    try {
      _comments[postId] = await _repo.addComment(
        postId: postId,
        content: content.trim(),
      );
      return true;
    } on AppException catch (e) {
      if (ctx.mounted) AppToast.error(ctx, title: "Failed", message: e.message);
      return false;
    } finally {
      _submitting.remove(postId);
      notifyListeners();
    }
  }

  // ── Add reply ─────────────────────────────────────────────────────────────
  Future<bool> addReply(
    BuildContext ctx, {
    required String postId,
    required String commentId,
    required String content,
  }) async {
    if (content.trim().isEmpty) return false;
    _submitting.add(postId);
    notifyListeners();
    try {
      _comments[postId] = await _repo.addReply(
        postId: postId,
        commentId: commentId,
        content: content.trim(),
      );
      return true;
    } on AppException catch (e) {
      if (ctx.mounted) AppToast.error(ctx, title: "Failed", message: e.message);
      return false;
    } finally {
      _submitting.remove(postId);
      notifyListeners();
    }
  }

  // ── Delete comment ────────────────────────────────────────────────────────
  Future<bool> deleteComment(
    BuildContext ctx, {
    required String postId,
    required String commentId,
  }) async {
    if (_deletingComment.contains(commentId)) return false;
    _deletingComment.add(commentId);
    // Optimistic removal
    final prev = _comments[postId] != null
        ? List<PostComment>.from(_comments[postId]!)
        : null;
    _comments[postId]?.removeWhere((c) => c.id == commentId);
    notifyListeners();
    try {
      await _repo.deleteComment(postId: postId, commentId: commentId);
      return true;
   } on AppException catch (e) {

  // ✅ If already deleted → KEEP IT REMOVED
  if (e.message.toLowerCase().contains("already")) {
    return true;
  }

  // ❌ Only revert for real errors
  if (prev != null) _comments[postId] = prev;

  if (ctx.mounted) {
    AppToast.error(ctx, title: "Failed", message: e.message);
  }

  return false;
} finally {
      _deletingComment.remove(commentId);
      notifyListeners();
    }
  }

  // ── Delete reply ──────────────────────────────────────────────────────────
  Future<bool> deleteReply(
    BuildContext ctx, {
    required String postId,
    required String commentId,
    required String replyId,
  }) async {
    if (_deletingReply.contains(replyId)) return false;
    _deletingReply.add(replyId);
    // Optimistic removal
    final comments = _comments[postId];
    final prevComments = comments != null
        ? List<PostComment>.from(comments)
        : null;
    if (comments != null) {
      final ci = comments.indexWhere((c) => c.id == commentId);
      if (ci != -1) {
        final c = comments[ci];
        final newReplies = List<CommentReply>.from(c.replies)
          ..removeWhere((r) => r.id == replyId);
        comments[ci] = PostComment(
          id: c.id,
          content: c.content,
          author: c.author,
          likes: c.likes,
          replies: newReplies,
          createdAt: c.createdAt,
        );
      }
    }
    notifyListeners();
    try {
      await _repo.deleteReply(
        postId: postId,
        commentId: commentId,
        replyId: replyId,
      );
      return true;
    } on AppException catch (e) {
      if (prevComments != null) _comments[postId] = prevComments;
      if (ctx.mounted) AppToast.error(ctx, title: "Failed", message: e.message);
      return false;
    } finally {
      _deletingReply.remove(replyId);
      notifyListeners();
    }
  }

  // ── Delete forum post ─────────────────────────────────────────────────────
  Future<bool> deleteForum(BuildContext ctx, {required String postId}) async {
    if (_deletingForum.contains(postId)) return false;
    _deletingForum.add(postId);
    notifyListeners();
    try {
      await _repo.deleteForum(postId: postId);
      // Clean up local state
      _comments.remove(postId);
      _forumLikes.remove(postId);
      return true;
    } on AppException catch (e) {
      if (ctx.mounted) AppToast.error(ctx, title: "Failed", message: e.message);
      return false;
    } finally {
      _deletingForum.remove(postId);
      notifyListeners();
    }
  }

  // ── Toggle forum like ─────────────────────────────────────────────────────
  Future<void> toggleForumLike(
    BuildContext ctx, {
    required String postId,
    required String currentUserId,
    List<dynamic>? seedLikes,
  }) async {
    if (_likingForum.contains(postId)) return;

    // Ensure seeded before optimistic update
    if (!_forumLikes.containsKey(postId) && seedLikes != null) {
      _forumLikes[postId] = List.from(seedLikes);
    }

    // Optimistic update
    final current = List<dynamic>.from(_forumLikes[postId] ?? []);
    final wasLiked = current.contains(currentUserId);
    _forumLikes[postId] = wasLiked
        ? (current..remove(currentUserId))
        : (current..add(currentUserId));
    _likingForum.add(postId);
    notifyListeners();

    try {
      final updated = await _repo.toggleForumLike(postId: postId);
      _forumLikes[postId] = updated;
    } on AppException catch (e) {
      _forumLikes[postId] = current;
      if (ctx.mounted) AppToast.error(ctx, title: "Failed", message: e.message);
    } finally {
      _likingForum.remove(postId);
      notifyListeners();
    }
  }

  // ── Toggle comment like ───────────────────────────────────────────────────
  Future<void> toggleCommentLike(
    BuildContext ctx, {
    required String postId,
    required String commentId,
    required String currentUserId,
  }) async {
    if (_likingComment.contains(commentId)) return;

    _optimisticCommentLike(postId, commentId, currentUserId);
    _likingComment.add(commentId);
    notifyListeners();

    try {
      _comments[postId] = await _repo.toggleCommentLike(
        postId: postId,
        commentId: commentId,
      );
    } on AppException catch (e) {
      _optimisticCommentLike(postId, commentId, currentUserId);
      if (ctx.mounted) AppToast.error(ctx, title: "Failed", message: e.message);
    } finally {
      _likingComment.remove(commentId);
      notifyListeners();
    }
  }

  void _optimisticCommentLike(String postId, String commentId, String uid) {
    final comments = _comments[postId];
    if (comments == null) return;
    final idx = comments.indexWhere((c) => c.id == commentId);
    if (idx == -1) return;
    final c = comments[idx];
    final likes = List<dynamic>.from(c.likes);
    likes.contains(uid) ? likes.remove(uid) : likes.add(uid);
    comments[idx] = PostComment(
      id: c.id,
      content: c.content,
      author: c.author,
      likes: likes,
      replies: c.replies,
      createdAt: c.createdAt,
    );
  }

  // ── Toggle reply like ─────────────────────────────────────────────────────
  Future<void> toggleReplyLike(
    BuildContext ctx, {
    required String postId,
    required String commentId,
    required String replyId,
    required String currentUserId,
  }) async {
    if (_likingReply.contains(replyId)) return;

    _optimisticReplyLike(postId, commentId, replyId, currentUserId);
    _likingReply.add(replyId);
    notifyListeners();

    try {
      _comments[postId] = await _repo.toggleReplyLike(
        postId: postId,
        commentId: commentId,
        replyId: replyId,
      );
    } on AppException catch (e) {
      _optimisticReplyLike(postId, commentId, replyId, currentUserId);
      if (ctx.mounted) AppToast.error(ctx, title: "Failed", message: e.message);
    } finally {
      _likingReply.remove(replyId);
      notifyListeners();
    }
  }

  void _optimisticReplyLike(
    String postId,
    String commentId,
    String replyId,
    String uid,
  ) {
    final comments = _comments[postId];
    if (comments == null) return;
    final ci = comments.indexWhere((c) => c.id == commentId);
    if (ci == -1) return;
    final c = comments[ci];
    final ri = c.replies.indexWhere((r) => r.id == replyId);
    if (ri == -1) return;
    final r = c.replies[ri];
    final likes = List<dynamic>.from(r.likes);
    likes.contains(uid) ? likes.remove(uid) : likes.add(uid);
    final updatedReplies = List<CommentReply>.from(c.replies);
    updatedReplies[ri] = CommentReply(
      id: r.id,
      content: r.content,
      author: r.author,
      likes: likes,
      createdAt: r.createdAt,
    );
    comments[ci] = PostComment(
      id: c.id,
      content: c.content,
      author: c.author,
      likes: c.likes,
      replies: updatedReplies,
      createdAt: c.createdAt,
    );
  }

  void reset() {
    _comments.clear();
    _forumLikes.clear();
    _submitting.clear();
    _likingForum.clear();
    _likingComment.clear();
    _likingReply.clear();
    _deletingComment.clear();
    _deletingReply.clear();
    _deletingForum.clear();
    notifyListeners();
  }
}
