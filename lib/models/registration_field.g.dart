// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IntegerRegistrationField _$IntegerRegistrationFieldFromJson(
    Map<String, dynamic> json) {
  return IntegerRegistrationField(
    json['label'] as String,
    json['description'] as String,
    json['required'] as bool,
    json['value'] as int?,
  );
}

Map<String, dynamic> _$IntegerRegistrationFieldToJson(
        IntegerRegistrationField instance) =>
    <String, dynamic>{
      'label': instance.label,
      'description': instance.description,
      'required': instance.isRequired,
      'value': instance.value,
    };

TextRegistrationField _$TextRegistrationFieldFromJson(
    Map<String, dynamic> json) {
  return TextRegistrationField(
    json['label'] as String,
    json['description'] as String,
    json['required'] as bool,
    json['value'] as String?,
  );
}

Map<String, dynamic> _$TextRegistrationFieldToJson(
        TextRegistrationField instance) =>
    <String, dynamic>{
      'label': instance.label,
      'description': instance.description,
      'required': instance.isRequired,
      'value': instance.value,
    };

CheckboxRegistrationField _$CheckboxRegistrationFieldFromJson(
    Map<String, dynamic> json) {
  return CheckboxRegistrationField(
    json['label'] as String,
    json['description'] as String,
    json['required'] as bool,
    json['value'] as bool?,
  );
}

Map<String, dynamic> _$CheckboxRegistrationFieldToJson(
        CheckboxRegistrationField instance) =>
    <String, dynamic>{
      'label': instance.label,
      'description': instance.description,
      'required': instance.isRequired,
      'value': instance.value,
    };
