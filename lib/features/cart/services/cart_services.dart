import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../../home/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartServices extends ChangeNotifier {
  static const String cartKey = 'cart';
  final List<CartItem> _items = []; 
  double get total {
    return _items.fold(0, (sum, item) {
      final price = double.tryParse(item.product.price) ?? 0; 
      return sum + (price * item.quantity);
    });
  }

  List<CartItem> get items => _items;

  void addProduct(Product product) {
    final index = _items.indexWhere(
      (item) => item.product.id == product.id
    ); 

    if (index >= 0) {
      final currentItem = _items[index]; 

      _items[index] = CartItem(
        product: currentItem.product, 
        quantity: currentItem.quantity + 1,
      );
    } else {
      _items.add(
        CartItem(
          product : product, 
          quantity : 1
        )
      );
    }
    notifyListeners();
    saveCart();
  }

  void increaseQuantity(Product product) {
    final index = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if(index >= 0) {
      final currentItem = _items[index]; 
      _items[index] = CartItem(
        product: currentItem.product, 
        quantity: currentItem.quantity + 1
      );
    }
    notifyListeners();
    saveCart();
  }

  void decreaseQuantity(Product product) {
    final index = _items.indexWhere(
      (item) => item.product.id == product.id,
    ); 

    if(index >= 0) {
      final currentItem = _items[index]; 

      if(currentItem.quantity > 1) {
        _items[index] = CartItem(
          product: currentItem.product,
          quantity: currentItem.quantity -1,
        );
      }
    } else {
      _items.removeAt(index);
    }

    notifyListeners();
    saveCart();
  }  

  void clearCart() {
    _items.clear(); 
    notifyListeners();
    saveCart();
  }

  int get totalItems {
    return _items.fold(0, (sum, item) {
      return sum + item.quantity;
    });
  }

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();

    final cartData = _items.map((item) {
      return '${item.product.id}:${item.quantity}';
    }).toList();
    await prefs.setStringList(cartKey, cartData); 
  }

  Future<void> loadCart(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance(); 

    final cartData = prefs.getStringList(cartKey);

    if(cartData == null) return; 

    _items.clear();

    for (final itemData in cartData) {
      final parts = itemData.split(':'); 

      final productId = int.parse(parts[0]);
      final quantity = int.parse(parts[1]);

      final product = products.firstWhere((p) => p.id == productId);
      _items.add(CartItem(product: product, quantity: quantity));
    }
  }
}