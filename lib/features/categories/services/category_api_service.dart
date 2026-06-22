import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:buymarket_frontend/core/config/api.config.dart';

class CategoryApiService {
  Future<List<dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/categories'),
      headers: const {
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode >= 300) {
      throw Exception('Error al obtener categorías');
    }

    return jsonDecode(response.body);
  }
}
