import 'package:buymarket_frontend/features/auth/models/auth_user.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'auth_api_services.dart';
class AuthServices extends ChangeNotifier{
  static const String tokenKey = 'token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String userRoleKey = 'user_role';
  static const String userNameKey = 'user_nam'; 
  final AuthApiServices _authApiServices = AuthApiServices(); 
  AuthUser? _user;
  AuthUser? get user => _user;
  bool _isLoggedIn = false; 
  bool get isLoggeIn => _isLoggedIn; 

  Future<void> login({
    required String email, 
    required String password, 
  }) async {
    final response = await _authApiServices.login(
      email: email,
      password: password,
    );

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(tokenKey, response.token);
    await prefs.setString(userIdKey, response.user.id);
    await prefs.setString(userEmailKey, response.user.email);
    await prefs.setString(userRoleKey, response.user.role);
    _user = response.user;
    _isLoggedIn = true;

    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(tokenKey);
    await prefs.remove(userIdKey);
    await prefs.remove(userEmailKey);
    await prefs.remove(userRoleKey);

    _user = null;
    _isLoggedIn = false;

    notifyListeners();
  }

  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString(tokenKey);
    final userId = prefs.getString(userIdKey);
    final userEmail = prefs.getString(userEmailKey);
    final userRole = prefs.getString(userRoleKey);
    final userName = prefs.getString(userNameKey);
    if (token == null || userId == null || userEmail == null || userRole == null || userName == null) {
      _isLoggedIn = false;
      _user = null;
      notifyListeners();
      return;
    }

    _user = AuthUser(
      id: userId,
      name : userName, 
      email: userEmail,
      role: userRole,
    );

    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> register({
  required String name,
  required String email,
  required String password,
  }) async {
    final response = await _authApiServices.register(
      name: name,
      email: email,
      password: password,
    );

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(tokenKey, response.token);
    await prefs.setString(userIdKey, response.user.id);
    await prefs.setString(userEmailKey, response.user.email);
    await prefs.setString(userRoleKey, response.user.role);

    _user = response.user;
    _isLoggedIn = true;

    notifyListeners();
  }
}