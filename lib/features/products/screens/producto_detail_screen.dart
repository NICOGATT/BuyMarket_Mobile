import 'package:flutter/material.dart';

import '../../cart/services/cart_services_instances.dart';
import '../../favorites/services/favorite_services_instances.dart';
import '../../home/models/product.dart';
import '../../home/services/product_api_service.dart';

typedef ProductDetailLoader = Future<Product> Function(String productId);
typedef ProductCartAdder =
    Future<void> Function(String productId, {String? variantId});

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final ProductDetailLoader? productLoader;
  final ProductCartAdder? cartAdder;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.productLoader,
    this.cartAdder,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _pageController = PageController();
  late final ProductDetailLoader _productLoader;
  late final ProductCartAdder _cartAdder;
  late Product _product;
  late final String? _heroTag;
  int _currentImageIndex = 0;
  bool _isLoadingDetail = false;
  String? _detailError;
  String? _selectedSize;
  String? _selectedColorKey;

  Product get product => _product;
  bool get _hasVariants => product.variants.isNotEmpty;

  ProductVariantModel? get _selectedVariant {
    if (!_hasVariants) return null;

    ProductVariantModel? firstMatch;
    for (final variant in product.variants) {
      final matchesSize = variant.size == _selectedSize;
      final matchesColor = _variantColorKey(variant) == _selectedColorKey;
      if (!matchesSize || !matchesColor) continue;
      if (variant.isAvailable) return variant;
      firstMatch ??= variant;
    }

    return firstMatch;
  }

  int get _visibleStock => _selectedVariant?.stock ?? product.stock;
  String get _visiblePrice {
    final variant = _selectedVariant;
    if (variant == null) return product.price;
    final decimals = variant.price.truncateToDouble() == variant.price ? 0 : 2;
    return variant.price.toStringAsFixed(decimals);
  }

  @override
  void initState() {
    super.initState();
    _productLoader = widget.productLoader ?? ProductApiService().getProductById;
    _cartAdder =
        widget.cartAdder ??
        (productId, {variantId}) =>
            cartService.addProduct(productId, variantId: variantId);
    _product = widget.product;
    _heroTag = widget.product.id.trim().isNotEmpty
        ? 'product-${widget.product.id}-${identityHashCode(widget.product)}'
        : null;
    _initializeVariantSelection();
    _loadProductDetail();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadProductDetail() async {
    if (widget.product.id.trim().isEmpty) {
      setState(() {
        _detailError = 'No se pudo cargar el detalle de este producto';
        _isLoadingDetail = false;
      });
      return;
    }

    setState(() {
      _isLoadingDetail = true;
      _detailError = null;
    });

    try {
      final detail = await _productLoader(widget.product.id);
      debugPrint(
        'PRODUCT DETAIL attributes parsed: ${detail.attributes.length}',
      );
      if (!mounted) return;
      setState(() {
        _product = detail;
        _initializeVariantSelection();
        _isLoadingDetail = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _detailError = e.toString();
        _isLoadingDetail = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          product.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xff5E2CA5),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xff5E2CA5)),
        actions: [
          AnimatedBuilder(
            animation: favoritesService,
            builder: (context, child) {
              final isFavorite = favoritesService.isFavorite(product.id);
              return IconButton(
                onPressed: product.id.trim().isEmpty
                    ? null
                    : () {
                        favoritesService.toggleFavorite(product.id);
                      },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_isLoadingDetail) const LinearProgressIndicator(minHeight: 2),
            if (_detailError != null)
              _DetailErrorBanner(message: _detailError!),
            _ImageCarousel(
              product: product,
              pageController: _pageController,
              currentIndex: _currentImageIndex,
              heroTag: _heroTag,
              onPageChanged: (index) {
                setState(() => _currentImageIndex = index);
              },
            ),
            const SizedBox(height: 16),
            _MainInfoSection(
              product: product,
              price: _visiblePrice,
              stock: _visibleStock,
            ),
            if (_hasVariants) ...[
              const SizedBox(height: 12),
              _VariantSelectorSection(
                sizes: _sizeOptions,
                colors: _colorOptionsForSelectedSize,
                selectedSize: _selectedSize,
                selectedColor: _selectedColorKey,
                selectedVariant: _selectedVariant,
                hasAvailableVariant: product.variants.any(
                  (variant) => variant.isAvailable,
                ),
                onSizeChanged: _selectSize,
                onColorChanged: _selectColor,
              ),
            ],
            const SizedBox(height: 12),
            _ClassificationSection(product: product),
            const SizedBox(height: 12),
            _DescriptionSection(product: product),
            const SizedBox(height: 12),
            _AttributesSection(
              title: _hasVariants
                  ? 'Caracteristicas de la variante seleccionada'
                  : 'Caracteristicas del producto',
              attributes: _visibleAttributes,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed:
                  (_hasVariants && _selectedVariant?.isAvailable != true) ||
                      (!_hasVariants && _visibleStock <= 0)
                  ? null
                  : () async {
                      if (product.id.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No se pudo agregar este producto'),
                          ),
                        );
                        return;
                      }

                      final variant = _selectedVariant;
                      if (_hasVariants && variant == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Seleccioná una variante disponible'),
                          ),
                        );
                        return;
                      }

                      if (variant != null && !variant.isAvailable) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Esta variante no está disponible'),
                          ),
                        );
                        return;
                      }

                      await _cartAdder(product.id, variantId: variant?.id);

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.title} agregado al carrito'),
                        ),
                      );
                    },
              icon: const Icon(Icons.shopping_cart),
              label: const Text(
                'Agregar al carrito',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff5E2CA5),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _initializeVariantSelection() {
    final variants = product.variants;
    if (variants.isEmpty) {
      _selectedSize = null;
      _selectedColorKey = null;
      return;
    }

    final variant = _preferredVariant(variants);
    _selectedSize = variant?.size;
    _selectedColorKey = variant == null ? null : _variantColorKey(variant);
  }

  ProductVariantModel? _preferredVariant(List<ProductVariantModel> variants) {
    for (final variant in variants) {
      if (variant.isAvailable) return variant;
    }

    return null;
  }

  List<_VariantOption> get _sizeOptions {
    final sizes = _uniqueValues(
      product.variants.map((variant) => variant.size),
    );

    return sizes.map((size) {
      final variants = product.variants.where(
        (variant) => variant.size == size,
      );
      return _VariantOption(
        value: size,
        isAvailable: variants.any((variant) => variant.isAvailable),
      );
    }).toList();
  }

  List<_ColorOption> get _colorOptionsForSelectedSize {
    final variants = _selectedSize == null
        ? product.variants.toList()
        : product.variants
              .where((variant) => variant.size == _selectedSize)
              .toList();
    final colors = _uniqueValues(variants.map(_variantColorKey));

    return colors.map((colorKey) {
      final matchingVariants = variants
          .where((variant) => _variantColorKey(variant) == colorKey)
          .toList();
      String? colorHex;
      String? label;
      for (final variant in matchingVariants) {
        label ??= _nonEmptyValue(variant.color);
        colorHex ??= _normalizedColorHex(variant.colorHex);
      }

      return _ColorOption(
        value: colorKey,
        label: label,
        colorHex: colorHex,
        isAvailable: matchingVariants.any((variant) => variant.isAvailable),
      );
    }).toList();
  }

  List<ProductAttributeValue> get _visibleAttributes {
    final variant = _selectedVariant;
    if (variant == null) return product.attributes;

    return variant.attributes
        .where(
          (attribute) =>
              attribute.name.trim().isNotEmpty &&
              attribute.value.trim().isNotEmpty,
        )
        .map(
          (attribute) => ProductAttributeValue(
            name: attribute.name,
            value: attribute.value,
          ),
        )
        .toList();
  }

  List<String> _uniqueValues(Iterable<String?> values) {
    final result = <String>[];
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed == null || trimmed.isEmpty) continue;
      if (!result.contains(trimmed)) result.add(trimmed);
    }
    return result;
  }

  void _selectSize(String size) {
    setState(() {
      _selectedSize = size;
      final variantsForSize = product.variants
          .where((variant) => variant.size == size)
          .toList();
      final currentColorIsAvailable = variantsForSize.any(
        (variant) =>
            _variantColorKey(variant) == _selectedColorKey &&
            variant.isAvailable,
      );

      if (!currentColorIsAvailable) {
        final preferredVariant = _preferredVariant(variantsForSize);
        _selectedColorKey = preferredVariant == null
            ? null
            : _variantColorKey(preferredVariant);
      }
    });
  }

  void _selectColor(String colorKey) {
    setState(() {
      _selectedColorKey = colorKey;
    });
  }

  String? _variantColorKey(ProductVariantModel variant) {
    final color = _nonEmptyValue(variant.color);
    if (color != null) return 'name:${color.toLowerCase()}';

    final colorHex = _normalizedColorHex(variant.colorHex);
    if (colorHex != null) return 'hex:$colorHex';

    return null;
  }
}

