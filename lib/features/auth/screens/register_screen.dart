import 'package:flutter/material.dart';

import '../services/auth_services_instance.dart';
import '../../../core/routes/app_routes.dart';

class RegisterScreen extends StatefulWidget{
  const RegisterScreen({super.key}); 

  @override 
  State<RegisterScreen> createState() => _RegisterScreenState(); 
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController(); 
  final emailController = TextEditingController(); 
  final passwordController = TextEditingController(); 
  final confirmPasswordController = TextEditingController(); 

  bool isLoading = false ; 

  @override
  void dispose() {
    nameController.dispose(); 
    emailController.dispose(); 
    passwordController.dispose(); 
    confirmPasswordController.dispose(); 
    super.dispose(); 
  }

  Future<void> register() async {
    final name = emailController.text.trim(); 
    final email = emailController.text.trim(); 
    final password = passwordController.text.trim(); 
    final confirmPassword = confirmPasswordController.text.trim(); 

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      throw Exception("Completa todos los campos");
    }

    if(password != confirmPassword) {
      throw Exception('Las contraseñas no coinciden');
    }
    await authServices.register(name: name, email: email, password: password);
  }

  @override
  Widget build(BuildContext context) {
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
                  color : const Color(0xff2D006B), 
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30), 
                    bottomRight: Radius.circular(30)
                  ), 
                  boxShadow: [
                    BoxShadow(
                      color : Colors.black.withValues(alpha: 0.15), 
                      blurRadius: 18, 
                      offset: const Offset(0, 6),
                    )
                  ]
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/BuyMarketLogo2.png', 
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 28,), 

              const Text(,
                'Creá tu cuenta', 
                style: TextStyle(
                  fontSize: 30, 
                  fontWeight: FontWeight.bold,
                  color: Colors.black87
                ),
              ), 

              const SizedBox(height: 30,), 

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined),

                        hintText: 'Ingresá tu email',

                        filled: true,
                        fillColor: Colors.white,

                        contentPadding:
                            const EdgeInsets.symmetric(
                          vertical: 16,
                        ),

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),

                          borderSide: BorderSide(
                            color: Colors.grey.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                      ),
                      controller: emailController,
                    ), 
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined),

                        hintText: 'Ingresá tu email',

                        filled: true,
                        fillColor: Colors.white,

                        contentPadding:
                            const EdgeInsets.symmetric(
                          vertical: 16,
                        ),

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),

                          borderSide: BorderSide(
                            color: Colors.grey.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                      ),
                      controller: emailController,
                    ), 

                  ],
                )
              )
            ],
          ),
        ) 
      ),
    );
  }

}