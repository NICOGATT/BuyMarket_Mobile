import 'package:flutter/material.dart';
import '../models/product.dart';
import '../../../core/routes/app_routes.dart';
import '../../favorites/services/favorite_services_instances.dart';
import '../../cart/services/cart_services_instances.dart';

class ProductGridCard extends StatelessWidget{
  final Product product; 

  const ProductGridCard ({
    super.key, 
    required this.product
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context, 
          AppRoutes.productDetail, 
          arguments: product
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color : Colors.black.withValues(alpha: 0.08), 
              blurRadius: 10, 
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18)
                  ),
                  child: Hero(
                    tag: 'product-${product.id}', 
                    child: Image.network(
                      product.imageUrl,
                      height: 135,
                      width: double.infinity,
                      fit: BoxFit.scaleDown,
                    ),
                  )
                ), 
                Positioned(
                  top: 8,
                  left: 8,
                  child: AnimatedBuilder(
                    animation: favoritesService, 
                    builder: (context, child) {
                      final isFavorite = favoritesService.isFavorite(product.id); 

                      return GestureDetector(
                        onTap: () {
                          favoritesService.toggleFavorite(product.id);
                        },
                        child:Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95), 
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.05),
                            )
                          ),
                          child:Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border, 
                            color: Colors.red,
                            size: 28,
                          ) ,
                        ) 
                        ,
                      );
                    }
                  ),
                ),
              ],
            ), 
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16, 
                      color: Color(0xff5E2CA5), 
                      fontWeight: FontWeight.bold
                    ),
                  ), 
                  
                  Text(
                    product.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),

                  Text(
                    '\$${product.price}',
                    style: const TextStyle(
                      fontSize: 16, 
                      color: Color(0xff5E2CA5),
                      fontWeight: FontWeight.bold,
                    ),
                  ), 
                  
                  const SizedBox(height: 8,), 

                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        cartService.addProduct(product); 
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.title} agregando al carrito')
                          )
                        );
                      }, 
                      icon: const Icon(Icons.shopping_cart, size: 18,),
                      label: const Text("Agregar"),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}