import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/models/pizza.dart';
import 'package:reaxit/models/pizza_event.dart';
import 'package:reaxit/providers/api_service.dart';
import 'package:reaxit/providers/pizzas_provider.dart';
import 'package:reaxit/ui/components/network_wrapper.dart';
import 'package:reaxit/ui/screens/pizza_admin_screen.dart';

class PizzaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pizza"),
        actions: [
          Consumer<PizzasProvider>(
            builder: (context, pizzas, child) {
              if (pizzas.pizzaEvent?.isAdmin ?? false) {
                return IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PizzaAdminScreen(),
                      ),
                    );
                  },
                );
              } else {
                return SizedBox(
                  width: 0,
                  height: 0,
                );
              }
            },
          )
        ],
      ),
      body: NetworkWrapper<PizzasProvider>(
        showWhileLoading: true,
        builder: (context, pizzas) {
          if (!pizzas.hasEvent) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  height: 100,
                  margin: const EdgeInsets.all(10),
                  child: Image.asset(
                    'assets/img/sad_cloud.png',
                    fit: BoxFit.fitHeight,
                  ),
                ),
                Text(
                  "There is currently no event for which food can be ordered",
                  textAlign: TextAlign.center,
                ),
              ],
            );
          } else if (!pizzas.hasOrder) {
            return ListView(
              padding: const EdgeInsets.all(10),
              children: [
                _PizzaEventInfo(pizzas.pizzaEvent),
                Divider(),
                Card(
                  child: Column(
                    children: ListTile.divideTiles(
                      context: context,
                      tiles: pizzas.pizzaList.map(
                        (pizza) {
                          return _PizzaTile(
                            pizza,
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _placeOrder(context, pizzas, pizza),
                              icon: Icon(Icons.shopping_bag),
                              label: Text("ORDER"),
                            ),
                          );
                        },
                      ),
                    ).toList(),
                  ),
                ),
              ],
            );
          } else {
            return ListView(
              padding: const EdgeInsets.all(10),
              children: [
                _PizzaEventInfo(pizzas.pizzaEvent),
                Divider(),
                _MyOrderInfoCard(pizzas),
                if (!pizzas.myOrder.isPaid) Divider(),
                if (!pizzas.myOrder.isPaid)
                  Card(
                    child: Column(
                      children: ListTile.divideTiles(
                        context: context,
                        tiles: pizzas.pizzaList.map(
                          (pizza) {
                            return _PizzaTile(
                              pizza,
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _placeOrder(context, pizzas, pizza),
                                icon: Icon(Icons.shopping_bag),
                                label: Text("CHANGE"),
                              ),
                            );
                          },
                        ),
                      ).toList(),
                    ),
                  ),
              ],
            );
          }
        },
      ),
    );
  }

  _placeOrder(BuildContext context, PizzasProvider pizzas, Pizza pizza) async {
    try {
      await pizzas.placeOrder(pizza);
    } on ApiException {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Couldn't order '${pizza.name}'..."),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}

class _PizzaTile extends StatelessWidget {
  final Pizza _pizza;
  final Widget _trailing;

  const _PizzaTile(this._pizza, [this._trailing]);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.local_pizza),
      title: Row(
        children: [
          Text(_pizza.name),
          SizedBox(width: 5),
          Text(
            "€${_pizza.price}",
            style: Theme.of(context).textTheme.caption.copyWith(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
      subtitle: (_pizza.description?.isNotEmpty ?? false)
          ? Text(_pizza.description)
          : null,
      enabled: _pizza.available,
      trailing: _trailing,
    );
  }
}

class _PizzaEventInfo extends StatelessWidget {
  final PizzaEvent _pizzaEvent;

  const _PizzaEventInfo(this._pizzaEvent);

  @override
  Widget build(BuildContext context) {
    DateFormat formatter = DateFormat('HH:mm');
    String start = formatter.format(_pizzaEvent.start);
    String end = formatter.format(_pizzaEvent.end);

    Text subtitle;
    if (!_pizzaEvent.hasStarted()) {
      subtitle = Text("It will be possible to order from $start.");
    } else if (_pizzaEvent.hasEnded()) {
      subtitle = Text("It was possible to order until $end.");
    } else {
      subtitle = Text("You can order until $end.");
    }

    return Column(
      children: [
        Text(
          _pizzaEvent.title,
          style: Theme.of(context).textTheme.headline5,
        ),
        subtitle,
      ],
    );
  }
}

class _MyOrderInfoCard extends StatelessWidget {
  final PizzasProvider _pizzas;

  const _MyOrderInfoCard(this._pizzas);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: _pizzas.myOrder.isPaid
                ? Container(
                    padding: const EdgeInsets.all(40),
                    color: Colors.green.shade200,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 200,
                        color: Colors.green.shade400,
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(40),
                    color: Colors.red.shade700,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Icon(
                        Icons.highlight_off,
                        color: Colors.red.shade900,
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 10,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _pizzas.myOrder.pizza.name,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    Text(
                      _pizzas.myOrder.isPaid
                          ? "has been paid"
                          : "not yet paid: €${_pizzas.myOrder.pizza.price}",
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ],
                ),
                if (_pizzas.myOrder.pizza?.description?.isNotEmpty ??
                    false) ...[
                  Divider(),
                  Text(_pizzas.myOrder.pizza.description),
                ],
                if (!_pizzas.myOrder.isPaid) ...[
                  Divider(),
                  if (_pizzas.canOrder())
                    ElevatedButton.icon(
                      onPressed: () => _cancelOrder(context),
                      icon: Icon(Icons.cancel),
                      label: Text("CANCEL ORDER"),
                    ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Thalia Pay!
                    },
                    icon: Icon(Icons.euro),
                    label: Text("THALIA PAY: €${_pizzas.myOrder.pizza.price}"),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelOrder(BuildContext context) async {
    try {
      await _pizzas.cancelOrder();
    } on ApiException catch (error) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Couldn't cancel the order...$error"),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}
