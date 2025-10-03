import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isDark = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _isDark;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _isDark = mode == ThemeMode.dark;
    notifyListeners();
  }

  void toggleTheme() {
    _isDark = !_isDark;
    _themeMode = _isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
