// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodOrder _$FoodOrderFromJson(Map<String, dynamic> json) {
  return FoodOrder(
    json['pk'] as int,
    json['member'] == null
        ? null
        : ListMember.fromJson(json['member'] as Map<String, dynamic>),
    json['name'] as String?,
    Product.fromJson(json['product'] as Map<String, dynamic>),
    json['payment'] == null
        ? null
        : Payment.fromJson(json['payment'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$FoodOrderToJson(FoodOrder instance) => <String, dynamic>{
      'pk': instance.pk,
      'member': instance.member,
      'name': instance.name,
      'product': instance.product,
      'payment': instance.payment,
    };
