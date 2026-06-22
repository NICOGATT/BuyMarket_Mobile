class SubCategory {
  final String id;
  final String name;
  final String categoryId;

  const SubCategory({
    required this.id,
    required this.name,
    required this.categoryId,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: (json['id'] ?? json['_id']).toString(),
      name: (json['name'] ?? json['nombre'] ?? json['title'] ?? '')
          .toString(),
      categoryId: (json['categoryId'] ?? json['category_id'])?.toString() ??
          (json['category'] is Map
              ? (json['category']['id'] ?? json['category']['_id'])
                      ?.toString() ??
                  ''
              : ''),
    );
  }
}
