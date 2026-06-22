import 'package:buymarket_frontend/core/config/api.config.dart';

import '../../auth/services/auth_services_instance.dart';
import 'cart_api_services_instances.dart';
import 'cart_services.dart';

final cartApiService = CartApiService(baseUrl: ApiConfig.baseUrl);

final cartService = CartService(
  cartApiService: cartApiService,
  authServices: authServices,
);
