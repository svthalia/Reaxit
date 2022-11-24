// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListGroup _$ListGroupFromJson(Map<String, dynamic> json) => ListGroup(
      json['pk'] as int,
      json['name'] as String,
      $enumDecode(_$MemberGroupTypeEnumMap, json['type']),
      json['description'] as String,
      json['since'] == null ? null : DateTime.parse(json['since'] as String),
      json['until'] == null ? null : DateTime.parse(json['until'] as String),
      json['contact_address'] as String,
      Photo.fromJson(json['photo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ListGroupToJson(ListGroup instance) => <String, dynamic>{
      'pk': instance.pk,
      'name': instance.name,
      'type': _$MemberGroupTypeEnumMap[instance.type]!,
      'description': instance.description,
      'since': instance.since?.toIso8601String(),
      'until': instance.until?.toIso8601String(),
      'contact_address': instance.contactAddress,
      'photo': instance.photo,
    };

const _$MemberGroupTypeEnumMap = {
  MemberGroupType.committee: 'committee',
  MemberGroupType.society: 'society',
  MemberGroupType.board: 'board',
};

Group _$GroupFromJson(Map<String, dynamic> json) => Group(
      json['pk'] as int,
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
      'description': instance.description,
      'since': instance.since?.toIso8601String(),
      'until': instance.until?.toIso8601String(),
      'contact_address': instance.contactAddress,
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
