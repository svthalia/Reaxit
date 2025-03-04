// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListAlbum _$ListAlbumFromJson(Map<String, dynamic> json) => ListAlbum(
  json['slug'] as String,
  json['title'] as String,
  json['accessible'] as bool,
  json['shareable'] as bool,
  json['cover'] == null
      ? null
      : CoverPhoto.fromJson(json['cover'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ListAlbumToJson(ListAlbum instance) => <String, dynamic>{
  'slug': instance.slug,
  'title': instance.title,
  'accessible': instance.accessible,
  'shareable': instance.shareable,
  'cover': instance.cover,
};

Album _$AlbumFromJson(Map<String, dynamic> json) => Album(
  json['slug'] as String,
  json['title'] as String,
  json['accessible'] as bool,
  json['shareable'] as bool,
  json['cover'] == null
      ? null
      : CoverPhoto.fromJson(json['cover'] as Map<String, dynamic>),
  (json['photos'] as List<dynamic>)
      .map((e) => AlbumPhoto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AlbumToJson(Album instance) => <String, dynamic>{
  'slug': instance.slug,
  'title': instance.title,
  'accessible': instance.accessible,
  'shareable': instance.shareable,
  'cover': instance.cover,
  'photos': instance.photos,
};
