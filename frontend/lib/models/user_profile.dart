class UserProfile {
  final int? id;
  final String? email;
  final String? name;
  final String? bio;
  final String? job;
  final String? location;
  final String? phoneNumber;
  final String? gender;
  final String? dateOfBirth;
  final String? socialSituation;
  final String? profilePicture;

  UserProfile({
    this.id,
    this.email,
    this.name,
    this.bio,
    this.job,
    this.location,
    this.phoneNumber,
    this.gender,
    this.dateOfBirth,
    this.socialSituation,
    this.profilePicture,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      bio: json['bio'],
      job: json['job'],
      location: json['location'],
      phoneNumber: json['phoneNumber'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      socialSituation: json['socialSituation'],
      profilePicture: json['profilePicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'bio': bio,
      'job': job,
      'location': location,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'socialSituation': socialSituation,
      'profilePicture': profilePicture,
    };
  }
}
