import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../services/local_storage.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    String? themeStr = await LocalStorage.getString(AppConstants.themeKey);
    if (themeStr == 'dark') {
      _isDarkMode = true;
      notifyListeners();
    }
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    LocalStorage.saveString(AppConstants.themeKey, _isDarkMode ? 'dark' : 'light');
    notifyListeners();
  }
}