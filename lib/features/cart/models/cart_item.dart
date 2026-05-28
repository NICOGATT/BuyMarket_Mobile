import '../../home/models/product.dart';

class CartItem {
  final Product product; 
  final int quantity; 

  const CartItem ({
    required this.product, 
    required this.quantity
  });
}
