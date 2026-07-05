import 'package:buymarket_frontend/core/utils/safe_change_notifier.dart';

import '../../auth/services/auth_services_instance.dart';
import '../../home/models/product.dart';
import 'favorites_api_services.dart';

class FavoritesService extends SafeChangeNotifier {
  final FavoritesApiServices _api = FavoritesApiServices();

  final List<Product> _favorites = [];

  List<Product> get favorites => _favorites;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool isFavorite(String productId) {
    return _favorites.any((product) => product.id == productId);
  }

  Future<void> loadFavorites() async {
    final token = authServices.token;

    if (token == null) {
      _favorites.clear();
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _api.getMyFavorites(token: token);

      _favorites
        ..clear()
        ..addAll(result);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String productId) async {
    final token = authServices.token;

    if (token == null) {
      throw Exception('Usuario no autenticado');
    }

    final alreadyFavorite = isFavorite(productId);

    if (alreadyFavorite) {
      await _api.removeFavorite(
        productId: productId,
        token: token,
      );

      _favorites.removeWhere(
        (product) => product.id == productId,
      );
    } else {
      await _api.addFavorite(
        productId: productId,
        token: token,
      );

      await loadFavorites();
    }

    notifyListeners();
  }

  void clearFavorites() {
    _favorites.clear();
    notifyListeners();
  }
}
