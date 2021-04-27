import 'package:flutter/material.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';

class PizzaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThaliaAppBar(),
      body: Center(
        child: Text('Pizza'),
      ),
    );
  }
}
