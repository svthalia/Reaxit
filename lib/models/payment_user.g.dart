// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentUser _$PaymentUserFromJson(Map<String, dynamic> json) {
  return PaymentUser(
    json['balance'] as String?,
    json['tpay_allowed'] as bool,
    json['tpay_enabled'] as bool,
  );
}

Map<String, dynamic> _$PaymentUserToJson(PaymentUser instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'tpay_allowed': instance.tpayAllowed,
      'tpay_enabled': instance.tpayEnabled,
    };
