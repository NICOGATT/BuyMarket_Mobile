class AuthUser {
  final String id;
  final String email;
  final String role;

  AuthUser({
    required this.id,
    required this.email,
    required this.role,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['sub'],
      email: json['email'],
      role: json['role'],
    );
  }
}