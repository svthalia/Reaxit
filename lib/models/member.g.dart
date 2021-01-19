// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListMember _$ListMemberFromJson(Map<String, dynamic> json) {
  return ListMember(
    json['pk'] as int,
    json['starting_year'] as int,
    json['display_name'] as String,
    json['membership_type'] as String,
    json['avatar'] == null
        ? null
        : Avatar.fromJson(json['avatar'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ListMemberToJson(ListMember instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'starting_year': instance.startingYear,
      'display_name': instance.displayName,
      'membership_type': instance.membershipType,
      'avatar': instance.avatar,
    };

DetailMember _$DetailMemberFromJson(Map<String, dynamic> json) {
  return DetailMember(
    json['pk'] as int,
    json['display_name'] as String,
    json['avatar'] == null
        ? null
        : Avatar.fromJson(json['avatar'] as Map<String, dynamic>),
    json['profile_description'] as String,
    json['birthday'] as String,
    json['starting_year'] as int,
    json['programme'] as String,
    json['website'] as String,
    json['membership_type'] as String,
    (json['achievements'] as List)
        ?.map((e) =>
            e == null ? null : Achievement.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['societies'] as List)
        ?.map((e) =>
            e == null ? null : Achievement.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$DetailMemberToJson(DetailMember instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'display_name': instance.displayName,
      'avatar': instance.avatar,
      'profile_description': instance.profileDescription,
      'birthday': instance.birthday,
      'starting_year': instance.startingYear,
      'programme': instance.programme,
      'website': instance.website,
      'membership_type': instance.membershipType,
      'achievements': instance.achievements,
      'societies': instance.societies,
    };

Period _$PeriodFromJson(Map<String, dynamic> json) {
  return Period(
    json['since'] == null ? null : DateTime.parse(json['since'] as String),
    json['until'] == null ? null : DateTime.parse(json['until'] as String),
    json['chair'] as bool,
    json['role'] as String,
  );
}

Map<String, dynamic> _$PeriodToJson(Period instance) => <String, dynamic>{
      'since': instance.since?.toIso8601String(),
      'until': instance.until?.toIso8601String(),
      'chair': instance.chair,
      'role': instance.role,
    };

Achievement _$AchievementFromJson(Map<String, dynamic> json) {
  return Achievement(
    json['name'] as String,
    (json['periods'] as List)
        ?.map((e) =>
            e == null ? null : Period.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$AchievementToJson(Achievement instance) =>
    <String, dynamic>{
      'name': instance.name,
      'periods': instance.periods,
    };

Avatar _$AvatarFromJson(Map<String, dynamic> json) {
  return Avatar(
    json['full'] as String,
    json['small'] as String,
    json['medium'] as String,
    json['large'] as String,
  );
}

Map<String, dynamic> _$AvatarToJson(Avatar instance) => <String, dynamic>{
      'full': instance.full,
      'small': instance.small,
      'medium': instance.medium,
      'large': instance.large,
    };
