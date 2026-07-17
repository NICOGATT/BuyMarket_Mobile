import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/routes/app_routes.dart';
import '../services/auth_api_services.dart';
import '../services/auth_services.dart';
import '../services/auth_services_instance.dart';
import '../services/google_auth_provider.dart';

enum _LoginMethod { password, google }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.authService});

  final AuthServices? authService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  _LoginMethod? _loadingMethod;

  AuthServices get _authService => widget.authService ?? authServices;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _runLogin(
    _LoginMethod method,
    Future<void> Function() authenticate,
  ) async {
    if (_loadingMethod != null) return;
    setState(() => _loadingMethod = method);

    try {
      await authenticate();
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.bottomNavigation,
        (route) => false,
      );
    } on GoogleAuthFailure catch (error) {
      if (error.type != GoogleAuthFailureType.canceled) {
        _showLoginError(_googleErrorMessage(error));
      }
    } on AuthApiException catch (error) {
      _showLoginError(
        error.statusCode == 401
            ? 'Google no pudo validar la sesión. Revisá la configuración OAuth.'
            : 'El servidor no pudo iniciar sesión con Google.',
      );
    } on TimeoutException catch (_) {
      _showLoginError('La conexión demoró demasiado. Intentá nuevamente.');
    } on http.ClientException catch (_) {
      _showLoginError('No hay conexión con el servidor.');
    } catch (error) {
      debugPrint('Error de inicio de sesión: $error');
      _showLoginError('No se pudo iniciar sesión.');
    } finally {
      if (mounted) setState(() => _loadingMethod = null);
    }
  }

  String _googleErrorMessage(GoogleAuthFailure error) {
    return switch (error.type) {
      GoogleAuthFailureType.configuration =>
        'Falta configurar correctamente Google Sign-In.',
      GoogleAuthFailureType.token =>
        'Google no devolvió una credencial válida.',
      GoogleAuthFailureType.unavailable =>
        'Google Sign-In no está disponible en este dispositivo.',
      GoogleAuthFailureType.canceled => '',
    };
  }

  void _showLoginError(String message) {
    if (!mounted || message.isEmpty) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _inputDecoration({
    required IconData icon,
    required String hint,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _loadingMethod != null;

    return Scaffold(
      backgroundColor: const Color(0xffFBF5FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xff27174E),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/BuyMarketLogo2.png',
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 34),
              const Text(
                'Ingresá a tu cuenta',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              Image.asset(
                'assets/images/tarjeta.png',
                height: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'E-mail o teléfono',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      key: const Key('login-email-field'),
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration(
                        icon: Icons.email_outlined,
                        hint: 'Ingresá tu email',
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Contraseña',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      key: const Key('login-password-field'),
                      controller: passwordController,
                      obscureText: true,
                      decoration: _inputDecoration(
                        icon: Icons.lock_outline,
                        hint: 'Ingresá tu contraseña',
                      ),
                    ),
                    const SizedBox(height: 34),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        key: const Key('password-login-button'),
                        onPressed: isBusy
                            ? null
                            : () => _runLogin(
                                _LoginMethod.password,
                                () => _authService.login(
                                  email: emailController.text.trim(),
                                  password: passwordController.text,
                                ),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff168BEE),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: _loadingMethod == _LoginMethod.password
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Continuar',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey.withValues(alpha: 0.4),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'o',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton.icon(
                        key: const Key('google-login-button'),
                        onPressed: isBusy
                            ? null
                            : () => _runLogin(
                                _LoginMethod.google,
                                _authService.loginWithGoogle,
                              ),
                        icon: _loadingMethod == _LoginMethod.google
                            ? const SizedBox.shrink()
                            : const Icon(
                                Icons.g_mobiledata,
                                size: 34,
                                color: Colors.red,
                              ),
                        label: _loadingMethod == _LoginMethod.google
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Iniciar sesión con Google',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: isBusy ? null : () {},
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            color: Color(0xff168BEE),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: isBusy
                            ? null
                            : () => Navigator.pushNamed(
                                context,
                                AppRoutes.register,
                              ),
                        child: const Text(
                          'Crear cuenta',
                          style: TextStyle(
                            color: Color(0xff2D006B),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
