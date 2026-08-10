import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api.config.dart';

class BrandService {
  Future<String?> resolveBrandId(String brandName, String token) async {
    final name = brandName.trim();
    if (name.isEmpty) return null;

    final existingId = await _findBrandId(name);
    if (existingId != null) return existingId;

    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/brands'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'ngrok-skip-browser-warning': 'true',
          },
          body: jsonEncode({'name': name}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 409) {
      final conflictingId = await _findBrandId(name);
      if (conflictingId != null) return conflictingId;
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('No se pudo registrar la marca ingresada');
    }

    final brand = _unwrapObject(jsonDecode(response.body));
    final id = (brand['id'] ?? brand['_id'])?.toString().trim();
    if (id == null || id.isEmpty) {
      throw Exception('La API no devolvió el identificador de la marca');
    }
    return id;
  }

  Future<String?> _findBrandId(String brandName) async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/brands'),
          headers: const {'ngrok-skip-browser-warning': 'true'},
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('No se pudieron consultar las marcas');
    }

    final decoded = jsonDecode(response.body);
    final brands = decoded is List
        ? decoded
        : decoded is Map && decoded['data'] is List
        ? decoded['data'] as List
        : decoded is Map && decoded['value'] is List
        ? decoded['value'] as List
        : const [];
    final normalizedName = _normalize(brandName);

    for (final item in brands) {
      if (item is! Map) continue;
      final name = (item['name'] ?? item['nombre'])?.toString() ?? '';
      if (_normalize(name) != normalizedName) continue;
      final id = (item['id'] ?? item['_id'])?.toString().trim();
      if (id != null && id.isNotEmpty) return id;
    }
    return null;
  }

  Map<String, dynamic> _unwrapObject(dynamic decoded) {
    if (decoded is! Map) return const {};
    final value = decoded['data'] ?? decoded['value'] ?? decoded;
    if (value is! Map) return const {};
    return Map<String, dynamic>.from(value);
  }

  String _normalize(String value) {
    return value.trim().toLowerCase();
  }
}
