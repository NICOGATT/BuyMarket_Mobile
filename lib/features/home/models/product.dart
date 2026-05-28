class Product {
  final int id; 
  final String title; 
  final String description; 
  final String price;
  final String category; 
  final String imageUrl; 

  const Product({
    required this.id, 
    required this.title, 
    required this.description, 
    required this.category, 
    required this.price, 
    required this.imageUrl,
  }); 

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id : json['id'],
      title : json['title'],
      description : json['description'],
      category : json['category'],
      price : json['price'].toString(),
      imageUrl : json['image'],
    );
  }
}