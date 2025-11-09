class Comment {
  final int id;
  final int postId;
  final String comment;
  final String authorEmail;
  final String? authorName;
  final DateTime commentDate;

  Comment({
    required this.id,
    required this.postId,
    required this.comment,
    required this.authorEmail,
    this.authorName,
    required this.commentDate,
  });

  String get userEmail => authorEmail;
  String? get userName => authorName;

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      postId: json['postId'] as int,
      comment: json['comment'] as String,
      authorEmail: json['authorEmail'] as String,
      authorName: json['authorName'] as String?,
      commentDate: DateTime.parse(json['commentDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'comment': comment,
      'authorEmail': authorEmail,
      'authorName': authorName,
      'commentDate': commentDate.toIso8601String(),
    };
  }
}