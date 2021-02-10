// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pizza_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PizzaEvent _$PizzaEventFromJson(Map<String, dynamic> json) {
  return PizzaEvent(
    json['start'] == null ? null : DateTime.parse(json['start'] as String),
    json['end'] == null ? null : DateTime.parse(json['end'] as String),
    json['event'] as int,
    json['title'] as String,
    json['isAdmin'] as bool,
  );
}

Map<String, dynamic> _$PizzaEventToJson(PizzaEvent instance) =>
    <String, dynamic>{
      'start': instance.start?.toIso8601String(),
      'end': instance.end?.toIso8601String(),
      'event': instance.event,
      'title': instance.title,
      'isAdmin': instance.isAdmin,
    };
