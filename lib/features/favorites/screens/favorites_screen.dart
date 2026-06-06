import 'package:buymarket_frontend/features/home/services/product_services.dart';
import 'package:buymarket_frontend/features/home/widgets/product_grid_card.dart';
import 'package:flutter/material.dart';
import '../../home/models/product.dart';
import '../services/favorite_services_instances.dart';
import '../../home/services/product_service_instance.dart';
class FavoritesScreen extends StatefulWidget{
  const FavoritesScreen({super.key}); 

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>{
  final ProductService productService =
      ProductService(); 

  List<Product> products = [];

  bool isLoading = true; 

  @override 
  void initState() {
    super.initState(); 
    productService.loadProducts();
  }

  Future<void> loadProducts() async {
    await productService.loadProducts();
    final result = productService.products;

    setState(() {
      
      products = result;
      isLoading = false;

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(
        title: const Text(
          'Favoritos', 
          style: TextStyle(
            color: Color(0xff5E2CA5), 
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body:AnimatedBuilder(
        animation: favoritesService,
        builder: (context, child) {

          final favoriteProducts = products.where(
            (product) {
              return favoritesService.isFavorite(product.id);
            },
          ).toList();

          if (favoriteProducts.isEmpty) {
            return const Center(
              child: Text(
                'No tienes productos favoritos ❤️',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(10),

            itemCount: favoriteProducts.length,

            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.60,
            ),

            itemBuilder: (context, index) {
              final product = favoriteProducts[index];

              return ProductGridCard(
                product: product,
              );
            },
          );
        },
      ), 
    );
  }

}