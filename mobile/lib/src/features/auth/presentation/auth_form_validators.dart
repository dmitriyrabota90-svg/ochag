class AuthFormValidators {
  const AuthFormValidators._();

  static bool isValidEmail(String value) {
    final trimmed = value.trim();
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
  }

  static bool isValidPassword(String value) {
    return value.length >= 8;
  }

  static bool isValidName(String value) {
    return value.trim().length <= 80;
  }
}