class _ImageCarousel extends StatelessWidget {
  final Product product;
  final PageController pageController;
  final int currentIndex;
  final String? heroTag;
  final ValueChanged<int> onPageChanged;

  const _ImageCarousel({
    required this.product,
    required this.pageController,
    required this.currentIndex,
    required this.heroTag,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final images = product.imageUrls;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: images.isEmpty
                ? const _EmptyImage()
                : _DetailImages(
                    images: images,
                    pageController: pageController,
                    onPageChanged: onPageChanged,
                    heroTag: heroTag,
                  ),
          ),
          if (images.length > 1) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                final isActive = index == currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: isActive ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xff5E2CA5)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyImage extends StatelessWidget {
  const _EmptyImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xffF6F7FB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 56,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class _DetailImages extends StatelessWidget {
  final List<String> images;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final String? heroTag;

  const _DetailImages({
    required this.images,
    required this.pageController,
    required this.onPageChanged,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final pageView = PageView.builder(
      controller: pageController,
      itemCount: images.length,
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Image.network(
            images[index],
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const _EmptyImage();
            },
          ),
        );
      },
    );

    if (heroTag == null) {
      return pageView;
    }

    return Hero(tag: heroTag!, child: pageView);
  }
}

class _DetailErrorBanner extends StatelessWidget {
  final String message;

