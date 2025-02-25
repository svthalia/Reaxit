// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thaliedje.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThaliedjePlayer _$ThaliedjePlayerFromJson(Map<String, dynamic> json) =>
    ThaliedjePlayer(
      (json['id'] as num).toInt(),
      json['slug'] as String,
      json['display_name'] as String,
      (json['venue'] as num?)?.toInt(),
      json['track'] == null
          ? null
          : ThaliedjeCurrentTrack.fromJson(
            json['track'] as Map<String, dynamic>,
          ),
      json['is_playing'] as bool,
      (json['current_volume'] as num?)?.toDouble(),
      json['shuffle'] as bool?,
      json['repeat'] as String?,
      (json['timestamp'] as num?)?.toInt(),
      (json['duration_ms'] as num?)?.toInt(),
      (json['progress_ms'] as num?)?.toInt(),
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
      'shuffle': instance.shuffle,
      'repeat': instance.repeat,
      'timestamp': instance.timestamp,
      'duration_ms': instance.duration,
      'progress_ms': instance.progress,
    };

ThaliedjeCurrentTrack _$ThaliedjeCurrentTrackFromJson(
  Map<String, dynamic> json,
) => ThaliedjeCurrentTrack(
  json['image'] == null ? null : Uri.parse(json['image'] as String),
  json['name'] as String?,
  (json['artists'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$ThaliedjeCurrentTrackToJson(
  ThaliedjeCurrentTrack instance,
) => <String, dynamic>{
  'image': instance.image?.toString(),
  'name': instance.name,
  'artists': instance.artists,
};
