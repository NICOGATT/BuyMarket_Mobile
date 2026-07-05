import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user_address.dart';

class UserAddressApiService {
  final String baseUrl;

  const UserAddressApiService({required this.baseUrl});

  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<UserAddress>> getMyAddresses(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user-addresses/me'),
      headers: _headers(token),
    );

    if (response.statusCode >= 300) {
      throw Exception(
        _errorMessage(response, 'No se pudieron cargar tus direcciones'),
      );
    }

    final data = jsonDecode(response.body);

    if (data is! List) return [];

    return data
        .whereType<Map>()
        .map((item) => UserAddress.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<UserAddress> createAddress({
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user-addresses'),
      headers: _headers(token),
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 300) {
      throw Exception(
        _errorMessage(response, 'No se pudo guardar la direccion'),
      );
    }

    final data = jsonDecode(response.body);
    return UserAddress.fromJson(Map<String, dynamic>.from(data));
  }

  Future<UserAddress> setDefaultAddress({
    required String token,
    required String id,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/user-addresses/$id/default'),
      headers: _headers(token),
    );

    if (response.statusCode >= 300) {
      throw Exception(
        _errorMessage(
          response,
          'No se pudo marcar la direccion como predeterminada',
        ),
      );
    }

    final data = jsonDecode(response.body);
    return UserAddress.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> deleteAddress({
    required String token,
    required String id,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/user-addresses/$id'),
      headers: _headers(token),
    );

    if (response.statusCode >= 300) {
      throw Exception(
        _errorMessage(response, 'No se pudo eliminar la direccion'),
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
