import 'package:buymarket_frontend/core/config/api.config.dart';

class Product {
  final String id;
  final String title;
  final String brand;
  final String description;
  final String price;
  final String category;
  final String? categoryId;
  final String? subCategory;
  final String? subCategoryId;
  final String imageUrl;
  final List<ProductMediaItem> media;
  final List<ProductAttributeValue> attributes;
  final List<ProductVariantModel> variants;
  final int stock;
  final bool isFeatured;
  final int discountPercentage;
  final String promotionLabel;
  final String approvalStatus;
  final bool hasFreeShipping;

  const Product({
    required this.id,
    required this.title,
    this.brand = '',
    required this.description,
    required this.category,
    this.categoryId,
    this.subCategory,
    this.subCategoryId,
    required this.price,
    required this.imageUrl,
    required this.media,
    required this.attributes,
    this.variants = const [],
    required this.stock,
    this.isFeatured = false,
    this.discountPercentage = 0,
    this.promotionLabel = '',
    this.approvalStatus = '',
    this.hasFreeShipping = false,
  });

  bool get hasOffer => discountPercentage > 0 || promotionLabel.isNotEmpty;

  bool get isPendingApproval =>
      _normalizeSearchText(approvalStatus) == 'pending' ||
      _normalizeSearchText(approvalStatus) == 'pendiente';

  String get offerBadgeText =>
      discountPercentage > 0 ? '-$discountPercentage%' : promotionLabel;

  List<String> get imageUrls {
    final urls = media
        .where((item) => item.type == 'image' && item.url.isNotEmpty)
        .map((item) => item.url)
        .toList();

    if (urls.isNotEmpty) {
      return urls;
    }

    return imageUrl.isNotEmpty ? [imageUrl] : const [];
  }

  bool matchesSearch(String query) {
    final normalizedQuery = _normalizeSearchText(query);
    if (normalizedQuery.isEmpty) return true;

    return _normalizeSearchText(title).contains(normalizedQuery) ||
        _normalizeSearchText(brand).contains(normalizedQuery);
  }

  bool matchesBrand(String brandName) {
    final normalizedBrand = _normalizeSearchText(brandName);
    return normalizedBrand.isNotEmpty &&
        _normalizeSearchText(brand) == normalizedBrand;
  }

  bool matchesCategory(String id, String name) {
    if (categoryId?.trim().isNotEmpty == true) {
      return categoryId == id;
    }
    return _normalizeSearchText(category) == _normalizeSearchText(name);
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final media = _parseMedia(json);
    final firstImageUrl = _firstImageUrl(media);
    final imageUrl = firstImageUrl.isNotEmpty
        ? firstImageUrl
        : _buildUrl(_readImageValue(json) ?? '');
    final categoryJson = json['category'];
    final attributes = _parseAttributes(json);
    final productId = _readString(json, ['id', 'productId', 'product_id']);
    final parsedBrand = _readBrand(json, attributes);
    final offer = _readOffer(json, attributes);
    final subCategoryJson =
        json['subCategory'] ?? json['subcategory'] ?? json['sub_category'];

    return Product(
      id: productId,
      title: json['title']?.toString() ?? '',
      brand: parsedBrand.isNotEmpty
          ? parsedBrand
          : _legacyBrandByProductId[productId] ?? '',
      description: json['description']?.toString() ?? '',
      category: categoryJson is Map
          ? categoryJson['name']?.toString() ?? ''
          : json['category']?.toString() ?? '',
      categoryId: categoryJson is Map
          ? categoryJson['id']?.toString()
          : json['categoryId']?.toString(),
      subCategory: subCategoryJson is Map
          ? subCategoryJson['name']?.toString()
          : (json['subCategory'] ?? json['subcategory'])?.toString(),
      subCategoryId: subCategoryJson is Map
          ? subCategoryJson['id']?.toString()
          : (json['subCategoryId'] ?? json['subcategoryId'])?.toString(),
      price: json['price'].toString(),
      imageUrl: imageUrl,
      media: media,
      attributes: attributes,
      variants: _parseVariants(json),
      stock: json['stock'] is int
          ? json['stock'] as int
          : int.tryParse(json['stock']?.toString() ?? '') ?? 0,
      isFeatured: _readBool(json['isFeatured']),
      discountPercentage: offer.percentage,
      promotionLabel: offer.label,
      approvalStatus:
          (json['approvalStatus'] ?? json['approval_status'])?.toString() ?? '',
      hasFreeShipping: _readFreeShipping(json, attributes),
    );
  }

