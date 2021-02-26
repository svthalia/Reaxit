import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models/user_registration.dart';

part 'event.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Event {
  final int pk;
  final String title;
  final String description;
  @JsonKey(fromJson: _dateTimeFromJson)
  final DateTime start;
  @JsonKey(fromJson: _dateTimeFromJson)
  final DateTime end;
  final String location;
  final String mapLocation;
  final String price;
  final bool registered;
  final bool isPizzaEvent;
  final bool registrationAllowed;
  @JsonKey(fromJson: _dateTimeFromJson)
  final DateTime registrationStart;
  @JsonKey(fromJson: _dateTimeFromJson)
  final DateTime registrationEnd;
  final Registration userRegistration;
  @JsonKey(fromJson: _dateTimeFromJson)
  final DateTime cancelDeadline;
  final int numParticipants;
  final int maxParticipants;
  final String noRegistrationMessage;
  final String fine;
  final bool hasFields;
  final String googleMapsUrl;
  final bool isAdmin;

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
    this.googleMapsUrl,
    this.mapLocation,
    this.isAdmin,
  );

  bool registrationRequired() {
    return registrationStart != null || registrationEnd != null;
  }

  bool registrationStarted() {
    return registrationStart.isBefore(DateTime.now());
  }

  bool isLateCancellation() {
    return userRegistration != null &&
        userRegistration.isLateCancellation != null;
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
