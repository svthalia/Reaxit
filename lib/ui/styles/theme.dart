import 'package:flutter/material.dart';

Color magenta = const Color(0xFFE62272);

ColorScheme lightColorScheme = ColorScheme(
  primary: Color(0xFFE62272),
  onPrimary: Colors.white,
  primaryVariant: Color(0xFFE62272),
  secondary: Color(0xFFE62272),
  onSecondary: Colors.black,
  secondaryVariant: Color(0xFFE62272),
  surface: Colors.white,
  onSurface: Colors.black,
  background: Colors.grey[50],
  onBackground: Colors.black,
  error: Colors.green,
  onError: Colors.white,
  brightness: Brightness.light,
);

// TextTheme lightTextTheme = TextTheme();
ThemeData lightTheme = ThemeData.from(
  colorScheme: lightColorScheme,
  // textTheme: lightTextTheme,
);
