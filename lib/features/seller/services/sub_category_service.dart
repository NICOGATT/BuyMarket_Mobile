import 'dart:convert';

import 'package:buymarket_frontend/core/config/api.config.dart';
import 'package:http/http.dart' as http;

import '../models/sub_category.dart';

class SubCategoryService {
  Future<List<SubCategory>> getByCategory(String categoryId) async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/subcategories/category/$categoryId'),
          headers: const {
            'ngrok-skip-browser-warning': 'true',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode >= 300) {
      throw Exception('No se pudieron cargar las subcategorias');
    }

    final decoded = jsonDecode(response.body);
    final data = decoded is List
        ? decoded
        : decoded is Map<String, dynamic> && decoded['data'] is List
            ? decoded['data'] as List
            : <dynamic>[];

    return data
        .map((json) => SubCategory.fromJson(json as Map<String, dynamic>))
        .where((subCategory) => subCategory.id.isNotEmpty)
        .toList();
  }
}
