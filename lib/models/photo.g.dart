// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoverPhoto _$CoverPhotoFromJson(Map<String, dynamic> json) => CoverPhoto(
      (json['pk'] as num).toInt(),
      (json['rotation'] as num?)?.toInt() ?? 0,
      Photo.fromJson(json['file'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CoverPhotoToJson(CoverPhoto instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'rotation': instance.rotation,
      'file': instance.file,
    };

AlbumPhoto _$AlbumPhotoFromJson(Map<String, dynamic> json) => AlbumPhoto(
      (json['pk'] as num).toInt(),
      (json['rotation'] as num?)?.toInt() ?? 0,
      Photo.fromJson(json['file'] as Map<String, dynamic>),
      json['liked'] as bool,
      (json['num_likes'] as num).toInt(),
    );

Map<String, dynamic> _$AlbumPhotoToJson(AlbumPhoto instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'rotation': instance.rotation,
      'file': instance.file.toJson(),
      'liked': instance.liked,
      'num_likes': instance.numLikes,
    };

Photo _$PhotoFromJson(Map<String, dynamic> json) => Photo(
      json['full'] as String,
      json['small'] as String,
      json['medium'] as String,
      json['large'] as String,
    );

Map<String, dynamic> _$PhotoToJson(Photo instance) => <String, dynamic>{
      'full': instance.full,
      'small': instance.small,
      'medium': instance.medium,
      'large': instance.large,
    };
