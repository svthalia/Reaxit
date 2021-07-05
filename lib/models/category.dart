import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Category {
  final String key;
  final String name;
  final String description;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  const Category(
    this.key, this.name, this.description
  );
}