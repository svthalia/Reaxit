import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/providers/events_provider.dart';
import 'package:reaxit/ui/screens/splash_screen.dart';
import 'package:reaxit/ui/styles/theme.dart';

import 'providers/auth_provider.dart';

void main() {
  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider(),
          ),
          ChangeNotifierProxyProvider<AuthProvider, EventsProvider>(
              create: (context) => EventsProvider(Provider.of<AuthProvider>(context, listen: false)),
              update: (context, auth, events) => EventsProvider(auth)
          )
        ],
      child: ThaliApp(),
    )
  );
}

class ThaliApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThaliApp',
      theme: lightTheme,
      home: SplashScreen(),
    );
  }
}
