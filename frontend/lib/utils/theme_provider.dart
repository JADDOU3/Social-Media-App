import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

class ThemeProvider with ChangeNotifier {
  final LocalStorageService _localStorageService;
  bool _isDarkMode = false;

  static const String _themeKey = 'isDarkMode';

  ThemeProvider(this._localStorageService) {
    _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;

  Future<void> _loadTheme() async {
    try {
      final stored = await _localStorageService.getThemeMode();
      _isDarkMode = stored ?? false;
      notifyListeners();
    } catch (e) {
      print('Error loading theme: $e');
      _isDarkMode = false;
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _localStorageService.saveThemeMode(_isDarkMode);
  }

  Future<void> setTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    await _localStorageService.saveThemeMode(_isDarkMode);
  }
}