import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/providers/auth_provider.dart';

import 'login_screen.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        switch (auth.status) {
          case Status.INIT:
            return Material(
              color: Color(0xFFE62272),
              child: Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),),
              ),
            );
          case Status.SIGNED_IN:
            return WelcomeScreen();
          default:
            return LoginScreen();
        }
      },
    );
  }
}