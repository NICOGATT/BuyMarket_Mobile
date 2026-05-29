import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesServices extends ChangeNotifier{
  static const String favoritesKey = 'favorites';
  final List<int> _favoriteIds = []; 

  List<int> get favoriteIds => _favoriteIds; 

  bool isFavorite(int productId){
    return _favoriteIds.contains(productId); 
  }

  void toggleFavorite(int productId) {
    if(_favoriteIds.contains(productId)){
      _favoriteIds.remove(productId);
    }else {
      _favoriteIds.add(productId);
    }

    notifyListeners();
    saveFavorites();
  }

  Future<void> saveFavorites()async {
    final prefs = await SharedPreferences.getInstance();
    final ids = _favoriteIds.map((id) => id.toString()).toList();
    await prefs.setStringList(favoritesKey, ids);
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance(); 
    final ids = prefs.getStringList(favoritesKey); 

    if (ids != null) {
      _favoriteIds.clear();
      _favoriteIds.addAll(ids.map((id) => int.parse(id)));
      notifyListeners();
    }
  }
}