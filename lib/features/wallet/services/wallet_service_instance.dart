import 'package:buymarket_frontend/core/config/api.config.dart';

import '../../auth/services/auth_services_instance.dart';
import 'wallet_api_service.dart';
import 'wallet_service.dart';

final walletService = WalletService(
  apiService: const WalletApiService(baseUrl: ApiConfig.baseUrl),
  authServices: authServices,
);
