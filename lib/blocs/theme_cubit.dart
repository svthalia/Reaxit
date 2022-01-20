import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModePreferenceKey = 'themeMode';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  Future<void> load() async {
    var prefs = await SharedPreferences.getInstance();
    var modeString = prefs.getString(_themeModePreferenceKey);
    if (modeString == null) {
      emit(ThemeMode.system);
    } else if (modeString == 'system') {
      emit(ThemeMode.system);
    } else if (modeString == 'light') {
      emit(ThemeMode.light);
    } else if (modeString == 'dark') {
      emit(ThemeMode.dark);
    }
  }

  Future<void> change(ThemeMode newMode) async {
    var prefs = await SharedPreferences.getInstance();
    switch (newMode) {
      case ThemeMode.system:
        await prefs.setString(_themeModePreferenceKey, 'system');
        break;
      case ThemeMode.light:
        await prefs.setString(_themeModePreferenceKey, 'light');
        break;
      case ThemeMode.dark:
        await prefs.setString(_themeModePreferenceKey, 'dark');
        break;
    }
    emit(newMode);
  }
}
