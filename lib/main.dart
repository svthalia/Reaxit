import 'package:flutter/material.dart';
import 'package:reaxit/ui/screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThaliApp',
      theme: ThemeData(
        primaryColor: Color(0xFFE62272),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
    );
  }
}
