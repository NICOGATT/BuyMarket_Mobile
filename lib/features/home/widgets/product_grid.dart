// import 'package:buymarket_frontend/features/home/widgets/product_card.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import './product_grid_card.dart';

class ProductGrid extends StatelessWidget{
  final List<Product> products;

  const ProductGrid({
    super.key, 
    required this.products,
  }); 

  @override
  Widget build(BuildContext context) {
    if(products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'No hay productos disponibles 😢',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return GridView.builder(
      itemCount : products.length, 
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        mainAxisSpacing: 14, 
        crossAxisSpacing: 14, 
        childAspectRatio: 0.58
      ),
      itemBuilder : (context, index) {
        final product = products[index]; 

        return ProductGridCard(product: product);
      }
    );
  }
}