import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class LocalStorage {
  static Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> saveFavorites(List<Map<String, dynamic>> favoritesJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.favsKey, jsonEncode(favoritesJson));
  }

  static Future<List<dynamic>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favsString = prefs.getString(AppConstants.favsKey);
    if (favsString != null) {
      return jsonDecode(favsString);
    }
    return [];
  }
}