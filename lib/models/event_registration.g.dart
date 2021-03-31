// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_registration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventRegistration _$EventRegistrationFromJson(Map<String, dynamic> json) {
  return EventRegistration(
    json['pk'] as int,
    json['member'] == null
        ? null
        : Member.fromJson(json['member'] as Map<String, dynamic>),
    json['name'] as String?,
  );
}

Map<String, dynamic> _$EventRegistrationToJson(EventRegistration instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'member': instance.member,
      'name': instance.name,
    };
