import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { light, dark }

class ThemeProvider with ChangeNotifier {
  AppTheme _currentTheme = AppTheme.light;

  AppTheme get currentTheme => _currentTheme;

  ThemeMode get themeMode =>
      _currentTheme == AppTheme.dark ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    _loadTheme();
  }

  void setTheme(AppTheme theme) async {
    _currentTheme = theme;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('appTheme', theme.toString().split('.').last);
  }

  void toggleTheme() {
    final newTheme =
    _currentTheme == AppTheme.dark ? AppTheme.light : AppTheme.dark;
    setTheme(newTheme);
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString('appTheme');
    if (themeStr == 'dark') {
      _currentTheme = AppTheme.dark;
    } else {
      _currentTheme = AppTheme.light;
    }
    notifyListeners();
  }
}
