// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Document _$DocumentFromJson(Map<String, dynamic> json) => Document(
      json['pk'] as int,
      json['name'] as String,
      json['url'] as String,
      $enumDecode(_$DocumentCategoryEnumMap, json['category']),
    );

Map<String, dynamic> _$DocumentToJson(Document instance) => <String, dynamic>{
      'pk': instance.pk,
      'name': instance.name,
      'url': instance.url,
      'category': _$DocumentCategoryEnumMap[instance.category]!,
    };

const _$DocumentCategoryEnumMap = {
  DocumentCategory.annual: 'annual',
  DocumentCategory.association: 'association',
  DocumentCategory.event: 'event',
  DocumentCategory.minutes: 'minutes',
  DocumentCategory.misc: 'misc',
};
