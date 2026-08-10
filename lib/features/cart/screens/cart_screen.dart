import 'package:buymarket_frontend/core/routes/app_routes.dart';
import 'package:buymarket_frontend/features/auth/services/auth_services_instance.dart';
import 'package:buymarket_frontend/features/cart/services/cart_services_instances.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    cartService.loadCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Carrito',
          style: TextStyle(
            color: Color(0xff5E2CA5),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: cartService,
        builder: (context, child) {
          final items = cartService.items;

          return items.isEmpty
              ? const Center(
                  child: Text(
                    "Tu carrito está vacío 🛒",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final product = item.product;

                          final media = product['media'] as List?;

                          String? imageUrl;

                          if (media != null && media.isNotEmpty) {
                            final firstMedia = media.first;

                            if (firstMedia is Map) {
                              imageUrl = firstMedia['url']?.toString();
                            }
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    imageUrl ?? '',
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.contain,
                                  ),
                                ),

                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['title'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xff5E2CA5),
                                        ),
                                      ),

                                      const SizedBox(height: 8),
                                      if (item.variantSize?.isNotEmpty ==
                                              true ||
                                          item.variantColor?.isNotEmpty ==
                                              true) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          [
                                            if (item.variantSize?.isNotEmpty ==
                                                true)
                                              'Talle: ${item.variantSize}',
                                            if (item.variantColor?.isNotEmpty ==
                                                true)
                                              'Color: ${item.variantColor}',
                                          ].join(' - '),
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],

                                      const SizedBox(height: 8),
                                      Text(
                                        '\$${item.unitPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        cartService.increaseQuantity(
                                          item.id,
                                          item.quantity,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.add_circle,
                                        color: Color(0xff5E2CA5),
                                      ),
                                    ),

                                    Text(
                                      '${item.quantity}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),

                                    IconButton(
                                      onPressed: () {
                                        cartService.decreaseQuantity(
                                          item.id,
                                          item.quantity,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () {
                                    cartService.removeItem(item.id);
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
        },
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: cartService,
        builder: (context, child) {
          final total = cartService.total;
          return Container(
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!authServices.isLoggeIn) {
                          Navigator.pushNamed(context, AppRoutes.authWelcome);
                          return;
                        }

                        //Usuario logueado
                        Navigator.pushNamed(context, AppRoutes.checkout);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff5E2CA5),
                        foregroundColor: Colors.white,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Finalizar comprar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
