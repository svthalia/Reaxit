// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'frontpage_article.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FrontpageArticle _$FrontpageArticleFromJson(Map<String, dynamic> json) =>
    FrontpageArticle(
      json['pk'] as int,
      json['title'] as String,
      json['content'] as String,
    );

Map<String, dynamic> _$FrontpageArticleToJson(FrontpageArticle instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'title': instance.title,
      'content': instance.content,
    };
