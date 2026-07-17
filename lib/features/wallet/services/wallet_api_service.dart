import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/wallet_balance.dart';
import '../models/wallet_transaction.dart';
import '../models/wallet_withdrawal.dart';
import '../models/wallet_sale.dart';
import '../models/wallet_earnings.dart';

class WalletApiService {
  final String baseUrl;

  const WalletApiService({required this.baseUrl});

  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<WalletBalance> getBalance(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/wallets/me/balance'),
      headers: _headers(token),
    );

    if (response.statusCode >= 300) {
      throw Exception(
        _errorMessage(response, 'No se pudo cargar el saldo de tu wallet'),
      );
    }

    final data = jsonDecode(response.body);
    return WalletBalance.fromJson(Map<String, dynamic>.from(data));
  }

  Future<List<WalletTransaction>> getMyTransactions(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/wallet-transaction/me'),
      headers: _headers(token),
    );

    if (response.statusCode >= 300) {
      throw Exception(
        _errorMessage(response, 'No se pudieron cargar tus movimientos'),
      );
    }

    final data = jsonDecode(response.body);
    if (data is! List) return [];

    return data
        .whereType<Map>()
        .map(
          (item) => WalletTransaction.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<List<WalletWithdrawal>> getMyWithdrawals(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/wallets/withdrawals/me'),
      headers: _headers(token),
    );

    if (response.statusCode >= 300) {
      throw Exception(
        _errorMessage(response, 'No se pudieron cargar tus retiros'),
      );
    }

    final data = jsonDecode(response.body);
    if (data is! List) return [];

    return data
        .whereType<Map>()
        .map(
          (item) => WalletWithdrawal.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<List<WalletSale>> getMySales(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/my-sales'),
      headers: _headers(token),
    );

    if (response.statusCode >= 300) {
      throw Exception(
        _errorMessage(response, 'No se pudieron cargar tus ventas'),
      );
    }

    final data = jsonDecode(response.body);
    if (data is! List) return [];

    return data
        .whereType<Map>()
        .map((item) => WalletSale.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<WalletEarnings> getMyEarnings({
    required String token,
    required DateTime from,
    required DateTime toExclusive,
  }) async {
    final uri = Uri.parse('$baseUrl/wallets/me/earnings').replace(
      queryParameters: {
        'from': from.toUtc().toIso8601String(),
        'to': toExclusive.toUtc().toIso8601String(),
      },
    );
    final response = await http.get(uri, headers: _headers(token));

    if (response.statusCode >= 300) {
      throw Exception(
        _errorMessage(response, 'No se pudieron calcular tus ganancias'),
      );
    }

    final data = jsonDecode(response.body);
    return WalletEarnings.fromJson(Map<String, dynamic>.from(data));
  }

  Future<WalletWithdrawal> requestWithdrawal({
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/wallets/withdrawals'),
      headers: _headers(token),
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 300) {
      throw Exception(
        _errorMessage(response, 'No se pudo solicitar el retiro'),
      );
    }

    final data = jsonDecode(response.body);
    return WalletWithdrawal.fromJson(Map<String, dynamic>.from(data));
  }

  String _errorMessage(http.Response response, String fallback) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        final message = decoded['message'];
        if (message is List) return message.join(', ');
        if (message is String && message.trim().isNotEmpty) return message;
      }
    } catch (_) {
      // Keep fallback for non-JSON errors.
    }

    if (response.statusCode == 404) {
      return 'Todavia no tenes una wallet activa';
    }

    return fallback;
  }
}
