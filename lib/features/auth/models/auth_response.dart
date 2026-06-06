import 'auth_user.dart';

class AuthResponse {
  final String token ; 
  final AuthUser user; 

  AuthResponse({
    required this.token, 
    required this.user,
  }); 

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
  final token = json['access_token'] ?? json['token'] ?? json['accessToken'];

  if (token == null) {
    throw Exception('El backend no devolvió token');
  }

  if (json['user'] == null) {
    throw Exception('El backend no devolvió usuario');
  }

  return AuthResponse(
    token: token,
    user: AuthUser.fromJson(json['user']),
  );
}

}
