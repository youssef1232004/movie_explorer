import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../services/auth_service.dart';
import '../services/local_storage.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> checkSavedToken() async {
    String? token = await LocalStorage.getString(AppConstants.tokenKey);
    if (token != null) {
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    final user = await _authService.login(username, password);
    if (user != null) {
      await LocalStorage.saveString(AppConstants.tokenKey, user.token);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await LocalStorage.remove(AppConstants.tokenKey);
    _isAuthenticated = false;
    notifyListeners();
  }
}