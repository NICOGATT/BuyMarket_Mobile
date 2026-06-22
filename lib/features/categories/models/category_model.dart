class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? banner;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.banner,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      banner: json['banner'],
    );
  }
}