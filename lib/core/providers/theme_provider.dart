import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final savedTheme = await StorageService.getThemeMode();
    if (savedTheme == 'Dark') {
      _themeMode = ThemeMode.dark;
    } else if (savedTheme == 'Light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setTheme(String themeStr) async {
    if (themeStr == 'Dark') {
      _themeMode = ThemeMode.dark;
    } else if (themeStr == 'Light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
    
    await StorageService.saveThemeMode(themeStr);
    notifyListeners();
  }

  String get themeName {
    if (_themeMode == ThemeMode.dark) return 'Dark';
    if (_themeMode == ThemeMode.light) return 'Light';
    return 'System';
  }
}
