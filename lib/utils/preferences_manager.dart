import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static late SharedPreferences _preferences;

  static const String _themeId = "theme";
  static const String _languageId = "language";

  // Init Method
  static Future init() async => _preferences = await SharedPreferences.getInstance();

  // Clear All Preferences
  static Future clear() async => await _preferences.clear();

  // Theme
  static ThemeMode getTheme() {
    if (_preferences.getString(_themeId) == null) {
      setTheme(ThemeMode.system);
      return ThemeMode.system;
    } else {
      return ThemeMode.values.firstWhere((e) => e.toString() == 'ThemeMode.${_preferences.getString("theme")}');
    }
  }

  static Future setTheme(ThemeMode theme) async => await _preferences.setString(_themeId, theme.name.toString());

  // Language
  static String getLanguage() {
    if (_preferences.getString(_languageId) == null) {
      _preferences.setString(_languageId, "auto");
      return "auto";
    } else {
      return _preferences.getString(_languageId)!;
    }
  }

  static Future setLanguage(String language) async => await _preferences.setString("language", language);
}
