import 'package:flutter/material.dart';
import '../models/product.dart';
import '../../../core/routes/app_routes.dart';
import '../../favorites/services/favorite_services_instances.dart';
import '../../cart/services/cart_services_instances.dart';

class ProductGridCard extends StatelessWidget {
  final Product product;

  const ProductGridCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final hasValidId = product.id.trim().isNotEmpty;
    final hasVariants = product.variants.isNotEmpty;
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
                    product.category,
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
                    hasVariants
                        ? 'Elegí una variante'
                        : product.stock > 0
                            ? 'Stock: ${product.stock}'
                            : 'Sin stock',
                    style: TextStyle(
                      color: hasVariants || product.stock > 0
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
                      onPressed: !hasVariants && product.stock <= 0
                          ? null
                          : () {
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
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.productDetail,
                                  arguments: product,
                                );
                                return;
                              }

                              cartService.addProduct(product.id);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product.title} agregado al carrito',
                                  ),
                                ),
                              );
                            },
                      icon: const Icon(Icons.shopping_cart, size: 18),
                      label: Text(hasVariants ? 'Elegir' : 'Agregar'),
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
    final preview = attributes.take(2).map((attribute) {
      return '${attribute.name}: ${attribute.value}';
    }).join(' · ');

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

  const _ProductImage({
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final image = imageUrl.isEmpty
        ? const _ProductImagePlaceholder()
        : Image.network(
            imageUrl,
            height: 135,
            width: double.infinity,
            fit: BoxFit.scaleDown,
            errorBuilder: (context, error, stackTrace) {
              return const _ProductImagePlaceholder();
            },
          );

    if (heroTag == null) {
      return image;
    }

    return Hero(
      tag: heroTag!,
      child: image,
    );
  }
}

class _ProductImagePlaceholder extends StatelessWidget {
  const _ProductImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 135,
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
