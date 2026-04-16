# Project Task: Firebase & Auth Migration

This document summarizes the current state of the **Movie Explorer** Flutter project, focusing on the migration from mock authentication and local storage to **Firebase Auth** and **Cloud Firestore**.

## 1. Accomplished Tasks

### Core Integration
- **Firebase Initialization**: Added `firebase_core`, `firebase_auth`, and `google_sign_in` to `pubspec.yaml`.
- **App Start**: Modified `main.dart` to initialize Firebase using `DefaultFirebaseOptions`.

### Authentication Service (`auth_service.dart`)
- **Email/Password**: `loginWithEmail()` and `registerWithEmail()` using `FirebaseAuth.instance`.
- **Google Sign-In (^7.2.0)**: Uses the new Singleton + Stream-based API:
  - `GoogleSignIn.instance` is accessed **lazily** (NOT as a field initializer — this caused a native ANR crash).
  - `initialize(serverClientId: ...)` is called once before first use.
  - `authenticate()` triggers the sign-in UI.
  - The `GoogleSignInAccount` is received via the `authenticationEvents` stream.
  - The `idToken` from the account is used to create a `GoogleAuthProvider.credential`.

### Authentication Provider (`auth_provider.dart`)
- Uses `FirebaseAuth.instance.currentUser != null` for `isAuthenticated`.
- Wraps `AuthService` methods (`login`, `register`, `signInWithGoogle`, `logout`).
- No local token storage — Firebase handles session persistence.

### Cloud Firestore Favorites (`movie_provider.dart`)
- Favorites stored at: `users/{uid}/favorites/{movieId}`.
- Each document stores the full `movie.toJson()` representation.
- `loadFavorites()` is public so it can be called after login to refresh.

### UI Screens
- **Login Screen**: Email/password login + Google Sign-In + link to Sign Up.
- **Signup Screen**: Email/password registration + Google Sign-In + link to Login.
- **Main Screen**: Calls `loadFavorites()` on init to sync after login.

## 2. Critical Bug Fix: Startup Crash (ANR)

### Root Cause
The app was crashing immediately on startup with:
```
Skipped 133 frames! The application may be doing too much work on its main thread.
Wrote stack traces to tombstoned
Lost connection to device.
```

This was caused by `GoogleSignIn.instance` being stored as a **field initializer** in `AuthService`:
```dart
// BAD: This runs during construction, before Flutter engine is ready
final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
```

Since `AuthService` is created by `AuthProvider`, which is created by `MultiProvider` during `main()`, the native Google Sign-In SDK was initialized too early, blocking the main thread and triggering an Android ANR kill (Signal 3 / SIGQUIT).

### Fix
- Removed the field initializer entirely.
- `GoogleSignIn.instance` is now accessed **only inside method bodies** (lazy access).
- `initialize()` is called the first time `signInWithGoogle()` is invoked.

## 3. Package Versions
- `firebase_core: ^4.7.0`
- `firebase_auth: ^6.4.0`
- `google_sign_in: ^7.2.0`
- `cloud_firestore: ^6.3.0`

## 4. Android Configuration
- `minSdk = flutter.minSdkVersion` (in `android/app/build.gradle.kts`)
- `multiDexEnabled = true`
- `google-services.json` present in `android/app/`
- `com.google.gms.google-services` plugin applied in both `settings.gradle.kts` and `app/build.gradle.kts`
