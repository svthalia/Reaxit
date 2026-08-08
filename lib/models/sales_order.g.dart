// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalesOrder _$SalesOrderFromJson(Map<String, dynamic> json) => SalesOrder(
  json['pk'] as String,
  (json['shift'] as num).toInt(),
  DateTime.parse(json['created_at'] as String),
  (json['order_items'] as List<dynamic>)
      .map((e) => SalesOrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  json['order_description'] as String,
  json['age_restricted'] as bool,
  json['subtotal'] as String,
  json['discount'] as String?,
  json['total_amount'] as String,
  (json['num_items'] as num).toInt(),
  json['payer'] == null
      ? null
      : ListMember.fromJson(json['payer'] as Map<String, dynamic>),
  json['payment'] == null
      ? null
      : Payment.fromJson(json['payment'] as Map<String, dynamic>),
  Uri.parse(json['payment_url'] as String),
);

Map<String, dynamic> _$SalesOrderToJson(SalesOrder instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'shift': instance.shift,
      'created_at': instance.createdAt.toIso8601String(),
      'order_items': instance.orderItems,
      'order_description': instance.orderDescription,
      'age_restricted': instance.ageRestricted,
      'subtotal': instance.subtotal,
      'discount': instance.discount,
      'total_amount': instance.totalAmount,
      'num_items': instance.numItems,
      'payer': instance.payer,
      'payment': instance.payment,
      'payment_url': instance.paymentUrl.toString(),
    };

SalesOrderItem _$SalesOrderItemFromJson(Map<String, dynamic> json) =>
    SalesOrderItem(
      json['product'] as String,
      (json['amount'] as num).toInt(),
      json['total'] as String,
    );

Map<String, dynamic> _$SalesOrderItemToJson(SalesOrderItem instance) =>
    <String, dynamic>{
      'product': instance.product,
      'amount': instance.amount,
      'total': instance.total,
    };

MinSalesOrderItem _$MinSalesOrderItemFromJson(Map<String, dynamic> json) =>
    MinSalesOrderItem(
      json['product'] as String,
      (json['amount'] as num).toInt(),
    );

Map<String, dynamic> _$MinSalesOrderItemToJson(MinSalesOrderItem instance) =>
    <String, dynamic>{'product': instance.product, 'amount': instance.amount};

ListSalesOrder _$ListSalesOrderFromJson(Map<String, dynamic> json) =>
    ListSalesOrder(
      json['pk'] as String,
      DateTime.parse(json['created_at'] as String),
      json['total_amount'] as String,
      (json['num_items'] as num).toInt(),
      (json['items'] as List<dynamic>)
          .map((e) => MinSalesOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['payer'] == null
          ? null
          : ListMember.fromJson(json['payer'] as Map<String, dynamic>),
      json['payment'] == null
          ? null
          : Payment.fromJson(json['payment'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ListSalesOrderToJson(ListSalesOrder instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'created_at': instance.createdAt.toIso8601String(),
      'total_amount': instance.totalAmount,
      'num_items': instance.numItems,
      'items': instance.items,
      'payer': instance.payer,
      'payment': instance.payment,
    };
