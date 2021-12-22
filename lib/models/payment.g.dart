// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
      json['pk'] as String,
      json['topic'] as String,
      json['notes'] as String?,
      $enumDecode(_$PaymentTypeEnumMap, json['type']),
      json['amount'] as String,
      DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
      'pk': instance.pk,
      'topic': instance.topic,
      'notes': instance.notes,
      'type': _$PaymentTypeEnumMap[instance.type],
      'amount': instance.amount,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$PaymentTypeEnumMap = {
  PaymentType.cashPayment: 'cash_payment',
  PaymentType.cardPayment: 'card_payment',
  PaymentType.tpayPayment: 'tpay_payment',
  PaymentType.wirePayment: 'wire_payment',
};
