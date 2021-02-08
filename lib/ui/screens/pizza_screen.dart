import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/providers/api_service.dart';
import 'package:reaxit/providers/pizzas_provider.dart';
import 'package:reaxit/ui/components/network_scrollable_wrapper.dart';

class PizzaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PizzasProvider>(
      builder: (context, pizzas, child) {
        if (pizzas.status == ApiStatus.DONE) {
          if (pizzas.hasOrder)
            return Scaffold(
              appBar: AppBar(
                title: Text('Pizza'),
              ),
              body: Text("pizza ordered"),
            );
        }
      },
    );
  }
}
