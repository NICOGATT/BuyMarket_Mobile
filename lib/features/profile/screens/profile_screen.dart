import 'package:flutter/material.dart';

import '../../auth/services/auth_services_instance.dart';
import '../../../core/routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
      animation: authServices,

      builder: (context, child) {

        if (!authServices.isLoggeIn) {

          return Scaffold(
            backgroundColor: const Color(0xffFBF5FF),

            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),

                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    const Icon(
                      Icons.person_outline,
                      size: 90,
                      color: Color(0xff2D006B),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'No has iniciado sesión',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Ingresá para acceder a tu perfil y compras',
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,

                      child: ElevatedButton(
                        onPressed: () {

                          Navigator.pushNamed(
                            context,
                            AppRoutes.login,
                          );
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xff168BEE),

                          foregroundColor: Colors.white,
                        ),

                        child: const Text(
                          'Iniciar sesión',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // PERFIL LOGUEADO
        return Scaffold(
          backgroundColor: const Color(0xffFBF5FF),

          appBar: AppBar(
            title: const Text('Perfil'),
          ),

          body: Center(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [

                const CircleAvatar(
                  radius: 50,
                  child: Icon(
                    Icons.person,
                    size: 50,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  authServices.user?.email ??'Usuario BuyMarket',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () async {

                    await authServices.logout();
                  },

                  child: const Text(
                    'Cerrar sesión',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}