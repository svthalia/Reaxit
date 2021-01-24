// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Photo _$PhotoFromJson(Map<String, dynamic> json) {
  return Photo(
    json['full'] as String,
    json['small'] as String,
    json['medium'] as String,
    json['large'] as String,
  );
}

Map<String, dynamic> _$PhotoToJson(Photo instance) => <String, dynamic>{
      'full': instance.full,
      'small': instance.small,
      'medium': instance.medium,
      'large': instance.large,
    };
