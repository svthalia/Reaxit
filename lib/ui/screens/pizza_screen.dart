import 'package:flutter/material.dart';

class PizzaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pizza'),
      ),
      body: Center(
        child: Icon(Icons.local_pizza),
      ),
    );
  }
}
