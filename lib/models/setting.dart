

import 'package:json_annotation/json_annotation.dart';

part 'setting.g.dart';

@JsonSerializable()
class Setting {
  final String name;
  final String description;

  factory Setting.fromJson(Map<String, dynamic> json) => _$SettingFromJson(json);

  const Setting(
    this.name, this.description
  );
}