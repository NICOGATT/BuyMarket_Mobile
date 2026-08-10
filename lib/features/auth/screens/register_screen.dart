import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../services/auth_services_instance.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.returnOnSuccess = false});

  final bool returnOnSuccess;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final lastNameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      throw Exception('Completa todos los campos');
    }

    if (password != confirmPassword) {
      throw Exception('Las contraseñas no coinciden');
    }

    await authServices.register(
      firstName: name,
      lastName: lastName,
      email: email,
      password: password,
    );
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
      isDense: true,
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 120,
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
                    height: 114,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_add_alt_1,
                          size: 36,
                          color: Color(0xff168BEE),
                        ),
                        SizedBox(width: 9),
                        Text(
                          'Creá tu cuenta',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        icon: Icons.person_outline,
                        hint: 'Ingresá tu nombre',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: lastNameController,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        icon: Icons.person_outline,
                        hint: 'Ingresá tu apellido',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        icon: Icons.email_outlined,
                        hint: 'Ingresá tu email',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        icon: Icons.lock_outline,
                        hint: 'Ingresá tu contraseña',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      decoration: _inputDecoration(
                        icon: Icons.lock_reset,
                        hint: 'Repetí tu contraseña',
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                setState(() => isLoading = true);
                                try {
                                  await register();
                                  if (!context.mounted) return;
                                  if (widget.returnOnSuccess) {
                                    Navigator.pop(context, true);
                                  } else {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      AppRoutes.bottomNavigation,
                                      (route) => false,
                                    );
                                  }
                                } catch (error) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error.toString())),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => isLoading = false);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff168BEE),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Registrarse',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (widget.returnOnSuccess) {
                          final authenticated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(
                                returnOnSuccess: true,
                              ),
                            ),
                          );
                          if (authenticated == true && context.mounted) {
                            Navigator.pop(context, true);
                          }
                        } else {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.login,
                          );
                        }
                      },
                      child: const Text(
                        'Ya tengo cuenta',
                        style: TextStyle(
                          color: Color(0xff2D006B),
                          fontWeight: FontWeight.bold,
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
