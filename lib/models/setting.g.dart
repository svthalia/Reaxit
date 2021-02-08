// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Setting _$SettingFromJson(Map<String, dynamic> json) {
  return Setting(
    json['key'] as String,
    json['name'] as String,
    json['description'] as String,
  );
}

Map<String, dynamic> _$SettingToJson(Setting instance) => <String, dynamic>{
      'key': instance.key,
      'name': instance.name,
      'description': instance.description,
    };
