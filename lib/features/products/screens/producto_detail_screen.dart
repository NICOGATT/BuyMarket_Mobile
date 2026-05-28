import 'package:flutter/material.dart';
import '../../home/models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product; 

  const ProductDetailScreen ({
    super.key, 
    required this.product,
  }); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              product.imageUrl, 
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ), 
            const SizedBox(height: 20,), 

            Text(
              product.title, 
              style: const TextStyle(
                fontSize: 26, 
                fontWeight: FontWeight.bold,
              ),
            ), 
            Text(product.category), 

            const SizedBox(height: 12,), 

            Text(
              product.price, 
              style: const TextStyle(
                fontSize: 22, 
                color: Colors.deepPurple, 
                fontWeight: FontWeight.bold,
              ),
            ), 

            const SizedBox(height: 12,), 
            
            Text(product.description), 

            const Spacer(), 

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:() {}, 
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Agregar al carrito'),
              ),
            )
          ],
        ),
      ),
    );
  }
}