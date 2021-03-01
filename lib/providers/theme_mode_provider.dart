import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  ThemeModeProvider() {
    _init();
  }

  Future<void> _init() async {
    ThemeMode storedThemeMode = await _getStoredMode();
    if (storedThemeMode == null) {
      await _setStoredMode(_themeMode);
    } else {
      _themeMode = storedThemeMode;
    }
    notifyListeners();
  }

  Future<ThemeMode> _getStoredMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String modeString = await prefs.getString("themeMode");
    switch (modeString) {
      case "light":
        return ThemeMode.light;
      case "dark":
        return ThemeMode.dark;
      case "system":
        return ThemeMode.system;
      default:
        return null;
    }
  }

  Future<void> _setStoredMode(ThemeMode themeMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    switch (themeMode) {
      case ThemeMode.light:
        await prefs.setString("themeMode", "light");
        break;
      case ThemeMode.dark:
        await prefs.setString("themeMode", "dark");
        break;
      case ThemeMode.system:
        await prefs.setString("themeMode", "system");
        break;
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    await _setStoredMode(themeMode);
    notifyListeners();
  }
}
