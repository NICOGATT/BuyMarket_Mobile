import 'package:flutter/material.dart';

import '../../../core/config/api.config.dart';
import '../../../shared/widgets/market_header.dart';
import '../models/category_model.dart';
import '../../auth/services/auth_services_instance.dart';
import '../../home/models/product.dart';
import '../../home/services/product_api_service.dart';
import '../../home/widgets/category_navigation_bar.dart';
import '../../home/widgets/product_filter_section.dart';
import '../../home/widgets/product_grid.dart';
import '../../products/screens/all_products_screen.dart';
import '../../products/screens/brand_products_screen.dart';
import 'categories_screen.dart';

typedef CategoryProductLoader =
    Future<List<Product>> Function(String categoryId);
typedef OwnedProductLoader = Future<List<Product>> Function();

class CategoryProductsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String? categoryDescription;
  final String? categoryIcon;
  final String? categoryBanner;
  final CategoryProductLoader? productLoader;
  final OwnedProductLoader? ownedProductLoader;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.categoryDescription,
    this.categoryIcon,
    this.categoryBanner,
    this.productLoader,
    this.ownedProductLoader,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  late final CategoryProductLoader _productLoader;

  bool _isLoading = true;
  String? _error;
  List<Product> _products = const [];

  @override
  void initState() {
    super.initState();
    _productLoader =
        widget.productLoader ?? (_) => ProductApiService().getProducts();
    _loadProductsByCategory();
  }

  List<Product> get _categoryProducts => _products
      .where(
        (product) => product.matchesCategory(
          widget.categoryId,
          widget.categoryName,
        ),
      )
      .toList();

  Future<void> _loadProductsByCategory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final publicProducts = await _productLoader(widget.categoryId);
      final productsById = <String, Product>{
        for (final product in publicProducts) product.id: product,
      };

      final token = authServices.token;
      final ownedLoader =
          widget.ownedProductLoader ??
          (widget.productLoader == null && token != null
              ? () => ProductApiService().getMyProducts(
                  token: token,
                )
              : null);
      if (ownedLoader != null) {
        try {
          final ownedProducts = await ownedLoader();
          for (final product in ownedProducts) {
            productsById[product.id] = product;
          }
        } catch (_) {
          // El catálogo público sigue disponible aunque falle Mis productos.
        }
      }

      if (!mounted) return;
      setState(() {
        _products = productsById.values.toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar los productos de esta categoría.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            MarketHeader(
              searchHint: 'Buscar productos',
              onSearchChanged: (_) {},
              onSearchSubmitted: _openSearchResults,
            ),
            CategoryNavigationBar(
              selectedCategoryId: widget.categoryId,
              showHome: true,
              onHomeTap: () => Navigator.popUntil(
                context,
                (route) => route.isFirst,
              ),
              onCategoryTap: _openCategory,
              onViewMoreTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                );
              },
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  void _openCategory(CategoryModel category) {
    if (category.id == widget.categoryId) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryProductsScreen(
          categoryId: category.id,
          categoryName: category.name,
          categoryDescription: category.description,
          categoryIcon: category.icon,
          categoryBanner: category.banner,
          productLoader: widget.productLoader,
          ownedProductLoader: widget.ownedProductLoader,
        ),
      ),
    );
  }

  void _openSearchResults(String value) {
    final query = value.trim();
    if (query.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AllProductsScreen(
          initialSearch: query,
          productLoader: () async => _products,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildStateBody(const Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return _buildStateBody(
        _MessageState(
          icon: Icons.cloud_off_outlined,
          message: _error!,
          actionLabel: 'Reintentar',
          onAction: _loadProductsByCategory,
        ),
      );
    }

    final categoryProducts = _categoryProducts;

    if (categoryProducts.isEmpty) {
      return _buildStateBody(
        const _MessageState(
          icon: Icons.inventory_2_outlined,
          message: 'No hay productos para esa categoria',
        ),
      );
    }

    final featuredProducts = categoryProducts
        .where((product) => product.isFeatured)
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ..._categoryHeader,
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (featuredProducts.isNotEmpty) ...[
                  const Text(
                    'Productos destacados',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ProductGrid(products: featuredProducts),
                ],
                const SizedBox(height: 24),
                ProductFilterSection(
                  title: 'Todos los productos',
                  products: categoryProducts,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> get _categoryHeader => [
    _CategoryTitle(
      categoryName: widget.categoryName,
      categoryIcon: widget.categoryIcon,
    ),
    _CategoryPromoBanner(
      categoryName: widget.categoryName,
      description: widget.categoryDescription,
      banner: widget.categoryBanner,
    ),
  ];

  Widget _buildStateBody(Widget state) {
    return ListView(
      children: [
        ..._categoryHeader,
        SizedBox(height: 260, child: state),
      ],
    );
  }
}

class _CategoryTitle extends StatelessWidget {
  final String categoryName;
  final String? categoryIcon;

  const _CategoryTitle({required this.categoryName, this.categoryIcon});

  @override
  Widget build(BuildContext context) {
    final isPetsCategory = _isPetsCategory(categoryName);
    final imageUrl = _buildCategoryImageUrl(categoryIcon);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              categoryName,
              key: const Key('category-title-text'),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xff2D006B),
                fontFamily: 'serif',
                fontSize: 30,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (isPetsCategory)
            Image.asset(
              'assets/images/CategoriaMascotas.png',
              key: const Key('pets-category-image'),
              width: 48,
              height: 48,
              fit: BoxFit.contain,
            )
          else if (imageUrl != null)
            Image.network(
              imageUrl,
              key: const Key('category-title-image'),
              width: 48,
              height: 48,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                _categoryIconForName(categoryName),
                key: const Key('category-title-icon'),
                color: const Color(0xff2D006B),
                size: 36,
              ),
            )
          else
            Icon(
              _categoryIconForName(categoryName),
              key: const Key('category-title-icon'),
              color: const Color(0xff2D006B),
              size: 36,
            ),
        ],
      ),
    );
  }
}

