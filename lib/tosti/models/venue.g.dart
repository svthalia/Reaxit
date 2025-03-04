// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TostiVenue _$TostiVenueFromJson(Map<String, dynamic> json) => TostiVenue(
  (json['id'] as num).toInt(),
  json['name'] as String,
  json['slug'] as String,
  json['color_in_calendar'] as String?,
  json['can_be_reserved'] as bool,
);

Map<String, dynamic> _$TostiVenueToJson(TostiVenue instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'color_in_calendar': instance.colorInCalendar,
      'can_be_reserved': instance.canBeReserved,
    };

TostiOrderVenue _$TostiOrderVenueFromJson(Map<String, dynamic> json) =>
    TostiOrderVenue(TostiVenue.fromJson(json['venue'] as Map<String, dynamic>));

Map<String, dynamic> _$TostiOrderVenueToJson(TostiOrderVenue instance) =>
    <String, dynamic>{'venue': instance.venue};