  static bool _readFreeShipping(
    Map<String, dynamic> json,
    List<ProductAttributeValue> attributes,
  ) {
    final directValue =
        json['hasFreeShipping'] ??
        json['freeShipping'] ??
        json['free_shipping'] ??
        json['envioGratis'] ??
        json['envíoGratis'];
    if (_readBool(directValue)) return true;

    for (final attribute in attributes) {
      final name = _normalizeSearchText(attribute.name);
      if (name.contains('envio gratis') || name.contains('free shipping')) {
        final value = _normalizeSearchText(attribute.value);
        return value == 'si' ||
            value == 'true' ||
            value == 'gratis' ||
            value == 'incluido' ||
            value == '1';
      }
    }

    return false;
  }

  static List<ProductMediaItem> _parseMedia(Map<String, dynamic> json) {
    final rawMedia =
        json['media'] ??
        json['productMedia'] ??
        json['product_media'] ??
        json['medias'] ??
        json['images'] ??
        [];

    if (rawMedia is! List) return const [];

    final media = rawMedia
        .map((item) {
          if (item is String) {
            return ProductMediaItem(
              id: '',
              url: _buildUrl(item),
              type: 'image',
              isCover: false,
              order: 0,
            );
          }

          if (item is Map) {
            return ProductMediaItem.fromJson(Map<String, dynamic>.from(item));
          }

          return null;
        })
        .whereType<ProductMediaItem>()
        .toList();

    media.sort((a, b) {
      if (a.isCover != b.isCover) return a.isCover ? -1 : 1;
      return a.order.compareTo(b.order);
    });

    return media;
  }

  static String _firstImageUrl(List<ProductMediaItem> media) {
    for (final item in media) {
      if (item.type == 'image' && item.url.isNotEmpty) {
        return item.url;
      }
    }

    return '';
  }

