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
    json['start'] == null ? null : DateTime.parse(json['start'] as String).toLocal(),
    json['end'] == null ? null : DateTime.parse(json['end'] as String).toLocal(),
    json['location'] as String,
    json['price'] as String,
    json['registered'] as bool,
    json['pizza'] as bool,
    json['registration_allowed'] as bool,
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
    };
