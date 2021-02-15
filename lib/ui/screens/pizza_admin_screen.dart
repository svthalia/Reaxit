import 'package:flutter/material.dart';
import 'package:reaxit/providers/pizzas_provider.dart';
import 'package:reaxit/ui/components/network_wrapper.dart';

class PizzaAdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pizza Admin"),
      ),
      body: NetworkWrapper<PizzasProvider>(
        builder: (context, pizzas) {
          return Center(
            child: Text("hello"),
          );
        },
      ),
    );
  }
}
