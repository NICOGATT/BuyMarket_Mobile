import 'package:buymarket_frontend/features/home/widgets/category_grid_card.dart';
import 'package:flutter/material.dart';

import '../../categories/services/category_service_instace.dart';
import 'sub_category_selection_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  @override
  void initState() {
    super.initState();
    categoryService.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Seleccionar categoria',
          style: TextStyle(
            color: Color(0xff2D006B),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff2D006B)),
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

          final categories = categoryService.categories;
          if (categories.isEmpty) {
            return const Center(child: Text('No hay categorias disponibles'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryGridCard(
                category: category,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubCategorySelectionScreen(
                        selectedCategory: category,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
