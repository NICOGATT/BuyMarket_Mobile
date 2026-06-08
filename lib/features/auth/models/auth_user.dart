class AuthUser {
  final String id;
  final String email;
  final String name; 
  final String role;

  AuthUser({
    required this.id,
    required this.email,
    required this.name, 
    required this.role,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['sub'],
      email: json['email'],
      name : json['name'], 
      role: json['role'],
    );
  }
}