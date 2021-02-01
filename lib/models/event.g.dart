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
    json['is_pizza_event'] as bool,
    json['registration_allowed'] as bool,
    _dateTimeFromJson(json['registration_start']),
    _dateTimeFromJson(json['registration_end']),
    _userRegistrationFromJson(json['user_registration']),
    _dateTimeFromJson(json['cancel_deadline']),
    json['num_participants'] as int,
    json['max_participants'] as int,
    json['no_registration_message'] as String,
    json['fine'] as String,
    json['has_fields'] as bool,
    json['google_maps_url'] as String,
    json['map_location'] as String,
  );
}

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'pk': instance.pk,
      'title': instance.title,
      'description': instance.description,
      'start': instance.start?.toIso8601String(),
      'end': instance.end?.toIso8601String(),
      'location': instance.location,
      'map_location': instance.mapLocation,
      'price': instance.price,
      'registered': instance.registered,
      'is_pizza_event': instance.isPizzaEvent,
      'registration_allowed': instance.registrationAllowed,
      'registration_start': instance.registrationStart?.toIso8601String(),
      'registration_end': instance.registrationEnd?.toIso8601String(),
      'user_registration': instance.userRegistration,
      'cancel_deadline': instance.cancelDeadline?.toIso8601String(),
      'num_participants': instance.numParticipants,
      'max_participants': instance.maxParticipants,
      'no_registration_message': instance.noRegistrationMessage,
      'fine': instance.fine,
      'has_fields': instance.hasFields,
      'google_maps_url': instance.googleMapsUrl,
    };
