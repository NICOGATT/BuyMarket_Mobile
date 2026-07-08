class CartItemModel {
  final String id;
  final int quantity;
  final double unitPrice;
  final Map<String, dynamic> product;
  final String? variantId;
  final Map<String, dynamic>? variant;

  CartItemModel({
    required this.id,
    required this.quantity,
    required this.unitPrice,
    required this.product,
    this.variantId,
    this.variant,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final rawVariant = json['variant'] ??
        json['productVariant'] ??
        json['product_variant'];
    final variantMap = rawVariant is Map
        ? Map<String, dynamic>.from(rawVariant)
        : null;

    return CartItemModel(
      id: json['id']?.toString() ?? '',
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      unitPrice: json['unitPrice'] is num
          ? (json['unitPrice'] as num).toDouble()
          : double.tryParse(json['unitPrice']?.toString() ?? '') ?? 0,
      product: json['product'] is Map
          ? Map<String, dynamic>.from(json['product'] as Map)
          : <String, dynamic>{},
      variantId: (json['variantId'] ??
              json['variant_id'] ??
              variantMap?['id'] ??
              variantMap?['variantId'])
          ?.toString(),
      variant: variantMap,
    );
  }

  String? get variantSize => variant?['size']?.toString();
  String? get variantColor => variant?['color']?.toString();
}
