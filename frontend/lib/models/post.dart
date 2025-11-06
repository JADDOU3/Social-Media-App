class Post {
  final int id;
  final String? text;
  final String authorEmail;
  final String authorName;
  final DateTime createdDate;
  final int imageCount;
  final List<String> imageUrls;

  Post({
    required this.id,
    this.text,
    required this.authorEmail,
    required this.authorName,
    required this.createdDate,
    required this.imageCount,
    required this.imageUrls,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    // Handle imageNames which can be null or a list
    List<String> imageUrls = [];
    if (json['imageNames'] != null) {
      if (json['imageNames'] is List) {
        imageUrls = List<String>.from(json['imageNames']);
      }
    }

    return Post(
      id: json['id'] as int,
      text: json['text'] as String?,
      authorEmail: json['authorEmail'] as String,
      authorName: json['authorName'] as String,
      createdDate: DateTime.parse(json['createdDate'] as String),
      imageCount: json['imageCount'] as int,
      imageUrls: imageUrls,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'authorEmail': authorEmail,
      'authorName': authorName,
      'createdDate': createdDate.toIso8601String(),
      'imageCount': imageCount,
      'imageNames': imageUrls.isEmpty ? null : imageUrls,
    };
  }
}