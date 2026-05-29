import 'package:flutter/material.dart';
import '../services/auth_services_instance.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key}); 

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController(); 
  final passwordController = TextEditingController(); 

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
      appBar: AppBar(
        title: const Text("Iniciar sesion"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child : Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email', 
                prefixIcon: Icon(Icons.email)
              ),
            ), 
            
            const SizedBox(height: 16,), 

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña', 
                prefixIcon: Icon(Icons.lock) 
              ),
            ), 
            const SizedBox(height: 24,), 
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: login, child: const Text('Ingresar')),
            )
          ],
        )
      ),
    );
  }
}