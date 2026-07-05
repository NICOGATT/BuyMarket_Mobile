import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user_payment_method.dart';

class UserPaymentMethodApiService {
  final String baseUrl;

  const UserPaymentMethodApiService({required this.baseUrl});

  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<UserPaymentMethod>> getMyPaymentMethods(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user-payment-methods/me'),
      headers: _headers(token),
    );

    if (response.statusCode >= 300) {
      throw Exception(
        _errorMessage(response, 'No se pudieron cargar tus metodos de pago'),
      );
    }

    final data = jsonDecode(response.body);

    if (data is! List) return [];

    return data
        .whereType<Map>()
        .map(
          (item) =>
              UserPaymentMethod.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<UserPaymentMethod> createPaymentMethod({
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user-payment-methods'),
      headers: _headers(token),
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 300) {
      throw Exception(
        _errorMessage(response, 'No se pudo guardar el metodo de pago'),
      );
    }

    final data = jsonDecode(response.body);
    return UserPaymentMethod.fromJson(Map<String, dynamic>.from(data));
  }

  Future<UserPaymentMethod> updatePaymentMethod({
    required String token,
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/user-payment-methods/$id'),
      headers: _headers(token),
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 300) {
      throw Exception(
        _errorMessage(response, 'No se pudo actualizar el metodo de pago'),
      );
    }

    final data = jsonDecode(response.body);
    return UserPaymentMethod.fromJson(Map<String, dynamic>.from(data));
  }

  Future<UserPaymentMethod> setDefaultPaymentMethod({
    required String token,
    required String id,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/user-payment-methods/$id/default'),
      headers: _headers(token),
    );

    if (response.statusCode >= 300) {
      throw Exception(
        _errorMessage(
          response,
          'No se pudo marcar el metodo de pago como predeterminado',
        ),
      );
    }

    final data = jsonDecode(response.body);
    return UserPaymentMethod.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> deletePaymentMethod({
    required String token,
    required String id,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/user-payment-methods/$id'),
      headers: _headers(token),
    );

    if (response.statusCode >= 300) {
      throw Exception(
        _errorMessage(response, 'No se pudo eliminar el metodo de pago'),
      );
    }
  }

  String _errorMessage(http.Response response, String fallback) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        final message = decoded['message'];
        if (message is List) return message.join(', ');
        if (message is String && message.trim().isNotEmpty) return message;
      }
    } catch (_) {
      // Keep fallback for non-JSON errors.
    }

    return fallback;
  }
}