  static String? _readImageValue(Map<String, dynamic> json) {
    const imageKeys = [
      'url',
      'path',
      'fileUrl',
      'imageUrl',
      'image',
      'filename',
      'key',
    ];

    for (final key in imageKeys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    final nestedMedia = json['media'];
    if (nestedMedia is Map) {
      return _readImageValue(Map<String, dynamic>.from(nestedMedia));
    }

    return null;
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return '';
  }

  static double _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _readBool(dynamic value, {bool defaultValue = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().toLowerCase().trim();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
    return defaultValue;
  }

  static List<ProductVariantModel> _parseVariants(Map<String, dynamic> json) {
    final rawVariants =
        json['variants'] ??
        json['productVariants'] ??
        json['product_variants'] ??
        [];

    if (rawVariants is! List) return const [];

    return rawVariants
        .map((item) {
          if (item is! Map) return null;
          return ProductVariantModel.fromJson(Map<String, dynamic>.from(item));
        })
        .whereType<ProductVariantModel>()
        .where((variant) => variant.id.isNotEmpty)
        .toList();
  }

  static List<ProductAttributeValue> _parseAttributes(
    Map<String, dynamic> json,
  ) {
    final rawAttributes =
        json['attributeValues'] ??
        json['attribute_values'] ??
        json['productAttributeValues'] ??
        json['product_attribute_values'] ??
        json['attributes'] ??
        json['productAttributes'] ??
        json['product_attributes'] ??
        json['characteristics'] ??
        json['features'] ??
        [];

    if (rawAttributes is Map) {
      return rawAttributes.entries.map((entry) {
        return ProductAttributeValue(
          name: entry.key.toString(),
          value: entry.value?.toString() ?? '',
        );
      }).toList();
    }

    if (rawAttributes is! List) return const [];

    return rawAttributes
        .map((item) {
          if (item is! Map) return null;
          final itemMap = Map<String, dynamic>.from(item);

          final attribute =
              itemMap['attribute'] ??
              itemMap['subCategoryAttribute'] ??
              itemMap['sub_category_attribute'] ??
              itemMap['subCategoryAttributeId'] ??
              itemMap['attributeDefinition'];

          final name = attribute is Map
              ? (attribute['name'] ?? attribute['label'] ?? attribute['title'])
                    ?.toString()
              : (itemMap['name'] ??
                        itemMap['attributeName'] ??
                        itemMap['label'] ??
                        itemMap['key'] ??
                        itemMap['attributeId'])
                    ?.toString();

          final value =
              itemMap['value'] ??
              itemMap['attributeValue'] ??
              itemMap['valor'] ??
              itemMap['selectedValue'] ??
              itemMap['textValue'] ??
              itemMap['numberValue'] ??
              itemMap['booleanValue'];

          if (name == null || name.isEmpty || value == null) return null;

          return ProductAttributeValue(name: name, value: value.toString());
        })
        .whereType<ProductAttributeValue>()
        .toList();
  }

  static String _readBrand(
    Map<String, dynamic> json,
    List<ProductAttributeValue> attributes,
  ) {
    final rawBrand =
        json['brand'] ??
        json['marca'] ??
        json['manufacturer'] ??
        json['brandName'];

    if (rawBrand is Map) {
      final name = rawBrand['name'] ?? rawBrand['nombre'] ?? rawBrand['label'];
      if (name != null && name.toString().trim().isNotEmpty) {
        return name.toString().trim();
      }
    } else if (rawBrand != null && rawBrand.toString().trim().isNotEmpty) {
      return rawBrand.toString().trim();
    }

    for (final attribute in attributes) {
      final name = _normalizeSearchText(attribute.name);
      if (name == 'marca' || name == 'brand' || name == 'fabricante') {
        return attribute.value.trim();
      }
    }

    return '';
  }

  // Compatibilidad temporal para publicaciones anteriores al atributo Marca.
  static const _legacyBrandByProductId = {
    'feaaf6dd-86f0-4be4-a530-010be5c3f12d': 'RPM',
    'c72ca6f9-c875-4167-b05c-1cfbbde34d85': 'RPM',
    'bc346cd9-c740-447e-b887-ac0cdd23263c': 'RPM',
  };

  static ({int percentage, String label}) _readOffer(
    Map<String, dynamic> json,
    List<ProductAttributeValue> attributes,
  ) {
    final rawOfferValue =
        json['coupon'] ??
        json['cupon'] ??
        json['promotion'] ??
        json['promocion'] ??
        json['promo'] ??
        json['discount'];
    final rawOffer = rawOfferValue is List && rawOfferValue.isNotEmpty
        ? rawOfferValue.first
        : rawOfferValue;
    final offerData = rawOffer is Map
        ? Map<String, dynamic>.from(rawOffer)
        : const <String, dynamic>{};

    final activeValue =
        offerData['isActive'] ?? offerData['active'] ?? offerData['enabled'];
    if (activeValue != null && !_readBool(activeValue)) {
      return (percentage: 0, label: '');
    }

    final rawPercentage =
        json['discountPercentage'] ??
        json['discount_percentage'] ??
        json['discountPercent'] ??
        json['percentageOff'] ??
        json['porcentajeDescuento'] ??
        offerData['percentage'] ??
        offerData['percent'] ??
        offerData['discountPercentage'] ??
        offerData['value'] ??
        (rawOffer is num ? rawOffer : null);
    final percentageText = rawPercentage?.toString().replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final parsedPercentage = int.tryParse(percentageText ?? '') ?? 0;
    var percentage = parsedPercentage > 100 ? 100 : parsedPercentage;

    var label = _readString(json, const [
      'promotionLabel',
      'promotionText',
      'promoText',
      'couponCode',
      'couponLabel',
    ]);
    if (label.isEmpty && offerData.isNotEmpty) {
      label = _readString(offerData, const [
        'label',
        'title',
        'name',
        'code',
        'description',
      ]);
    }
    if (label.isEmpty && rawOffer is String && rawOffer.trim().isNotEmpty) {
      label = rawOffer.trim();
    }

    if (percentage == 0 && label.isEmpty) {
      for (final attribute in attributes) {
        final name = _normalizeSearchText(attribute.name);
        if (name.contains('descuento')) {
          final digits = attribute.value.replaceAll(RegExp(r'[^0-9]'), '');
          final parsed = int.tryParse(digits) ?? 0;
          if (parsed > 0) {
            percentage = parsed > 100 ? 100 : parsed;
            break;
          }
        }
        if (name.contains('cupon') || name.contains('promocion')) {
          label = attribute.value.trim();
          if (label.isNotEmpty) break;
        }
      }
    }

    final explicitlyActive = _readBool(
      json['hasCoupon'] ?? json['hasDiscount'] ?? json['isOnSale'],
    );
    if (label.isEmpty && percentage == 0 && explicitlyActive) {
      label = 'Cupón disponible';
    }

    return (percentage: percentage, label: label);
  }

  static String _normalizeSearchText(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u');
  }

  static String _buildUrl(String url) {
    if (url.isEmpty) return '';

    if (url.startsWith('http://localhost:3000')) {
      return url.replaceFirst('http://localhost:3000', ApiConfig.baseUrl);
    }

    if (url.startsWith('http')) return url;

    if (url.startsWith('/')) return '${ApiConfig.baseUrl}$url';

    return '${ApiConfig.baseUrl}/$url';
  }
}

class ProductMediaItem {
  final String id;
  final String url;
  final String type;
  final bool isCover;
  final int order;

  const ProductMediaItem({
    required this.id,
    required this.url,
    required this.type,
    required this.isCover,
    required this.order,
  });

  factory ProductMediaItem.fromJson(Map<String, dynamic> json) {
    return ProductMediaItem(
      id: json['id']?.toString() ?? '',
      url: Product._buildUrl(Product._readImageValue(json) ?? ''),
      type: json['type']?.toString() ?? 'image',
      isCover: json['isCover'] == true,
      order: json['order'] is int
          ? json['order'] as int
          : int.tryParse(json['order']?.toString() ?? '') ?? 0,
    );
  }
}

class ProductAttributeValue {
  final String name;
  final String value;

  const ProductAttributeValue({required this.name, required this.value});
}

class ProductVariantModel {
  final String id;
  final String? size;
  final String? color;
  final String? colorHex;
  final double price;
  final int stock;
  final bool isActive;
  final List<ProductVariantAttributeModel> attributes;

  const ProductVariantModel({
    required this.id,
    this.size,
    this.color,
    this.colorHex,
    required this.price,
    required this.stock,
    required this.isActive,
    required this.attributes,
  });

  bool get isAvailable => isActive && stock > 0;

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    final rawAttributes =
        json['attributes'] ??
        json['attributeValues'] ??
        json['variantAttributes'] ??
        json['variant_attributes'] ??
        [];

    return ProductVariantModel(
      id: Product._readString(json, ['id', 'variantId', 'variant_id']),
      size: _emptyToNull(json['size']?.toString()),
      color: _emptyToNull(json['color']?.toString()),
      colorHex: _emptyToNull(
        (json['colorHex'] ?? json['color_hex'])?.toString(),
      ),
      price: Product._readDouble(json['price']),
      stock: Product._readInt(json['stock']),
      isActive: Product._readBool(json['isActive'], defaultValue: true),
      attributes: rawAttributes is List
          ? rawAttributes
                .map((item) {
                  if (item is! Map) return null;
                  return ProductVariantAttributeModel.fromJson(
                    Map<String, dynamic>.from(item),
                  );
                })
                .whereType<ProductVariantAttributeModel>()
                .toList()
          : const [],
    );
  }

  static String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}

class ProductVariantAttributeModel {
  final String attributeId;
  final String name;
  final String value;

