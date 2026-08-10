import 'package:buymarket_frontend/features/categories/screens/category_products_screen.dart';
import 'package:buymarket_frontend/features/home/widgets/category_grid_card.dart';
import 'package:buymarket_frontend/features/products/screens/all_products_screen.dart';
import 'package:flutter/material.dart';
import 'package:buymarket_frontend/core/config/api.config.dart';

import '../models/category_model.dart';
import '../services/category_service_instace.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    categoryService.loadCategories();
  }

  String? buildImageUrl(CategoryModel category) {
    final image = category.banner ?? category.icon;

    if (image == null || image.isEmpty) return null;

    if (image.startsWith('http')) {
      return image.replaceFirst('http://localhost:3000', ApiConfig.baseUrl);
    }

    return '${ApiConfig.baseUrl}$image';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Categorías',
          style: TextStyle(
            color: Color.fromARGB(255, 11, 8, 210),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 28, 8, 209)),
      ),
      body: AnimatedBuilder(
        animation: categoryService,
        builder: (context, _) {
          if (categoryService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (categoryService.error != null) {
            return Center(child: Text(categoryService.error!));
          }

          if (categoryService.categories.isEmpty) {
            return const Center(child: Text('No hay categorías disponibles'));
          }

          final categories = categoryService.categories;

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final category = categories[index];

                    return CategoryGridCard(
                      category: category,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryProductsScreen(
                              categoryId: category.id,
                              categoryName: category.name,
                              categoryDescription: category.description,
                              categoryIcon: category.icon,
                              categoryBanner: category.banner,
                            ),
                          ),
                        );
                      },
                    );
                  }, childCount: categories.length),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xff2D006B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AllProductsScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'VER TODOS LOS PRODUCTOS',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
