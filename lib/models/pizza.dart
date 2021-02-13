import 'package:json_annotation/json_annotation.dart';

part 'pizza.g.dart';

@JsonSerializable()
class Pizza {
  final int pk;
  final String name;
  final String description;
  final bool available;
  final String price;

  Pizza(this.pk, this.name, this.available, this.price, this.description);

  factory Pizza.fromJson(Map<String, dynamic> json) => _$PizzaFromJson(json);
}
