import 'dart:convert';
import 'dart:async';
import 'package:buymarket_frontend/features/auth/models/auth_response.dart';
import 'package:buymarket_frontend/features/auth/models/auth_user.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/api.config.dart';
import 'package:flutter/material.dart';

class AuthApiServices {
  AuthApiServices({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

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

  Future<AuthResponse> loginWithGoogle({required String idToken}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/google');

    final response = await _client
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'idToken': idToken}),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw AuthApiException(
        statusCode: response.statusCode,
        message: _readErrorMessage(
          response,
          'No se pudo iniciar sesion con Google',
        ),
      );
    }

    final data = jsonDecode(response.body);
    if (data is! Map) {
      throw const AuthApiException(
        message: 'El backend devolvio una respuesta invalida',
      );
    }

    return AuthResponse.fromJson(Map<String, dynamic>.from(data));
  }

  String _readErrorMessage(http.Response response, String fallback) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map) {
        final message = data['message'];
        if (message is String && message.trim().isNotEmpty) return message;
        if (message is List && message.isNotEmpty) {
          return message.first.toString();
        }
      }
    } catch (_) {
      // Use the user-facing fallback when the response is not JSON.
    }

    return fallback;
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

class AuthApiException implements Exception {
  const AuthApiException({this.statusCode, required this.message});

  final int? statusCode;
  final String message;

  @override
  String toString() => 'AuthApiException($statusCode, $message)';
}
