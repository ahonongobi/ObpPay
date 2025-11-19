import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  //bool isDarkMode = false;
  // make dark mode default
  bool isDarkMode = true;

  ThemeProvider() {
    _loadTheme();
  }

  /// Load saved theme from device
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool("isDarkMode") ?? false; // default light
    notifyListeners();
  }

  /// oggle + Save theme
  Future<void> toggleTheme(bool value) async {
    isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isDarkMode", isDarkMode);
    notifyListeners();
  }
}
