class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final reg = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!reg.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    final hasUppercase = RegExp(r'[A-Z]');
    final hasLowercase = RegExp(r'[a-z]');
    final hasNumber = RegExp(r'\d');
    final hasSpecial = RegExp(r'[!@#\$&*~%^_+=<>?]');

    if (!hasUppercase.hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!hasLowercase.hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!hasNumber.hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!hasSpecial.hasMatch(value)) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  static String? validateConfirmPassword(String? pass, String? confirm) {
    if (confirm == null || confirm.isEmpty) return 'Confirm your password';
    if (pass != confirm) return 'Passwords do not match';
    return null;
  }
}
