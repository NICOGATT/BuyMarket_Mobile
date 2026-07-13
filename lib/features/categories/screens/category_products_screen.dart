import 'package:flutter/material.dart';

import '../../../shared/widgets/market_header.dart';
import '../../home/models/product.dart';
import '../../home/services/product_api_service.dart';
import '../../home/widgets/product_grid.dart';

typedef CategoryProductLoader = Future<List<Product>> Function(
  String categoryId,
);

class CategoryProductsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final CategoryProductLoader? productLoader;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.productLoader,
  });

  @override
  State<CategoryProductsScreen> createState() =>
      _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  late final CategoryProductLoader _productLoader;

  bool _isLoading = true;
  String? _error;
  String _search = '';
  List<Product> _products = const [];

  @override
  void initState() {
    super.initState();
    _productLoader = widget.productLoader ??
        ProductApiService().getProductsByCategory;
    _loadProductsByCategory();
  }

  List<Product> get _filteredProducts {
    final query = _search.trim().toLowerCase();
    if (query.isEmpty) return _products;

    return _products
        .where((product) => product.title.toLowerCase().contains(query))
        .toList();
  }

  Future<void> _loadProductsByCategory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products = await _productLoader(widget.categoryId);
      if (!mounted) return;
      setState(() {
        _products = products;
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
      backgroundColor: const Color(0xffFAF5FC),
      body: SafeArea(
        child: Column(
          children: [
            MarketHeader(
              searchHint: 'Buscar en ${widget.categoryName}',
              onSearchChanged: (value) => setState(() => _search = value),
            ),
            _CategoryTitle(categoryName: widget.categoryName),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _MessageState(
        icon: Icons.cloud_off_outlined,
        message: _error!,
        actionLabel: 'Reintentar',
        onAction: _loadProductsByCategory,
      );
    }

    if (_products.isEmpty) {
      return const _MessageState(
        icon: Icons.inventory_2_outlined,
        message: 'No hay productos para esa categoria',
      );
    }

    final filteredProducts = _filteredProducts;
    if (filteredProducts.isEmpty) {
      return const _MessageState(
        icon: Icons.search_off,
        message: 'No encontramos productos para tu búsqueda.',
      );
    }

    final featuredProducts = filteredProducts
        .where((product) => product.isFeatured)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
      children: [
        if (featuredProducts.isNotEmpty) ...[
          const _SectionTitle(title: 'Productos destacados'),
          const SizedBox(height: 14),
          ProductGrid(products: featuredProducts),
        ],
        const SizedBox(height: 24),
        const _SectionTitle(title: 'Todos los productos'),
        const SizedBox(height: 14),
        ProductGrid(products: filteredProducts),
      ],
    );
  }
}

class _CategoryTitle extends StatelessWidget {
  final String categoryName;

  const _CategoryTitle({required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _categoryIconForName(categoryName),
            key: const Key('category-title-icon'),
            color: const Color(0xff2D006B),
            size: 30,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              categoryName,
              key: const Key('category-title-text'),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xff2D006B),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _categoryIconForName(String categoryName) {
  final normalized = categoryName
      .trim()
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u');

  if (normalized.contains('tecnologia') ||
      normalized.contains('electronica')) {
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );
  }
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
