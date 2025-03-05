// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Announcement _$AnnouncementFromJson(Map<String, dynamic> json) => Announcement(
  json['content'] as String,
  json['closeable'] as bool,
  json['icon'] as String,
  (json['id'] as num?)?.toInt(),
);

Map<String, dynamic> _$AnnouncementToJson(Announcement instance) =>
    <String, dynamic>{
      'content': instance.content,
      'closeable': instance.closeable,
      'icon': instance.icon,
      'id': instance.id,
    };
