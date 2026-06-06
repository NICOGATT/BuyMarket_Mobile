import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_api_service.dart';

class ProductService extends ChangeNotifier {
  final ProductApiService _api = ProductApiService();

  final List<Product> _products = [];

  List<Product> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _api.getProducts();

      _products
        ..clear()
        ..addAll(result);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}