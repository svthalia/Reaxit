// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SmallGroup _$SmallGroupFromJson(Map<String, dynamic> json) => SmallGroup(
  (json['pk'] as num).toInt(),
  json['name'] as String,
  $enumDecode(_$MemberGroupTypeEnumMap, json['type']),
  json['since'] == null ? null : DateTime.parse(json['since'] as String),
  json['until'] == null ? null : DateTime.parse(json['until'] as String),
  json['contact_address'] as String,
);

Map<String, dynamic> _$SmallGroupToJson(SmallGroup instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'name': instance.name,
      'type': _$MemberGroupTypeEnumMap[instance.type]!,
      'since': instance.since?.toIso8601String(),
      'until': instance.until?.toIso8601String(),
      'contact_address': instance.contactAddress,
    };

const _$MemberGroupTypeEnumMap = {
  MemberGroupType.committee: 'committee',
  MemberGroupType.society: 'society',
  MemberGroupType.board: 'board',
};

ListGroup _$ListGroupFromJson(Map<String, dynamic> json) => ListGroup(
  (json['pk'] as num).toInt(),
  json['name'] as String,
  $enumDecode(_$MemberGroupTypeEnumMap, json['type']),
  json['since'] == null ? null : DateTime.parse(json['since'] as String),
  json['until'] == null ? null : DateTime.parse(json['until'] as String),
  json['contact_address'] as String,
  json['description'] as String,
  Photo.fromJson(json['photo'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ListGroupToJson(ListGroup instance) => <String, dynamic>{
  'pk': instance.pk,
  'name': instance.name,
  'type': _$MemberGroupTypeEnumMap[instance.type]!,
  'since': instance.since?.toIso8601String(),
  'until': instance.until?.toIso8601String(),
  'contact_address': instance.contactAddress,
  'description': instance.description,
  'photo': instance.photo.toJson(),
};

Group _$GroupFromJson(Map<String, dynamic> json) => Group(
  (json['pk'] as num).toInt(),
  json['name'] as String,
  $enumDecode(_$MemberGroupTypeEnumMap, json['type']),
  json['description'] as String,
  json['since'] == null ? null : DateTime.parse(json['since'] as String),
  json['until'] == null ? null : DateTime.parse(json['until'] as String),
  json['contact_address'] as String,
  Photo.fromJson(json['photo'] as Map<String, dynamic>),
  (json['members'] as List<dynamic>)
      .map((e) => GroupMembership.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
  'pk': instance.pk,
  'name': instance.name,
  'type': _$MemberGroupTypeEnumMap[instance.type]!,
  'since': instance.since?.toIso8601String(),
  'until': instance.until?.toIso8601String(),
  'contact_address': instance.contactAddress,
  'description': instance.description,
  'photo': instance.photo,
  'members': instance.members,
};

GroupMembership _$GroupMembershipFromJson(Map<String, dynamic> json) =>
    GroupMembership(
      ListMember.fromJson(json['member'] as Map<String, dynamic>),
      json['chair'] as bool,
      DateTime.parse(json['since'] as String),
      json['until'] == null ? null : DateTime.parse(json['until'] as String),
      json['role'] as String?,
    );

Map<String, dynamic> _$GroupMembershipToJson(GroupMembership instance) =>
    <String, dynamic>{
      'member': instance.member,
      'chair': instance.chair,
      'since': instance.since.toIso8601String(),
      'until': instance.until?.toIso8601String(),
      'role': instance.role,
    };
