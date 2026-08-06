import 'package:json_annotation/json_annotation.dart';

part 'shift_product.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ShiftListProduct {
  final String name;
  final String price;
  final bool ageRestricted;

  factory ShiftListProduct.fromJson(Map<String, dynamic> json) =>
      _$ShiftListProductFromJson(json);

  const ShiftListProduct(this.name, this.price, this.ageRestricted);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ShiftProduct {
  final int pk;
  final String name;
  final String description;
  final String price;

  factory ShiftProduct.fromJson(Map<String, dynamic> json) =>
      _$ShiftProductFromJson(json);

  const ShiftProduct(this.pk, this.name, this.description, this.price);
}
