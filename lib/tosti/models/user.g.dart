// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TostiUser _$TostiUserFromJson(Map<String, dynamic> json) => TostiUser(
  (json['id'] as num).toInt(),
  json['first_name'] as String,
  json['last_name'] as String,
  json['full_name'] as String,
  json['display_name'] as String,
  (json['association'] as num?)?.toInt(),
);

Map<String, dynamic> _$TostiUserToJson(TostiUser instance) => <String, dynamic>{
  'id': instance.id,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'full_name': instance.fullName,
  'display_name': instance.displayName,
  'association': instance.association,
};
