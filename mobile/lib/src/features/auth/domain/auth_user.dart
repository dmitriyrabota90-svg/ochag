class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    this.displayName,
  });

  final String id;
  final String email;
  final String? displayName;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get name =>
      displayName?.trim().isNotEmpty == true ? displayName!.trim() : email;
}
