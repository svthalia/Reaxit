// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thaliedje.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThaliedjePlayer _$ThaliedjePlayerFromJson(Map<String, dynamic> json) =>
    ThaliedjePlayer(
      json['id'] as int,
      json['slug'] as String? ?? 'noord',
      json['display_name'] as String,
      json['venue'] as int,
      json['track'] == null
          ? null
          : ThaliedjeCurrentTrack.fromJson(
              json['track'] as Map<String, dynamic>),
      json['is_playing'] as bool,
      json['current_volume'] as int?,
    );

Map<String, dynamic> _$ThaliedjePlayerToJson(ThaliedjePlayer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'display_name': instance.displayName,
      'venue': instance.venue,
      'track': instance.track,
      'is_playing': instance.isPlaying,
      'current_volume': instance.currentVolume,
    };

ThaliedjeCurrentTrack _$ThaliedjeCurrentTrackFromJson(
        Map<String, dynamic> json) =>
    ThaliedjeCurrentTrack(
      Uri.parse(json['image'] as String),
      json['name'] as String,
      (json['artists'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ThaliedjeCurrentTrackToJson(
        ThaliedjeCurrentTrack instance) =>
    <String, dynamic>{
      'image': instance.image.toString(),
      'name': instance.name,
      'artists': instance.artists,
    };
