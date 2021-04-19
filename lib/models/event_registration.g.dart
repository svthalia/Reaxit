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
        : ListMember.fromJson(json['member'] as Map<String, dynamic>),
    json['name'] as String?,
  );
}

Map<String, dynamic> _$EventRegistrationToJson(EventRegistration instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'member': instance.member,
      'name': instance.name,
    };

AdminRegistration _$AdminRegistrationFromJson(Map<String, dynamic> json) {
  return AdminRegistration(
    json['pk'] as int,
    json['present'] as bool,
    json['queue_position'] as int?,
    DateTime.parse(json['date'] as String),
    json['payment'] as String?,
  );
}

Map<String, dynamic> _$AdminRegistrationToJson(AdminRegistration instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'present': instance.present,
      'queue_position': instance.queuePosition,
      'date': instance.date.toIso8601String(),
      'payment': instance.payment,
    };
