import 'package:json_annotation/json_annotation.dart';

part 'pizza_order.g.dart';

@JsonSerializable()
class PizzaOrder {
  final int pk;
  @JsonKey(name: "product")
  final int pizza;
  final String name;
  final String payment;
  final String member;

  PizzaOrder(this.pk, this.name, this.pizza, this.payment, this.member);

  factory PizzaOrder.fromJson(Map<String, dynamic> json) =>
      _$PizzaOrderFromJson(json);
}
