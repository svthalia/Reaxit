import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:reaxit/models/pizza.dart';
import 'package:reaxit/models/pizza_order.dart';
import 'package:reaxit/providers/api_service.dart';
import 'package:reaxit/providers/auth_provider.dart';

class PizzasProvider extends ApiService {
  List<Pizza> _pizzaList = [];

  List<Pizza> get pizzaList => _pizzaList;

  PizzasProvider(AuthProvider authProvider) : super(authProvider);

  bool get hasOrder => true;

  Future<void> load() async {
    status = ApiStatus.LOADING;
    notifyListeners();
    try {
      String response = await this.get("/pizzas/");
      List<dynamic> jsonPizzas = jsonDecode(response);
      print(jsonPizzas);
      _pizzaList =
          jsonPizzas.map((jsonPizza) => Pizza.fromJson(jsonPizza)).toList();
      status = ApiStatus.DONE;
      notifyListeners();
    } on ApiException catch (_) {
      notifyListeners();
    }
  }

  Future<PizzaOrder> getMyOrder() {
    // TODO: retrieve orders
    throw UnimplementedError();
  }

  Future<PizzaOrder> orderPizza(Pizza pizza) async {
    // TODO: order pizza
    throw UnimplementedError();
  }

  Future<void> cancelOrder(PizzaOrder order) async {
    // TODO: order pizza
    throw UnimplementedError();
  }

  Future<List<PizzaOrder>> getOrders() async {
    // TODO: retrieve orders
    throw UnimplementedError();
  }

  Future<PizzaOrder> updateOrder(PizzaOrder order, String payment) async {
    // TODO: update an order
    throw UnimplementedError();
  }
}

// TODO: change provider system:
// should have an abstract class that does authentication and provides some general networking utilities, (can be used in networkwrapper)
// and subclasses for lists (can be used in scrollablewrapper)
// subclass with search
// Other subclasses/implementations without a single list (pizzas)
