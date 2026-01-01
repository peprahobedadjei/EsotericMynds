import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class ThemeProvider extends ChangeNotifier {
  final _storage = StorageService();
  bool _isDarkMode = false;
  int _themeColorIndex = 0;

  bool get isDarkMode => _isDarkMode;
  int get themeColorIndex => _themeColorIndex;
  Color get primaryColor => AppColors.themeColors[_themeColorIndex];

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() {
    _isDarkMode = _storage.isDarkMode();
    _themeColorIndex = _storage.getThemeColorIndex();
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _storage.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  void setThemeColor(int colorIndex) {
    _themeColorIndex = colorIndex;
    _storage.setThemeColorIndex(colorIndex);
    notifyListeners();
  }

  ThemeData get themeData {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  ThemeData get _lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: AppColors.lightBackground,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightText),
      bodyMedium: TextStyle(color: AppColors.lightText),
      bodySmall: TextStyle(color: AppColors.greyText),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.lightText,
      elevation: 0,
    ),
  );

  ThemeData get _darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkText),
      bodyMedium: TextStyle(color: AppColors.darkText),
      bodySmall: TextStyle(color: AppColors.greyText),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkText,
      elevation: 0,
    ),
  );
}