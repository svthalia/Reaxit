// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListGroup _$ListMemberGroupFromJson(Map<String, dynamic> json) {
  return ListGroup(
    json['pk'] as int,
    json['name'] as String,
    _$enumDecode(_$MemberGroupTypeEnumMap, json['type']),
    json['since'] == null ? null : DateTime.parse(json['since'] as String),
    json['until'] == null ? null : DateTime.parse(json['until'] as String),
    json['contact_address'] as String,
    Photo.fromJson(json['photo'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ListMemberGroupToJson(ListGroup instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'name': instance.name,
      'type': _$MemberGroupTypeEnumMap[instance.type],
      'since': instance.since?.toIso8601String(),
      'until': instance.until?.toIso8601String(),
      'contact_address': instance.contactAddress,
      'photo': instance.photo,
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$MemberGroupTypeEnumMap = {
  MemberGroupType.committee: 'committee',
  MemberGroupType.society: 'society',
  MemberGroupType.board: 'board',
};

Group _$MemberGroupFromJson(Map<String, dynamic> json) {
  return Group(
    json['pk'] as int,
    json['name'] as String,
    _$enumDecode(_$MemberGroupTypeEnumMap, json['type']),
    json['since'] == null ? null : DateTime.parse(json['since'] as String),
    json['until'] == null ? null : DateTime.parse(json['until'] as String),
    json['contact_address'] as String,
    Photo.fromJson(json['photo'] as Map<String, dynamic>),
    (json['members'] as List<dynamic>)
        .map((e) => ListMember.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$MemberGroupToJson(Group instance) => <String, dynamic>{
      'pk': instance.pk,
      'name': instance.name,
      'type': _$MemberGroupTypeEnumMap[instance.type],
      'since': instance.since?.toIso8601String(),
      'until': instance.until?.toIso8601String(),
      'contact_address': instance.contactAddress,
      'photo': instance.photo,
      'members': instance.members,
    };
