import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  background: Colors.grey[50]!,
  onBackground: Colors.black,
  error: Colors.red,
  onError: Colors.white,
  brightness: Brightness.light,
);

ColorScheme darkColorScheme = ColorScheme(
  primary: Color(0xFFE62272),
  onPrimary: Colors.white,
  primaryVariant: Color(0xFFE62272),
  secondary: Color(0xFFE62272),
  onSecondary: Colors.black,
  secondaryVariant: Color(0xFFE62272),
  surface: Color(0xFF181818),
  onSurface: Colors.white,
  background: Colors.black,
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
  headline1: GoogleFonts.oswald(
    fontSize: 88,
    fontWeight: FontWeight.w300,
    letterSpacing: -1.5,
  ),
  headline2: GoogleFonts.oswald(
    fontSize: 55,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.5,
  ),
  headline3: GoogleFonts.oswald(
    fontSize: 44,
    fontWeight: FontWeight.w400,
  ),
  headline4: GoogleFonts.oswald(
    fontSize: 31,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  ),
  headline5: GoogleFonts.oswald(
    // increased fontSize from 22
    fontSize: 24,
    fontWeight: FontWeight.w400,
  ),
  headline6: GoogleFonts.oswald(
    // increased fontSize from 18
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  ),
  subtitle1: GoogleFonts.oswald(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
  ),
  subtitle2: GoogleFonts.oswald(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  ),
  bodyText1: GoogleFonts.openSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  ),
  bodyText2: GoogleFonts.openSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  ),
  button: GoogleFonts.oswald(
    // switched fontFamily from openSans
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
  ),
  caption: GoogleFonts.openSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  ),
  overline: GoogleFonts.openSans(
    fontSize: 10,
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
  toggleableActiveColor: darkColorScheme.primary,
  // TODO: Make text less white.
  primaryTextTheme: ThemeData.dark().primaryTextTheme.merge(generatedTextTheme),
  appBarTheme: lightTheme.appBarTheme.copyWith(color: Colors.black),
  dialogBackgroundColor: darkColorScheme.surface,
  dividerColor: Colors.white38,
);
