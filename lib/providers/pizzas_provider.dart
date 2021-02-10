import 'dart:convert';

import 'package:reaxit/models/pizza.dart';
import 'package:reaxit/models/pizza_event.dart';
import 'package:reaxit/models/pizza_order.dart';
import 'package:reaxit/providers/api_service.dart';
import 'package:reaxit/providers/auth_provider.dart';

class PizzasProvider extends ApiService {
  List<Pizza> _pizzaList = [];

  List<Pizza> get pizzaList => _pizzaList;

  PizzaOrder _myOrder;
  PizzaOrder get myOrder => _myOrder;
  bool get hasOrder => _myOrder != null;

  PizzaEvent _pizzaEvent;
  PizzaEvent get pizzaEvent => _pizzaEvent;
  bool get canOrder =>
      _pizzaEvent != null &&
      DateTime.now().isAfter(_pizzaEvent?.start) &&
      DateTime.now().isBefore(_pizzaEvent?.end);

  PizzasProvider(AuthProvider authProvider) : super(authProvider);

  @override
  Future<void> loadImplementation() async {
    _pizzaList = await _getPizzas();
    _pizzaEvent = await _getPizzaEvent();
    _myOrder = await _getMyOrder();
    // TODO: may need to manually handle some errors here...
  }

  Future<List<Pizza>> _getPizzas() async {
    String response = await this.get("/pizzas/");
    List<dynamic> jsonPizzas = jsonDecode(response);
    return jsonPizzas.map((jsonPizza) => Pizza.fromJson(jsonPizza)).toList();
  }

  Future<PizzaOrder> _getMyOrder() async {
    String response = await this.get("/pizzas/orders/me");
    return PizzaOrder.fromJson(jsonDecode(response));
  }

  Future<PizzaEvent> _getPizzaEvent() async {
    String response = await this.get("/pizzas/event");
    return PizzaEvent.fromJson(jsonDecode(response));
  }

  Future<PizzaOrder> orderPizza(Pizza pizza) async {
    // TODO: order pizza
    throw UnimplementedError();
  }

  Future<void> cancelOrder(PizzaOrder order) async {
    // TODO: cancel order, separate cancelMyOrder()?
    throw UnimplementedError();
  }

  Future<List<PizzaOrder>> getOrders() async {
    // TODO: retrieve orders
    throw UnimplementedError();
  }

  Future<PizzaOrder> updateOrder(PizzaOrder order, String payment) async {
    // TODO: update an order, separate or only updateMyOrder()?
    throw UnimplementedError();
  }
}
