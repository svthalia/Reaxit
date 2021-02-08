import 'package:json_annotation/json_annotation.dart';

part 'pizza.g.dart';

@JsonSerializable()
class Pizza {
  final int pk;
  final String name;
  final bool available;
  final String price;

  Pizza(this.pk, this.name, this.available, this.price);

  factory Pizza.fromJson(Map<String, dynamic> json) => _$PizzaFromJson(json);
}
