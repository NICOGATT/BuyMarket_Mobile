import 'package:buymarket_frontend/features/favorites/screens/favorites_screen.dart';
import 'package:flutter/material.dart';
import '../../home/screens/home_screen.dart';
import '../../cart/screens/cart_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../cart/services/cart_services_instances.dart';
import '../../../core/routes/app_routes.dart';
import '../../home/models/product.dart';
import '../../products/screens/producto_detail_screen.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigationScreen> {
  int currentIndex = 0;

  final GlobalKey<NavigatorState> _homeNavigatorKey =
      GlobalKey<NavigatorState>();

  late final List<Widget> screens = [
    NavigatorPopHandler<Object?>(
      onPopWithResult: (_) => _homeNavigatorKey.currentState?.pop(),
      child: Navigator(
        key: _homeNavigatorKey,
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.productDetail) {
            final product = settings.arguments as Product;
            return MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
            );
          }

          return MaterialPageRoute(builder: (_) => const HomeScreen());
        },
      ),
    ),
    const FavoritesScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: cartService,
      builder: (context, child) {
        return Scaffold(
          body: IndexedStack(index: currentIndex, children: screens),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: const Color(0xff2D006B),
            selectedItemColor: const Color(0xff7FE3FF),
            unselectedItemColor: Colors.white70,
            showUnselectedLabels: true,
            currentIndex: currentIndex,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              if (index == 0 && currentIndex == 0) {
                _homeNavigatorKey.currentState?.popUntil(
                  (route) => route.isFirst,
                );
                return;
              }
              setState(() {
                currentIndex = index;
              });
            },

            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Favoritos',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart),
                    if (cartService.badgeCount > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          width: 16,
                          height: 16,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${cartService.badgeCount}',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Carrito',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        );
      },
    );
  }
}
