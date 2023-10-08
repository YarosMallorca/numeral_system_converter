import 'package:flutter/material.dart';
import 'package:numeral_systems/utils/preferences_manager.dart';

class ThemeProvider with ChangeNotifier {
  ThemeProvider({required this.selectedThemeMode});
  ThemeMode selectedThemeMode;
  setSelectedThemeMode(ThemeMode themeMode) {
    selectedThemeMode = themeMode;
    PreferencesManager.setTheme(themeMode);
    notifyListeners();
  }
}

class AppTheme {
  ThemeMode mode;

  AppTheme({
    required this.mode,
  });
}

List<AppTheme> appThemes = [
  AppTheme(
    mode: ThemeMode.light,
  ),
  AppTheme(
    mode: ThemeMode.dark,
  ),
  AppTheme(
    mode: ThemeMode.system,
  ),
];
