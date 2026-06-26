// ─── comment_models.dart ──────────────────────────────────────────────────────

class CommentAuthor {
  final String id;
  final String name;
  final String email;

  CommentAuthor({required this.id, required this.name, required this.email});

  factory CommentAuthor.fromJson(Map<String, dynamic> json) => CommentAuthor(
        id:    json['_id']   ?? '',
        name:  json['name']  ?? '',
        email: json['email'] ?? '',
      );
}

class CommentReply {
  final String id;
  final String content;
  final CommentAuthor? author;
  final List<dynamic> likes;
  final DateTime? createdAt;

  CommentReply({
    required this.id,
    required this.content,
    this.author,
    required this.likes,
    this.createdAt,
  });

  factory CommentReply.fromJson(Map<String, dynamic> json) => CommentReply(
        id:        json['_id']     ?? '',
        content:   json['content'] ?? '',
        author:    json['author']  != null
            ? CommentAuthor.fromJson(json['author']) : null,
        likes:     json['likes']   as List? ?? [],
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt']) : null,
      );
}

class PostComment {
  final String id;
  final String content;
  final CommentAuthor? author;
  final List<dynamic> likes;
  final List<CommentReply> replies;
  final DateTime? createdAt;

  PostComment({
    required this.id,
    required this.content,
    this.author,
    required this.likes,
    required this.replies,
    this.createdAt,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) => PostComment(
        id:      json['_id']     ?? '',
        content: json['content'] ?? '',
        author:  json['author']  != null
            ? CommentAuthor.fromJson(json['author']) : null,
        likes:   json['likes']   as List? ?? [],
        replies: (json['replies'] as List?)
                ?.map((e) => CommentReply.fromJson(e))
                .toList() ??
            [],
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt']) : null,
      );
}