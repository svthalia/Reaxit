// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShiftListProduct _$ShiftListProductFromJson(Map<String, dynamic> json) =>
    ShiftListProduct(
      json['name'] as String,
      json['price'] as String,
      json['age_restricted'] as bool,
    );

Map<String, dynamic> _$ShiftListProductToJson(ShiftListProduct instance) =>
    <String, dynamic>{
      'name': instance.name,
      'price': instance.price,
      'age_restricted': instance.ageRestricted,
    };

ShiftProduct _$ShiftProductFromJson(Map<String, dynamic> json) => ShiftProduct(
  (json['pk'] as num).toInt(),
  json['name'] as String,
  json['description'] as String,
  json['price'] as String,
);

Map<String, dynamic> _$ShiftProductToJson(ShiftProduct instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
    };
