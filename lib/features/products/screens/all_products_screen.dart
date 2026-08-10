import 'package:flutter/material.dart';

import '../../../shared/widgets/market_header.dart';
import '../../home/models/product.dart';
import '../../home/services/product_api_service.dart';
import '../../home/widgets/product_filter_section.dart';

typedef AllProductsLoader = Future<List<Product>> Function();

class AllProductsScreen extends StatefulWidget {
  final AllProductsLoader? productLoader;
  final String initialSearch;
  final bool autofocusSearch;

  const AllProductsScreen({
    super.key,
    this.productLoader,
    this.initialSearch = '',
    this.autofocusSearch = false,
  });

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  late final AllProductsLoader _productLoader;

  bool _isLoading = true;
  String? _error;
  late String _search;
  late final TextEditingController _searchController;
  List<Product> _products = const [];

  @override
  void initState() {
    super.initState();
    _search = widget.initialSearch;
    _searchController = TextEditingController(text: widget.initialSearch);
    _productLoader = widget.productLoader ?? ProductApiService().getProducts;
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    final query = _search.trim().toLowerCase();
    if (query.isEmpty) return _products;

    return _products.where((product) => product.matchesSearch(query)).toList();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products = await _productLoader();
      if (!mounted) return;
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar los productos.';
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
              searchController: _searchController,
              autofocus: widget.autofocusSearch,
              showBackButton: Navigator.canPop(context),
              onSearchChanged: (value) => setState(() => _search = value),
            ),
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
      return _AllProductsMessage(
        icon: Icons.cloud_off_outlined,
        message: _error!,
        actionLabel: 'Reintentar',
        onAction: _loadProducts,
      );
    }

    if (_products.isEmpty) {
      return const _AllProductsMessage(
        icon: Icons.inventory_2_outlined,
        message: 'No hay productos publicados.',
      );
    }

    final products = _filteredProducts;
    if (products.isEmpty) {
      return const _AllProductsMessage(
        icon: Icons.search_off,
        message: 'No encontramos productos para tu búsqueda.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
      child: ProductFilterSection(
        title: _search.trim().isEmpty
            ? 'Todos los productos'
            : 'Resultados para “${_search.trim()}”',
        products: products,
        includeCategoryFilter: true,
        titleStyle: const TextStyle(
          color: Color(0xff2D006B),
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AllProductsMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _AllProductsMessage({
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
