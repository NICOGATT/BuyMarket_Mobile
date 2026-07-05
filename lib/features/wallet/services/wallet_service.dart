import 'package:buymarket_frontend/core/utils/safe_change_notifier.dart';

import '../../auth/services/auth_services.dart';
import '../models/wallet_balance.dart';
import '../models/wallet_transaction.dart';
import '../models/wallet_withdrawal.dart';
import 'wallet_api_service.dart';

class WalletService extends SafeChangeNotifier {
  final WalletApiService _apiService;
  final AuthServices _authServices;

  WalletService({
    required WalletApiService apiService,
    required AuthServices authServices,
  }) : _apiService = apiService,
       _authServices = authServices;

  WalletBalance? _balance;
  List<WalletTransaction> _transactions = [];
  List<WalletWithdrawal> _withdrawals = [];
  bool _isLoading = false;
  bool _isSubmittingWithdrawal = false;
  String? _error;

  WalletBalance? get balance => _balance;
  List<WalletTransaction> get transactions => List.unmodifiable(_transactions);
  List<WalletWithdrawal> get withdrawals => List.unmodifiable(_withdrawals);
  bool get isLoading => _isLoading;
  bool get isSubmittingWithdrawal => _isSubmittingWithdrawal;
  String? get error => _error;
  double get availableBalance => _balance?.balance ?? 0;

  String get _token {
    final token = _authServices.token;

    if (!_authServices.isLoggeIn || token == null) {
      throw Exception('Usuario no autenticado');
    }

    return token;
  }

  Future<void> loadWallet() async {
    if (!_authServices.isLoggeIn) {
      _balance = null;
      _transactions = [];
      _withdrawals = [];
      _error = 'Inicia sesion para ver tu billetera';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await Future.wait([
        _apiService.getBalance(_token),
        _apiService.getMyTransactions(_token),
        _apiService.getMyWithdrawals(_token),
      ]);

      _balance = result[0] as WalletBalance;
      _transactions = (result[1] as List<WalletTransaction>)
        ..sort(_sortTransactionsByDateDesc);
      _withdrawals = (result[2] as List<WalletWithdrawal>)
        ..sort(_sortWithdrawalsByDateDesc);
    } catch (error) {
      _balance = null;
      _transactions = [];
      _withdrawals = [];
      _error = _cleanError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> requestWithdrawal({
    required double amount,
    String? alias,
    String? cbu,
  }) async {
    final payload = <String, dynamic>{'amount': amount};

    if (alias != null && alias.trim().isNotEmpty) {
      payload['alias'] = alias.trim();
    }

    if (cbu != null && cbu.trim().isNotEmpty) {
      payload['cbu'] = cbu.trim();
    }

    _isSubmittingWithdrawal = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.requestWithdrawal(token: _token, payload: payload);
      final result = await Future.wait([
        _apiService.getBalance(_token),
        _apiService.getMyWithdrawals(_token),
      ]);

      _balance = result[0] as WalletBalance;
      _withdrawals = (result[1] as List<WalletWithdrawal>)
        ..sort(_sortWithdrawalsByDateDesc);
    } catch (error) {
      _error = _cleanError(error);
      rethrow;
    } finally {
      _isSubmittingWithdrawal = false;
      notifyListeners();
    }
  }

  int _sortTransactionsByDateDesc(
    WalletTransaction left,
    WalletTransaction right,
  ) {
    final leftDate = left.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final rightDate = right.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return rightDate.compareTo(leftDate);
  }

  int _sortWithdrawalsByDateDesc(
    WalletWithdrawal left,
    WalletWithdrawal right,
  ) {
    final leftDate = left.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final rightDate = right.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return rightDate.compareTo(leftDate);
  }

  String _cleanError(Object error) {
    final message = error.toString();
    return message.startsWith('Exception: ')
        ? message.replaceFirst('Exception: ', '')
        : message;
  }
}
