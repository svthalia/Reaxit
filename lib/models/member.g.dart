// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Member _$MemberFromJson(Map<String, dynamic> json) {
  return Member(
    json['pk'] as int,
    _$enumDecode(_$MembershipTypeEnumMap, json['membership_type']),
    Profile.fromJson(json['profile'] as Map<String, dynamic>),
    (json['achievements'] as List<dynamic>?)
        ?.map((e) => Achievement.fromJson(e as Map<String, dynamic>))
        .toList(),
    (json['societies'] as List<dynamic>?)
        ?.map((e) => Achievement.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$MemberToJson(Member instance) => <String, dynamic>{
      'pk': instance.pk,
      'membership_type': _$MembershipTypeEnumMap[instance.membershipType],
      'profile': instance.profile,
      'achievements': instance.achievements,
      'societies': instance.societies,
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

const _$MembershipTypeEnumMap = {
  MembershipType.member: 'member',
  MembershipType.benefactor: 'benefactor',
  MembershipType.honorary: 'honorary',
};

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  return Profile(
    json['display_name'] as String,
    json['short_display_name'] as String,
    json['birthday'] == null
        ? null
        : DateTime.parse(json['birthday'] as String),
    Photo.fromJson(json['photo'] as Map<String, dynamic>),
    _$enumDecodeNullable(_$ProgrammeEnumMap, json['programme']),
    json['starting_year'] as int,
    json['website'] == null ? null : Uri.parse(json['website'] as String),
    json['profile_description'] as String?,
  );
}

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'display_name': instance.displayName,
      'short_display_name': instance.shortDisplayName,
      'birthday': instance.birthday?.toIso8601String(),
      'photo': instance.photo,
      'programme': _$ProgrammeEnumMap[instance.programme],
      'starting_year': instance.startingYear,
      'website': instance.website?.toString(),
      'profile_description': instance.profileDescription,
    };

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  dynamic source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
}

const _$ProgrammeEnumMap = {
  Programme.computingscience: 'computingscience',
  Programme.informationscience: 'informationscience',
};

Period _$PeriodFromJson(Map<String, dynamic> json) {
  return Period(
    DateTime.parse(json['since'] as String),
    DateTime.parse(json['until'] as String),
    json['chair'] as bool,
    json['role'] as String,
  );
}

Map<String, dynamic> _$PeriodToJson(Period instance) => <String, dynamic>{
      'since': instance.since.toIso8601String(),
      'until': instance.until.toIso8601String(),
      'chair': instance.chair,
      'role': instance.role,
    };

Achievement _$AchievementFromJson(Map<String, dynamic> json) {
  return Achievement(
    json['name'] as String,
    (json['periods'] as List<dynamic>)
        .map((e) => Period.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$AchievementToJson(Achievement instance) =>
    <String, dynamic>{
      'name': instance.name,
      'periods': instance.periods,
    };
