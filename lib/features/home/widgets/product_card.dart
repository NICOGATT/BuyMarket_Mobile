// import 'package:buymarket_frontend/features/cart/services/cart_services_instances.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
// import '../../products/screens/producto_detail_screen.dart';
import '../../cart/services/cart_services_instances.dart';
import '../../favorites/services/favorite_services_instances.dart';
import '../../../core/routes/app_routes.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.productDetail,
          arguments: product,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Positioned(
              right: 10,
              top: 10,
              child: AnimatedBuilder(
                animation: favoritesService,
                builder: (context, child) {
                  final isFavorite = favoritesService.isFavorite(product.id);
                  return GestureDetector(
                    onTap: () {
                      favoritesService.toggleFavorite(product.id);
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
            //IMAGE
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),

              child: SizedBox(
                height: 140,
                child: Image.network(
                  product.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsetsGeometry.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    product.category,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  Text(
                    product.price,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton.icon(
                      onPressed: () {
                        cartService.addProduct(product.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${product.title} agregado al carrito',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Agregar al carrito'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
