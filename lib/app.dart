// import 'package:buymarket_frontend/features/home/screens/home_screen.dart';
import 'features/navigation/screens/buttom_navigation_screen.dart';
import 'package:flutter/material.dart';

class BuyMarketApp extends StatelessWidget {
  const BuyMarketApp({super.key}); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp (
      title : 'BuyMarket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3 : true, 
        colorSchemeSeed: Colors.deepPurple,
      ),
      home : const BottomNavigationScreen(),
    );
  }
}