import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models/user_registration.dart';

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
  @JsonKey(name: 'registration_start', fromJson: _dateTimeFromJson, nullable: true)
  final DateTime registrationStart;
  @JsonKey(name: 'registration_end', fromJson: _dateTimeFromJson, nullable: true)
  final DateTime registrationEnd;
  @JsonKey(nullable: true)
  final UserRegistration registration;
  @JsonKey(name: 'cancel_deadline', fromJson: _dateTimeFromJson, nullable: true)
  final DateTime cancelDeadline;

  Event(this.pk, this.title, this.description, this.start, this.end, this.location, this.price, this.registered, this.pizza, this.registrationAllowed, this.registrationStart, this.registrationEnd, this.registration, this.cancelDeadline);

  bool registrationRequired() {
    return registrationStart != null || registrationEnd != null;
  }

  bool registrationStarted() {
    return registrationStart.isBefore(DateTime.now());
  }

  bool isLateCancellation() {
    return registration != null && registration.isLateCancellation;
  }

  bool registrationAllowedAndPossible() {
    return registrationRequired() && (DateTime.now()).isBefore(registrationEnd) && registrationStarted() && registrationAllowed && !isLateCancellation();
  }

  bool afterCancelDeadline() {
    cancelDeadline != null && (DateTime.now()).isAfter(cancelDeadline);
  }

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}

DateTime _dateTimeFromJson(json) {
  if (json == null) {
    return null;
  }
  else {
    return DateTime.parse(json).toLocal();
  }
}