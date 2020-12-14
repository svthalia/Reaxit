import 'package:json_annotation/json_annotation.dart';

part 'event.g.dart';

@JsonSerializable()
class Event {
  final int pk;
  final String title;
  final String description;
  @JsonKey(fromJson: _dateTimeFromJson)
  final DateTime start;
  @JsonKey(fromJson: _dateTimeFromJson)
  final DateTime end;
  final String location;
  final String price;
  final bool registered;
  final bool pizza;
  @JsonKey(name: 'registration_allowed')
  final bool registrationAllowed;

  Event(this.pk, this.title, this.description, this.start, this.end, this.location, this.price, this.registered, this.pizza, this.registrationAllowed);

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}

DateTime _dateTimeFromJson(json) => DateTime.parse(json).toLocal();