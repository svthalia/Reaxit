import 'package:flutter/material.dart';
import 'package:reaxit/ui/components/menu_drawer.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome'),),
      drawer: MenuDrawer(),
      body: Center(
        child: Text('New Thalia App!'),
      ),
    );
  }
}