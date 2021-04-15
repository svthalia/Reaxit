import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models/member.dart';

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
class AdminRegistration {
  final int pk;
  final bool present;
  final int? queuePosition;
  final DateTime date;
  final String? payment;

  factory AdminRegistration.fromJson(Map<String, dynamic> json) =>
      _$AdminRegistrationFromJson(json);

  const AdminRegistration(
    this.pk,
    this.present,
    this.queuePosition,
    this.date,
    this.payment,
  );
}
