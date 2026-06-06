import 'package:flutter/material.dart';
import '../../home/models/product.dart';
import '../../cart/services/cart_services_instances.dart';
import '../../favorites/services/favorite_services_instances.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product; 

  const ProductDetailScreen ({
    super.key, 
    required this.product,
  }); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          product.title, 
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xff5E2CA5),
            fontWeight: FontWeight.bold
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xff5E2CA5),
        ),
        actions: [
          AnimatedBuilder(
            animation: favoritesService, 
            builder: (context, child) {
              final isFavorite = favoritesService.isFavorite(product.id); 
              return IconButton(
                onPressed: (){
                  favoritesService.toggleFavorite(product.id);
                }, 
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                )
              );
            }
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Hero(
                tag: 'product-${product.id}',
                child: Image.network(
                  product.imageUrl,
                  height: 280,
                  fit: BoxFit.contain,
                ),
              ),
            ), 

            const SizedBox(height: 16,), 

            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(18)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title, 
                    style: const TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xff5E2CA5),
                    ),
                  ), 

                  const SizedBox(height: 18,), 

                  const Text(
                    "Descripcion", 
                    style: TextStyle(
                      fontSize: 17, 
                      fontWeight: FontWeight.bold,
                      color: Color(0xff333333),
                    ),
                  ), 

                  const SizedBox(height: 8,), 

                  Text(
                    product.description, 
                    style: const TextStyle(
                      fontSize: 15, 
                      height: 1.4, 
                      color: Color(0xff666666),
                    ),
                  )
                ],
              ),
            ), 
            const SizedBox(height: 100,)
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                cartService.addProduct(product);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.title} agregado al carrito'),
                  ),
                );
              },
              icon: const Icon(Icons.shopping_cart),
              label: const Text(
                'Agregar al carrito',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff5E2CA5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      )
    );
  }
}