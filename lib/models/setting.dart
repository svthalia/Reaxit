import 'package:json_annotation/json_annotation.dart';

part 'setting.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Setting {
  final int pk;
  final String registrationId;
  final bool active;
  final String dateCreated;
  final String type;
  final List<String> receiveCategory;

  factory Setting.fromJson(Map<String, dynamic> json) =>
        _$SettingFromJson(json);

  const Setting(
    this.pk, this.registrationId, this.active, this.dateCreated, this.type, this.receiveCategory
  );
}