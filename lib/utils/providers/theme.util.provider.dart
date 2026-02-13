import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project_route_p/ui/cl_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({bool isDarkMode = false}) : _isDarkMode = isDarkMode;

  bool _isDarkMode;
  bool get isDarkMode => _isDarkMode;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await CLTheme.saveThemeMode(_isDarkMode ? ThemeMode.dark : ThemeMode.light);
    notifyListeners();
  }
}
