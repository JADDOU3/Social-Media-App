class Post {
  final int id;
  final String text;
  final List<String> imageUrls;
  final DateTime createdAt;
  final String authorName;
  final String authorEmail;

  Post({
    required this.id,
    required this.text,
    required this.imageUrls,
    required this.createdAt,
    required this.authorName,
    required this.authorEmail,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      text: json['text'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      authorName: json['authorName'] ?? '',
      authorEmail: json['authorEmail'] ?? '',
    );
  }
}