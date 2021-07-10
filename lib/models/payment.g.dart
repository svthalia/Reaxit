// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) {
  return Payment(
    json['pk'] as String,
    json['topic'] as String,
    json['notes'] as String?,
    _$enumDecode(_$PaymentTypeEnumMap, json['type']),
    json['amount'] as String,
    DateTime.parse(json['created_at'] as String),
  );
}

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
      'pk': instance.pk,
      'topic': instance.topic,
      'notes': instance.notes,
      'type': _$PaymentTypeEnumMap[instance.type],
      'amount': instance.amount,
      'created_at': instance.createdAt.toIso8601String(),
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$PaymentTypeEnumMap = {
  PaymentType.cashPayment: 'cash_payment',
  PaymentType.cardPayment: 'card_payment',
  PaymentType.tpayPayment: 'tpay_payment',
  PaymentType.wirePayment: 'wire_payment',
};
