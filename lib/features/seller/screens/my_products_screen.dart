import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

import '../../auth/services/auth_services_instance.dart';
import '../../home/models/product.dart';
import '../../home/services/product_service_instance.dart';
import '../../home/widgets/product_grid.dart';
class MyProductsScreen extends StatefulWidget{
  const MyProductsScreen({super.key}); 

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState(); 
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  List<Product> products = []; 
  bool isLoading = true; 
  String? errorMessage; 

  @override
  void initState() {
    super.initState(); 
    loadMyProducts();
  }

  Future<void> loadMyProducts() async{
    try {
      final token = authServices.token; 

      if(token == null) {
        throw Exception("Usuario no autenticado");
      }

      final result = await productService.getMyProducts(token: token);

      if(!mounted) return; 

      setState((){
        products = result; 
        isLoading = false; 
        errorMessage = null;
      });
    } catch (e) {
      if(!mounted) return; 

      setState(() {
        isLoading = false; 
        errorMessage = e.toString();
      });
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFBF5FF),
      appBar: AppBar(
        title: const Text(
          'Mis productos',
          style: TextStyle(
            color: Color(0xff2D006B),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xff2D006B),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? Center(
                  child: Text(errorMessage!),
                )
              : products.isEmpty
                  ? const Center(
                      child: Text(
                        'Todavía no publicaste productos',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: loadMyProducts,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          ProductGrid(products: products),
                        ],
                      ),
                    ),
    );
  }
}