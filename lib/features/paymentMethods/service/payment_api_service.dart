import 'dart:convert';
import 'package:buymarket_frontend/core/config/api.config.dart';
import 'package:http/http.dart' as http;



class PaymentApiService {
  Future<String> createPreference({
    required String orderId,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/payments/mercadopago/create-preference/$orderId',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear preferencia: ${response.body}');
    }

    final data = jsonDecode(response.body);

    final paymentUrl = data['initPoint'] ?? data['sandboxInitPoint'];

    if (paymentUrl == null) {
      throw Exception('Mercado Pago no devolvió URL de pago');
    }

    return paymentUrl;
  }
}