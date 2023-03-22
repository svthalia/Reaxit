import 'package:json_annotation/json_annotation.dart';

part 'payment_user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class PaymentUser {
  final String? tpayBalance;
  final bool tpayAllowed;
  final bool tpayEnabled;

  factory PaymentUser.fromJson(Map<String, dynamic> json) =>
      _$PaymentUserFromJson(json);

  const PaymentUser(this.tpayBalance, this.tpayAllowed, this.tpayEnabled);
}
