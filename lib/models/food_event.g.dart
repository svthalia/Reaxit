// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodEvent _$FoodEventFromJson(Map<String, dynamic> json) {
  return FoodEvent(
    json['pk'] as int,
    Event.fromJson(json['event'] as Map<String, dynamic>),
    DateTime.parse(json['start'] as String),
    DateTime.parse(json['end'] as String),
    json['can_manage'] as bool,
    json['order'] == null
        ? null
        : FoodEvent.fromJson(json['order'] as Map<String, dynamic>),
    json['title'] as String,
  );
}

Map<String, dynamic> _$FoodEventToJson(FoodEvent instance) => <String, dynamic>{
      'pk': instance.pk,
      'title': instance.title,
      'event': instance.event,
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'can_manage': instance.canManage,
      'order': instance.order,
    };
