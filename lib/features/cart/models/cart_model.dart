import 'package:buymarket_frontend/features/cart/models/cart_item.dart';


class CartModel {
  final String id;
  final List<CartItemModel> items;

  CartModel({
    required this.id,
    required this.items,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'],
      items: (json['items'] as List)
          .map((item) => CartItemModel.fromJson(item))
          .toList(),
    );
  }
}