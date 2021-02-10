import 'package:flutter/material.dart';
import 'package:reaxit/providers/pizzas_provider.dart';
import 'package:reaxit/ui/components/network_wrapper.dart';

class PizzaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pizza'),
      ),
      body: NetworkWrapper<PizzasProvider>(
        builder: (context, pizzas) {
          if (pizzas.hasOrder) {
            return ListView(
              children: [Center(child: Text("has order"))],
              physics: AlwaysScrollableScrollPhysics(),
            );
          } else {
            return ListView(
              children: [Center(child: Text("has no order"))],
              physics: AlwaysScrollableScrollPhysics(),
            );
          }
        },
      ),
    );
  }
}
