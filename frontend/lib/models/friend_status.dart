class FriendStatus {
  final String status;
  final int? requestId;

  FriendStatus({required this.status, this.requestId});

  factory FriendStatus.fromJson(Map<String, dynamic> json) {
    return FriendStatus(
      status: json['status'] ?? 'NONE',
      requestId: json['requestId'],
    );
  }

  bool get isFriends => status == 'FRIENDS';
  bool get isPendingSent => status == 'PENDING_SENT';
  bool get isPendingReceived => status == 'PENDING_RECEIVED';
  bool get isBlocked => status == 'BLOCKED';
  bool get isNone => status == 'NONE';
  bool get isSelf => status == 'SELF';
}
