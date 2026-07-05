import 'package:buymarket_frontend/core/config/api.config.dart';

import '../../auth/services/auth_services_instance.dart';
import 'user_address_api_service.dart';
import 'user_address_service.dart';

final userAddressService = UserAddressService(
  apiService: const UserAddressApiService(baseUrl: ApiConfig.baseUrl),
  authServices: authServices,
);
