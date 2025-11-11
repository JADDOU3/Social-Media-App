class UserProfile {
  final int? id;
  final String email;
  final String? name;
  final String? bio;
  final String? job;
  final String? location;
  final String? phoneNumber;
  final String? profilePicture;
  final int postsCount;
  final int friendsCount;
  final String? gender;
  final String? dateOfBirth;
  final String? socialSituation;

  UserProfile({
    this.id,
    required this.email,
    this.name,
    this.bio,
    this.job,
    this.location,
    this.phoneNumber,
    this.profilePicture,
    this.postsCount = 0,
    this.friendsCount = 0,
    this.gender,
    this.dateOfBirth,
    this.socialSituation,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'] ?? '',
      name: json['name'],
      bio: json['bio'],
      job: json['job'],
      location: json['location'],
      phoneNumber: json['phoneNumber'],
      profilePicture: json['profilePicture'],
      postsCount: json['postsCount'] ?? 0,
      friendsCount: json['friendsCount'] ?? 0,
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      socialSituation: json['socialSituation'],
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'name': name,
    'bio': bio,
    'job': job,
    'location': location,
    'phoneNumber': phoneNumber,
    'profilePicture': profilePicture,
    'postsCount': postsCount,
    'friendsCount': friendsCount,
    'gender': gender,
    'dateOfBirth': dateOfBirth,
    'socialSituation': socialSituation,
  };
}
