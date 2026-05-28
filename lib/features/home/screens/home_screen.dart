import 'package:buymarket_frontend/features/home/services/product_services.dart';
import 'package:flutter/material.dart';
import '../widgets/product_card.dart';
import '../models/product.dart';
import '../../../shared/widgets/search_input.dart';
import '../widgets/category_chip.dart';

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

    final result =
        await productServices.getProducts();

    setState(() {
      products = result;
      isLoading = false;
    });
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
      appBar: AppBar(
        title: const Text('BuyMarket'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            //Search bar 
            SearchInput(onChanged: (value) {
              setState(() {
                search = value;
              });
            }),

            const SizedBox(height: 20), 
            
            //TITLE
            const Text(
              'Categorias', 
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold,
              ),
            ), 

            const SizedBox(height: 10), 
            
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
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

            const SizedBox(height: 20,), 

            //Products Title
            const Text(
              'Productos', 
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold,
              ),
            ), 

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

