import 'dart:convert';
import 'package:http/http.dart' as http;

class CartApiService {
  final String baseUrl;

  CartApiService({
    required this.baseUrl,
  });

  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getCart(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/carts/my-cart'),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Error loading cart');
    }

    return jsonDecode(response.body);
  }

  Future<void> addProduct({
    required String token,
    required String productId,
    int quantity = 1,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/carts/add-product'),
      headers: _headers(token),
      body: jsonEncode({
        "productId": productId,
        "quantity": quantity,
      }),
    );

    if (response.statusCode >= 300) {
      throw Exception('Error adding product');
    }
  }

  Future<void> updateQuantity({
    required String token,
    required String itemId,
    required int quantity,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/carts/items/$itemId'),
      headers: _headers(token),
      body: jsonEncode({
        "quantity": quantity,
      }),
    );

    if (response.statusCode >= 300) {
      throw Exception('Error updating quantity');
    }
  }

  Future<void> removeItem({
    required String token,
    required String itemId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/carts/items/$itemId'),
      headers: _headers(token),
    );

    if (response.statusCode >= 300) {
      throw Exception('Error removing item');
    }
  }

  Future<void> clearCart(String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/carts/clear'),
      headers: _headers(token),
    );

    if (response.statusCode >= 300) {
      throw Exception('Error clearing cart');
    }
  }
}