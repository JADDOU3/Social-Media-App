class UserProfile {
  final String name;
  final String email;
  final String? bio;
  final String? job;
  final String? location;
  final String? phoneNumber;
  final String? profilePicture;
  final int postsCount;
  final int friendsCount;

  UserProfile({
    required this.name,
    required this.email,
    this.bio,
    this.job,
    this.location,
    this.phoneNumber,
    this.profilePicture,
    this.postsCount = 0,
    this.friendsCount = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'],
      job: json['job'],
      location: json['location'],
      phoneNumber: json['phoneNumber'],
      profilePicture: json['profilePicture'],
      postsCount: json['postsCount'] ?? 0,
      friendsCount: json['friendsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'bio': bio,
    'job': job,
    'location': location,
    'phoneNumber': phoneNumber,
    'profilePicture': profilePicture,
    'postsCount': postsCount,
    'friendsCount': friendsCount
  };
}
