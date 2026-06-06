import 'dart:convert';
import 'dart:async';
import 'package:buymarket_frontend/features/auth/models/auth_response.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/api.config.dart';

class AuthApiServices {
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    ).timeout(
      const Duration(seconds: 8), 
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Email o contraseña incorrectos');
    }

    final data = jsonDecode(response.body);

    return AuthResponse.fromJson(data);
  }
}
