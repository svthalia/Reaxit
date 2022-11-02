import 'package:json_annotation/json_annotation.dart';

part 'photo.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CoverPhoto {
  final int pk;
  final int rotation;
  final bool hidden;
  final Photo file;

  String get full => file.full;
  String get small => file.small;
  String get medium => file.medium;
  String get large => file.large;

  CoverPhoto copyWith({
    int? pk,
    int? rotation,
    bool? hidden,
    Photo? file,
  }) =>
      CoverPhoto(
        pk ?? this.pk,
        rotation ?? this.rotation,
        hidden ?? this.hidden,
        file ?? this.file,
      );

  const CoverPhoto(this.pk, this.rotation, this.hidden, this.file);

  factory CoverPhoto.fromJson(Map<String, dynamic> json) =>
      _$CoverPhotoFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AlbumPhoto extends CoverPhoto {
  final bool liked;
  final int numLikes;

  @override
  AlbumPhoto copyWith({
    int? pk,
    int? rotation,
    bool? hidden,
    Photo? file,
    bool? liked,
    int? numLikes,
  }) =>
      AlbumPhoto(
        pk ?? this.pk,
        rotation ?? this.rotation,
        hidden ?? this.hidden,
        file ?? this.file,
        liked ?? this.liked,
        numLikes ?? this.numLikes,
      );

  const AlbumPhoto(
      int pk, int rotation, bool hidden, Photo file, this.liked, this.numLikes)
      : super(pk, rotation, hidden, file);

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
