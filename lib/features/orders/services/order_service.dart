import 'package:buymarket_frontend/core/utils/safe_change_notifier.dart';

import '../../auth/services/auth_services.dart';
import '../models/order_model.dart';
import 'order_api_service.dart';

class OrderService extends SafeChangeNotifier {
  final OrderApiService _orderApiService;
  final AuthServices _authServices;

  OrderService({
    required OrderApiService orderApiService,
    required AuthServices authServices,
  })  : _orderApiService = orderApiService,
        _authServices = authServices;

  bool _isLoading = false;
  String? _error;
  List<OrderModel> _orders = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<OrderModel> get orders => _orders;

  String get _token {
    final token = _authServices.token;

    if (token == null) {
      throw Exception('Usuario no autenticado');
    }

    return token;
  }

  Future<OrderModel?> checkout({
    required String deliveryAddress,
    String? paymentMethod,
    String? paymentMethodId,
    String? notes,
  }) async {
    if (!_authServices.isLoggeIn) {
      throw Exception('Usuario no autenticado');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final json = await _orderApiService.checkout(
        token: _token,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
        paymentMethodId: paymentMethodId,
        notes: notes,
      );

      final order = OrderModel.fromJson(json);

      _isLoading = false;
      notifyListeners();

      return order;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> loadMyOrders() async {
    if (!_authServices.isLoggeIn) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final jsonList = await _orderApiService.getMyOrders(_token);

      _orders = jsonList
          .map((json) => OrderModel.fromJson(json))
          .toList();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final json = await _orderApiService.getOrderById(
        token: _token,
        orderId: orderId,
      );

      return OrderModel.fromJson(json);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}
