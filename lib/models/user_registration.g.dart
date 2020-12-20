// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_registration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRegistration _$UserRegistrationFromJson(Map<String, dynamic> json) {
  return UserRegistration(
    json['pk'] as int,
    json['member'] as int,
    json['name'] as String,
    _dateTimeFromJson(json['registered_on']),
    json['is_cancelled'] as bool,
    json['is_late_cancellation'] as bool,
    json['queue_position'] as int,
    json['payment'] as String,
    json['present'] as bool,
  );
}

Map<String, dynamic> _$UserRegistrationToJson(UserRegistration instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'member': instance.member,
      'name': instance.name,
      'registered_on': instance.registeredOn?.toIso8601String(),
      'is_cancelled': instance.isCancelled,
      'is_late_cancellation': instance.isLateCancellation,
      'queue_position': instance.queuePosition,
      'payment': instance.payment,
      'present': instance.present,
    };
