import 'package:buymarket_frontend/core/utils/safe_change_notifier.dart';

import '../../auth/services/auth_services.dart';
import '../models/user_address.dart';
import 'user_address_api_service.dart';

class UserAddressService extends SafeChangeNotifier {
  final UserAddressApiService _apiService;
  final AuthServices _authServices;

  UserAddressService({
    required UserAddressApiService apiService,
    required AuthServices authServices,
  }) : _apiService = apiService,
       _authServices = authServices;

  List<UserAddress> _addresses = [];
  bool _isLoading = false;
  String? _error;

  List<UserAddress> get addresses => List.unmodifiable(_addresses);
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get _token {
    final token = _authServices.token;

    if (!_authServices.isLoggeIn || token == null) {
      throw Exception('Usuario no autenticado');
    }

    return token;
  }

  Future<void> loadAddresses() async {
    if (!_authServices.isLoggeIn) {
      _addresses = [];
      _error = 'Inicia sesion para ver tus direcciones';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _addresses = await _apiService.getMyAddresses(_token);
    } catch (error) {
      _error = _cleanError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createAddress(Map<String, dynamic> payload) async {
    final newAddress = await _apiService.createAddress(
      token: _token,
      payload: payload,
    );

    if (newAddress.isDefault) {
      _addresses = [
        for (final address in _addresses)
          UserAddress(
            id: address.id,
            label: address.label,
            receiverName: address.receiverName,
            phone: address.phone,
            street: address.street,
            number: address.number,
            floor: address.floor,
            apartment: address.apartment,
            city: address.city,
            province: address.province,
            postalCode: address.postalCode,
            reference: address.reference,
            isDefault: false,
          ),
        newAddress,
      ];
    } else {
      _addresses = [..._addresses, newAddress];
    }

    _error = null;
    notifyListeners();
  }

  Future<void> setDefaultAddress(String id) async {
    final updatedAddress = await _apiService.setDefaultAddress(
      token: _token,
      id: id,
    );

    _addresses = [
      for (final address in _addresses)
        UserAddress(
          id: address.id,
          label: address.label,
          receiverName: address.receiverName,
          phone: address.phone,
          street: address.street,
          number: address.number,
          floor: address.floor,
          apartment: address.apartment,
          city: address.city,
          province: address.province,
          postalCode: address.postalCode,
          reference: address.reference,
          isDefault: address.id == updatedAddress.id,
        ),
    ];

    _error = null;
    notifyListeners();
  }

  Future<void> deleteAddress(String id) async {
    await _apiService.deleteAddress(token: _token, id: id);

    _addresses = _addresses.where((address) => address.id != id).toList();
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
