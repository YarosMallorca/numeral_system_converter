import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static late SharedPreferences _preferences;

  // Init Method
  static Future init() async => _preferences = await SharedPreferences.getInstance();

  // Clear All Preferences
  static Future clear() async => await _preferences.clear();

  // Theme
  static ThemeMode getTheme() {
    if (_preferences.getString("theme") == null) {
      setTheme(ThemeMode.system);
      return ThemeMode.system;
    } else {
      return ThemeMode.values.firstWhere((e) => e.toString() == 'ThemeMode.${_preferences.getString("theme")}');
    }
  }

  static Future setTheme(ThemeMode theme) async => await _preferences.setString("theme", theme.name.toString());
}
