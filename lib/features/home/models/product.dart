import 'package:buymarket_frontend/core/config/api.config.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final String price;
  final String category;
  final String? categoryId;
  final String? subCategory;
  final String? subCategoryId;
  final String imageUrl;
  final List<ProductMediaItem> media;
  final List<ProductAttributeValue> attributes;
  final int stock;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.categoryId,
    this.subCategory,
    this.subCategoryId,
    required this.price,
    required this.imageUrl,
    required this.media,
    required this.attributes,
    required this.stock,
  });

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

  factory Product.fromJson(Map<String, dynamic> json) {
    final media = _parseMedia(json);
    final firstImageUrl = _firstImageUrl(media);
    final imageUrl = firstImageUrl.isNotEmpty
        ? firstImageUrl
        : _buildUrl(_readImageValue(json) ?? '');
    final categoryJson = json['category'];
    final subCategoryJson =
        json['subCategory'] ?? json['subcategory'] ?? json['sub_category'];

    return Product(
      id: _readString(json, ['id', 'productId', 'product_id']),
      title: json['title']?.toString() ?? '',
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
      attributes: _parseAttributes(json),
      stock: json['stock'] is int
          ? json['stock'] as int
          : int.tryParse(json['stock']?.toString() ?? '') ?? 0,
    );
  }

  static List<ProductMediaItem> _parseMedia(Map<String, dynamic> json) {
    final rawMedia = json['media'] ??
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

  static List<ProductAttributeValue> _parseAttributes(
    Map<String, dynamic> json,
  ) {
    final rawAttributes = json['attributes'] ??
        json['productAttributes'] ??
        json['product_attributes'] ??
        json['attributeValues'] ??
        json['attribute_values'] ??
        json['productAttributeValues'] ??
        json['product_attribute_values'] ??
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

          final attribute = itemMap['attribute'] ??
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

          final value = itemMap['value'] ??
              itemMap['attributeValue'] ??
              itemMap['valor'] ??
              itemMap['selectedValue'] ??
              itemMap['textValue'] ??
              itemMap['numberValue'] ??
              itemMap['booleanValue'];

          if (name == null || name.isEmpty || value == null) return null;

          return ProductAttributeValue(
            name: name,
            value: value.toString(),
          );
        })
        .whereType<ProductAttributeValue>()
        .toList();
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

  const ProductAttributeValue({
    required this.name,
    required this.value,
  });
}
