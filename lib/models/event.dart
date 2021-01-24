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
  @JsonKey(name: 'is_pizza_event')
  final bool isPizzaEvent;
  @JsonKey(name: 'registration_allowed')
  final bool registrationAllowed;
  @JsonKey(
      name: 'registration_start', fromJson: _dateTimeFromJson, nullable: true)
  final DateTime registrationStart;
  @JsonKey(
      name: 'registration_end', fromJson: _dateTimeFromJson, nullable: true)
  final DateTime registrationEnd;
  @JsonKey(nullable: true)
  final UserRegistration userRegistration;
  @JsonKey(name: 'cancel_deadline', fromJson: _dateTimeFromJson, nullable: true)
  final DateTime cancelDeadline;
  @JsonKey(name: 'num_participants', nullable: true)
  final int numParticipants;
  @JsonKey(name: 'max_participants', nullable: true)
  final int maxParticipants;
  @JsonKey(name: 'no_registration_message', nullable: true)
  final String noRegistrationMessage;
  final String fine;
  @JsonKey(name: 'has_fields')
  final bool hasFields;

  Event(
    this.pk,
    this.title,
    this.description,
    this.start,
    this.end,
    this.location,
    this.price,
    this.registered,
    this.isPizzaEvent,
    this.registrationAllowed,
    this.registrationStart,
    this.registrationEnd,
    this.userRegistration,
    this.cancelDeadline,
    this.numParticipants,
    this.maxParticipants,
    this.noRegistrationMessage,
    this.fine,
    this.hasFields,
  );

  bool registrationRequired() {
    return registrationStart != null || registrationEnd != null;
  }

  bool registrationStarted() {
    return registrationStart.isBefore(DateTime.now());
  }

  bool isLateCancellation() {
    return userRegistration != null && userRegistration.isLateCancellation;
  }

  bool registrationAllowedAndPossible() {
    return registrationRequired() &&
        (DateTime.now()).isBefore(registrationEnd) &&
        registrationStarted() &&
        registrationAllowed &&
        !isLateCancellation();
  }

  bool afterCancelDeadline() {
    return cancelDeadline != null && (DateTime.now()).isAfter(cancelDeadline);
  }

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}

DateTime _dateTimeFromJson(json) {
  if (json == null) {
    return null;
  } else {
    return DateTime.parse(json).toLocal();
  }
}
