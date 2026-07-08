import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../core/config/api.config.dart';
import '../models/product.dart';

class ProductApiService {
  Future<List<Product>> getProducts() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/products');

    final response = await http.get(
      url,
      headers: const {
        'ngrok-skip-browser-warning': 'true',
      },
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar los productos');
    }

    final data = jsonDecode(response.body) as List;

    return data.map((json) {
      return Product.fromJson(json);
    }).toList();
  }

  Future<Product> getProductById(String productId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/products/$productId');

    final response = await http.get(
      url,
      headers: const {
        'ngrok-skip-browser-warning': 'true',
      },
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('No se pudo cargar el detalle del producto');
    }

    final decoded = jsonDecode(response.body);
    final data = decoded is Map<String, dynamic>
        ? (decoded['data'] ?? decoded['value'] ?? decoded)
        : decoded;

    return Product.fromJson(data as Map<String, dynamic>);
  }

  Future<Product> createProduct({
    required String title,
    required String description,
    required String price,
    required int stock,
    String? subCategoryId,
    List<Map<String, dynamic>>? attributes,
    List<Map<String, dynamic>>? variants,
    List<String>? mediaIds,
    required String token,
    required String seller,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/products');
    final body = {
      'title': title,
      'description': description,
      'price': double.parse(price),
      'stock': stock,
      if (subCategoryId != null) 'subCategoryId': subCategoryId,
      if (attributes != null && attributes.isNotEmpty) 'attributes': attributes,
      if (variants != null && variants.isNotEmpty) 'variants': variants,
      if (mediaIds != null && mediaIds.isNotEmpty) 'mediaIds': mediaIds,
      'seller': seller,
    };

    debugPrint('CREATE PRODUCT REQUEST BODY: ${jsonEncode(body)}');

    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'ngrok-skip-browser-warning': 'true',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint('CREATE PRODUCT STATUS: ${response.statusCode}');
      debugPrint('CREATE PRODUCT BODY: ${response.body}');
      throw Exception(_readErrorMessage(response.body));
    }

    final decoded = jsonDecode(response.body);
    final data = decoded is Map<String, dynamic>
        ? (decoded['data'] ?? decoded['value'] ?? decoded)
        : decoded;

    return Product.fromJson(data as Map<String, dynamic>);
  }

  String _readErrorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'] ?? decoded['error'];
        if (message is List && message.isNotEmpty) {
          return message.first.toString();
        }
        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString();
        }
      }
    } catch (_) {
      // Keep the user-facing fallback below.
    }

    return 'No se pudo publicar el producto';
  }

  Future<void> uploadProductImage({
    required String productId,
    required File imageFile,
    required String token,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/products/$productId/images');

    final request = http.MultipartRequest(
      'POST',
      url,
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['ngrok-skip-browser-warning'] = 'true';

    request.files.add(
      await http.MultipartFile.fromPath(
        'images',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('No se pudo subir la imagen');
    }
  }

  Future<List<Product>> getMyProducts({
    required String token,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/products/my-products');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    }).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar los productos');
    }

    final data = jsonDecode(response.body) as List;

    return data.map((json) {
      return Product.fromJson(json);
    }).toList();
  }

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/products?categoryId=$categoryId',
    );

    final response = await http.get(
      url,
      headers: const {
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar los productos de la categoria');
    }

    final List data = jsonDecode(response.body);

    return data.map((json) => Product.fromJson(json)).toList();
  }
}
