// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vacancie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vacancy _$VacancyFromJson(Map<String, dynamic> json) => Vacancy(
  (json['pk'] as num).toInt(),
  json['title'] as String,
  json['description'] as String,
  json['location'] as String?,
  json['keywords'] as String,
  json['link'] as String,
  (json['partnet'] as num?)?.toInt(),
  json['company_name'] as String,
  json['company_logo'] == null
      ? null
      : Photo.fromJson(json['company_logo'] as Map<String, dynamic>),
);

Map<String, dynamic> _$VacancyToJson(Vacancy instance) => <String, dynamic>{
  'pk': instance.pk,
  'title': instance.title,
  'description': instance.description,
  'location': instance.location,
  'keywords': instance.keywords,
  'link': instance.link,
  'partnet': instance.partnerpk,
  'company_name': instance.companyname,
  'company_logo': instance.companylogo?.toJson(),
};
