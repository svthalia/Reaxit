import 'package:flutter/material.dart';

abstract class BaseColorScheme {
  const BaseColorScheme({
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.onSecondaryContainer,
    required this.secondaryContainer,
    required this.surface,
    required this.onSurface,
    required this.background,
    required this.onBackground,
    required this.error,
    required this.onError,
  });

  final Brightness brightness;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color surface;
  final Color onSurface;
  final Color background;
  final Color onBackground;
  final Color error;
  final Color onError;

  ColorScheme get materialColorScheme => ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      surface: surface,
      onSurface: onSurface,
      background: background,
      onBackground: background,
      error: error,
      onError: onError);
}


