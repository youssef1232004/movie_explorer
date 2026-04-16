import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isGoogleInitialized = false;

  // Server Client ID (web client from google-services.json, client_type: 3)
  static const String _serverClientId =
      '197692349748-1vqnag30q1d02u0rs49blgfktvvij9rn.apps.googleusercontent.com';

  // Login with Email and Password
  Future<UserCredential?> loginWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Login Error: $e');
      return null;
    }
  }

  // Register with Email and Password
  Future<UserCredential?> registerWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Register Error: $e');
      return null;
    }
  }

  // Initialize Google Sign-In lazily (only when actually needed)
  Future<void> _ensureGoogleInitialized() async {
    if (_isGoogleInitialized) return;
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: _serverClientId,
      );
      _isGoogleInitialized = true;
    } catch (e) {
      debugPrint('Google Sign-In Initialization Error: $e');
    }
  }

  // Sign in with Google (google_sign_in ^7.x API)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Step 1: Initialize Google Sign-In (lazy, only on first call)
      await _ensureGoogleInitialized();

      final signIn = GoogleSignIn.instance;

      // Step 2: Listen for the authentication result via the event stream
      final completer = Completer<GoogleSignInAccount?>();
      StreamSubscription? subscription;
      subscription = signIn.authenticationEvents.listen(
        (event) {
          if (!completer.isCompleted) {
            switch (event) {
              case GoogleSignInAuthenticationEventSignIn():
                completer.complete(event.user);
              case GoogleSignInAuthenticationEventSignOut():
                completer.complete(null);
            }
          }
          subscription?.cancel();
        },
        onError: (e) {
          if (!completer.isCompleted) completer.complete(null);
          subscription?.cancel();
        },
      );

      // Step 3: Trigger the Google Sign-In UI
      await signIn.authenticate();

      // Step 4: Wait for the user from the stream
      final googleUser = await completer.future;
      if (googleUser == null) return null;

      // Step 5: Get the idToken and create Firebase credential
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Step 6: Sign into Firebase with the Google credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      if (_isGoogleInitialized) {
        await GoogleSignIn.instance.signOut();
      }
    } catch (e) {
      debugPrint('Logout Error: $e');
    }
  }
}