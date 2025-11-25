import 'package:flutter/foundation.dart';

class SuggestedFriendResponse {
  final int id;
  final String name;
  final int mutualFriendsCount;

  SuggestedFriendResponse({
    required this.id,
    required this.name,
    required this.mutualFriendsCount,
  });

  factory SuggestedFriendResponse.fromJson(Map<String, dynamic> json) {
    return SuggestedFriendResponse(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown User',
      mutualFriendsCount: json['mutualFriendsCount'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SuggestedFriendResponse && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}