import 'package:json_annotation/json_annotation.dart';

part 'thabliod.g.dart';

enum DocumentCategory { annual, association, event, minutes, misc }

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Thabloid {
  final int pk;
  final int year;
  final int issue;
  final String cover;
  final String file;

  factory Thabloid.fromJson(Map<String, dynamic> json) =>
      _$ThabloidFromJson(json);
  Map<String, dynamic> toJson() => _$ThabloidToJson(this);

  const Thabloid(this.pk, this.year, this.issue, this.cover, this.file);
}
