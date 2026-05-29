import 'package:flutter/foundation.dart'; 

class AuthServices extends ChangeNotifier{
  bool _isLoggedIn = false; 
  bool get isLoggeIn => _isLoggedIn; 

  Future<void> login({
    required String email, 
    required String password, 
  }) async {
    await Future.delayed(const Duration(seconds: 1)); 
    _isLoggedIn = true; 
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false; 
    notifyListeners(); 
  }
}