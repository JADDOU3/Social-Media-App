class Post {
  final int id;
  final String? text;
  final List<String> imageUrls;
  final DateTime createdDate;
  final String? authorEmail;
  final String? authorName;
  final int? commentCount;

  Post({
    required this.id,
    this.text,
    required this.imageUrls,
    required this.createdDate,
    this.authorEmail,
    this.authorName,
    this.commentCount,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      text: json['text'],
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : [],
      createdDate: DateTime.parse(json['createdDate']),
      authorEmail: json['authorEmail'],
      authorName: json['authorName'],
      commentCount: json['commentCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'imageUrls': imageUrls,
      'createdDate': createdDate.toIso8601String(),
      'authorEmail': authorEmail,
      'authorName': authorName ?? "unknown",
      'commentCount': commentCount,
    };
  }
}