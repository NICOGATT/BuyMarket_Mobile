import 'package:flutter/material.dart';
import 'app.dart';
import 'features/favorites/services/favorite_services_instances.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await favoritesService.loadFavorites();
  runApp(const BuyMarketApp());
}
