import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/config.dart' as config;

part 'document.g.dart';

enum DocumentCategory { annual, association, event, minutes, misc }

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Document {
  final int pk;
  final String name;
  final String url;
  final DocumentCategory category;

  Uri getURL() => Uri.parse(url);

  factory Document.fromJson(Map<String, dynamic> json) =>
      _$DocumentFromJson(json);
  Map<String, dynamic> toJson() => _$DocumentToJson(this);

  const Document(
    this.pk,
    this.name,
    this.url,
    this.category,
  );
}
