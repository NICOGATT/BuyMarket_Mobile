import 'package:flutter/material.dart';
import '../models/product.dart';
import '../../../core/routes/app_routes.dart';
import '../../favorites/services/favorite_services_instances.dart';
import '../../cart/services/cart_services_instances.dart';
import 'variant_selection_modal.dart';

class ProductGridCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onDelete;

  const ProductGridCard({super.key, required this.product, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final hasValidId = product.id.trim().isNotEmpty;
    final hasVariants = product.variants.isNotEmpty;
    final hasAvailableVariant = product.variants.any(
      (variant) => variant.isAvailable,
    );
    final heroTag = hasValidId
        ? 'product-${product.id}-${identityHashCode(product)}'
        : null;

    return GestureDetector(
      onTap: () {
        if (!hasValidId) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo abrir el detalle de este producto'),
            ),
          );
          return;
        }

        Navigator.pushNamed(
          context,
          AppRoutes.productDetail,
          arguments: product,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: _ProductImage(
                    imageUrl: product.imageUrl,
                    heroTag: heroTag,
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: AnimatedBuilder(
                    animation: favoritesService,
                    builder: (context, child) {
                      final isFavorite = favoritesService.isFavorite(
                        product.id,
                      );

                      return GestureDetector(
                        onTap: () async {
                          if (!hasValidId) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No se pudo actualizar este favorito',
                                ),
                              ),
                            );
                            return;
                          }

                          try {
                            await favoritesService.toggleFavorite(product.id);
                          } catch (e) {
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                            size: 28,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (product.hasOffer)
                  Positioned(
                    top: onDelete == null ? 8 : 50,
                    right: 8,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 104),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffFF7A00),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        product.offerBadgeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                if (onDelete != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.95),
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: 'Eliminar producto',
                        onPressed: onDelete,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xff5E2CA5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    product.brand.isNotEmpty
                        ? '${product.brand} · ${product.category}'
                        : product.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  Text(
                    '\$${product.price}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xff5E2CA5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    product.isPendingApproval
                        ? 'Pendiente de aprobación'
                        : hasVariants
                        ? 'Elegí una variante'
                        : product.stock > 0
                        ? 'Stock: ${product.stock}'
                        : 'Sin stock',
                    style: TextStyle(
                      color: product.isPendingApproval
                          ? const Color(0xffD97706)
                          : hasVariants || product.stock > 0
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (product.attributes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _AttributePreview(attributes: product.attributes),
                  ],

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton.icon(
                      onPressed:
                          (hasVariants && !hasAvailableVariant) ||
                              (!hasVariants && product.stock <= 0)
                          ? null
                          : () async {
                              if (!hasValidId) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'No se pudo agregar este producto',
                                    ),
                                  ),
                                );
                                return;
                              }

                              if (hasVariants) {
                                final variant =
                                    await showVariantSelectionModal(
                                      context,
                                      product,
                                    );
                                if (variant == null || !context.mounted) return;

                                await cartService.addProduct(
                                  product.id,
                                  variantId: variant.id,
                                );
                              } else {
                                await cartService.addProduct(product.id);
                              }

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product.title} agregado al carrito',
                                  ),
                                ),
                              );
                            },
                      icon: const Icon(Icons.shopping_cart, size: 18),
                      label: const Text('Agregar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttributePreview extends StatelessWidget {
  final List<ProductAttributeValue> attributes;

  const _AttributePreview({required this.attributes});

  @override
  Widget build(BuildContext context) {
    final preview = attributes
        .take(2)
        .map((attribute) {
          return '${attribute.name}: ${attribute.value}';
        })
        .join(' · ');

    return Text(
      preview,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Color(0xff666666),
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;

  const _ProductImage({required this.imageUrl, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    final image = SizedBox(
      height: 135,
      width: double.infinity,
      child: imageUrl.isEmpty
          ? const _ProductImagePlaceholder()
          : Image.network(
              imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const _ProductImagePlaceholder();
              },
            ),
    );

    if (heroTag == null) {
      return image;
    }

    return Hero(tag: heroTag!, child: image);
  }
}

class _ProductImagePlaceholder extends StatelessWidget {
  const _ProductImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xffF6F7FB),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey.shade400,
        size: 42,
      ),
    );
  }
}
