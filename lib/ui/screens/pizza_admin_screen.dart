import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/models/pizza_order.dart';
import 'package:reaxit/providers/api_service.dart';
import 'package:reaxit/providers/pizzas_provider.dart';
import 'package:reaxit/ui/components/network_search_delegate.dart';
import 'package:reaxit/ui/components/network_wrapper.dart';

// TODO: make this properly as in EventAdminScreen, with stateful tiles.

class PizzaAdminScreen extends StatefulWidget {
  @override
  _PizzaAdminScreenState createState() => _PizzaAdminScreenState();
}

class _PizzaAdminScreenState extends State<PizzaAdminScreen> {
  bool filterPaid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () {
            setState(() => filterPaid = !filterPaid);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  filterPaid
                      ? "Showing only unpaid orders"
                      : "Showing all orders",
                ),
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: Icon(Icons.filter_alt),
        ),
      ),
      appBar: AppBar(
        title: Text("Orders"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: "Search for orders",
            onPressed: () => showSearch(
              context: context,
              delegate: NetworkSearchDelegate<PizzasProvider>(
                search: (pizzas, query) => pizzas.searchOrders(query),
                resultBuilder: (context, pizzas, orderList) {
                  return ListView.builder(
                    itemCount: orderList.length,
                    itemBuilder: (context, index) =>
                        _OrderTile(orderList[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: NetworkWrapper<PizzasProvider>(
        showWhileLoading: true,
        builder: (context, pizzas) {
          return ListView.builder(
            itemCount: pizzas.orderList.length,
            itemBuilder: (context, index) {
              PizzaOrder order = pizzas.orderList[index];
              if (filterPaid && order.isPaid) {
                return SizedBox(height: 0, width: 0);
              } else {
                return _OrderTile(order);
              }
            },
          );
        },
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final PizzaOrder order;

  const _OrderTile(this.order);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          dense: true,
          title: Text(order.displayName),
          subtitle: Text(order.pizza.name),
          trailing: order.payment == "tpay_payment"
              ? DropdownButton(
                  items: [DropdownMenuItem(child: Text("Thalia Pay"))],
                  value: order.payment,
                  onChanged: null,
                )
              : DropdownButton(
                  value: order.payment,
                  onChanged: (payment) async {
                    try {
                      await Provider.of<PizzasProvider>(context, listen: false)
                          .payOrder(order, payment);
                      order.payment = payment;
                      // payOrder loads the list again, this is only
                      // temporary so that the value is updated before
                      // finishing the loading.
                    } on ApiException {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            (payment == "no_payment")
                                ? "Couldn't mark ${order.displayName}'s order as not paid..."
                                : "Couldn't mark ${order.displayName}'s order as paid...",
                          ),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: "no_payment",
                      child: Text("Not paid"),
                    ),
                    DropdownMenuItem(
                      value: "cash_payment",
                      child: Text("Cash"),
                    ),
                    DropdownMenuItem(
                      value: "card_payment",
                      child: Text("Card"),
                    ),
                  ],
                ),
        ),
        Divider(),
      ],
    );
  }
}
