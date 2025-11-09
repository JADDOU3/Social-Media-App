class FriendResponse {
  final int id;
  final int senderId;
  final int receiverId;
  final String senderName;
  final String receiverName;
  final String senderEmail;
  final String receiverEmail;
  final String status; // PENDING, APPROVED, DECLINED, BLOCKED
  final DateTime createdAt;

  FriendResponse({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    required this.receiverName,
    required this.senderEmail,
    required this.receiverEmail,
    required this.status,
    required this.createdAt,
  });

  factory FriendResponse.fromJson(Map<String, dynamic> json) {
    return FriendResponse(
      id: json['id'] ?? 0,
      senderId: json['senderId'] ?? 0,
      receiverId: json['receiverId'] ?? 0,
      senderName: json['senderName'] ?? '',
      receiverName: json['receiverName'] ?? '',
      senderEmail: json['senderEmail'] ?? '',
      receiverEmail: json['receiverEmail'] ?? '',
      status: json['status'] ?? 'PENDING',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}