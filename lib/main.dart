import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/ui/screens/splash_screen.dart';

import 'model/auth_model.dart';

void main() {
  runApp(
    ChangeNotifierProvider<AuthModel>(
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
      home: SplashScreen()
    );
  }
}
