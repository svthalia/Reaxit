// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Registration _$RegistrationFromJson(Map<String, dynamic> json) {
  return Registration(
    json['pk'] as int,
    json['member'] as int,
    json['name'] as String,
    _dateTimeFromJson(json['registered_on']),
    json['is_cancelled'] as bool,
    json['is_late_cancellation'] as bool,
    json['queue_position'] as int,
    json['payment'] as String,
    json['present'] as bool,
    json['avatar'] == null
        ? null
        : Photo.fromJson(json['avatar'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RegistrationToJson(Registration instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'member': instance.memberPk,
      'name': instance.name,
      'registered_on': instance.registeredOn?.toIso8601String(),
      'is_cancelled': instance.isCancelled,
      'is_late_cancellation': instance.isLateCancellation,
      'queue_position': instance.queuePosition,
      'avatar': instance.avatar,
      'present': instance.present,
      'payment': instance.payment,
    };
