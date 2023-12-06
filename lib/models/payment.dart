import 'package:json_annotation/json_annotation.dart';

part 'payment.g.dart';

enum PaymentType {
  @JsonValue('cash_payment')
  cashPayment,
  @JsonValue('card_payment')
  cardPayment,
  @JsonValue('tpay_payment')
  tpayPayment,
  @JsonValue('wire_payment')
  wirePayment;

  @override
  String toString() {
    switch (this) {
      case PaymentType.cashPayment:
        return 'Cash payment';
      case PaymentType.cardPayment:
        return 'Card payment';
      case PaymentType.tpayPayment:
        return 'Thalia Pay';
      case PaymentType.wirePayment:
        return 'Wire payment';
    }
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Payment {
  final String pk;
  final String topic;
  final String? notes;
  final PaymentType type;
  final String amount;
  final DateTime createdAt;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);

  const Payment(
    this.pk,
    this.topic,
    this.notes,
    this.type,
    this.amount,
    this.createdAt,
  );
}
