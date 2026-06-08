import 'package:buymarket_frontend/features/home/services/product_services.dart';
import 'package:flutter/material.dart';
import '../widgets/product_card.dart';
import '../models/product.dart';
import '../../../shared/widgets/search_input.dart';
import '../widgets/category_chip.dart';
import '../../cart/services/cart_services.dart';
import '../../cart/services/cart_services_instances.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen ({super.key}); 

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  String search = "";
  String selectedCategory = ""; 
  String? errorMessage; 

  final ProductServices productServices = ProductServices();

  List<Product> products = [];
  bool isLoading = true; 

  @override
  void initState() {
    super.initState(); 
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      final result = await productServices.getProducts();

      await cartService.loadCart(result);

      setState(() {
        products = result;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  List<Product> get filteredProducts {
    return products.where((product) {
      final matchesSearch = product.title.toLowerCase().contains(search.toLowerCase()); 
      final matchesCategory = selectedCategory.isEmpty || product.category == selectedCategory; 
      return matchesSearch && matchesCategory; 
    }).toList();
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAF5FC),
      body: SafeArea(
        child: Column(
          children: [
            //Search bar 
            Container(
              color: const Color(0xff2D006B),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(child: Icon(Icons.person),), 
                  const SizedBox(width: 12,), 
                  Expanded(child: TextField(
                    onChanged: (value) {
                      setState(() {
                        search = value; 
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar producto', 
                      prefixIcon: const Icon(Icons.search), 
                      filled: true, 
                      fillColor: Colors.white, 
                      contentPadding: EdgeInsets.zero, 
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30), 
                        borderSide: BorderSide.none
                      )
                    ),
                  )),
                  const SizedBox(width: 12,), 
                  const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                    size: 30, 
                  ),
                ],
              ),
            ),

            Container(
              color: const Color(0xff9ED8FF),
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  CategoryChip(
                    title: 'Tecnologia', 
                    isSelected: selectedCategory == "Tecnologia",
                    onTap: () {
                      setState(() {
                        selectedCategory = selectedCategory == "Tecnologia" ? '' : 'Tecnologia';
                      });
                    },
                  ),
                  CategoryChip(
                    title: 'Moda', 
                    isSelected: selectedCategory == "Moda",
                    onTap: () {
                      setState(() {
                        selectedCategory = selectedCategory == "Moda" ? '' : "Moda";
                      });
                    },
                  ),
                  CategoryChip(
                    title: 'Gaming', 
                    isSelected: selectedCategory == "Gaming",
                    onTap: () {
                      setState(() {
                        selectedCategory = selectedCategory == "Gaming" ? '' : "Gaming";
                      });
                    },
                  ),
                  CategoryChip(
                    title: 'Mascotas', 
                    isSelected: selectedCategory == "Mascotas",
                    onTap: () {
                      setState(() {
                        selectedCategory = selectedCategory == "Mascotas" ? '' : "Mascotas";                
                      });
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: const[
                  _PromoBanner(), 
                  SizedBox(height: 20,),
                  Text(
                    'Recomendados', 
                    style: TextStyle(
                      fontSize: 26, 
                      fontWeight: FontWeight.bold,
                    ),
                  ), 
                  SizedBox(height: 16,), 
                  _ProductGrid();
                ],
              ) 
            )

            const SizedBox(height: 10,), 
            //Product List
            Expanded(
              child: isLoading ? const Center(
                child : CircularProgressIndicator(),
              ) : errorMessage != null 
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(errorMessage!),
                    const SizedBox(height: 20,), 
                    ElevatedButton(
                      onPressed: (){
                        setState(() {
                          isLoading = true;
                        });
                        loadProducts();
                      }, 
                      child: const Text("Reintentar")
                    )
                  ],
                ),
              ): ListView(
                children: filteredProducts.map((product) {
                  return ProductCard(product : product);
                }).toList(),
              ),
            )
          ],
        )
      ),  
    );
  }
}

