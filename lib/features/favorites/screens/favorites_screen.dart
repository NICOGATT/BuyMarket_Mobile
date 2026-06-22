import 'package:flutter/material.dart';

import '../../home/widgets/product_grid.dart';
import '../services/favorite_services_instances.dart';
class FavoritesScreen extends StatefulWidget{
  const FavoritesScreen({super.key}); 

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>{
 

  @override 
  void initState() {
    super.initState(); 
    favoritesService.loadFavorites();
  }

  Future<void> refreshFavorites() async {
    await favoritesService.loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: favoritesService, 
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xffFBF5FF),
          appBar: AppBar(
            title: const Text(
              'Mis favoritos', 
              style: TextStyle(
                color : Color(0xff2D006B),
                fontWeight: FontWeight.bold
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: favoritesService.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : favoritesService.favorites.isEmpty
              ? const Center(
                child: Text(
                  'Todavía no tenés favoritos ❤️', 
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: refreshFavorites, 
                child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          ProductGrid(
                            products: favoritesService.favorites,
                          ),
                        ],
                      ),
              )
        );
      }
    );
  }

}