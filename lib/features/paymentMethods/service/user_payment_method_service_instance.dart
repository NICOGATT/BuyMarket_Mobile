import 'package:buymarket_frontend/core/config/api.config.dart';

import '../../auth/services/auth_services_instance.dart';
import 'user_payment_method_api_service.dart';
import 'user_payment_method_service.dart';

final userPaymentMethodService = UserPaymentMethodService(
  apiService: const UserPaymentMethodApiService(baseUrl: ApiConfig.baseUrl),
  authServices: authServices,
);
