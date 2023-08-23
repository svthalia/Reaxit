import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color magenta = Color(0xFFE62272);

ColorScheme lightColorScheme = ColorScheme(
  primary: magenta,
  onPrimary: Colors.white,
  secondary: magenta,
  onSecondary: Colors.white,
  surface: Colors.white,
  onSurface: Colors.black,
  background: Colors.grey[50]!,
  onBackground: Colors.black,
  error: Colors.red,
  onError: Colors.white,
  brightness: Brightness.light,
);

ColorScheme darkColorScheme = const ColorScheme(
  primary: magenta,
  onPrimary: Colors.white,
  secondary: magenta,
  onSecondary: Colors.white,
  surface: Color(0xFF212121),
  onSurface: Colors.white,
  background: Color(0xFF111111),
  onBackground: Colors.white,
  error: Colors.red,
  onError: Colors.white,
  brightness: Brightness.dark,
);

/// TextTheme mostly following material design guidelines.
///
/// Generated and modified from:
/// https://material.io/design/typography/the-type-system.html
TextTheme generatedTextTheme = TextTheme(
  displayLarge: GoogleFonts.oswald(
    fontSize: 44,
    fontWeight: FontWeight.w400,
    letterSpacing: -1,
  ),
  displayMedium: GoogleFonts.oswald(
    fontSize: 36,
    fontWeight: FontWeight.w300,
  ),
  displaySmall: GoogleFonts.oswald(
    fontSize: 28,
    fontWeight: FontWeight.w400,
  ),
  headlineMedium: GoogleFonts.oswald(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
  ),
  headlineSmall: GoogleFonts.oswald(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  ),
  titleLarge: GoogleFonts.oswald(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  ),
  titleMedium: GoogleFonts.oswald(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  ),
  titleSmall: GoogleFonts.openSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
  ),
  bodyLarge: GoogleFonts.openSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  ),
  bodyMedium: GoogleFonts.openSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  ),
  labelLarge: GoogleFonts.oswald(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
  ),
  bodySmall: GoogleFonts.openSans(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
  ),
  labelSmall: GoogleFonts.openSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.5,
  ),
);

ThemeData lightBaseTheme = ThemeData.from(
  colorScheme: lightColorScheme,
  textTheme: generatedTextTheme,
);

ThemeData lightTheme = lightBaseTheme.copyWith(
  primaryTextTheme:
      ThemeData.light().primaryTextTheme.merge(generatedTextTheme),
  floatingActionButtonTheme: lightBaseTheme.floatingActionButtonTheme.copyWith(
    foregroundColor: Colors.white,
  ),
);

ThemeData darkTheme = ThemeData.from(
  colorScheme: darkColorScheme,
  textTheme: generatedTextTheme,
).copyWith(
  applyElevationOverlayColor: false,
  // TODO: Make text less white.
  primaryTextTheme: ThemeData.dark().primaryTextTheme.merge(generatedTextTheme),
  appBarTheme: lightTheme.appBarTheme.copyWith(
    color: darkColorScheme.background,
  ),
  dialogBackgroundColor: darkColorScheme.surface,
  dividerColor: Colors.white60,
  checkboxTheme: CheckboxThemeData(
    fillColor:
        MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return null;
      }
      if (states.contains(MaterialState.selected)) {
        return darkColorScheme.primary;
      }
      return null;
    }),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    extendedTextStyle: generatedTextTheme.labelLarge,
  ),
  radioTheme: RadioThemeData(
    fillColor:
        MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return null;
      }
      if (states.contains(MaterialState.selected)) {
        return darkColorScheme.primary;
      }
      return null;
    }),
  ),
  switchTheme: SwitchThemeData(
    thumbColor:
        MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return null;
      }
      if (states.contains(MaterialState.selected)) {
        return darkColorScheme.primary;
      }
      return null;
    }),
    trackColor:
        MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return null;
      }
      if (states.contains(MaterialState.selected)) {
        return darkColorScheme.primary;
      }
      return null;
    }),
  ),
);
