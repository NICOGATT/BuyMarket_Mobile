import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';

class AuthWelcomeScreen extends StatelessWidget{
  const AuthWelcomeScreen ({super.key}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAF5FC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(), 

              Image.asset(
                'assets/images/BuyMarketLogo2.png', 
                height: 160,
              ), 
              const SizedBox(height: 50,),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context, 
                      AppRoutes.login
                    );
                  }, 
                  child: const Text(
                    'Iniciar sesion', 
                    style: TextStyle(fontSize: 20),
                  )
                ),
              ), 

              const SizedBox(height: 24,), 

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87, 
                    foregroundColor: Colors.white,
                  ),
                  onPressed: (){
                    Navigator.pushNamed(context, AppRoutes.register);
                  }, 
                  child: const Text(
                    'Registrarse', 
                    style: TextStyle(fontSize: 20),
                  )
                ),
              ), 
              const Spacer(), 
              const Align(
                alignment: Alignment.bottomRight,
                child: Icon(Icons.headphones, color: Colors.grey, size: 32,),
              )
            ],
          ),
        ),
      ),
    );
  }
}