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
    DateTime.parse(json['start'] as String),
    DateTime.parse(json['end'] as String),
    _$enumDecode(_$EventCategoryEnumMap, json['category']),
    json['registration_start'] == null
        ? null
        : DateTime.parse(json['registration_start'] as String),
    json['registration_end'] == null
        ? null
        : DateTime.parse(json['registration_end'] as String),
    json['cancel_deadline'] == null
        ? null
        : DateTime.parse(json['cancel_deadline'] as String),
    json['location'] as String,
    (json['price'] as num).toDouble(),
    (json['fine'] as num).toDouble(),
    json['num_participants'] as int,
    json['max_participants'] as int?,
    json['no_registration_message'] as String?,
    json['has_fields'] as bool,
    json['is_pizza_event'] as bool,
    json['maps_url'] as String,
    EventPermissions.fromJson(json['user_permissions'] as Map<String, dynamic>),
    json['user_registration'] == null
        ? null
        : AdminRegistration.fromJson(
            json['user_registration'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'pk': instance.pk,
      'title': instance.title,
      'description': instance.description,
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'category': _$EventCategoryEnumMap[instance.category],
      'registration_start': instance.registrationStart?.toIso8601String(),
      'registration_end': instance.registrationEnd?.toIso8601String(),
      'cancel_deadline': instance.cancelDeadline?.toIso8601String(),
      'location': instance.location,
      'price': instance.price,
      'fine': instance.fine,
      'num_participants': instance.numParticipants,
      'max_participants': instance.maxParticipants,
      'no_registration_message': instance.noRegistrationMessage,
      'has_fields': instance.hasFields,
      'is_pizza_event': instance.isPizzaEvent,
      'maps_url': instance.mapsUrl,
      'user_permissions': instance.userPermissions,
      'user_registration': instance.userRegistration,
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$EventCategoryEnumMap = {
  EventCategory.alumni: 'alumni',
  EventCategory.education: 'education',
  EventCategory.career: 'career',
  EventCategory.leisure: 'leisure',
  EventCategory.association: 'association',
  EventCategory.other: 'other',
};

EventPermissions _$EventPermissionsFromJson(Map<String, dynamic> json) {
  return EventPermissions(
    json['create_registration'] as bool,
    json['cancel_registration'] as bool,
    json['update_registration'] as bool,
    json['manage_event'] as bool,
  );
}

Map<String, dynamic> _$EventPermissionsToJson(EventPermissions instance) =>
    <String, dynamic>{
      'create_registration': instance.createRegistration,
      'cancel_registration': instance.cancelRegistration,
      'update_registration': instance.updateRegistration,
      'manage_event': instance.manageEvent,
    };
