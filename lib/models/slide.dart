import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models.dart';

part 'slide.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Slide {
  final int pk;
  final String title;
  final Photo content;
  final int order;
  final Uri? url;

  const Slide(this.pk, this.title, this.content, this.order, this.url);

  factory Slide.fromJson(Map<String, dynamic> json) => _$SlideFromJson(json);
}
