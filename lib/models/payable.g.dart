// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payable _$PayableFromJson(Map<String, dynamic> json) {
  return Payable(
    json['amount'] as String,
    json['topic'] as String,
    json['notes'] as String?,
    json['payment'] == null
        ? null
        : Payment.fromJson(json['payment'] as Map<String, dynamic>),
    json['tpay_allowed'] as bool,
  );
}

Map<String, dynamic> _$PayableToJson(Payable instance) => <String, dynamic>{
      'amount': instance.amount,
      'topic': instance.topic,
      'notes': instance.notes,
      'payment': instance.payment,
      'tpay_allowed': instance.tpayAllowed,
    };
