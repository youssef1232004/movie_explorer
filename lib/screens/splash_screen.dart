import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'main_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    final authProvider = context.read<AuthProvider>();

    // Artificial delay for UI purposes
    await Future.delayed(const Duration(seconds: 4));
    await authProvider.checkSavedToken();

    if (mounted) {
      if (authProvider.isAuthenticated) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simple check: is dark mode on?
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Pick colors based on theme
    final Color topColor = isDark ? const Color(0xFFE50914) : Colors.deepOrange;
    final Color bottomColor = isDark ? Colors.black : const Color(0xFF6D4C41);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [topColor, bottomColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.movie_creation_rounded, size: 100, color: Colors.white),
              SizedBox(height: 24),
              Text(
                'Movie Explorer',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 48),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}