// import 'package:buymarket_frontend/features/home/screens/home_screen.dart';
import 'features/navigation/screens/buttom_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'core/routes/app_routes.dart';
import 'features/cart/screens/cart_screen.dart';
import 'features/favorites/screens/favorites_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/home/models/product.dart';
import 'features/products/screens/producto_detail_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/checkout/screens/checkout_screen.dart';
import 'core/guards/auth_guard.dart';
import 'features/auth/screens/auth_welcome_screen.dart';
import 'features/auth/screens/register_screen.dart';

class BuyMarketApp extends StatelessWidget {
  const BuyMarketApp({super.key}); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp (
      title : 'BuyMarket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3 : true, 
        colorSchemeSeed: Colors.deepPurple,
      ),
      initialRoute: AppRoutes.home,
      routes : {
        AppRoutes.home : (context) => const BottomNavigationScreen(),
        AppRoutes.cart : (context) => const CartScreen(),
        AppRoutes.login : (context) => const LoginScreen(), 
        AppRoutes.favorites :  (context) => const FavoritesScreen(),
        AppRoutes.profile : (context) => const AuthGuard(child: ProfileScreen()),
        AppRoutes.checkout : (context) => const AuthGuard(child: CheckoutScreen()), 
        AppRoutes.authWelcome : (context) => const AuthWelcomeScreen(),
        AppRoutes.bottomNavigation: (context) => const BottomNavigationScreen(),
        AppRoutes.register : (context) => const RegisterScreen(), 
      }, 
      onGenerateRoute : (settings) {
        if (settings.name == AppRoutes.productDetail) {
          final product = settings.arguments as Product; 
          return MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          );
        }
        return null;
      }
    );
  }
}