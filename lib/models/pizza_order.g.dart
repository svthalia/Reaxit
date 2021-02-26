// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pizza_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PizzaOrder _$PizzaOrderFromJson(Map<String, dynamic> json) {
  return PizzaOrder(
    json['pk'] as int,
    json['name'] as String,
    json['product'] as int,
    json['payment'] as String,
    json['member'] as int,
    json['display_name'] as String,
  );
}

Map<String, dynamic> _$PizzaOrderToJson(PizzaOrder instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'product': instance.pizzaPk,
      'name': instance.name,
      'member': instance.member,
      'display_name': instance.displayName,
      'payment': instance.payment,
    };
