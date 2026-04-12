import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: Colors.deepOrange, // warm orange accent
    scaffoldBackgroundColor: const Color(0xFFFAF6F0), // soft cream
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Color(0xFFFAF6F0),
      foregroundColor: Colors.black87,
      iconTheme: IconThemeData(color: Colors.deepOrange),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFFAF6F0),
      selectedItemColor: Colors.deepOrange,
      unselectedItemColor: Colors.grey,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: const Color(0xFFE50914), // vibrant modern red
    scaffoldBackgroundColor: const Color(0xFF0A0A0A), // deep black
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Color(0xFF0A0A0A),
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Color(0xFFE50914)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF0A0A0A),
      selectedItemColor: Color(0xFFE50914),
      unselectedItemColor: Colors.grey,
    ),
    cardTheme: CardThemeData(
      elevation: 6,
      shadowColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1A1A1A),
    ),
  );
}
