import 'dart:convert';

import 'package:buymarket_frontend/features/auth/models/auth_user.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'auth_api_services.dart';
class AuthServices extends ChangeNotifier{
  static const String tokenKey = 'token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String userRoleKey = 'user_role';
  static const String userNameKey = 'user_firstName'; 
  static const String userlastNameKey = 'user_lastName'; 
  final AuthApiServices _authApiServices = AuthApiServices(); 
  AuthUser? _user;
  AuthUser? get user => _user;
  bool _isLoggedIn = false; 
  bool get isLoggeIn => _isLoggedIn; 
  String? _token;
  String? get token => _token;

  Future<void> login({
    required String email, 
    required String password, 
  }) async {
    final response = await _authApiServices.login(
      email: email,
      password: password,
    );

    _token = response.token; 

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(tokenKey, response.token);
    await prefs.setString(userIdKey, response.user.id);
    await prefs.setString(userEmailKey, response.user.email);
    await prefs.setString(userRoleKey, response.user.role);
    await prefs.setString(userNameKey, response.user.firstName);
    await prefs.setString(userlastNameKey, response.user.lastName);
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
    await prefs.remove(userNameKey);
    await prefs.remove(userlastNameKey);

    _user = null;
    _token = null; 
    _isLoggedIn = false;

    notifyListeners();
  }

  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString(tokenKey);
    _token = token; 
    final userId = prefs.getString(userIdKey);
    final userEmail = prefs.getString(userEmailKey);
    final userRole = prefs.getString(userRoleKey);
    final userName = prefs.getString(userNameKey);
    final userLastName = prefs.getString(userlastNameKey);
    if (token == null || userId == null || userEmail == null || userRole == null) {
      _isLoggedIn = false;
      _user = null;
      notifyListeners();
      return;
    }

    final restoredUserJson = {
      ..._tokenPayload(token),
      'id': userId,
      'email': userEmail,
      'role': userRole,
      if (userName != null && userName.trim().isNotEmpty)
        'firstName': userName,
      if (userLastName != null && userLastName.trim().isNotEmpty)
        'lastName': userLastName,
    };

    _user = AuthUser.fromJson(restoredUserJson);

    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> register({
  required String firstName,
  required String lastName,
  required String email,
  required String password,
  }) async {
    final response = await _authApiServices.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(tokenKey, response.token);
    await prefs.setString(userIdKey, response.user.id);
    await prefs.setString(userEmailKey, response.user.email);
    await prefs.setString(userRoleKey, response.user.role);
    final registeredUser = AuthUser(
      id: response.user.id,
      email: response.user.email,
      role: response.user.role,
      firstName: response.user.firstName.isNotEmpty
          ? response.user.firstName
          : firstName,
      lastName: response.user.lastName.isNotEmpty
          ? response.user.lastName
          : lastName,
    );

    await prefs.setString(userNameKey, registeredUser.firstName);
    await prefs.setString(userlastNameKey, registeredUser.lastName);

    _user = registeredUser;
    _token = response.token; 
    _isLoggedIn = true;

    notifyListeners();
  }

  Map<String, dynamic> _tokenPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) {
        return {};
      }

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final decoded = jsonDecode(payload);

      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      return {};
    }
  }
}
