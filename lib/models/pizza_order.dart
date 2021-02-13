import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models/pizza.dart';

part 'pizza_order.g.dart';

@JsonSerializable()
class PizzaOrder {
  final int pk;
  @JsonKey(name: "product")
  final int pizzaPk;
  final String name;
  final String payment;
  final int member;
  @JsonKey(ignore: true)
  Pizza pizza;

  PizzaOrder(this.pk, this.name, this.pizzaPk, this.payment, this.member);

  bool get isPaid => (payment?.isNotEmpty ?? false) && payment != 'no_payment';

  factory PizzaOrder.fromJson(Map<String, dynamic> json) =>
      _$PizzaOrderFromJson(json);
}
