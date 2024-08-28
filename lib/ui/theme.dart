import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color magenta = Color(0xFFE62272);

ColorScheme lightColorScheme = const ColorScheme(
  primary: magenta,
  onPrimary: Colors.white,
  secondary: magenta,
  onSecondary: Colors.white,
  surface: Colors.white,
  surfaceTint: Colors.transparent,
  onSurface: Colors.black,
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
  surfaceTint: Colors.transparent,
  onSurface: Colors.white,
  error: Colors.red,
  onError: Colors.white,
  brightness: Brightness.dark,
);

DividerThemeData dividerTheme = const DividerThemeData(
  thickness: 0,
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

ButtonStyle darkElevatedButtonStyle = ButtonStyle(
  backgroundColor:
      WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return darkColorScheme.onSurface.withOpacity(0.12);
    }
    return darkColorScheme.primary;
  }),
  foregroundColor:
      WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return darkColorScheme.onSurface.withOpacity(0.38);
    }
    return darkColorScheme.onPrimary;
  }),
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
  dividerTheme: dividerTheme,
);

ThemeData darkTheme = ThemeData.from(
  colorScheme: darkColorScheme,
  textTheme: generatedTextTheme,
).copyWith(
  applyElevationOverlayColor: false,
  // TODO: Make text less white.
  primaryTextTheme: ThemeData.dark().primaryTextTheme.merge(generatedTextTheme),
  elevatedButtonTheme: ElevatedButtonThemeData(style: darkElevatedButtonStyle),
  appBarTheme: lightTheme.appBarTheme.copyWith(),
  dialogBackgroundColor: darkColorScheme.surface,
  dividerColor: Colors.white60,
  checkboxTheme: CheckboxThemeData(
    fillColor:
        WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return null;
      }
      if (states.contains(WidgetState.selected)) {
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
        WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return null;
      }
      if (states.contains(WidgetState.selected)) {
        return darkColorScheme.primary;
      }
      return null;
    }),
  ),
  switchTheme: SwitchThemeData(
    thumbColor:
        WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return null;
      }
      if (states.contains(WidgetState.selected)) {
        return darkColorScheme.primary;
      }
      return null;
    }),
    trackColor:
        WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return null;
      }
      if (states.contains(WidgetState.selected)) {
        return darkColorScheme.primary;
      }
      return null;
    }),
  ),
  dividerTheme: dividerTheme,
);
