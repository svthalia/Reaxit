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

  const EventRegistration(this.pk, this.member, this.name);
}
