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
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.createdAt,
    this.updatedAt,
  });

  UserProfile copyWith({
    int? id,
    String? email,
    String? name,
    String? bio,
    String? job,
    String? location,
    String? phoneNumber,
    String? gender,
    String? dateOfBirth,
    String? socialSituation,
    String? profilePicture,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      job: job ?? this.job,
      location: location ?? this.location,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      socialSituation: socialSituation ?? this.socialSituation,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int?,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      bio: json['bio'] as String?,
      job: json['job'] as String?,
      location: json['location'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      socialSituation: json['socialSituation'] as String?,
      profilePicture: json['profilePicture'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'bio': bio,
      'job': job,
      'location': location,
      'phone': phoneNumber,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'socialSituation': socialSituation,
      'profilePicture': profilePicture,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

}
