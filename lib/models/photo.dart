import 'package:json_annotation/json_annotation.dart';

part 'photo.g.dart';

@JsonSerializable()
class Photo {
  final String full;
  final String small;
  final String medium;
  final String large;

  Photo(this.full, this.small, this.medium, this.large);
  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);
}
