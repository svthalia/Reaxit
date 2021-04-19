import 'package:json_annotation/json_annotation.dart';

part 'photo.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AlbumPhoto {
  final int pk;
  final int rotation;
  final bool hidden;
  final int album;
  final Photo file;

  String get full => file.full;
  String get small => file.small;
  String get medium => file.medium;
  String get large => file.large;

  const AlbumPhoto(
    this.pk,
    this.rotation,
    this.hidden,
    this.album,
    this.file,
  );

  factory AlbumPhoto.fromJson(Map<String, dynamic> json) =>
      _$AlbumPhotoFromJson(json);
}

@JsonSerializable()
class Photo {
  final String full;
  final String small;
  final String medium;
  final String large;

  const Photo(this.full, this.small, this.medium, this.large);
  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);
}
