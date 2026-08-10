// import 'package:buymarket_frontend/features/home/screens/home_screen.dart';
import 'package:buymarket_frontend/features/categories/screens/categories_screen.dart';
import 'package:buymarket_frontend/features/coupons/screens/coupons_screen.dart';
import 'package:buymarket_frontend/features/plans/screens/plans_screen.dart';

import 'features/adresses/screens/addresses_screen.dart';
import 'features/adresses/screens/add_address_screen.dart';
import 'features/navigation/screens/buttom_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'core/routes/app_routes.dart';
import 'features/cart/screens/cart_screen.dart';
import 'features/favorites/screens/favorites_screen.dart';
import 'features/orders/screens/my_orders_screen.dart';
import 'features/paymentMethods/screen/payment_method_form_screen.dart';
import 'features/paymentMethods/screen/payment_methods_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/home/models/product.dart';
import 'features/products/screens/producto_detail_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/checkout/screens/checkout_screen.dart';
import 'core/guards/auth_guard.dart';
import 'features/auth/screens/auth_welcome_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/startup_video_screen.dart';
import 'features/profile/screens/profile_settings_screen.dart';
import 'features/seller/screens/category_selection_screen.dart';
import 'features/seller/screens/my_products_screen.dart';
import 'features/wallet/screens/wallet_screen.dart';
import 'features/wallet/screens/wallet_billing_screen.dart';
import 'features/wallet/screens/wallet_earnings_screen.dart';
import 'core/theme/app_theme.dart';

class BuyMarketApp extends StatelessWidget {
  const BuyMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buy Market',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) =>
          AppGradientBackground(child: child ?? const SizedBox.shrink()),
      initialRoute: AppRoutes.startup,
      routes: {
        AppRoutes.startup: (context) => const StartupVideoScreen(),
        AppRoutes.authWelcome: (context) => const AuthWelcomeScreen(),
        AppRoutes.home: (context) => const BottomNavigationScreen(),
        AppRoutes.cart: (context) => const CartScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.favorites: (context) => const FavoritesScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.checkout: (context) =>
            const AuthGuard(child: CheckoutScreen()),
        AppRoutes.bottomNavigation: (context) => const BottomNavigationScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.myOrders: (context) => const MyOrdersScreen(),
        AppRoutes.myProducts: (context) => const MyProductsScreen(),
        AppRoutes.addProduct: (context) => const CategorySelectionScreen(),
        AppRoutes.profileSettings: (context) => const ProfileSettingsScreen(),
        AppRoutes.addresses: (context) => const AddressesScreen(),
        AppRoutes.addAddress: (context) => const AddAddressScreen(),
        AppRoutes.paymentMethods: (context) => const PaymentMethodsScreen(),
        AppRoutes.paymentMethodForm: (context) =>
            const PaymentMethodFormScreen(),
        AppRoutes.wallet: (context) => const AuthGuard(child: WalletScreen()),
        AppRoutes.walletBilling: (context) =>
            const AuthGuard(child: WalletBillingSalesScreen()),
        AppRoutes.walletPendingWithdrawals: (context) =>
            const AuthGuard(child: WalletPendingWithdrawalsScreen()),
        AppRoutes.walletTransactions: (context) =>
            const AuthGuard(child: WalletTransactionsScreen()),
        AppRoutes.walletEarnings: (context) =>
            const AuthGuard(child: WalletPeriodEarningsScreen()),
        AppRoutes.categories: (context) => const CategoriesScreen(),
        AppRoutes.coupons: (context) => const CouponsScreen(),
        AppRoutes.plans: (context) => const PlansScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.productDetail) {
          final product = settings.arguments as Product;
          return MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          );
        }
        return null;
      },
    );
  }
}
