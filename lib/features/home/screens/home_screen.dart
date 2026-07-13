import 'package:buymarket_frontend/features/categories/screens/categories_screen.dart';
import 'package:buymarket_frontend/features/categories/screens/category_products_screen.dart';
import 'package:buymarket_frontend/features/categories/services/category_service_instace.dart';
import 'package:buymarket_frontend/features/home/services/product_services.dart';
import 'package:flutter/material.dart';
// import '../widgets/product_card.dart';
import '../models/product.dart';
// import '../../../shared/widgets/search_input.dart';
import '../widgets/category_chip.dart';
// import '../../cart/services/cart_services.dart';
import '../../cart/services/cart_services_instances.dart';
import '../widgets/promo_banner.dart';
import '../widgets/product_grid.dart';
import '../../../shared/widgets/market_header.dart';

// import '../widgets/product_grid_card.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String search = "";
  String selectedCategory = "";
  String? errorMessage;

  final ProductService productServices = ProductService();

  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
    categoryService.loadCategories();
  }

  Future<void> loadProducts() async {
    try {
      await productServices.loadProducts();

      final result = productServices.products;

      await cartService.loadCart();

      setState(() {
        products = result;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  List<Product> get filteredProducts {
    return products.where((product) {
      final matchesSearch = product.title.toLowerCase().contains(
        search.toLowerCase(),
      );
      final matchesCategory =
          selectedCategory.isEmpty || product.categoryId == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final recommendedProduct = products.take(3).toList();
    final allProducts = filteredProducts;
    return Scaffold(
      backgroundColor: const Color(0xffFAF5FC),
      body: SafeArea(
        child: Column(
          children: [
            MarketHeader(
              onSearchChanged: (value) {
                setState(() {
                  search = value;
                });
              },
            ),

           Container(
              color: const Color(0xff9ED8FF),
              height: 52,
              child: AnimatedBuilder(
                animation: categoryService,
                builder: (context, _) {
                  final categories = categoryService.categories.take(4).toList();

                  if (categoryService.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    itemCount: categories.length + 1,
                    separatorBuilder: (context, index) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      if (index == categories.length) {
                        return ActionChip(
                          label: const Text('Ver más'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CategoriesScreen(),
                              ),
                            );
                          },
                        );
                      }

                      final category = categories[index];

                      return CategoryChip(
                        title: category.name,
                        isSelected: selectedCategory == category.id,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryProductsScreen(
                                categoryId: category.id,
                                categoryName: category.name,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                  ? Center(child: Text(errorMessage!))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        PromoBanner(),

                        const SizedBox(height: 20),

                        const Text(
                          'Recomendados',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        ProductGrid(products: recommendedProduct),

                        const SizedBox(height: 20),

                        const Text(
                          'Todos los productos',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        ProductGrid(products: allProducts),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
