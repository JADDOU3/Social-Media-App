class UserSearchResult {
  final int id;
  final String name;
  final String email;
  final String? bio;
  final String? job;
  final String? location;
  final String? phoneNumber;
  final String? profilePicture;

  UserSearchResult({
    required this.id,
    required this.name,
    required this.email,
    this.bio,
    this.job,
    this.location,
    this.phoneNumber,
    this.profilePicture,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'],
      job: json['job'],
      location: json['location'],
      phoneNumber: json['phoneNumber'],
      profilePicture: json['profilePicture'],
    );
  }
}