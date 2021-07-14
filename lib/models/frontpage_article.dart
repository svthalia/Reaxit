import 'package:json_annotation/json_annotation.dart';

part 'frontpage_article.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class FrontpageArticle {
  final int pk;
  final String title;
  final String content;

  const FrontpageArticle(this.pk, this.title, this.content);

  factory FrontpageArticle.fromJson(Map<String, dynamic> json) =>
      _$FrontpageArticleFromJson(json);
}
