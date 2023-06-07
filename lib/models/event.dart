import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models.dart';

part 'event.g.dart';

enum EventCategory { alumni, education, career, leisure, association, other }

enum RegistrationStatus {
  notRegistered,
  registered,
  inQueue,
  cancelled,
  lateCancelled
}

abstract class BaseEvent {
  abstract final int pk;
  abstract final String title;
  abstract final String caption;
  abstract final DateTime start;
  abstract final DateTime end;
  abstract final String location;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Event implements BaseEvent {
  @override
  final int pk;
  @override
  final String title;
  @override
  final String caption;
  @override
  final DateTime start;
  @override
  final DateTime end;
  @override
  final String location;

  final String url;

  final List<SmallGroup> organisers;

  final EventCategory category;

  final bool hasFields;

  final bool optionalRegistrations;

  final DateTime? registrationStart;
  final DateTime? registrationEnd;
  final DateTime? cancelDeadline;

  final String price;
  final String fine;

  final int numParticipants;
  final int? maxParticipants;

  final String cancelTooLateMessage;
  final String? noRegistrationMessage;
  final int? foodEvent;
  final String mapsUrl;
  final EventPermissions userPermissions;
  @JsonKey(name: 'user_registration')
  final UserEventRegistration? registration;

  final List<Document> documents;

  bool get hasFoodEvent => foodEvent != null;

  bool get isRegistered => registration?.isRegistered ?? false;
  bool get isInQueue => registration?.isInQueue ?? false;
  bool get isInvited => registration?.isInvited ?? false;

  bool get registrationIsRequired =>
      registrationStart != null || registrationEnd != null;

  bool get registrationIsOptional =>
      optionalRegistrations && !registrationIsRequired;

  bool get paymentIsRequired => double.tryParse(price) != 0;

  bool get reachedMaxParticipants =>
      maxParticipants != null && numParticipants >= maxParticipants!;

  bool cancelDeadlinePassed() =>
      cancelDeadline?.isBefore(DateTime.now()) ?? false;
  bool registrationStarted() =>
      registrationStart?.isBefore(DateTime.now()) ?? false;
  bool registrationClosed() =>
      registrationEnd?.isBefore(DateTime.now()) ?? false;
  bool registrationIsOpen() => registrationStarted() && !registrationClosed();

  bool hasStarted() => start.isBefore(DateTime.now());
  bool hasEnded() => end.isBefore(DateTime.now());

  bool get canCreateRegistration => userPermissions.createRegistration;
  bool get canUpdateRegistration => userPermissions.updateRegistration;
  bool get canCancelRegistration => userPermissions.cancelRegistration;
  bool get canManageEvent => userPermissions.manageEvent;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  const Event(
    this.pk,
    this.title,
    this.url,
    this.caption,
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
    this.registration,
    this.organisers,
    this.cancelTooLateMessage,
    this.optionalRegistrations,
    this.documents,
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

@JsonSerializable(fieldRename: FieldRename.snake)
class PartnerEvent implements BaseEvent {
  @override
  final int pk;
  @override
  final String title;
  @override
  final String caption;
  @override
  final DateTime start;
  @override
  final DateTime end;
  @override
  final String location;

  final Uri url;

  factory PartnerEvent.fromJson(Map<String, dynamic> json) =>
      _$PartnerEventFromJson(json);

  const PartnerEvent(
    this.pk,
    this.title,
    this.caption,
    this.start,
    this.end,
    this.location,
    this.url,
  );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminEvent implements BaseEvent {
  @override
  @JsonKey(name: 'id')
  final int pk;
  @override
  final String title;
  @override
  final String caption;
  @override
  final DateTime start;
  @override
  final DateTime end;
  @override
  final String location;

  final String description;
  final EventCategory category;
  final bool optionalRegistrations;
  final DateTime? registrationStart;
  final DateTime? registrationEnd;
  final DateTime? cancelDeadline;

  final String price;
  final String fine;

  // final Uri markPresentUrl;
  final String markPresentUrlToken;

  bool get registrationIsRequired =>
      registrationStart != null || registrationEnd != null;

  bool get registrationIsOptional =>
      optionalRegistrations && !registrationIsRequired;

  bool get paymentIsRequired => double.tryParse(price) != 0;

  bool cancelDeadlinePassed() =>
      cancelDeadline?.isBefore(DateTime.now()) ?? false;
  bool registrationStarted() =>
      registrationStart?.isBefore(DateTime.now()) ?? false;
  bool registrationClosed() =>
      registrationEnd?.isBefore(DateTime.now()) ?? false;
  bool registrationIsOpen() => registrationStarted() && !registrationClosed();

  bool hasStarted() => start.isBefore(DateTime.now());
  bool hasEnded() => end.isBefore(DateTime.now());

  factory AdminEvent.fromJson(Map<String, dynamic> json) =>
      _$AdminEventFromJson(json);

  AdminEvent(
    this.pk,
    this.title,
    this.caption,
    this.start,
    this.end,
    this.location,
    this.description,
    this.category,
    this.optionalRegistrations,
    this.registrationStart,
    this.registrationEnd,
    this.cancelDeadline,
    this.price,
    this.fine,
    this.markPresentUrlToken,
  );
}
