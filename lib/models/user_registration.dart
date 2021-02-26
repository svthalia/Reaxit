import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models/member.dart';
import 'package:reaxit/models/photo.dart';

part 'user_registration.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Registration {
  final int pk;
  @JsonKey(name: 'member')
  final int memberPk;
  final String name;
  @JsonKey(fromJson: _dateTimeFromJson)
  final DateTime registeredOn;
  final bool isCancelled;
  final bool isLateCancellation;
  final int queuePosition;
  final Photo avatar;
  bool present;
  String payment;

  Registration(
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

  factory Registration.fromJson(Map<String, dynamic> json) =>
      _$RegistrationFromJson(json);

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
