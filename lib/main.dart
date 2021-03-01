import 'package:flutter/material.dart';
import 'package:reaxit/providers/pizzas_provider.dart';
import 'package:reaxit/providers/settings_provider.dart';
import 'package:reaxit/providers/theme_mode_provider.dart';
import 'package:reaxit/ui/screens/splash_screen.dart';
import 'package:reaxit/ui/styles/theme.dart';

import 'package:provider/provider.dart';
import 'package:reaxit/providers/auth_provider.dart';
import 'package:reaxit/providers/events_provider.dart';
import 'package:reaxit/providers/members_provider.dart';
import 'package:reaxit/providers/photos_provider.dart';

void main() {
  runApp(ThaliApp());
}

class ThaliApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeModeProvider>(
            create: (_) => ThemeModeProvider(),
          ),
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider(),
          ),
          ChangeNotifierProxyProvider<AuthProvider, EventsProvider>(
            create: (context) => EventsProvider(
              Provider.of<AuthProvider>(context, listen: false),
            ),
            update: (context, auth, events) => EventsProvider(auth),
          ),
          ChangeNotifierProxyProvider<AuthProvider, MembersProvider>(
            create: (context) => MembersProvider(
              Provider.of<AuthProvider>(context, listen: false),
            ),
            update: (context, auth, members) => MembersProvider(auth),
          ),
          ChangeNotifierProxyProvider<AuthProvider, PhotosProvider>(
            create: (context) => PhotosProvider(
              Provider.of<AuthProvider>(context, listen: false),
            ),
            update: (context, auth, photos) => PhotosProvider(auth),
          ),
          ChangeNotifierProxyProvider<AuthProvider, PizzasProvider>(
            create: (context) => PizzasProvider(
              Provider.of<AuthProvider>(context, listen: false),
            ),
            update: (context, auth, pizzas) => PizzasProvider(auth),
          ),
          ChangeNotifierProxyProvider<AuthProvider, SettingsProvider>(
            create: (context) => SettingsProvider(
              Provider.of<AuthProvider>(context, listen: false),
            ),
            update: (context, auth, pizzas) => SettingsProvider(auth),
          ),
        ],
        child: Consumer<ThemeModeProvider>(
          builder: (context, themeModeProvider, child) => MaterialApp(
            title: 'ThaliApp',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeModeProvider.themeMode,
            home: SplashScreen(),
          ),
        ));
  }
}
