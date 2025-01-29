import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models/photo.dart';

part 'vacancie.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Vacancy {
  final int pk;
  final String title;
  final String description;
  final String? location;
  final String keywords;
  final String link;
  @JsonKey(name: 'partnet')
  final int? partnerpk;
  @JsonKey(name: 'company_name')
  final String companyname;
  @JsonKey(name: 'company_logo')
  final Photo? companylogo;
  const Vacancy(
    this.pk,
    this.title,
    this.description,
    this.location,
    this.keywords,
    this.link,
    this.partnerpk,
    this.companyname,
    this.companylogo,
  );

  factory Vacancy.fromJson(Map<String, dynamic> json) =>
      _$VacancyFromJson(json);
  Map<String, dynamic> toJson() => _$VacancyToJson(this);
}
