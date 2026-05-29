import 'package:flutter/material.dart'; 

class CheckoutScreen extends StatelessWidget{
  const CheckoutScreen({super.key}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizar compra'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Checkout Buymarket', 
          style: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}