import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Product {
  final int pk;
  final String name;
  final String description;
  final String price;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  const Product(
    this.pk,
    this.name,
    this.description,
    this.price,
  );
}
