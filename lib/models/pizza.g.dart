// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pizza.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pizza _$PizzaFromJson(Map<String, dynamic> json) {
  return Pizza(
    json['pk'] as int,
    json['name'] as String,
    json['available'] as bool,
    json['price'] as String,
  );
}

Map<String, dynamic> _$PizzaToJson(Pizza instance) => <String, dynamic>{
      'pk': instance.pk,
      'name': instance.name,
      'available': instance.available,
      'price': instance.price,
    };
