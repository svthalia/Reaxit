import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/models/food_order.dart';
import 'package:reaxit/models/payment.dart';

part 'food_event.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class FoodEvent {
  final int pk;
  final String title;
  final Event event;
  final DateTime start;
  final DateTime end;
  final bool canManage;
  final FoodOrder? order;

  bool get hasOrder => order != null;

  bool hasEnded() => DateTime.now().isAfter(end);
  bool hasStarted() => DateTime.now().isAfter(start);

  bool canOrder() => hasStarted() && !hasEnded();
  bool canChangeOrder() =>
      hasOrder &&
      canOrder() &&
      (!order!.isPaid || order!.payment!.type == PaymentType.tpayPayment);

  factory FoodEvent.fromJson(Map<String, dynamic> json) =>
      _$FoodEventFromJson(json);

  const FoodEvent(
    this.pk,
    this.event,
    this.start,
    this.end,
    this.canManage,
    this.order,
    this.title,
  );
}
