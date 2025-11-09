class Comment {
  final int id;
  final int postId;
  final String comment;
  final String userEmail;
  final String? userName;
  final DateTime createdDate;

  Comment({
    required this.id,
    required this.postId,
    required this.comment,
    required this.userEmail,
    this.userName,
    required this.createdDate,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['postId'],
      comment: json['comment'],
      userEmail: json['userEmail'],
      userName: json['userName'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'comment': comment,
      'userEmail': userEmail,
      'userName': userName,
      'createdDate': createdDate.toIso8601String(),
    };
  }
}

class CommentRequest {
  final int postId;
  final String comment;

  CommentRequest({
    required this.postId,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'comment': comment,
    };
  }
}