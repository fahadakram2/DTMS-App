import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get currentTheme => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Load local theme before login (from SharedPreferences)
  Future<void> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('themeMode') ?? false;
    notifyListeners();
  }

  /// Toggle theme and save locally
  void toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('themeMode', _isDarkMode);
  }

  /// Used by PostLoginSplashScreen after Firestore fetch
  Future<void> setInitialTheme(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('themeMode', isDark);
    notifyListeners();
  }

  /// Called on logout to clear local preference (but not Firestore)
  Future<void> resetTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('themeMode');
    _isDarkMode = false;
    notifyListeners();
  }
}
