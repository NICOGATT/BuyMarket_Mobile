import 'package:buymarket_frontend/features/cart/models/cart_item.dart';
import 'package:flutter/foundation.dart';
import '../../auth/services/auth_services.dart';
import '../models/cart_model.dart';
import 'cart_api_services_instances.dart';

class CartService extends ChangeNotifier {
  final CartApiService _cartApiService;
  final AuthServices _authServices;

  CartService({
    required CartApiService cartApiService,
    required AuthServices authServices,
  })  : _cartApiService = cartApiService,
        _authServices = authServices;

  CartModel? _cart;
  bool _isLoading = false;
  String? _error;

  CartModel? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<CartItemModel> get items => _cart?.items ?? [];

  int get badgeCount {
    return items.fold<int>(
      0,
      (total, item) => total + item.quantity,
    );
  }

  double get total {
    return items.fold<double>(
      0,
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );
  }

  bool get isEmpty => items.isEmpty;

  String get _token {
    final token = _authServices.token;

    if (token == null) {
      throw Exception('Usuario no autenticado');
    }

    return token;
  }

  Future<void> loadCart() async {
    if (!_authServices.isLoggeIn) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final json = await _cartApiService.getCart(_token);
      _cart = CartModel.fromJson(json);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct(String productId) async {
    await _cartApiService.addProduct(
      token: _token,
      productId: productId,
      quantity: 1,
    );

    await loadCart();
  }

  Future<void> increaseQuantity(String itemId, int currentQuantity) async {
    await _cartApiService.updateQuantity(
      token: _token,
      itemId: itemId,
      quantity: currentQuantity + 1,
    );

    await loadCart();
  }

  Future<void> decreaseQuantity(String itemId, int currentQuantity) async {
    if (currentQuantity <= 1) {
      await removeItem(itemId);
      return;
    }

    await _cartApiService.updateQuantity(
      token: _token,
      itemId: itemId,
      quantity: currentQuantity - 1,
    );

    await loadCart();
  }

  Future<void> removeItem(String itemId) async {
    await _cartApiService.removeItem(
      token: _token,
      itemId: itemId,
    );

    await loadCart();
  }

  Future<void> clearCart() async {
    await _cartApiService.clearCart(_token);
    await loadCart();
  }
}