  const _DetailErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xffFFF7E6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xffB7791F), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xff6B4E16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MainInfoSection extends StatelessWidget {
  final Product product;
  final String price;
  final int stock;

  const _MainInfoSection({
    required this.product,
    required this.price,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.title,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Color(0xff2D006B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '\$$price',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xff168BEE),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                stock > 0 ? Icons.check_circle_outline : Icons.cancel_outlined,
                color: stock > 0 ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                stock > 0 ? 'Stock: $stock' : 'Sin stock',
                style: TextStyle(
                  color: stock > 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VariantSelectorSection extends StatelessWidget {
  final List<_VariantOption> sizes;
  final List<_ColorOption> colors;
  final String? selectedSize;
  final String? selectedColor;
  final ProductVariantModel? selectedVariant;
  final bool hasAvailableVariant;
  final ValueChanged<String> onSizeChanged;
  final ValueChanged<String> onColorChanged;

  const _VariantSelectorSection({
    required this.sizes,
    required this.colors,
    required this.selectedSize,
    required this.selectedColor,
    required this.selectedVariant,
    required this.hasAvailableVariant,
    required this.onSizeChanged,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isUnavailable =
        !hasAvailableVariant ||
        (selectedVariant != null && !selectedVariant!.isAvailable);

    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Elegí tu variante'),
          if (sizes.isNotEmpty) ...[
            const SizedBox(height: 12),
            _OptionGroup(
              label: 'Talle',
              options: sizes,
              selectedValue: selectedSize,
              onChanged: onSizeChanged,
            ),
          ],
          if (colors.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ColorOptionGroup(
              options: colors,
              selectedValue: selectedColor,
              onChanged: onColorChanged,
            ),
          ],
          if (isUnavailable) ...[
            const SizedBox(height: 12),
            const Text(
              'Esta variante no está disponible',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );
  }
}

class _OptionGroup extends StatelessWidget {
  final String label;
  final List<_VariantOption> options;
  final String? selectedValue;
  final ValueChanged<String> onChanged;

  const _OptionGroup({
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xff666666),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = option.value == selectedValue;
            return ChoiceChip(
              key: Key('variant-size-${option.value}'),
              label: Text(option.value),
              selected: isSelected,
              onSelected: option.isAvailable
                  ? (_) => onChanged(option.value)
                  : null,
              selectedColor: const Color(0xff5E2CA5).withValues(alpha: 0.16),
              labelStyle: TextStyle(
                color: !option.isAvailable
                    ? Colors.black38
                    : isSelected
                    ? const Color(0xff5E2CA5)
                    : Colors.black87,
                fontWeight: FontWeight.w700,
              ),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xff5E2CA5)
                    : Colors.grey.withValues(alpha: 0.35),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ColorOptionGroup extends StatelessWidget {
  final List<_ColorOption> options;
  final String? selectedValue;
  final ValueChanged<String> onChanged;

  const _ColorOptionGroup({
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(
            color: Color(0xff666666),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = option.value == selectedValue;
            final swatchColor = _parseHexColor(option.colorHex);
            final accessibleLabel =
                option.label ?? option.colorHex ?? 'Color disponible';
            final widgetKey = option.label ?? option.colorHex ?? option.value;

            return Semantics(
              label: 'Color $accessibleLabel',
              button: true,
              selected: isSelected,
              enabled: option.isAvailable,
              child: Tooltip(
                message: accessibleLabel,
                child: ChoiceChip(
                  key: Key('variant-color-$widgetKey'),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (swatchColor != null)
                        Container(
                          key: Key('variant-color-swatch-$widgetKey'),
                          width: option.label == null ? 24 : 16,
                          height: option.label == null ? 24 : 16,
                          decoration: BoxDecoration(
                            color: swatchColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black26),
                          ),
                        ),
                      if (swatchColor != null && option.label != null)
                        const SizedBox(width: 7),
                      if (option.label != null)
                        Text(option.label!)
                      else if (swatchColor == null)
                        Text(accessibleLabel),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: option.isAvailable
                      ? (_) => onChanged(option.value)
                      : null,
                  selectedColor: const Color(
                    0xff5E2CA5,
                  ).withValues(alpha: 0.16),
                  labelStyle: TextStyle(
                    color: !option.isAvailable
                        ? Colors.black38
                        : isSelected
                        ? const Color(0xff5E2CA5)
                        : Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xff5E2CA5)
                        : Colors.grey.withValues(alpha: 0.35),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _VariantOption {
  final String value;
  final bool isAvailable;

  const _VariantOption({required this.value, required this.isAvailable});
}

class _ColorOption extends _VariantOption {
  final String? label;
  final String? colorHex;

  const _ColorOption({
    required super.value,
    required super.isAvailable,
    this.label,
    this.colorHex,
  });
}

Color? _parseHexColor(String? value) {
  final normalized = _normalizedColorHex(value);
  if (normalized == null) return null;

  final rgb = int.parse(normalized.substring(1), radix: 16);
  return Color(0xff000000 | rgb);
}

String? _normalizedColorHex(String? value) {
  final normalized = value?.trim();
  if (normalized == null ||
      !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(normalized)) {
    return null;
  }

  return normalized.toUpperCase();
}

String? _nonEmptyValue(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}

class _ClassificationSection extends StatelessWidget {
  final Product product;

  const _ClassificationSection({required this.product});

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Clasificacion'),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.category_outlined,
            label: 'Categoria',
            value: product.category.isEmpty
                ? 'Sin categoria'
                : product.category,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.account_tree_outlined,
            label: 'Subcategoria',
            value: product.subCategory?.isNotEmpty == true
                ? product.subCategory!
                : 'Sin subcategoria',
          ),
        ],
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  final Product product;

  const _DescriptionSection({required this.product});

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Descripcion'),
          const SizedBox(height: 8),
          Text(
            product.description.isEmpty
                ? 'Sin descripcion'
                : product.description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Color(0xff666666),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttributesSection extends StatelessWidget {
  final String title;
  final List<ProductAttributeValue> attributes;

  const _AttributesSection({required this.title, required this.attributes});

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title),
          const SizedBox(height: 12),
          if (attributes.isEmpty)
            const Text(
              'Sin caracteristicas cargadas',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            )
          else
            ...attributes.map((attribute) => _AttributeTile(attribute)),
        ],
      ),
    );
  }
}

class _AttributeTile extends StatelessWidget {
  final ProductAttributeValue attribute;

  const _AttributeTile(this.attribute);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.18)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              attribute.name,
              style: const TextStyle(
                color: Color(0xff666666),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              attribute.value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xff2D006B),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final Widget child;

  const _DetailCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Color(0xff333333),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xff168BEE), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xff333333),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
