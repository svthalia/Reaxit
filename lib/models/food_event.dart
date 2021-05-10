import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models/event.dart';

part 'food_event.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class FoodEvent {
  final int pk;
  final String title;
  final Event event;
  final DateTime start;
  final DateTime end;
  final bool canManage;
  final FoodEvent? order;

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
