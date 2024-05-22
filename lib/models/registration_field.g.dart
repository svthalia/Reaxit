// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IntegerRegistrationField _$IntegerRegistrationFieldFromJson(
        Map<String, dynamic> json) =>
    IntegerRegistrationField(
      json['label'] as String,
      json['description'] as String,
      json['required'] as bool,
      (json['value'] as num?)?.toInt(),
    );

Map<String, dynamic> _$IntegerRegistrationFieldToJson(
        IntegerRegistrationField instance) =>
    <String, dynamic>{
      'label': instance.label,
      'description': instance.description,
      'required': instance.isRequired,
      'value': instance.value,
    };

TextRegistrationField _$TextRegistrationFieldFromJson(
        Map<String, dynamic> json) =>
    TextRegistrationField(
      json['label'] as String,
      json['description'] as String,
      json['required'] as bool,
      json['value'] as String?,
    );

Map<String, dynamic> _$TextRegistrationFieldToJson(
        TextRegistrationField instance) =>
    <String, dynamic>{
      'label': instance.label,
      'description': instance.description,
      'required': instance.isRequired,
      'value': instance.value,
    };

CheckboxRegistrationField _$CheckboxRegistrationFieldFromJson(
        Map<String, dynamic> json) =>
    CheckboxRegistrationField(
      json['label'] as String,
      json['description'] as String,
      json['required'] as bool,
      json['value'] as bool?,
    );

Map<String, dynamic> _$CheckboxRegistrationFieldToJson(
        CheckboxRegistrationField instance) =>
    <String, dynamic>{
      'label': instance.label,
      'description': instance.description,
      'required': instance.isRequired,
      'value': instance.value,
    };
