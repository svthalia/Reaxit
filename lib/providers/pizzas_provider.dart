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
    if (authProvider.status == AuthStatus.SIGNED_IN) {
      status = ApiStatus.LOADING;
      notifyListeners();

      try {
        Response response = await authProvider.helper
            .get('https://staging.thalia.nu/api/v1/pizzas/');
        if (response.statusCode == 200) {
          List<dynamic> jsonPizzaList = jsonDecode(response.body)['results'];
          _pizzaList = jsonPizzaList
              .map((jsonPizza) => Pizza.fromJson(jsonPizza))
              .toList();
          status = ApiStatus.DONE;
        } else if (response.statusCode == 403)
          status = ApiStatus.NOT_AUTHENTICATED;
        else
          status = ApiStatus.UNKNOWN_ERROR;
      } on SocketException catch (_) {
        status = ApiStatus.NO_INTERNET;
      } catch (_) {
        status = ApiStatus.UNKNOWN_ERROR;
      }
      // TODO: refactor all providers to use {} in all control statements
      // TODO: change ApiStatus to lowercase

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
