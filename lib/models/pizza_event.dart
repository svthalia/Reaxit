import 'package:json_annotation/json_annotation.dart';

part 'pizza_event.g.dart';

@JsonSerializable()
class PizzaEvent {
  final DateTime start;
  final DateTime end;
  final int event;
  final String title;
  final bool isAdmin;

  PizzaEvent(this.start, this.end, this.event, this.title, this.isAdmin);

  factory PizzaEvent.fromJson(Map<String, dynamic> json) =>
      _$PizzaEventFromJson(json);

  bool hasEnded() => DateTime.now().isAfter(end);
  bool hasStarted() => DateTime.now().isAfter(start);
}
