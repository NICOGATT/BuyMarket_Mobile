import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../../home/models/product.dart';

class CartServices extends ChangeNotifier {
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
  }  

  void clearCart() {
    _items.clear(); 
    notifyListeners();
  }

  int get totalItems {
    return _items.fold(0, (sum, item) {
      return sum + item.quantity;
    });
  }
}