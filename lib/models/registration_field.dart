import 'package:json_annotation/json_annotation.dart';

part 'registration_field.g.dart';

abstract class RegistrationField {
  final String label;
  final String description;
  // ignore: prefer_typing_uninitialized_variables
  abstract final value;

  @JsonKey(name: 'required')
  final bool isRequired;

  RegistrationField(this.label, this.description, this.isRequired);

  factory RegistrationField.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'boolean':
        return CheckboxRegistrationField.fromJson(json);
      case 'integer':
        return IntegerRegistrationField.fromJson(json);
      case 'text':
        return TextRegistrationField.fromJson(json);
      default:
        throw Exception('Unknown Type');
    }
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class IntegerRegistrationField extends RegistrationField {
  @override
  int? value;

  IntegerRegistrationField(
    String label,
    String description,
    bool isRequired,
    this.value,
  ) : super(label, description, isRequired);

  factory IntegerRegistrationField.fromJson(Map<String, dynamic> json) =>
      _$IntegerRegistrationFieldFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TextRegistrationField extends RegistrationField {
  @override
  String? value;

  TextRegistrationField(
    String label,
    String description,
    bool isRequired,
    this.value,
  ) : super(label, description, isRequired);

  factory TextRegistrationField.fromJson(Map<String, dynamic> json) =>
      _$TextRegistrationFieldFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CheckboxRegistrationField extends RegistrationField {
  @override
  bool? value;

  CheckboxRegistrationField(
    String label,
    String description,
    bool isRequired,
    this.value,
  ) : super(label, description, isRequired);

  factory CheckboxRegistrationField.fromJson(Map<String, dynamic> json) =>
      _$CheckboxRegistrationFieldFromJson(json);
}
