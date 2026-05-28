import 'package:flutter/material.dart';
import '../../home/models/product.dart';
import '../../home/widgets/product_card.dart';
import '../services/favorite_services_instances.dart';
import '../../home/services/product_services.dart';
class FavoritesScreen extends StatefulWidget{
  const FavoritesScreen({super.key}); 

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>{
  final ProductServices productService =
      ProductServices(); 

  List<Product> products = [];

  bool isLoading = true; 

  @override 
  void initState() {
    super.initState(); 
    loadProducts();
  }

  Future<void> loadProducts() async {

    final result =
        await productService.getProducts();

    setState(() {

      products = result;
      isLoading = false;

    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: favoritesService, 
      builder: (context, child) {
        final favoritesProducts = products.where((product) {
          return favoritesService.isFavorite(product.id);
        }).toList();
        if (isLoading) {

          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }
        if(favoritesProducts.isEmpty) {
          return const Center(child: Text('No tenes favoritos todavia'),);
        }

        return ListView(
          padding: const EdgeInsets.only(
            top: 40,
            left: 16,
            right: 16,
            bottom: 16,
          ),
          children: favoritesProducts.map((product){
            return ProductCard(product: product);
          }).toList(),
        );
      }
    );
  }

}