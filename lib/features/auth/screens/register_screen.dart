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
  final lastNameController = TextEditingController();
  final confirmPasswordController = TextEditingController(); 

  bool isLoading = false ; 

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

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      throw Exception("Completa todos los campos");
    }

    if(password != confirmPassword) {
      throw Exception('Las contraseñas no coinciden');
    }
    await authServices.register(firstName: name, lastName: lastName, email: email, password: password);
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
                  color : const Color(0xff27174E),  
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

              const Text(
                'Creá tu cuenta', 
                style: TextStyle(
                  fontSize: 30, 
                  fontWeight: FontWeight.bold,
                  color: Colors.black87
                ),
              ), 

              const SizedBox(height: 30,),

              const Icon(
                Icons.person_add_alt_1, 
                size: 85,
                color : Color(0xff168BEE), 
              ), 

              const SizedBox(height: 80,), 

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline),

                        hintText: 'Ingresá tu nombre',

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
                      controller: nameController,
                    ), 
                    const SizedBox(height: 20,),
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline),

                        hintText: 'Ingresá tu apellido',

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
                      controller: lastNameController,
                    ), 
                    const SizedBox(height: 20,),
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
                    const SizedBox(height: 20,), 

                    TextField(
                      obscureText: true,

                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.lock_outline),

                        hintText: 'Ingresá tu contraseña',

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
                      controller: passwordController,
                    ),
                    const SizedBox(height: 20,),
                    TextField(
                      obscureText: true,

                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.lock_reset),

                        hintText: 'Repeti tu contraseña',

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
                      controller: confirmPasswordController,
                    ),
                    const SizedBox(height: 32,), 
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
                              Navigator.pushReplacementNamed(
                                context, 
                                AppRoutes.bottomNavigation
                              );
                            } catch (e) { 
                              if (!context.mounted) return; 
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString()))
                              ); 
                            } finally {
                              if(mounted) {
                                setState(() => isLoading = false ); 
                              }
                            }
                          } ,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff168BEE), 
                          foregroundColor: Colors.white, 
                          elevation: 4, 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          )
                        ),
                        child: isLoading 
                          ? const CircularProgressIndicator(
                              color : Colors.white, 
                            )
                          : const Text (
                            'Registrarse', 
                            style : TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold
                            ),
                          )
                      ),
                    ), 
                    const SizedBox(height:20), 
                    Center(
                      child : TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        }, 
                        child: const Text(
                          'Ya tengo cuenta', 
                          style: TextStyle(
                            color : Color(0xff2D006B),
                            fontWeight: FontWeight.bold, 
                          ),
                        )
                      )
                    )
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