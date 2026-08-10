import 'package:flutter/material.dart';

import '../models/product.dart';

Future<ProductVariantModel?> showVariantSelectionModal(
  BuildContext context,
  Product product,
) {
  return showModalBottomSheet<ProductVariantModel>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => VariantSelectionModal(product: product),
  );
}

class VariantSelectionModal extends StatefulWidget {
  final Product product;

  const VariantSelectionModal({super.key, required this.product});

  @override
  State<VariantSelectionModal> createState() =>
      _VariantSelectionModalState();
}

class _VariantSelectionModalState extends State<VariantSelectionModal> {
  ProductVariantModel? _selectedVariant;

  @override
  void initState() {
    super.initState();
    for (final variant in widget.product.variants) {
      if (variant.isAvailable) {
        _selectedVariant = variant;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final variants = widget.product.variants;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.78,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Seleccioná una variante',
                        style: TextStyle(
                          color: Color(0xff2D006B),
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Cerrar',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (variants.isEmpty)
            const Padding(
              padding: EdgeInsets.all(28),
              child: Text(
                'Este producto no tiene variantes disponibles.',
                textAlign: TextAlign.center,
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                itemCount: variants.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final variant = variants[index];
                  return _VariantTile(
                    index: index,
                    product: widget.product,
                    variant: variant,
                    isSelected: variant.id == _selectedVariant?.id,
                    onTap: variant.isAvailable
                        ? () => setState(() => _selectedVariant = variant)
                        : null,
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
            child: FilledButton.icon(
              key: const Key('confirm-variant-add'),
              onPressed: _selectedVariant == null
                  ? null
                  : () => Navigator.pop(context, _selectedVariant),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xff5E2CA5),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.shopping_cart),
              label: const Text(
                'Agregar al carrito',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VariantTile extends StatelessWidget {
  final int index;
  final Product product;
  final ProductVariantModel variant;
  final bool isSelected;
  final VoidCallback? onTap;

  const _VariantTile({
    required this.index,
    required this.product,
    required this.variant,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _parseHexColor(variant.colorHex);
    final details = <String>[
      if (variant.size?.trim().isNotEmpty == true) 'Talle: ${variant.size}',
      if (variant.color?.trim().isNotEmpty == true) 'Color: ${variant.color}',
      ...variant.attributes
          .where(
            (attribute) =>
                attribute.name.trim().isNotEmpty &&
                attribute.value.trim().isNotEmpty,
          )
          .take(2)
          .map((attribute) => '${attribute.name}: ${attribute.value}'),
    ];
    final price = variant.price > 0
        ? _formatPrice(variant.price)
        : product.price;

    return Opacity(
      opacity: variant.isAvailable ? 1 : 0.5,
      child: Material(
        color: isSelected ? const Color(0xffF2ECFF) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          key: Key('variant-option-${variant.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? const Color(0xff5E2CA5)
                    : Colors.black12,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                if (color != null) ...[
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black26),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        details.isEmpty
                            ? 'Variante ${index + 1}'
                            : details.join(' · '),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        variant.isAvailable
                            ? 'Stock: ${variant.stock}'
                            : 'Sin stock',
                        style: TextStyle(
                          color: variant.isAvailable
                              ? Colors.green.shade700
                              : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$$price',
                      style: const TextStyle(
                        color: Color(0xff2D006B),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? const Color(0xff5E2CA5)
                          : Colors.black26,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatPrice(double value) {
  final decimals = value.truncateToDouble() == value ? 0 : 2;
  return value.toStringAsFixed(decimals);
}

Color? _parseHexColor(String? value) {
  final normalized = value?.trim();
  if (normalized == null ||
      !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(normalized)) {
    return null;
  }

  final rgb = int.parse(normalized.substring(1), radix: 16);
  return Color(0xff000000 | rgb);
}
