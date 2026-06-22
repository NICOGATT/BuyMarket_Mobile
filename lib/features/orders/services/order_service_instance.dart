import 'package:buymarket_frontend/core/config/api.config.dart';

import '../../auth/services/auth_services_instance.dart';
import 'order_api_service.dart';
import 'order_service.dart';

final orderApiService = OrderApiService(
  baseUrl: ApiConfig.baseUrl,
);

final orderService = OrderService(
  orderApiService: orderApiService,
  authServices: authServices,
);