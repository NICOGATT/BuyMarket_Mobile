import '../models/product.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
class ProductServices {
  Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse('https://fakestoreapi.com/products'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((json) {
        return Product(
          id : json["id"],
          title : json["title"],
          description : json["description"],
          category : json["category"],
          price : json["price"].toString(),
          imageUrl: json['image']
        );
      }).toList();
    } else {
      throw Exception("Error al cargar productos");
    }
  }

}