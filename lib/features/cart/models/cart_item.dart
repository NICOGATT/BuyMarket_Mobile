class CartItemModel {
  final String id;
  final int quantity;
  final double unitPrice;
  final Map<String, dynamic> product;

  CartItemModel({
    required this.id,
    required this.quantity,
    required this.unitPrice,
    required this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      quantity: json['quantity'],
      unitPrice: double.parse(json['unitPrice']),
      product: json['product'],
    );
  }
}