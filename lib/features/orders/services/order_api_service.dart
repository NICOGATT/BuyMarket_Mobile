import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderApiService {
  final String baseUrl;

  OrderApiService({
    required this.baseUrl,
  });

  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> checkout({
    required String token,
    required String deliveryAddress,
    String? paymentMethod,
    String? paymentMethodId,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'deliveryAddress': deliveryAddress,
      'notes': notes,
    };

    if (paymentMethodId != null && paymentMethodId.trim().isNotEmpty) {
      body['paymentMethodId'] = paymentMethodId;
    } else if (paymentMethod != null && paymentMethod.trim().isNotEmpty) {
      body['paymentMethod'] = paymentMethod;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/orders/checkout'),
      headers: _headers(token),
      body: jsonEncode(body),
    );

    debugPrint('CHECKOUT STATUS: ${response.statusCode}');
    debugPrint('CHECKOUT BODY: ${response.body}');

    if (response.statusCode >= 300) {
      throw Exception(response.body);
    }

    return jsonDecode(response.body);
  }

  Future<List<dynamic>> getMyOrders(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/my-orders'),
      headers: _headers(token),
    );

    if (response.statusCode >= 300) {
      throw Exception('Error al obtener las órdenes');
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getOrderById({
    required String token,
    required String orderId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/$orderId'),
      headers: _headers(token),
    );

    if (response.statusCode >= 300) {
      throw Exception('Error al obtener la orden');
    }

    return jsonDecode(response.body);
  }
}
