enum Gender { male, female }

extension GenderExtension on Gender {
  String get value => this == Gender.male ? "Male" : "Female";

  static Gender? fromString(String? gender) {
    if (gender == null) return null;
    switch (gender.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      default:
        return null;
    }
  }
}
