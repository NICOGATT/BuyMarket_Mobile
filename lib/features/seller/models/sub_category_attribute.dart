class SubCategoryAttribute {
  final String id;
  final String name;
  final String type;
  final bool isRequired;
  final List<String> options;
  final String subCategoryId;

  const SubCategoryAttribute({
    required this.id,
    required this.name,
    required this.type,
    required this.isRequired,
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
      options: rawOptions is List
          ? rawOptions.map((option) => option.toString()).toList()
          : const [],
      subCategoryId: json['subCategoryId']?.toString() ??
          json['subcategoryId']?.toString() ??
          '',
    );
  }
}
