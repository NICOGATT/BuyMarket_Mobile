import 'package:flutter/foundation.dart';

class FavoritesServices extends ChangeNotifier{
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
  }
}