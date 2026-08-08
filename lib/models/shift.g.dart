// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShiftInfo _$ShiftInfoFromJson(Map<String, dynamic> json) => ShiftInfo(
  (json['pk'] as num).toInt(),
  json['title'] as String,
  DateTime.parse(json['start'] as String),
  DateTime.parse(json['end'] as String),
);

Map<String, dynamic> _$ShiftInfoToJson(ShiftInfo instance) => <String, dynamic>{
  'pk': instance.pk,
  'title': instance.title,
  'start': instance.start.toIso8601String(),
  'end': instance.end.toIso8601String(),
};

Shift _$ShiftFromJson(Map<String, dynamic> json) => Shift(
  (json['pk'] as num).toInt(),
  json['title'] as String,
  DateTime.parse(json['start'] as String),
  DateTime.parse(json['end'] as String),
  (json['products'] as List<dynamic>)
      .map((e) => ShiftListProduct.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ShiftToJson(Shift instance) => <String, dynamic>{
  'pk': instance.pk,
  'title': instance.title,
  'start': instance.start.toIso8601String(),
  'end': instance.end.toIso8601String(),
  'products': instance.products,
};
