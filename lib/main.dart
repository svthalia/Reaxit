import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/ui/screens/login_screen.dart';
import 'package:reaxit/ui/screens/splash_screen.dart';

import 'model/auth_model.dart';
import 'ui/screens/welcome_screen/welcome_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthModel(),
      child: ThaliApp(),
    )
  );
}

class ThaliApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThaliApp',
      theme: ThemeData(
        primaryColor: Color(0xFFE62272),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Consumer<AuthModel>(
        builder: (context, auth, child) {
          switch (auth.status) {
            case Status.INIT:
              return SplashScreen();
            case Status.SIGNED_IN:
              return WelcomeScreen();
            default:
              return LoginScreen();
          }
        },
      )
    );
  }
}
