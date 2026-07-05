import 'package:buymarket_frontend/core/utils/safe_change_notifier.dart';

import '../../auth/services/auth_services.dart';
import '../models/user_payment_method.dart';
import 'user_payment_method_api_service.dart';

class UserPaymentMethodService extends SafeChangeNotifier {
  final UserPaymentMethodApiService _apiService;
  final AuthServices _authServices;

  UserPaymentMethodService({
    required UserPaymentMethodApiService apiService,
    required AuthServices authServices,
  }) : _apiService = apiService,
       _authServices = authServices;

  List<UserPaymentMethod> _paymentMethods = [];
  bool _isLoading = false;
  String? _error;

  List<UserPaymentMethod> get paymentMethods =>
      List.unmodifiable(_paymentMethods);
  List<UserPaymentMethod> get activePaymentMethods =>
      _paymentMethods.where((method) => method.isActive).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get _token {
    final token = _authServices.token;

    if (!_authServices.isLoggeIn || token == null) {
      throw Exception('Usuario no autenticado');
    }

    return token;
  }

  Future<void> loadPaymentMethods() async {
    if (!_authServices.isLoggeIn) {
      _paymentMethods = [];
      _error = 'Inicia sesion para ver tus metodos de pago';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _paymentMethods = await _apiService.getMyPaymentMethods(_token);
    } catch (error) {
      _error = _cleanError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPaymentMethod(Map<String, dynamic> payload) async {
    final newPaymentMethod = await _apiService.createPaymentMethod(
      token: _token,
      payload: payload,
    );

    _upsertPaymentMethod(newPaymentMethod);
  }

  Future<void> updatePaymentMethod({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final updatedPaymentMethod = await _apiService.updatePaymentMethod(
      token: _token,
      id: id,
      payload: payload,
    );

    _upsertPaymentMethod(updatedPaymentMethod);
  }

  Future<void> setDefaultPaymentMethod(String id) async {
    final updatedPaymentMethod = await _apiService.setDefaultPaymentMethod(
      token: _token,
      id: id,
    );

    _paymentMethods = [
      for (final paymentMethod in _paymentMethods)
        UserPaymentMethod(
          id: paymentMethod.id,
          method: paymentMethod.method,
          label: paymentMethod.label,
          isDefault: paymentMethod.id == updatedPaymentMethod.id,
          isActive: paymentMethod.isActive,
          senderAlias: paymentMethod.senderAlias,
          senderCbu: paymentMethod.senderCbu,
        ),
    ];

    _error = null;
    notifyListeners();
  }

  Future<void> deletePaymentMethod(String id) async {
    await _apiService.deletePaymentMethod(token: _token, id: id);

    _paymentMethods = _paymentMethods
        .where((paymentMethod) => paymentMethod.id != id)
        .toList();
    _error = null;
    notifyListeners();
  }

  void _upsertPaymentMethod(UserPaymentMethod paymentMethod) {
    final withoutDuplicate = _paymentMethods
        .where((item) => item.id != paymentMethod.id)
        .toList();

    if (paymentMethod.isDefault) {
      _paymentMethods = [
        for (final item in withoutDuplicate)
          UserPaymentMethod(
            id: item.id,
            method: item.method,
            label: item.label,
            isDefault: false,
            isActive: item.isActive,
            senderAlias: item.senderAlias,
            senderCbu: item.senderCbu,
          ),
        paymentMethod,
      ];
    } else {
      _paymentMethods = [...withoutDuplicate, paymentMethod];
    }

    _error = null;
    notifyListeners();
  }

  String _cleanError(Object error) {
    final message = error.toString();
    return message.startsWith('Exception: ')
        ? message.replaceFirst('Exception: ', '')
        : message;
  }
}
