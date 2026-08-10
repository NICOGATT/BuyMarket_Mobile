import 'package:flutter/material.dart';

import '../../auth/screens/login_screen.dart';
import '../../auth/screens/register_screen.dart';

class SellerAuthRequiredScreen extends StatelessWidget {
  const SellerAuthRequiredScreen({super.key});

  Future<void> _openAuthScreen(
    BuildContext context,
    Widget screen,
  ) async {
    final authenticated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );

    if (authenticated == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff2D006B)),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x242D006B),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: Color(0xffEEE6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      size: 46,
                      color: Color(0xff5E2CA5),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Para poder vender tus productos debes iniciar sesión o registrarte.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xff2D006B),
                      fontSize: 23,
                      height: 1.25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Cuando termines, volverás a tu publicación sin perder los datos cargados.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      key: const Key('seller-login-button'),
                      onPressed: () => _openAuthScreen(
                        context,
                        const LoginScreen(returnOnSuccess: true),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xff168BEE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.login),
                      label: const Text(
                        'Iniciar sesión',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      key: const Key('seller-register-button'),
                      onPressed: () => _openAuthScreen(
                        context,
                        const RegisterScreen(returnOnSuccess: true),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xff2D006B),
                        side: const BorderSide(color: Color(0xff2D006B)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text(
                        'Registrarse',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
