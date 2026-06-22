import 'dart:convert';

import 'package:buymarket_frontend/core/config/api.config.dart';
import 'package:http/http.dart' as http;

import '../models/sub_category_attribute.dart';

class SubCategoryAttributeService {
  Future<List<SubCategoryAttribute>> getBySubCategory(
    String subCategoryId,
  ) async {
    final response = await http
        .get(
          Uri.parse(
            '${ApiConfig.baseUrl}/sub-category-attributes/subcategory/$subCategoryId',
          ),
          headers: const {
            'ngrok-skip-browser-warning': 'true',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode >= 300) {
      throw Exception('No se pudieron cargar los atributos');
    }

    final data = jsonDecode(response.body) as List;
    return data
        .map(
          (json) => SubCategoryAttribute.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }
}
