import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models/member.dart';
import 'package:reaxit/models/payment.dart';

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

  @JsonKey(ignore: true)
  bool? _tpayAllowed;

  /// Whether this registration can be paid with Thalia Pay.
  /// See https://github.com/svthalia/concrexit/issues/1784.
  ///
  /// Warning: this is only properly set on registrations
  /// retrieved through [ApiRepository.getEvent].
  @JsonKey(ignore: true)
  bool get tpayAllowed => _tpayAllowed ?? false;

  // TODO: Cancelled registrations.
  bool get isLateCancelled => false;
  bool get isCancelled => false;

  @JsonKey(ignore: true)
  set tpayAllowed(bool value) => _tpayAllowed = value;

  bool get isInQueue => queuePosition != null;
  bool get isInvited => queuePosition == null;
  bool get isPaid => payment != null;

  factory UserEventRegistration.fromJson(Map<String, dynamic> json) =>
      _$UserEventRegistrationFromJson(json);

  UserEventRegistration(
    this.pk,
    this.present,
    this.queuePosition,
    this.date,
    this.payment,
  );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminEventRegistration
    implements EventRegistration, UserEventRegistration {
  @override
  final int pk;
  @override
  final ListMember? member;
  @override
  final String? name;

  @override
  final bool present;
  @override
  final int? queuePosition;
  @override
  final DateTime date;
  @override
  final Payment? payment;

  @override
  @JsonKey(ignore: true)
  bool? _tpayAllowed;

  /// Whether this registration can be paid with Thalia Pay.
  /// See https://github.com/svthalia/concrexit/issues/1784.
  ///
  /// Warning: this is not properly set on orders retrieved
  /// through [ApiRepository.getEvents].
  @override
  @JsonKey(ignore: true)
  bool get tpayAllowed => _tpayAllowed ?? false;
  @override
  @JsonKey(ignore: true)
  set tpayAllowed(bool value) => _tpayAllowed = value;

  @override
  bool get isInQueue => queuePosition != null;
  @override
  bool get isInvited => queuePosition == null;
  @override
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

  @override
  // TODO: Implement isCancelled.
  bool get isCancelled => false;

  @override
  // TODO: Implement isLateCancelled.
  bool get isLateCancelled => false;
}
