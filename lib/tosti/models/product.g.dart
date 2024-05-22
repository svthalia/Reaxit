// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TostiProduct _$TostiProductFromJson(Map<String, dynamic> json) => TostiProduct(
      (json['id'] as num).toInt(),
      json['name'] as String,
      json['icon'] as String?,
      json['available'] as bool,
      json['current_price'] as String,
      json['orderable'] as bool,
      json['ignore_shift_restrictions'] as bool,
      (json['max_allowed_per_shift'] as num?)?.toInt(),
      json['barcode'] as String?,
    );

Map<String, dynamic> _$TostiProductToJson(TostiProduct instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'available': instance.available,
      'current_price': instance.currentPrice,
      'orderable': instance.orderable,
      'ignore_shift_restrictions': instance.ignoreShiftRestrictions,
      'max_allowed_per_shift': instance.maxAllowedPerShift,
      'barcode': instance.barcode,
    };
