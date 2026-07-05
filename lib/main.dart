import 'dart:async';

import 'package:flutter/material.dart';
import 'app.dart';
import 'features/favorites/services/favorite_services_instances.dart';
import 'features/auth/services/auth_services_instance.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await authServices.checkSession();
  } catch (error) {
    debugPrint('Error restoring session: $error');
  }

  runApp(const BuyMarketApp());

  unawaited(_loadFavoritesAfterStartup());
}

Future<void> _loadFavoritesAfterStartup() async {
  try {
    await favoritesService.loadFavorites();
  } catch (error) {
    debugPrint('Error loading favorites after startup: $error');
  }
}
