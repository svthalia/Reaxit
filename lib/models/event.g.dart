// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
  (json['pk'] as num).toInt(),
  json['title'] as String,
  json['url'] as String,
  json['caption'] as String,
  json['description'] as String,
  DateTime.parse(json['start'] as String),
  DateTime.parse(json['end'] as String),
  $enumDecode(_$EventCategoryEnumMap, json['category']),
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
  json['price'] as String,
  json['fine'] as String,
  (json['num_participants'] as num).toInt(),
  (json['max_participants'] as num?)?.toInt(),
  json['no_registration_message'] as String?,
  json['has_fields'] as bool,
  (json['food_event'] as num?)?.toInt(),
  json['maps_url'] as String,
  EventPermissions.fromJson(json['user_permissions'] as Map<String, dynamic>),
  json['user_registration'] == null
      ? null
      : UserEventRegistration.fromJson(
        json['user_registration'] as Map<String, dynamic>,
      ),
  (json['organisers'] as List<dynamic>)
      .map((e) => SmallGroup.fromJson(e as Map<String, dynamic>))
      .toList(),
  json['cancel_too_late_message'] as String,
  json['optional_registrations'] as bool,
  (json['documents'] as List<dynamic>)
      .map((e) => Document.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
  'pk': instance.pk,
  'title': instance.title,
  'caption': instance.caption,
  'start': instance.start.toIso8601String(),
  'end': instance.end.toIso8601String(),
  'location': instance.location,
  'description': instance.description,
  'url': instance.url,
  'organisers': instance.organisers,
  'category': _$EventCategoryEnumMap[instance.category]!,
  'has_fields': instance.hasFields,
  'optional_registrations': instance.optionalRegistrations,
  'registration_start': instance.registrationStart?.toIso8601String(),
  'registration_end': instance.registrationEnd?.toIso8601String(),
  'cancel_deadline': instance.cancelDeadline?.toIso8601String(),
  'price': instance.price,
  'fine': instance.fine,
  'num_participants': instance.numParticipants,
  'max_participants': instance.maxParticipants,
  'cancel_too_late_message': instance.cancelTooLateMessage,
  'no_registration_message': instance.noRegistrationMessage,
  'food_event': instance.foodEvent,
  'maps_url': instance.mapsUrl,
  'user_permissions': instance.userPermissions,
  'user_registration': instance.registration,
  'documents': instance.documents,
};

const _$EventCategoryEnumMap = {
  EventCategory.alumni: 'alumni',
  EventCategory.education: 'education',
  EventCategory.career: 'career',
  EventCategory.leisure: 'leisure',
  EventCategory.association: 'association',
  EventCategory.other: 'other',
};

EventPermissions _$EventPermissionsFromJson(Map<String, dynamic> json) =>
    EventPermissions(
      json['create_registration'] as bool,
      json['create_registration_when_open'] as bool,
      json['cancel_registration'] as bool,
      json['update_registration'] as bool,
      json['manage_event'] as bool,
    );

Map<String, dynamic> _$EventPermissionsToJson(EventPermissions instance) =>
    <String, dynamic>{
      'create_registration': instance.createRegistration,
      'create_registration_when_open': instance.createRegistrationWhenOpen,
      'cancel_registration': instance.cancelRegistration,
      'update_registration': instance.updateRegistration,
      'manage_event': instance.manageEvent,
    };

PartnerEvent _$PartnerEventFromJson(Map<String, dynamic> json) => PartnerEvent(
  (json['pk'] as num).toInt(),
  json['title'] as String,
  json['description'] as String,
  DateTime.parse(json['start'] as String),
  DateTime.parse(json['end'] as String),
  json['location'] as String,
  Uri.parse(json['url'] as String),
);

Map<String, dynamic> _$PartnerEventToJson(PartnerEvent instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'title': instance.title,
      'description': instance.caption,
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'location': instance.location,
      'url': instance.url.toString(),
    };

AdminEvent _$AdminEventFromJson(Map<String, dynamic> json) => AdminEvent(
  (json['id'] as num).toInt(),
  json['title'] as String,
  json['caption'] as String,
  DateTime.parse(json['start'] as String),
  DateTime.parse(json['end'] as String),
  json['location'] as String,
  json['description'] as String,
  $enumDecode(_$EventCategoryEnumMap, json['category']),
  json['optional_registrations'] as bool,
  json['registration_start'] == null
      ? null
      : DateTime.parse(json['registration_start'] as String),
  json['registration_end'] == null
      ? null
      : DateTime.parse(json['registration_end'] as String),
  json['cancel_deadline'] == null
      ? null
      : DateTime.parse(json['cancel_deadline'] as String),
  json['price'] as String,
  json['fine'] as String,
  json['mark_present_url_token'] as String,
);

Map<String, dynamic> _$AdminEventToJson(AdminEvent instance) =>
    <String, dynamic>{
      'id': instance.pk,
      'title': instance.title,
      'caption': instance.caption,
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'location': instance.location,
      'description': instance.description,
      'category': _$EventCategoryEnumMap[instance.category]!,
      'optional_registrations': instance.optionalRegistrations,
      'registration_start': instance.registrationStart?.toIso8601String(),
      'registration_end': instance.registrationEnd?.toIso8601String(),
      'cancel_deadline': instance.cancelDeadline?.toIso8601String(),
      'price': instance.price,
      'fine': instance.fine,
      'mark_present_url_token': instance.markPresentUrlToken,
    };
