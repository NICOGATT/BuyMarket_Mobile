import 'package:flutter/material.dart';
import '../services/cart_services_instances.dart';
import '../../../core/routes/app_routes.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override 
  Widget build(BuildContext context) {
    final items = cartService.items; 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito'),
      ),
      body: AnimatedBuilder(
        animation: cartService, 
        builder: (context, child) {
          final items = cartService.items; 

          return items.isEmpty
          ? const Center(
            child :Text("El carrito esta vacio")
          ) : Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: items.map((item){
                  return Card(
                    child: ListTile(
                      title: Text(item.product.title),
                      subtitle: Text('Cantidad : ${item.quantity}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: (){
                              cartService.decreaseQuantity(item.product,);
                            }, 
                            icon: const Icon(Icons.remove)
                          ), 

                          Text('${item.quantity}'), 

                          IconButton(
                            onPressed: (){
                              cartService.increaseQuantity(item.product);
                            }, 
                            icon: const Icon(Icons.add)
                          )
                        ],
                      ),
                    ),
                  );
                }).toList(),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Total : \$${cartService.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 12,), 

                    SizedBox(
                      width: double.infinity,
                      child : ElevatedButton(
                        onPressed: (){
                          Navigator.pushNamed(
                            context, 
                            AppRoutes.checkout
                          );
                        }, 
                        child: const Text('Finalizar comprar'),
                      )
                    )
                  ],
                ),
              )
            ],
          );
        }
      )
    );
  }
}