class ProductBasicInfo {
  final String title;
  final String description;
  final String brand;

  const ProductBasicInfo({
    required this.title,
    required this.description,
    this.brand = '',
  });
}
