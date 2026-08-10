import '../../home/models/product.dart';

class CouponOffer {
  final String id;
  final String title;
  final int discountPercentage;
  final List<Product> products;

  const CouponOffer({
    required this.id,
    required this.title,
    required this.discountPercentage,
    required this.products,
  });

  String get benefitText {
    if (discountPercentage > 0) {
      return '$discountPercentage% de descuento';
    }
    return 'Promoción especial';
  }
}

List<CouponOffer> buildCouponsFromProducts(List<Product> products) {
  final groupedProducts = <String, List<Product>>{};

  for (final product in products.where((item) => item.hasOffer)) {
    final normalizedLabel = product.promotionLabel.trim().toLowerCase();
    final key = '$normalizedLabel|${product.discountPercentage}';
    groupedProducts.putIfAbsent(key, () => []).add(product);
  }

  final coupons = groupedProducts.entries.map((entry) {
    final product = entry.value.first;
    final label = product.promotionLabel.trim();
    final title = label.isNotEmpty
        ? label
        : '${product.discountPercentage}% de descuento';

    return CouponOffer(
      id: entry.key,
      title: title,
      discountPercentage: product.discountPercentage,
      products: List.unmodifiable(entry.value),
    );
  }).toList();

  coupons.sort((a, b) {
    final percentageComparison = b.discountPercentage.compareTo(
      a.discountPercentage,
    );
    if (percentageComparison != 0) return percentageComparison;
    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  });

  return coupons;
}
