class FriendRequest {
  final int receiverId;

  FriendRequest({required this.receiverId});

  Map<String, dynamic> toJson() => {
    'receiverId': receiverId,
  };
}