// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TostiOrder _$TostiOrderFromJson(Map<String, dynamic> json) => TostiOrder(
      json['id'] as int,
      DateTime.parse(json['created'] as String),
      json['user'] == null
          ? null
          : TostiUser.fromJson(json['user'] as Map<String, dynamic>),
      TostiProduct.fromJson(json['product'] as Map<String, dynamic>),
      json['order_price'] as String,
      json['ready'] as bool,
      json['ready_at'] == null
          ? null
          : DateTime.parse(json['ready_at'] as String),
      json['paid'] as bool,
      json['paid_at'] == null
          ? null
          : DateTime.parse(json['paid_at'] as String),
    );

Map<String, dynamic> _$TostiOrderToJson(TostiOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created': instance.created.toIso8601String(),
      'user': instance.user,
      'product': instance.product,
      'order_price': instance.orderPrice,
      'ready': instance.ready,
      'ready_at': instance.readyAt?.toIso8601String(),
      'paid': instance.paid,
      'paid_at': instance.paidAt?.toIso8601String(),
    };
