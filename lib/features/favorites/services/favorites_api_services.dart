import 'dart:convert';

import 'package:buymarket_frontend/core/config/api.config.dart';
import 'package:buymarket_frontend/features/home/models/product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FavoritesApiServices {
  Future<List<Product>> getMyFavorites({
    required String token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/favorites/my-favorites',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    ).timeout(
      const Duration(seconds: 8),
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar favoritos');
    }

    final data = jsonDecode(response.body) as List;

    return data
        .map((json) {
          if (json is! Map) return null;

          final item = Map<String, dynamic>.from(json);
          final productJson = _extractProductJson(item);

          if (productJson == null) {
            return null;
          }

          return Product.fromJson(productJson);
        })
        .whereType<Product>()
        .where((product) => product.id.isNotEmpty)
        .toList();
  }

  Map<String, dynamic>? _extractProductJson(Map<String, dynamic> item) {
    final directProduct = item['product'] ?? item['producto'];
    if (directProduct is Map) {
      final productJson = Map<String, dynamic>.from(directProduct);
      final wrapperProductId = item['productId'] ?? item['product_id'];

      if (!_hasValue(productJson, ['id']) && wrapperProductId != null) {
        productJson['productId'] = wrapperProductId;
      }

      return productJson;
    }

    final nestedItem = item['item'];
    if (nestedItem is Map) {
      final nestedProduct = nestedItem['product'] ?? nestedItem['producto'];
      if (nestedProduct is Map) {
        final productJson = Map<String, dynamic>.from(nestedProduct);
        final wrapperProductId = item['productId'] ??
            item['product_id'] ??
            nestedItem['productId'] ??
            nestedItem['product_id'];

        if (!_hasValue(productJson, ['id']) && wrapperProductId != null) {
          productJson['productId'] = wrapperProductId;
        }

        return productJson;
      }
    }

    if (_looksLikeProduct(item)) {
      return item;
    }

    return null;
  }

  bool _looksLikeProduct(Map<String, dynamic> item) {
    return _hasValue(item, ['title']) ||
        _hasValue(item, ['description']) ||
        _hasValue(item, ['price']);
  }

  bool _hasValue(Map<String, dynamic> item, List<String> keys) {
    return keys.any((key) {
      final value = item[key];
      return value != null && value.toString().trim().isNotEmpty;
    });
  }

  Future<void> addFavorite({
    required String productId,
    required String token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/favorites/$productId',
    );

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    debugPrint('STATUS ADD FAVORITE: ${response.statusCode}');
    debugPrint('BODY ADD FAVORITE: ${response.body}');

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('No se pudo agregar favorito');
    }
  }

  Future<void> removeFavorite({
    required String productId,
    required String token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/favorites/$productId',
    );

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudo eliminar favorito');
    }
  }
}
