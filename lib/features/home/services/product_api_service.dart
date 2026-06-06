import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/config/api.config.dart';
import '../models/product.dart';

class ProductApiService {
  Future<List<Product>> getProducts() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/products'); 

    final response = await http.get(url).timeout(
      const Duration(seconds: 8)
    );

    if(response.statusCode != 200) {
      throw Exception("No se pudieron cargar los productos");
    }

    final data = jsonDecode(response.body) as List; 

    return data.map((json){
      return Product.fromJson(json);
    }).toList();
  }
}