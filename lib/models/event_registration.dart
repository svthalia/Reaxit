import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models.dart';

part 'event_registration.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class EventRegistration {
  final int pk;
  final ListMember? member;
  final String? name;

  factory EventRegistration.fromJson(Map<String, dynamic> json) =>
      _$EventRegistrationFromJson(json);

  const EventRegistration(this.pk, this.member, this.name)
      : assert(
          member != null || name != null,
          'Either a member or name must be given. $member, $name',
        );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UserEventRegistration {
  final int pk;
  final bool? present;
  final int? queuePosition;
  final DateTime date;
  final Payment? payment;

  final bool isCancelled;

  @JsonKey(defaultValue: false)
  final bool isLateCancellation;

  bool get isRegistered => !isCancelled;
  bool get isInQueue => !isCancelled && queuePosition != null;
  bool get isInvited => !isCancelled && queuePosition == null;

  bool get isPaid => payment != null;

  @JsonKey(ignore: true)
  bool? _tpayAllowed;

  /// Whether this registration can be paid with Thalia Pay.
  /// See https://github.com/svthalia/concrexit/issues/1784.
  ///
  /// Warning: this is only properly set on registrations
  /// retrieved through [ApiRepository.getEvent].
  @JsonKey(ignore: true)
  bool get tpayAllowed => _tpayAllowed ?? false;
  set tpayAllowed(bool value) => _tpayAllowed = value;

  factory UserEventRegistration.fromJson(Map<String, dynamic> json) =>
      _$UserEventRegistrationFromJson(json);

  UserEventRegistration(
    this.pk,
    this.present,
    this.queuePosition,
    this.date,
    this.payment,
    this.isCancelled,
    this.isLateCancellation,
  );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminEventRegistration implements EventRegistration {
  @override
  final int pk;
  @override
  final AdminListMember? member;
  @override
  final String? name;

  final bool present;
  final int? queuePosition;
  final DateTime date;
  final Payment? payment;

  bool get isInQueue => queuePosition != null;
  bool get isInvited => queuePosition == null;
  bool get isPaid => payment != null;

  AdminEventRegistration(
    this.pk,
    this.member,
    this.name,
    this.present,
    this.queuePosition,
    this.date,
    this.payment,
  ) : assert(
          member != null || name != null,
          'Either a member or name must be given.',
        );

  AdminEventRegistration copyWithPresent(bool newPresent) =>
      AdminEventRegistration(
        pk,
        member,
        name,
        newPresent,
        queuePosition,
        date,
        payment,
      );

  AdminEventRegistration copyWithPayment(Payment? newPayment) =>
      AdminEventRegistration(
        pk,
        member,
        name,
        present,
        queuePosition,
        date,
        newPayment,
      );

  factory AdminEventRegistration.fromJson(Map<String, dynamic> json) =>
      _$AdminEventRegistrationFromJson(json);
}
