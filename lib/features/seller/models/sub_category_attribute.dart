class SubCategoryAttribute {
  final String id;
  final String name;
  final String type;
  final bool isRequired;
  final String appliesTo;
  final String usage;
  final List<String> options;
  final String subCategoryId;

  const SubCategoryAttribute({
    required this.id,
    required this.name,
    required this.type,
    required this.isRequired,
    required this.appliesTo,
    required this.usage,
    required this.options,
    required this.subCategoryId,
  });

  factory SubCategoryAttribute.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];

    return SubCategoryAttribute(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'text',
      isRequired: json['required'] == true,
      appliesTo: (json['appliesTo']?.toString() ?? 'PRODUCT').toUpperCase(),
      usage: (json['usage']?.toString() ?? 'product_attribute').toLowerCase(),
      options: rawOptions is List
          ? rawOptions.map((option) => option.toString()).toList()
          : const [],
      subCategoryId: json['subCategoryId']?.toString() ??
          json['subcategoryId']?.toString() ??
          '',
    );
  }

  bool get isProductAttribute => appliesTo == 'PRODUCT';
  bool get isVariantAttribute =>
      appliesTo == 'VARIANT' && !isVariantSize && !isVariantColor;
  bool get isVariantSize => usage == 'variant_size';
  bool get isVariantColor => usage == 'variant_color';
}
