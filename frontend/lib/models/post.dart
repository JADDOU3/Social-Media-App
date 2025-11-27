import '../enums/reaction_type.dart';

class Post {
  final int id;
  final String? text;
  final List<String> imageUrls;
  final DateTime createdDate;
  final String? authorEmail;
  final String authorName;

  final int? commentCount;
  final String? currentUserReaction;
  final Map<String, int>? reactionCounts;

  Post({
    required this.id,
    this.text,
    required this.imageUrls,
    required this.createdDate,
    this.authorEmail,
   required this.authorName,
    this.commentCount,
    this.currentUserReaction,
    this.reactionCounts,
  });

  ReactionType? get currentReactionType {
    if (currentUserReaction == null) return null;
    try {
      return ReactionType.values.firstWhere(
            (e) => e.name.toUpperCase() == currentUserReaction!.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

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
      currentUserReaction: json['currentUserReaction'],
      reactionCounts: json['reactionCounts'] != null
          ? Map<String, int>.from(json['reactionCounts'])
          : null,
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
      'currentUserReaction': currentUserReaction,
      'reactionCounts': reactionCounts,
    };
  }

  Post copyWith({
    int? id,
    String? text,
    List<String>? imageUrls,
    DateTime? createdDate,
    String? authorEmail,
    String? authorName,
    int? commentCount,
    String? currentUserReaction,
    Map<String, int>? reactionCounts,
  }) {
    return Post(
      id: id ?? this.id,
      text: text ?? this.text,
      imageUrls: imageUrls ?? this.imageUrls,
      createdDate: createdDate ?? this.createdDate,
      authorEmail: authorEmail ?? this.authorEmail,
      authorName: authorName ?? this.authorName,
      commentCount: commentCount ?? this.commentCount,
      currentUserReaction: currentUserReaction ?? this.currentUserReaction,
      reactionCounts: reactionCounts ?? this.reactionCounts,
    );
  }
}