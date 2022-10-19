// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListMember _$ListMemberFromJson(Map<String, dynamic> json) => ListMember(
      json['pk'] as int,
      $enumDecodeNullable(_$MembershipTypeEnumMap, json['membership_type']),
      Profile.fromJson(json['profile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ListMemberToJson(ListMember instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'membership_type': _$MembershipTypeEnumMap[instance.membershipType],
      'profile': instance.profile,
    };

const _$MembershipTypeEnumMap = {
  MembershipType.member: 'member',
  MembershipType.benefactor: 'benefactor',
  MembershipType.honorary: 'honorary',
};

AdminListMember _$AdminListMemberFromJson(Map<String, dynamic> json) =>
    AdminListMember(
      json['pk'] as int,
      $enumDecodeNullable(_$MembershipTypeEnumMap, json['membership_type']),
      Profile.fromJson(json['profile'] as Map<String, dynamic>),
      json['first_name'] as String,
      json['last_name'] as String,
    );

Map<String, dynamic> _$AdminListMemberToJson(AdminListMember instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'membership_type': _$MembershipTypeEnumMap[instance.membershipType],
      'profile': instance.profile,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
    };

Member _$MemberFromJson(Map<String, dynamic> json) => Member(
      json['pk'] as int,
      $enumDecodeNullable(_$MembershipTypeEnumMap, json['membership_type']),
      Profile.fromJson(json['profile'] as Map<String, dynamic>),
      (json['achievements'] as List<dynamic>)
          .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['societies'] as List<dynamic>)
          .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MemberToJson(Member instance) => <String, dynamic>{
      'pk': instance.pk,
      'membership_type': _$MembershipTypeEnumMap[instance.membershipType],
      'profile': instance.profile,
      'achievements': instance.achievements,
      'societies': instance.societies,
    };

FullMember _$FullMemberFromJson(Map<String, dynamic> json) => FullMember(
      json['pk'] as int,
      $enumDecodeNullable(_$MembershipTypeEnumMap, json['membership_type']),
      FullProfile.fromJson(json['profile'] as Map<String, dynamic>),
      (json['achievements'] as List<dynamic>)
          .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['societies'] as List<dynamic>)
          .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FullMemberToJson(FullMember instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'membership_type': _$MembershipTypeEnumMap[instance.membershipType],
      'achievements': instance.achievements,
      'societies': instance.societies,
      'profile': instance.profile,
    };

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
      json['display_name'] as String,
      json['short_display_name'] as String,
      json['birthday'] == null
          ? null
          : DateTime.parse(json['birthday'] as String),
      Photo.fromJson(json['photo'] as Map<String, dynamic>),
      $enumDecodeNullable(_$ProgrammeEnumMap, json['programme']),
      json['starting_year'] as int?,
      _nonEmptyUriFromJson(json['website'] as String?),
      json['profile_description'] as String?,
    );

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

const _$ProgrammeEnumMap = {
  Programme.computingscience: 'computingscience',
  Programme.informationscience: 'informationscience',
};

FullProfile _$FullProfileFromJson(Map<String, dynamic> json) => FullProfile(
      json['display_name'] as String,
      json['short_display_name'] as String,
      json['birthday'] == null
          ? null
          : DateTime.parse(json['birthday'] as String),
      Photo.fromJson(json['photo'] as Map<String, dynamic>),
      $enumDecodeNullable(_$ProgrammeEnumMap, json['programme']),
      json['starting_year'] as int?,
      _nonEmptyUriFromJson(json['website'] as String?),
      json['profile_description'] as String?,
      json['address_street'] as String?,
      json['address_street2'] as String?,
      json['address_postal_code'] as String?,
      json['address_city'] as String?,
      json['address_country'] as String?,
      json['phone_number'] as String?,
      json['emergency_contact'] as String?,
      json['emergency_contact_phone_number'] as String?,
      json['show_birthday'] as bool,
      json['initials'] as String?,
      json['nickname'] as String?,
      $enumDecode(
          _$DisplayNamePreferenceEnumMap, json['display_name_preference']),
      json['receive_optin'] as bool,
      json['receive_newsletter'] as bool,
      json['receive_magazine'] as bool,
      json['email_gsuite_only'] as bool,
    );

Map<String, dynamic> _$FullProfileToJson(FullProfile instance) =>
    <String, dynamic>{
      'display_name': instance.displayName,
      'short_display_name': instance.shortDisplayName,
      'birthday': instance.birthday?.toIso8601String(),
      'photo': instance.photo,
      'programme': _$ProgrammeEnumMap[instance.programme],
      'starting_year': instance.startingYear,
      'website': instance.website?.toString(),
      'profile_description': instance.profileDescription,
      'address_street': instance.addressStreet,
      'address_street2': instance.addressStreet2,
      'address_postal_code': instance.addressPostalCode,
      'address_city': instance.addressCity,
      'address_country': instance.addressCountry,
      'phone_number': instance.phoneNumber,
      'emergency_contact': instance.emergencyContact,
      'emergency_contact_phone_number': instance.emergencyContactPhoneNumber,
      'show_birthday': instance.showBirthday,
      'initials': instance.initials,
      'nickname': instance.nickname,
      'display_name_preference':
          _$DisplayNamePreferenceEnumMap[instance.displayNamePreference]!,
      'receive_optin': instance.receiveOptin,
      'receive_newsletter': instance.receiveNewsletter,
      'receive_magazine': instance.receiveMagazine,
      'email_gsuite_only': instance.emailGsuiteOnly,
    };

const _$DisplayNamePreferenceEnumMap = {
  DisplayNamePreference.full: 'full',
  DisplayNamePreference.nickname: 'nickname',
  DisplayNamePreference.firstname: 'firstname',
  DisplayNamePreference.initials: 'initials',
  DisplayNamePreference.fullnick: 'fullnick',
  DisplayNamePreference.nicklast: 'nicklast',
};

Period _$PeriodFromJson(Map<String, dynamic> json) => Period(
      DateTime.parse(json['since'] as String),
      json['until'] == null ? null : DateTime.parse(json['until'] as String),
      json['chair'] as bool,
      json['role'] as String?,
    );

Map<String, dynamic> _$PeriodToJson(Period instance) => <String, dynamic>{
      'since': instance.since.toIso8601String(),
      'until': instance.until?.toIso8601String(),
      'chair': instance.chair,
      'role': instance.role,
    };

Achievement _$AchievementFromJson(Map<String, dynamic> json) => Achievement(
      json['name'] as String,
      (json['periods'] as List<dynamic>?)
          ?.map((e) => Period.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['pk'] as int?,
      json['active'] as bool?,
      json['url'] == null ? null : Uri.parse(json['url'] as String),
      DateTime.parse(json['earliest'] as String),
      json['latest'] == null ? null : DateTime.parse(json['latest'] as String),
    );

Map<String, dynamic> _$AchievementToJson(Achievement instance) =>
    <String, dynamic>{
      'name': instance.name,
      'earliest': instance.earliest.toIso8601String(),
      'active': instance.active,
      'latest': instance.latest?.toIso8601String(),
      'periods': instance.periods,
      'pk': instance.pk,
      'url': instance.url?.toString(),
    };
