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

UserEventRegistration _$UserEventRegistrationFromJson(
    Map<String, dynamic> json) {
  return UserEventRegistration(
    json['pk'] as int,
    json['present'] as bool?,
    json['queue_position'] as int?,
    DateTime.parse(json['date'] as String),
    json['payment'] == null
        ? null
        : Payment.fromJson(json['payment'] as Map<String, dynamic>),
    json['is_cancelled'] as bool,
    json['is_late_cancellation'] as bool? ?? false,
  );
}

Map<String, dynamic> _$UserEventRegistrationToJson(
        UserEventRegistration instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'present': instance.present,
      'queue_position': instance.queuePosition,
      'date': instance.date.toIso8601String(),
      'payment': instance.payment,
      'is_cancelled': instance.isCancelled,
      'is_late_cancellation': instance.isLateCancellation,
    };

AdminEventRegistration _$AdminEventRegistrationFromJson(
    Map<String, dynamic> json) {
  return AdminEventRegistration(
    json['pk'] as int,
    json['member'] == null
        ? null
        : ListMember.fromJson(json['member'] as Map<String, dynamic>),
    json['name'] as String?,
    json['present'] as bool,
    json['queue_position'] as int?,
    DateTime.parse(json['date'] as String),
    json['payment'] == null
        ? null
        : Payment.fromJson(json['payment'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$AdminEventRegistrationToJson(
        AdminEventRegistration instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'member': instance.member,
      'name': instance.name,
      'present': instance.present,
      'queue_position': instance.queuePosition,
      'date': instance.date.toIso8601String(),
      'payment': instance.payment,
    };
