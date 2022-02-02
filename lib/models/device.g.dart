// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) => Device(
      json['pk'] as int,
      json['registration_id'] as String,
      json['active'] as bool,
      json['date_created'] as String,
      json['type'] as String,
      (json['receive_category'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
      'pk': instance.pk,
      'active': instance.active,
      'date_created': instance.dateCreated,
      'type': instance.type,
      'receive_category': instance.receiveCategory,
      'registration_id': instance.token,
    };
