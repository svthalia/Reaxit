import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models/payment.dart';

part 'payable.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Payable {
  final String amount;
  final String topic;
  final String? notes;
  final Payment? payment;

  bool get isPaid => payment != null;

  factory Payable.fromJson(Map<String, dynamic> json) =>
      _$PayableFromJson(json);

  const Payable(
    this.amount,
    this.topic,
    this.notes,
    this.payment,
  );
}
