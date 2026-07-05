import 'dart:convert';
import 'dart:async';
import 'package:buymarket_frontend/features/auth/models/auth_response.dart';
import 'package:buymarket_frontend/features/auth/models/auth_user.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/api.config.dart';
import 'package:flutter/material.dart';

class AuthApiServices {
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Email o contraseña incorrectos');
    }

    final data = jsonDecode(response.body);

    return AuthResponse.fromJson(data);
  }

  Future<AuthUser> getCurrentUser({required String token}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/me');

    final response = await http
        .get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('No se pudo cargar la informacion del usuario');
    }

    final data = jsonDecode(response.body);

    return AuthUser.fromJson({..._tokenPayload(token), ..._readUserMap(data)});
  }

  Future<AuthUser?> getUserFromUsers({
    required String token,
    required AuthUser currentUser,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users');

    final response = await http
        .get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body);
    final users = _readUsersList(data);

    for (final userJson in users) {
      final user = AuthUser.fromJson(userJson);
      final sameId = currentUser.id.isNotEmpty && user.id == currentUser.id;
      final sameEmail =
          currentUser.email.isNotEmpty &&
          user.email.toLowerCase() == currentUser.email.toLowerCase();

      if (sameId || sameEmail) {
        return user;
      }
    }

    return null;
  }

  Future<AuthResponse> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/register');

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'firstName': firstName,
            'lastName': lastName,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 8));

    debugPrint('STATUS REGISTER: ${response.statusCode}');
    debugPrint('BODY REGISTER: ${response.body}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('No se pudo iniciar sesion ');
    }

    final data = jsonDecode(response.body);

    return AuthResponse.fromJson(data);
  }

  Map<String, dynamic> _readUserMap(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception('El backend no devolvio informacion del usuario');
  }

  List<Map<String, dynamic>> _readUsersList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (data is Map) {
      final users = data['users'] ?? data['data'];
      if (users is List) {
        return users
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }

    return [];
  }

  Map<String, dynamic> _tokenPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return {};

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
