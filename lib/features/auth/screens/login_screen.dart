import 'package:flutter/material.dart';
import '../services/auth_services_instance.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/routes/app_routes.dart';
class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key}); 

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController(); 
  final passwordController = TextEditingController(); 
  bool isLoading = false;
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async{
    final email = emailController.text; 
    final password = passwordController.text; 

    await authServices.login(email: email, password: password); 
    if(!mounted) return ; 
    Navigator.pop(context); 
  }

  @override 
 Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFBF5FF),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // HEADER
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

                child: SafeArea(
                  child: Center(
                    child: Image.asset(
                      'assets/images/BuyMarketLogo2.png',
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 34),

              // TITULO
              const Text(
                'Ingresá a tu cuenta',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 30),

              // ICONO
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

                    // EMAIL
                    const Text(
                      'E-mail o teléfono',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

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

                    const SizedBox(height: 24),

                    // PASSWORD
                    const Text(
                      'Contraseña',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

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

                    const SizedBox(height: 34),

                    // BOTON LOGIN
                    SizedBox(
                      width: double.infinity,
                      height: 55,

                      child: ElevatedButton(
                        onPressed: isLoading ? null :() async {
                          setState(() {
                            isLoading = true;
                          });

                          try {
                            await login();

                            if (!context.mounted) return;

                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.bottomNavigation,
                            );
                          } catch (e) {
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No se pudo iniciar sesión'),
                              ),
                            );

                            debugPrint(e.toString());
                          } finally {
                            if (mounted) {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }
                        },


                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xff168BEE),

                          foregroundColor: Colors.white,

                          elevation: 4,

                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(40),
                          ),
                        ),

                        child: isLoading ? const CircularProgressIndicator(
                          color : Colors.white
                        ): 
                          const Text(
                          'Continuar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // DIVIDER
                    Row(
                      children: [

                        Expanded(
                          child: Divider(
                            color: Colors.grey.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),

                        const Padding(
                          padding:
                              EdgeInsets.symmetric(
                            horizontal: 16,
                          ),

                          child: Text(
                            'o',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                        Expanded(
                          child: Divider(
                            color: Colors.grey.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // GOOGLE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,

                      child: OutlinedButton.icon(
                        onPressed: () {},

                        icon: const Icon(
                          Icons.g_mobiledata,
                          size: 34,
                          color: Colors.red,
                        ),

                        label: const Text(
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
                            color: Colors.grey.withValues(
                              alpha: 0.3,
                            ),
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // FORGOT PASSWORD
                    Center(
                      child: TextButton(
                        onPressed: () {},

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

                    // REGISTER
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.register,
                          );
                        },

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