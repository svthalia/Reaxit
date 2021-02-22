import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:reaxit/models/pizza.dart';
import 'package:reaxit/models/pizza_event.dart';
import 'package:reaxit/models/pizza_order.dart';
import 'package:reaxit/providers/api_service.dart';
import 'package:reaxit/providers/auth_provider.dart';

/// Filters a list of orders on a string.
///
/// [arguments] must be a map with `arguments['list']` a [List<PizzaOrder>] and
/// `arguments['query']` the [String] query.
List<PizzaOrder> _filterOrders(Map arguments) {
  return arguments['list'].where((PizzaOrder order) {
    String query = arguments['query'].toLowerCase();
    return (order.displayName.toLowerCase().contains(query) ||
        order.pizza.name.toLowerCase().contains(query));
  }).toList();
}

class PizzasProvider extends ApiService {
  List<Pizza> _pizzaList = [];
  List<Pizza> get pizzaList => _pizzaList;

  List<PizzaOrder> _orderList = [];
  List<PizzaOrder> get orderList => _orderList;

  PizzaOrder _myOrder;
  PizzaOrder get myOrder => _myOrder;
  bool get hasOrder => _myOrder != null;

  PizzaEvent _pizzaEvent;
  PizzaEvent get pizzaEvent => _pizzaEvent;
  bool get hasEvent => _pizzaEvent != null;

  bool canOrder() =>
      _pizzaEvent != null &&
      DateTime.now().isAfter(_pizzaEvent?.start) &&
      DateTime.now().isBefore(_pizzaEvent?.end);

  PizzasProvider(AuthProvider authProvider) : super(authProvider);

  @override
  Future<void> loadImplementation() async {
    _pizzaEvent = await _getPizzaEvent();
    _myOrder = await _getMyOrder();
    _pizzaList = await _getPizzas();
    _orderList = await _getOrders();
    if (_myOrder != null) {
      _myOrder.pizza = _pizzaList.firstWhere(
        (pizza) => pizza.pk == _myOrder.pizzaPk,
      );
    }
  }

  Future<List<Pizza>> _getPizzas() async {
    String response = await this.get("/pizzas/");
    List<dynamic> jsonPizzas = jsonDecode(response);
    return jsonPizzas.map((jsonPizza) => Pizza.fromJson(jsonPizza)).toList();
  }

  Future<PizzaOrder> _getMyOrder() async {
    try {
      String response = await this.get("/pizzas/orders/me/");
      return PizzaOrder.fromJson(jsonDecode(response));
    } on ApiException catch (error) {
      if (error == ApiException.notFound) {
        return null;
      } else {
        rethrow;
      }
    }
  }

  Future<PizzaEvent> _getPizzaEvent() async {
    try {
      String response = await this.get("/pizzas/event/");
      return PizzaEvent.fromJson(jsonDecode(response));
    } on ApiException catch (error) {
      if (error == ApiException.notFound) {
        return null;
      } else {
        rethrow;
      }
    }
  }

  Future<List<PizzaOrder>> _getOrders() async {
    if (_pizzaEvent?.isAdmin ?? false) {
      String response = await this.get("/pizzas/orders/");
      List<dynamic> jsonOrders = jsonDecode(response);
      return jsonOrders.map<PizzaOrder>((jsonOrder) {
        PizzaOrder order = PizzaOrder.fromJson(jsonOrder);
        order.pizza = _pizzaList.firstWhere(
          (pizza) => pizza.pk == order.pizzaPk,
          orElse: () => null,
        );
        return order;
      }).toList();
    } else {
      return [];
    }
  }

  Future<List<PizzaOrder>> searchOrders(String query) async {
    return compute(
      _filterOrders,
      {'list': _orderList, 'query': query},
    );
  }

  Future<void> placeOrder(Pizza pizza) async {
    String body = jsonEncode({'product': pizza.pk});
    if (hasOrder) {
      await this.patch("/pizzas/orders/me/", body);
      _myOrder = await _getMyOrder();
      _myOrder.pizza = pizza;
    } else {
      String response = await this.post("/pizzas/orders/", body);
      _myOrder = PizzaOrder.fromJson(jsonDecode(response));
      _myOrder.pizza = pizza;
    }
    notifyListeners();
  }

  Future<void> cancelOrder() async {
    await this.delete("/pizzas/orders/me/");
    _myOrder = null;
    notifyListeners();
  }

  /// Marks an [order] as paid with payment method [payment].
  Future<void> payOrder(PizzaOrder order, String payment) async {
    String body = jsonEncode({'payment': payment});
    await this.patch("/pizzas/orders/${order.pk}/", body);
    load();
  }
}
