import 'dart:io';

import 'package:buymarket_frontend/core/utils/safe_change_notifier.dart';

import '../models/product.dart';
import 'product_api_service.dart';

class ProductService extends SafeChangeNotifier {
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

  Future<Product> createProduct({
    required String title,
    required String description,
    String? price,
    int? stock,
    String? subCategoryId,
    List<Map<String, dynamic>>? attributes,
    List<Map<String, dynamic>>? variants,
    List<String>? mediaIds,
    required String token,
    required String seller,
  }) async {
    final product = await _api.createProduct(
      title: title,
      description: description,
      price: price,
      stock: stock,
      subCategoryId: subCategoryId,
      attributes: attributes,
      variants: variants,
      mediaIds: mediaIds,
      token: token,
      seller: seller,
    );

    await loadProducts();
    return product;
  }

  Future<void> uploadProductImage({
    required String productId,
    required File imageFile,
    required String token,
  }) async {
    await _api.uploadProductImage(
      productId: productId,
      imageFile: imageFile,
      token: token,
    );

    await loadProducts();
  }

  Future<List<Product>> getMyProducts({required String token}) async {
    return await _api.getMyProducts(token: token);
  }
}
