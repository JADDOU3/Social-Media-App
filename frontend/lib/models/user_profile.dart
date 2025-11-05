class UserProfile{
  final String name;
  final String email;
  final String? bio;
  final String? job;
  final String? location;
  final String? phoneNumber;
  final int postsCount;
  final int friendsCount;
  final int followingCount;

  UserProfile({
    required this.name,
    required this.email,
    this.bio,
    this.job,
    this.location,
    this.phoneNumber,
    this.postsCount = 0,
    this.friendsCount = 0,
    this.followingCount = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'],
      job: json['job'],
      location: json['location'],
      phoneNumber: json['phoneNumber'],
      postsCount: json['postsCount'] ?? 0,
      friendsCount: json['friendsCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
    );
  }
}