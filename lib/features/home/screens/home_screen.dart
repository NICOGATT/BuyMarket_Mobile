import 'package:buymarket_frontend/features/categories/screens/categories_screen.dart';
import 'package:buymarket_frontend/features/categories/screens/category_products_screen.dart';
import 'package:buymarket_frontend/features/categories/services/category_service_instace.dart';
import 'package:buymarket_frontend/features/home/services/product_services.dart';
import 'package:buymarket_frontend/features/products/screens/all_products_screen.dart';
import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
// import '../widgets/product_card.dart';
import '../models/product.dart';
// import '../../../shared/widgets/search_input.dart';
import '../widgets/category_navigation_bar.dart';
// import '../../cart/services/cart_services.dart';
import '../../cart/services/cart_services_instances.dart';
import '../widgets/promo_banner.dart';
import '../widgets/featured_brands_carousel.dart';
import '../widgets/product_filter_section.dart';
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
  final ScrollController _scrollController = ScrollController();

  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
    categoryService.loadCategories();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _exploreProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AllProductsScreen()),
    );
  }

  Future<void> loadProducts() async {
    try {
      await productServices.loadProducts();

      final result = productServices.products;

      await cartService.loadCart();

      if (!mounted) return;

      setState(() {
        products = result;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  List<Product> get filteredProducts {
    final query = search.trim();
    return products.where((product) {
      final matchesSearch = product.matchesSearch(query);
      final matchesCategory =
          query.isNotEmpty ||
          selectedCategory.isEmpty ||
          product.categoryId == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final featuredProducts = products;
    final offerProducts = products
        .where((product) => product.hasOffer)
        .toList();
    final allProducts = filteredProducts;
    final isSearching = search.trim().isNotEmpty;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            MarketHeader(
              searchHint: 'Buscar productos',
              onProfileTap: () => Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamed(AppRoutes.profile),
              onSearchChanged: (value) {
                setState(() {
                  search = value;
                });
              },
            ),

            CategoryNavigationBar(
              selectedCategoryId: selectedCategory,
              onCategoryTap: (category) {
                setState(() {
                  selectedCategory = category.id;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryProductsScreen(
                      categoryId: category.id,
                      categoryName: category.name,
                      categoryDescription: category.description,
                      categoryIcon: category.icon,
                      categoryBanner: category.banner,
                    ),
                  ),
                );
              },
              onViewMoreTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                );
              },
            ),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                  ? Center(child: Text(errorMessage!))
                  : ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (isSearching) ...[
                          if (allProducts.isEmpty)
                            const _SearchEmptyState()
                          else
                            ProductFilterSection(
                              title: 'Resultados para “${search.trim()}”',
                              products: allProducts,
                              titleStyle: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff2D006B),
                              ),
                              emptyMessage:
                                  'No hay resultados con esos filtros.',
                            ),
                        ] else ...[
                          PromoBanner(
                            onExplore: _exploreProducts,
                            onSell: () => Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushNamed(AppRoutes.addProduct),
                          ),
                          const SizedBox(height: 26),
                          const FeaturedBrandsCarousel(),
                          const SizedBox(height: 26),
                          const Text(
                            'Productos destacados',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff2D006B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ProductGrid(products: featuredProducts),
                          const SizedBox(height: 20),
                          const Text(
                            'Ofertas',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff2D006B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (offerProducts.isEmpty)
                            const _OffersEmptyState()
                          else
                            ProductGrid(products: offerProducts),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 70, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: Color(0xffEEE6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off,
              size: 44,
              color: Color(0xff5E2CA5),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No encontramos productos',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xff2D006B),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Probá buscando otro título o marca.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _OffersEmptyState extends StatelessWidget {
  const _OffersEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x1AFF7A00)),
      ),
      child: const Column(
        children: [
          Icon(Icons.local_offer_outlined, color: Color(0xffF97316), size: 38),
          SizedBox(height: 10),
          Text(
            'No hay ofertas disponibles por el momento',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xff2D006B),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Cuando un producto tenga un cupón o descuento, aparecerá aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