  const ProductVariantAttributeModel({
    required this.attributeId,
    required this.name,
    required this.value,
  });

  factory ProductVariantAttributeModel.fromJson(Map<String, dynamic> json) {
    final attribute =
        json['attribute'] ??
        json['subCategoryAttribute'] ??
        json['sub_category_attribute'] ??
        json['attributeDefinition'];

    final name = attribute is Map
        ? (attribute['name'] ?? attribute['label'] ?? attribute['title'])
              ?.toString()
        : (json['name'] ?? json['attributeName'] ?? json['label'])?.toString();

    final value =
        json['value'] ??
        json['attributeValue'] ??
        json['selectedValue'] ??
        json['textValue'] ??
        json['numberValue'] ??
        json['booleanValue'];
    final directAttributeId = Product._readString(json, [
      'attributeId',
      'attribute_id',
      'id',
    ]);
    final nestedAttributeId = attribute is Map
        ? Product._readString(Map<String, dynamic>.from(attribute), [
            'id',
            'attributeId',
            'attribute_id',
          ])
        : '';

    return ProductVariantAttributeModel(
      attributeId: directAttributeId.isNotEmpty
          ? directAttributeId
          : nestedAttributeId,
      name: name ?? '',
      value: value?.toString() ?? '',
    );
  }
}
