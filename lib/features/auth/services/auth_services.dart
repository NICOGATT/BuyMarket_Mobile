import 'dart:convert';

import 'package:buymarket_frontend/core/utils/safe_change_notifier.dart';
import 'package:buymarket_frontend/features/auth/models/auth_response.dart';
import 'package:buymarket_frontend/features/auth/models/auth_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_api_services.dart';
import 'google_auth_provider.dart';

class AuthServices extends SafeChangeNotifier {
  AuthServices({
    AuthApiServices? authApiServices,
    GoogleAuthProvider? googleAuthProvider,
  }) : _authApiServices = authApiServices ?? AuthApiServices(),
       _googleAuthProvider = googleAuthProvider ?? GoogleSignInAuthProvider();

  static const String tokenKey = 'token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String userRoleKey = 'user_role';
  static const String userNameKey = 'user_firstName';
  static const String userlastNameKey = 'user_lastName';
  static const String userPhoneKey = 'user_phone';
  static const String userEmailVerifiedKey = 'user_email_verified';
  static const String userPhoneVerifiedKey = 'user_phone_verified';
  final AuthApiServices _authApiServices;
  final GoogleAuthProvider _googleAuthProvider;
  AuthUser? _user;
  AuthUser? get user => _user;
  bool _isLoggedIn = false;
  bool get isLoggeIn => _isLoggedIn;
  String? _token;
  String? get token => _token;

  Future<void> login({required String email, required String password}) async {
    final response = await _authApiServices.login(
      email: email,
      password: password,
    );

    await _saveSession(response);
  }

  Future<void> loginWithGoogle() async {
    final idToken = await _googleAuthProvider.getIdToken();
    final response = await _authApiServices.loginWithGoogle(idToken: idToken);
    await _saveSession(response);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(tokenKey);
    await prefs.remove(userIdKey);
    await prefs.remove(userEmailKey);
    await prefs.remove(userRoleKey);
    await prefs.remove(userNameKey);
    await prefs.remove(userlastNameKey);
    await prefs.remove(userPhoneKey);
    await prefs.remove(userEmailVerifiedKey);
    await prefs.remove(userPhoneVerifiedKey);

    _user = null;
    _token = null;
    _isLoggedIn = false;

    notifyListeners();

    await _googleAuthProvider.signOut();
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
    final userPhone = prefs.getString(userPhoneKey);
    final userEmailVerified = prefs.getBool(userEmailVerifiedKey);
    final userPhoneVerified = prefs.getBool(userPhoneVerifiedKey);
    if (token == null ||
        userId == null ||
        userEmail == null ||
        userRole == null) {
      _isLoggedIn = false;
      _user = null;
      notifyListeners();
      return;
    }

    final restoredUserJson = <String, dynamic>{
      ..._tokenPayload(token),
      'id': userId,
      'email': userEmail,
      'role': userRole,
      if (userName != null && userName.trim().isNotEmpty) 'firstName': userName,
      if (userLastName != null && userLastName.trim().isNotEmpty)
        'lastName': userLastName,
      if (userPhone != null && userPhone.trim().isNotEmpty) 'phone': userPhone,
    };

    if (userEmailVerified != null) {
      restoredUserJson['emailVerified'] = userEmailVerified;
    }
    if (userPhoneVerified != null) {
      restoredUserJson['phoneVerified'] = userPhoneVerified;
    }

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
      emailVerified: response.user.emailVerified,
    );

    await _persistUser(prefs, registeredUser);

    _user = registeredUser;
    _token = response.token;
    _isLoggedIn = true;

