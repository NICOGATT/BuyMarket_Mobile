import 'package:flutter/material.dart';

import '../../home/models/product.dart';
import '../../home/services/product_api_service.dart';
import '../../home/widgets/product_grid_card.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}


class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final ProductApiService _productApiServices = ProductApiService();

  bool isLoading = true;
  String? error;
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    loadProductsByCategory();
  }

  Future<void> loadProductsByCategory() async {
    try {
      final data = await _productApiServices.getProductsByCategory(
        widget.categoryId,
      );

      setState(() {
        products = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            color: Color(0xff5E2CA5),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff5E2CA5)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : products.isEmpty
                  ? const Center(child: Text('No hay productos en esta categoría'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: products.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.62,
                      ),
                      itemBuilder: (context, index) {
                        final product = products[index];

                        return ProductGridCard(product: product);
                      },
                    ),
    );
  }
}