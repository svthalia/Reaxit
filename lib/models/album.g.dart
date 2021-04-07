// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListAlbum _$ListAlbumFromJson(Map<String, dynamic> json) {
  return ListAlbum(
    json['pk'] as int,
    json['title'] as String,
    json['accessible'] as bool,
    json['shareable'] as bool,
    AlbumPhoto.fromJson(json['cover'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ListAlbumToJson(ListAlbum instance) => <String, dynamic>{
      'pk': instance.pk,
      'title': instance.title,
      'accessible': instance.accessible,
      'shareable': instance.shareable,
      'cover': instance.cover,
    };

Album _$AlbumFromJson(Map<String, dynamic> json) {
  return Album(
    json['pk'] as int,
    json['title'] as String,
    json['accessible'] as bool,
    json['shareable'] as bool,
    AlbumPhoto.fromJson(json['cover'] as Map<String, dynamic>),
    (json['photos'] as List<dynamic>)
        .map((e) => AlbumPhoto.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$AlbumToJson(Album instance) => <String, dynamic>{
      'pk': instance.pk,
      'title': instance.title,
      'accessible': instance.accessible,
      'shareable': instance.shareable,
      'cover': instance.cover,
      'photos': instance.photos,
    };