    notifyListeners();
  }

  Future<AuthUser> refreshCurrentUser() async {
    final currentToken = _token;

    if (!_isLoggedIn || currentToken == null) {
      throw Exception('Usuario no autenticado');
    }

    final refreshedUser = await _authApiServices.getCurrentUser(
      token: currentToken,
    );
    final userWithFallback = await _completeUserFromUsersIfNeeded(
      token: currentToken,
      user: refreshedUser,
    );
    final mergedUser = _mergeUser(_user, userWithFallback);
    final prefs = await SharedPreferences.getInstance();

    await _persistUser(prefs, mergedUser);

    _user = mergedUser;
    _isLoggedIn = true;
    notifyListeners();

    return mergedUser;
  }

  Future<AuthUser> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final currentToken = _token;
    final currentUser = _user;
    if (!_isLoggedIn || currentToken == null || currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    final updatedUser = await _authApiServices.updateUser(
      token: currentToken,
      userId: currentUser.id,
      firstName: firstName,
      lastName: lastName,
      email: email,
    );
    final emailChanged = currentUser.email.toLowerCase() != email.toLowerCase();
    final mergedUser = _mergeUser(currentUser, updatedUser).copyWith(
      emailVerified: emailChanged ? false : currentUser.emailVerified,
    );
    final prefs = await SharedPreferences.getInstance();
    await _persistUser(prefs, mergedUser);

    _user = mergedUser;
    notifyListeners();
    return mergedUser;
  }

  Future<String> sendEmailVerificationCode() async {
    final currentToken = _token;
    if (!_isLoggedIn || currentToken == null) {
      throw Exception('Usuario no autenticado');
    }

    return _authApiServices.sendEmailVerificationCode(token: currentToken);
  }

  Future<String> verifyEmail(String code) async {
    final currentToken = _token;
    final currentUser = _user;
    if (!_isLoggedIn || currentToken == null || currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    final result = await _authApiServices.verifyEmail(
      token: currentToken,
      code: code,
    );
    final prefs = await SharedPreferences.getInstance();
    if (result.token?.trim().isNotEmpty == true) {
      _token = result.token;
      await prefs.setString(tokenKey, result.token!);
    }

    final verifiedUser = currentUser.copyWith(emailVerified: true);
    await _persistUser(prefs, verifiedUser);
    _user = verifiedUser;
    notifyListeners();
    return result.message;
  }

  Future<AuthUser> _completeUserFromUsersIfNeeded({
    required String token,
    required AuthUser user,
  }) async {
    if (user.lastName.trim().isNotEmpty) return user;

    try {
      final usersUser = await _authApiServices.getUserFromUsers(
        token: token,
        currentUser: user,
      );

      if (usersUser == null) return user;

      return _mergeUser(user, usersUser);
    } catch (_) {
      return user;
    }
  }

  AuthUser _mergeUser(AuthUser? currentUser, AuthUser refreshedUser) {
    if (currentUser == null) return refreshedUser;

    return AuthUser(
      id: refreshedUser.id.isNotEmpty ? refreshedUser.id : currentUser.id,
      email: refreshedUser.email.isNotEmpty
          ? refreshedUser.email
          : currentUser.email,
      role: refreshedUser.role.isNotEmpty
          ? refreshedUser.role
          : currentUser.role,
      firstName: refreshedUser.firstName.isNotEmpty
          ? refreshedUser.firstName
          : currentUser.firstName,
      lastName: refreshedUser.lastName.isNotEmpty
          ? refreshedUser.lastName
          : currentUser.lastName,
      phone: refreshedUser.phone.isNotEmpty
          ? refreshedUser.phone
          : currentUser.phone,
      emailVerified: refreshedUser.emailVerified || currentUser.emailVerified,
      phoneVerified: refreshedUser.phoneVerified || currentUser.phoneVerified,
    );
  }

  Future<void> _persistUser(SharedPreferences prefs, AuthUser user) async {
    await prefs.setString(userIdKey, user.id);
    await prefs.setString(userEmailKey, user.email);
    await prefs.setString(userRoleKey, user.role);
    await prefs.setString(userNameKey, user.firstName);
    await prefs.setString(userlastNameKey, user.lastName);
    await prefs.setString(userPhoneKey, user.phone);
    await prefs.setBool(userEmailVerifiedKey, user.emailVerified);
    await prefs.setBool(userPhoneVerifiedKey, user.phoneVerified);
  }

  Future<void> _saveSession(AuthResponse response) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(tokenKey, response.token);
    await _persistUser(prefs, response.user);

    _token = response.token;
    _user = response.user;
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
