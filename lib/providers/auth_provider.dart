import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  // Getter to check if user is authenticated via Firebase
  bool get isAuthenticated => FirebaseAuth.instance.currentUser != null;

  // Stream to listen to auth changes if needed, but for simplicity we use currentUser check
  User? get currentUser => FirebaseAuth.instance.currentUser;

  Future<bool> login(String email, String password) async {
    final result = await _authService.loginWithEmail(email, password);
    if (result != null) {
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String email, String password) async {
    final result = await _authService.registerWithEmail(email, password);
    if (result != null) {
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> signInWithGoogle() async {
    final result = await _authService.signInWithGoogle();
    if (result != null) {
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }

  // Placeholder for initialization if needed (e.g. Firebase Auth persistent check is automatic)
  Future<void> checkSavedToken() async {
    // With Firebase, the SDK handles persistence.
    // Just notify listeners to ensure UI reflects the current state.
    notifyListeners();
  }
}