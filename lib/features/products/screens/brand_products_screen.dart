import 'package:flutter/material.dart';

import '../../../shared/widgets/market_header.dart';
import '../../home/models/product.dart';
import '../../home/services/product_api_service.dart';
import '../../home/widgets/product_filter_section.dart';

typedef BrandProductsLoader = Future<List<Product>> Function();

class BrandProductsScreen extends StatefulWidget {
  final String brandName;
  final String? imageAsset;
  final BrandProductsLoader? productLoader;

  const BrandProductsScreen({
    super.key,
    required this.brandName,
    this.imageAsset,
    this.productLoader,
  });

  @override
  State<BrandProductsScreen> createState() => _BrandProductsScreenState();
}

class _BrandProductsScreenState extends State<BrandProductsScreen> {
  late final BrandProductsLoader _productLoader;

  bool _isLoading = true;
  String? _error;
  String _search = '';
  List<Product> _products = const [];

  @override
  void initState() {
    super.initState();
    _productLoader = widget.productLoader ?? ProductApiService().getProducts;
    _loadProducts();
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
        _products = products
            .where((product) => product.matchesBrand(widget.brandName))
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar los productos de esta marca.';
        _isLoading = false;
      });
    }
  }

  List<Product> get _filteredProducts {
    final query = _search.trim();
    if (query.isEmpty) return _products;
    return _products.where((product) => product.matchesSearch(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            MarketHeader(
              searchHint: 'Buscar en ${widget.brandName}',
              onSearchChanged: (value) => setState(() => _search = value),
            ),
            _BrandHeader(
              brandName: widget.brandName,
              imageAsset: widget.imageAsset,
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
      return _BrandProductsMessage(
        icon: Icons.cloud_off_outlined,
        message: _error!,
        actionLabel: 'Reintentar',
        onAction: _loadProducts,
      );
    }

    if (_products.isEmpty) {
      return _BrandProductsMessage(
        icon: Icons.inventory_2_outlined,
        message: 'No hay productos publicados de ${widget.brandName}.',
      );
    }

    final products = _filteredProducts;
    if (products.isEmpty) {
      return const _BrandProductsMessage(
        icon: Icons.search_off,
        message: 'No encontramos productos para tu búsqueda.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
      child: ProductFilterSection(
        title: 'Productos disponibles',
        products: products,
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  final String brandName;
  final String? imageAsset;

  const _BrandHeader({required this.brandName, this.imageAsset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            padding: EdgeInsets.all(imageAsset == null ? 0 : 5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: imageAsset == null
                  ? const Color(0xff5E2CA5)
                  : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x262D006B),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: imageAsset == null
                ? Text(
                    _brandInitials(brandName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                : ClipOval(
                    child: Image.asset(
                      imageAsset!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Flexible(
            child: Text(
              'Productos de $brandName',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xff2D006B),
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandProductsMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _BrandProductsMessage({
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

String _brandInitials(String brand) {
  final words = brand
      .trim()
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
