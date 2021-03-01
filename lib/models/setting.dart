import 'package:json_annotation/json_annotation.dart';

part 'setting.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Setting {
  final String key;
  final String name;
  final String description;

  Setting(this.key, this.name, this.description);

  factory Setting.fromJson(Map<String, dynamic> json) =>
      _$SettingFromJson(json);
}
