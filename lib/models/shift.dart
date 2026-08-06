import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models/shift_product.dart';

part 'shift.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ShiftInfo extends Equatable {
  final int pk;
  final String title;
  final DateTime start;
  final DateTime end;

  @override
  List<Object?> get props => [pk, title, start, end];

  // bool get hasOrder => order != null;

  bool hasEnded() => DateTime.now().isAfter(end);
  bool hasStarted() => DateTime.now().isAfter(start);

  bool canOrder() => hasStarted() && !hasEnded();
  // bool canChangeOrder() =>
  //     hasOrder &&
  //     canOrder() &&
  //     (!order!.isPaid || order!.payment!.type == PaymentType.tpayPayment);

  factory ShiftInfo.fromJson(Map<String, dynamic> json) =>
      _$ShiftInfoFromJson(json);

  const ShiftInfo(this.pk, this.title, this.start, this.end);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Shift extends Equatable {
  final int pk;
  final String title;
  final DateTime start;
  final DateTime end;
  final List<ShiftListProduct> products;

  @override
  List<Object?> get props => [pk, title, start, end, products];

  // bool get hasOrder => order != null;

  bool hasEnded() => DateTime.now().isAfter(end);
  bool hasStarted() => DateTime.now().isAfter(start);

  bool canOrder() => hasStarted() && !hasEnded();
  // bool canChangeOrder() =>
  //     hasOrder &&
  //     canOrder() &&
  //     (!order!.isPaid || order!.payment!.type == PaymentType.tpayPayment);

  factory Shift.fromJson(Map<String, dynamic> json) => _$ShiftFromJson(json);

  const Shift(this.pk, this.title, this.start, this.end, this.products);
}
