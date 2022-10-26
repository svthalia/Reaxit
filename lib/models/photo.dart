import 'package:json_annotation/json_annotation.dart';

part 'photo.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AlbumPhoto {
  final int pk;
  final int rotation;
  final bool hidden;
  final Photo file;
  final bool liked;

  String get full => file.full;
  String get small => file.small;
  String get medium => file.medium;
  String get large => file.large;

  AlbumPhoto copyWith({
    int? pk,
    int? rotation,
    bool? hidden,
    Photo? file,
    bool? liked,
  }) =>
      AlbumPhoto(
        pk ?? this.pk,
        rotation ?? this.rotation,
        hidden ?? this.hidden,
        file ?? this.file,
        liked: liked ?? this.liked,
      );

  const AlbumPhoto(this.pk, this.rotation, this.hidden, this.file,
      {this.liked = false});

  const AlbumPhoto.liked(
    this.pk,
    this.rotation,
    this.hidden,
    this.file,
    this.liked,
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
