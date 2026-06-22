import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import 'category_api_service.dart';

class CategoryService extends ChangeNotifier {
  final CategoryApiService _api = CategoryApiService();

  bool isLoading = false;
  String? error;
  List<CategoryModel> categories = [];

  Future<void> loadCategories() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final data = await _api.getCategories();
      categories = data.map((e) => CategoryModel.fromJson(e)).toList();
      debugPrint('CATEGORIAS CARGADAS: ${categories.length}');
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}