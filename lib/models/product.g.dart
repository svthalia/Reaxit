// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      json['pk'] as int,
      json['name'] as String,
      json['description'] as String,
      json['price'] as String,
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'pk': instance.pk,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
    };
