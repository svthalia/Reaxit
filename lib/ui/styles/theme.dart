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
  background: Colors.grey[50],
  onBackground: Colors.black,
  error: Colors.green,
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
  surface: Colors.grey[900],
  onSurface: Colors.white,
  background: Colors.black,
  onBackground: Colors.white,
  error: Colors.green,
  onError: Colors.white,
  brightness: Brightness.dark,
);

TextTheme baseTextTheme = GoogleFonts.openSansTextTheme();
TextTheme oswaldTextTheme = TextTheme().copyWith(
  headline1: GoogleFonts.oswald(textStyle: baseTextTheme.headline1),
  headline2: GoogleFonts.oswald(textStyle: baseTextTheme.headline2),
  headline3: GoogleFonts.oswald(textStyle: baseTextTheme.headline3),
  headline4: GoogleFonts.oswald(textStyle: baseTextTheme.headline4),
  headline5: GoogleFonts.oswald(textStyle: baseTextTheme.headline5),
  headline6: GoogleFonts.oswald(textStyle: baseTextTheme.headline6),
  subtitle1: GoogleFonts.oswald(textStyle: baseTextTheme.subtitle1),
  subtitle2: GoogleFonts.oswald(textStyle: baseTextTheme.subtitle2),
  caption: GoogleFonts.oswald(textStyle: baseTextTheme.caption),

  // bodyText1: GoogleFonts.oswald(textStyle: baseTextTheme.bodyText1),
  // bodyText2: GoogleFonts.oswald(textStyle: baseTextTheme.bodyText2),
  // button: GoogleFonts.oswald(textStyle: baseTextTheme.button),
  // bodyText2: GoogleFonts.oswald(textStyle: baseTextTheme.bodyText2),
);

ThemeData lightBaseTheme = ThemeData.from(
  colorScheme: lightColorScheme,
  textTheme: oswaldTextTheme,
);

ThemeData lightTheme = lightBaseTheme.copyWith(
  // appBarTheme: lightBaseTheme.appBarTheme.copyWith(
  //   textTheme: TextTheme(
  //     headline6: GoogleFonts.oswald(
  //       textStyle: ThemeData.light().primaryTextTheme.headline6,
  //       fontSize: 22,
  //     ),
  //   ),
  // ),
  primaryTextTheme:
      GoogleFonts.oswaldTextTheme(ThemeData.light().primaryTextTheme),
);

// AppBar a = AppBar());