class _CategoryPromoBanner extends StatelessWidget {
  final String categoryName;
  final String? description;
  final String? banner;

  const _CategoryPromoBanner({
    required this.categoryName,
    this.description,
    this.banner,
  });

  @override
  Widget build(BuildContext context) {
    final presentation = _categoryPresentation(categoryName);
    final bannerUrl = _buildCategoryImageUrl(banner);
    final bannerDescription = description?.trim().isNotEmpty == true
        ? description!.trim()
        : presentation.description;

    return Container(
      height: 270,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: presentation.colors,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x182D006B),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (bannerUrl != null) ...[
            Image.network(
              bannerUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    presentation.colors.first.withValues(alpha: 0.88),
                    presentation.colors.last.withValues(alpha: 0.82),
                  ],
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bannerDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'MARCAS DESTACADAS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: presentation.brands.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 10),
                    itemBuilder: (context, index) => _FeaturedBrandCard(
                      brand: presentation.brands[index],
                      colorIndex: index,
                      onTap: () {
                        final brand = presentation.brands[index];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BrandProductsScreen(
                              brandName: brand,
                              imageAsset:
                                  brand.trim().toLowerCase() == 'rpm'
                                  ? 'assets/images/rpm_logo_white.png'
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedBrandCard extends StatelessWidget {
  final String brand;
  final int colorIndex;
  final VoidCallback onTap;

  const _FeaturedBrandCard({
    required this.brand,
    required this.colorIndex,
    required this.onTap,
  });

  static const _logoGradients = [
    [Color(0xffFF9A56), Color(0xffFF4D00)],
    [Color(0xffFF929A), Color(0xffF40046)],
    [Color(0xffFFD22E), Color(0xffF28A00)],
    [Color(0xff67C9F4), Color(0xff246BFD)],
    [Color(0xffB3A2FF), Color(0xff5740EF)],
  ];

  @override
  Widget build(BuildContext context) {
    final logoColors = _logoGradients[colorIndex % _logoGradients.length];
    final isRpm = brand.trim().toLowerCase() == 'rpm';

    return Material(
      color: const Color(0xffFFF9F4),
      borderRadius: BorderRadius.circular(16),
      elevation: 3,
      shadowColor: const Color(0x26000000),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 132,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isRpm ? Colors.white : null,
                    gradient: isRpm
                        ? null
                        : LinearGradient(colors: logoColors),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isRpm
                      ? Padding(
                          padding: const EdgeInsets.all(6),
                          child: Image.asset(
                            'assets/images/rpm_logo_white.png',
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Text(
                          _brandInitials(brand),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                brand,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xff190A35),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffFF7A00),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Ofertas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _brandInitials(String brand) {
  final words = brand
      .replaceAll(RegExp(r"[^A-Za-zÀ-ÿ0-9 ]"), '')
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();
  if (words.isEmpty) return 'BM';
  if (words.length == 1) {
    final end = words.first.length >= 2 ? 2 : 1;
    return words.first.substring(0, end).toUpperCase();
  }
  return '${words.first[0]}${words[1][0]}'.toUpperCase();
}

String? _buildCategoryImageUrl(String? image) {
  if (image == null || image.trim().isEmpty) return null;

  final value = image.trim();
  if (value.startsWith('http://localhost:3000')) {
    return value.replaceFirst('http://localhost:3000', ApiConfig.baseUrl);
  }
  if (value.startsWith('http')) return value;

  final separator = value.startsWith('/') ? '' : '/';
  return '${ApiConfig.baseUrl}$separator$value';
}

({String description, List<String> brands, List<Color> colors})
_categoryPresentation(String categoryName) {
  final name = _normalizeCategoryName(categoryName);

  if (name.contains('mascota')) {
    return (
      description:
          'Todo para acompañar, cuidar y consentir a tus mascotas cada día.',
      brands: const ['RPM', 'Pedigree', 'Royal Canin', 'Purina', 'Pro Plan'],
      colors: const [Color(0xffF6A800), Color(0xffD94A00)],
    );
  }
  if (name.contains('comput')) {
    return (
      description:
          'Equipos, periféricos y accesorios para estudiar, trabajar y jugar.',
      brands: const ['Lenovo', 'HP', 'Logitech', 'Asus', 'Dell'],
      colors: const [Color(0xff0891B2), Color(0xff1D4ED8)],
    );
  }
  if (name.contains('tecno') || name.contains('electron')) {
    return (
      description:
          'Tecnología para conectar, crear y disfrutar todos los días.',
      brands: const ['Apple', 'Samsung', 'Xiaomi', 'Motorola', 'Sony'],
      colors: const [Color(0xff4338CA), Color(0xff2563EB)],
    );
  }
  if (name.contains('indument') ||
      name.contains('ropa') ||
      name.contains('moda')) {
    return (
      description:
          'Prendas y tendencias para encontrar un estilo que se sienta propio.',
      brands: const ['Nike', 'Adidas', "Levi's", 'Puma', 'Zara'],
      colors: const [Color(0xffDB2777), Color(0xff7C3AED)],
    );
  }
  if (name.contains('belleza') || name.contains('cuidado')) {
    return (
      description: 'Belleza y cuidado personal con opciones para cada rutina.',
      brands: const ["L'Oréal", 'Nivea', 'Maybelline', 'Garnier', 'Dove'],
      colors: const [Color(0xffF43F5E), Color(0xffC026D3)],
    );
  }
  if (name.contains('accesorio')) {
    return (
      description:
          'Detalles que completan tu estilo y acompañan todos tus planes.',
      brands: const ['Ray-Ban', 'Casio', 'Pandora', 'Swatch', 'Tous'],
      colors: const [Color(0xffB45309), Color(0xff6D28D9)],
    );
  }
  if (name.contains('alimento')) {
    return (
      description:
          'Sabores, bebidas y opciones para disfrutar en cualquier momento.',
      brands: const ['Arcor', 'Nestlé', 'Coca-Cola', 'Pepsi', 'Lucchetti'],
      colors: const [Color(0xff15803D), Color(0xffEA580C)],
    );
  }
  if (name.contains('hogar')) {
    return (
      description: 'Productos prácticos para renovar y disfrutar cada espacio.',
      brands: const ['Philips', 'Tramontina', 'Samsung', 'Atma', 'Drean'],
      colors: const [Color(0xff0F766E), Color(0xff2563EB)],
    );
  }
  if (name.contains('deporte')) {
    return (
      description:
          'Equipamiento e indumentaria para moverte y alcanzar nuevas metas.',
      brands: const ['Nike', 'Adidas', 'Puma', 'Reebok', 'Under Armour'],
      colors: const [Color(0xff059669), Color(0xff0F4C81)],
    );
  }

  return (
    description:
        'Descubrí productos seleccionados, novedades y ofertas en $categoryName.',
    brands: const ['Destacados', 'Más vendidos', 'Novedades', 'Ofertas'],
    colors: const [Color(0xff5E2CA5), Color(0xff168BEE)],
  );
}

String _normalizeCategoryName(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u');
}

bool _isPetsCategory(String categoryName) {
  return _normalizeCategoryName(categoryName).replaceAll(RegExp(r'\s+'), '') ==
      'mascotas';
}

IconData _categoryIconForName(String categoryName) {
  final normalized = _normalizeCategoryName(categoryName);

  if (normalized.contains('tecnologia') || normalized.contains('electronica')) {
    return Icons.devices;
  }
  if (normalized.contains('ropa') || normalized.contains('moda')) {
    return Icons.checkroom;
  }
  if (normalized.contains('hogar')) return Icons.home;
  if (normalized.contains('deporte')) return Icons.sports_soccer;
  if (normalized.contains('belleza')) return Icons.face_retouching_natural;
  if (normalized.contains('alimento')) return Icons.restaurant;

  return Icons.category;
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: Colors.grey),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, color: Colors.black54),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
