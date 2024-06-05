// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thabliod.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Thabloid _$ThabloidFromJson(Map<String, dynamic> json) => Thabloid(
      (json['pk'] as num).toInt(),
      (json['year'] as num).toInt(),
      (json['issue'] as num).toInt(),
      json['cover'] as String,
      json['file'] as String,
    );

Map<String, dynamic> _$ThabloidToJson(Thabloid instance) => <String, dynamic>{
      'pk': instance.pk,
      'year': instance.year,
      'issue': instance.issue,
      'cover': instance.cover,
      'file': instance.file,
    };
