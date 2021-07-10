import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models/event_registration.dart';

part 'event.g.dart';

enum EventCategory { alumni, education, career, leisure, association, other }

@JsonSerializable(fieldRename: FieldRename.snake)
class Event {
  final int pk;
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final EventCategory category;
  final DateTime? registrationStart;
  final DateTime? registrationEnd;
  final DateTime? cancelDeadline;
  final String location;
  final String price;
  final String fine;
  final int numParticipants;
  final int? maxParticipants;
  final String? noRegistrationMessage;
  final bool hasFields;
  final int? foodEvent;
  final String mapsUrl;
  final EventPermissions userPermissions;
  final AdminRegistration? userRegistration;
  // final Commitee organiser;
  // final Slide? slide;

  bool get hasFoodEvent => foodEvent != null;

  bool get isRegistered => userRegistration != null;
  bool get isInQueue => userRegistration?.isInQueue ?? false;
  bool get isInvited => userRegistration?.isInvited ?? false;
  bool get registrationIsRequired => registrationStart != null;
  bool get paymentIsRequired => double.tryParse(price) != 0;

  bool get canCreateRegistration => userPermissions.createRegistration;
  bool get canUpdateRegistration => userPermissions.updateRegistration;
  bool get canCancelRegistration => userPermissions.cancelRegistration;
  bool get canManageEvent => userPermissions.manageEvent;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  const Event(
    this.pk,
    this.title,
    this.description,
    this.start,
    this.end,
    this.category,
    this.registrationStart,
    this.registrationEnd,
    this.cancelDeadline,
    this.location,
    this.price,
    this.fine,
    this.numParticipants,
    this.maxParticipants,
    this.noRegistrationMessage,
    this.hasFields,
    this.foodEvent,
    this.mapsUrl,
    this.userPermissions,
    this.userRegistration,
  );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class EventPermissions {
  final bool createRegistration;
  final bool cancelRegistration;
  final bool updateRegistration;
  final bool manageEvent;

  const EventPermissions(
    this.createRegistration,
    this.cancelRegistration,
    this.updateRegistration,
    this.manageEvent,
  );

  factory EventPermissions.fromJson(Map<String, dynamic> json) =>
      _$EventPermissionsFromJson(json);
}
