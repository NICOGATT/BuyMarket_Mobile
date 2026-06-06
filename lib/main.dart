import 'package:flutter/material.dart';
import 'app.dart';
import 'features/favorites/services/favorite_services_instances.dart';
import 'features/auth/services/auth_services_instance.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await favoritesService.loadFavorites();
   await authServices.checkSession();
  runApp(const BuyMarketApp());
}
