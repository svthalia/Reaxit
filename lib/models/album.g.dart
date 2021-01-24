// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Album _$AlbumFromJson(Map<String, dynamic> json) {
  return Album(
    json['pk'] as int,
    json['title'] as String,
    _dateTimeFromJson(json['date']),
    json['cover'] == null
        ? null
        : Photo.fromJson(json['cover'] as Map<String, dynamic>),
    json['hidden'] as bool,
    json['shareable'] as bool,
    json['accessible'] as bool,
  );
}

Map<String, dynamic> _$AlbumToJson(Album instance) => <String, dynamic>{
      'pk': instance.pk,
      'title': instance.title,
      'date': instance.date?.toIso8601String(),
      'cover': instance.cover,
      'hidden': instance.hidden,
      'shareable': instance.shareable,
      'accessible': instance.accessible,
    };
