import 'dart:convert';

import 'auth_user.dart';

class AuthResponse {
  final String token;
  final AuthUser user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final token = (json['access_token'] ?? json['token'] ?? json['accessToken'])
        ?.toString();

    if (token == null) {
      throw Exception('El backend no devolvio token');
    }

    if (json['user'] == null) {
      throw Exception('El backend no devolvio usuario');
    }

    final userJson = Map<String, dynamic>.from(json['user']);

    return AuthResponse(
      token: token,
      user: AuthUser.fromJson({
        ..._tokenPayload(token),
        ...userJson,
      }),
    );
  }

  static Map<String, dynamic> _tokenPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) {
        return {};
      }

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final decoded = jsonDecode(payload);

      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      return {};
    }
  }
}
