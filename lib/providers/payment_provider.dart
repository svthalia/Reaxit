import 'dart:convert';

import 'package:reaxit/models/pizza_order.dart';
import 'package:reaxit/providers/api_service.dart';
import 'package:reaxit/providers/auth_provider.dart';

class PhotosProvider extends ApiService {
  PhotosProvider(AuthProvider authProvider) : super(authProvider);

  @override
  Future<void> loadImplementation() async {
    // TODO: get thaliapay info (allowed or not), probably from authprovider
  }

  Future<void> makePizzaPayment(PizzaOrder pizzaOrder) async {
    String body = jsonEncode({
      "app_label": "pizzas",
      "model_name": "pizza_order",
      "payable_pk": pizzaOrder.pk,
    });
    String response = await this.post("/payments/", body);
  }
}
