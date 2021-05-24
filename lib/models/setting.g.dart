// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Setting _$SettingFromJson(Map<String, dynamic> json) {
  return Setting(
    json['pk'] as int,
    json['registration_id'] as String,
    json['active'] as bool,
    json['date_created'] as String,
    json['type'] as String,
    (json['receive_category'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
  );
}

Map<String, dynamic> _$SettingToJson(Setting instance) => <String, dynamic>{
      'pk': instance.pk,
      'registration_id': instance.registrationId,
      'active': instance.active,
      'date_created': instance.dateCreated,
      'type': instance.type,
      'receive_category': instance.receiveCategory,
    };
