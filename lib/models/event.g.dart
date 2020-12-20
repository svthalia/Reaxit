// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) {
  return Event(
    json['pk'] as int,
    json['title'] as String,
    json['description'] as String,
    _dateTimeFromJson(json['start']),
    _dateTimeFromJson(json['end']),
    json['location'] as String,
    json['price'] as String,
    json['registered'] as bool,
    json['pizza'] as bool,
    json['registration_allowed'] as bool,
    _dateTimeFromJson(json['registration_start']),
    _dateTimeFromJson(json['registration_end']),
    json['registration'] == null
        ? null
        : UserRegistration.fromJson(
            json['registration'] as Map<String, dynamic>),
    _dateTimeFromJson(json['cancel_deadline']),
  );
}

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'pk': instance.pk,
      'title': instance.title,
      'description': instance.description,
      'start': instance.start?.toIso8601String(),
      'end': instance.end?.toIso8601String(),
      'location': instance.location,
      'price': instance.price,
      'registered': instance.registered,
      'pizza': instance.pizza,
      'registration_allowed': instance.registrationAllowed,
      'registration_start': instance.registrationStart?.toIso8601String(),
      'registration_end': instance.registrationEnd?.toIso8601String(),
      'registration': instance.registration,
      'cancel_deadline': instance.cancelDeadline?.toIso8601String(),
    };
