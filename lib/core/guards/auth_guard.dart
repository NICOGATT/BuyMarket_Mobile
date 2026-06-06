import 'package:flutter/material.dart'; 

import '../../features/auth/screens/auth_welcome_screen.dart';
import '../../features/auth/services/auth_services_instance.dart';

class AuthGuard extends StatelessWidget{
  final Widget child; 

  const AuthGuard({
    super.key, 
    required this.child,
  }); 

  @override
  Widget build(BuildContext context) {
    if(authServices.isLoggeIn) {
      return child; 
    }
    return const AuthWelcomeScreen(); 
  }
}