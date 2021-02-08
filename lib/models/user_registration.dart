import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models/member.dart';
import 'package:reaxit/models/photo.dart';

part 'user_registration.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserRegistration {
  final int pk;
  @JsonKey(name: 'member')
  final int memberPk;
  final String name;
  @JsonKey(fromJson: _dateTimeFromJson)
  final DateTime registeredOn;
  final bool isCancelled;
  final bool isLateCancellation;
  final int queuePosition;
  final String payment;
  final bool present;
  final Photo avatar;

  UserRegistration(
    this.pk,
    this.memberPk,
    this.name,
    this.registeredOn,
    this.isCancelled,
    this.isLateCancellation,
    this.queuePosition,
    this.payment,
    this.present,
    this.avatar,
  );

  factory UserRegistration.fromJson(Map<String, dynamic> json) =>
      _$UserRegistrationFromJson(json);

  Member get member => Member(
      memberPk, name, avatar, null, null, null, null, null, null, null, null);
}

DateTime _dateTimeFromJson(json) {
  if (json == null) {
    return null;
  } else {
    return DateTime.parse(json).toLocal();
  }
}
