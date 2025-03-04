import 'package:json_annotation/json_annotation.dart';

part 'photo.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CoverPhoto {
  final int pk;

  @JsonKey(defaultValue: 0)
  final int rotation;

  final Photo file;

  String get full => file.full;
  String get small => file.small;
  String get medium => file.medium;
  String get large => file.large;

  CoverPhoto copyWith({int? pk, int? rotation, Photo? file}) =>
      CoverPhoto(pk ?? this.pk, rotation ?? this.rotation, file ?? this.file);

  const CoverPhoto(this.pk, this.rotation, this.file);

  factory CoverPhoto.fromJson(Map<String, dynamic> json) =>
      _$CoverPhotoFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class AlbumPhoto extends CoverPhoto {
  final bool liked;
  final int numLikes;

  @override
  AlbumPhoto copyWith({
    int? pk,
    int? rotation,
    Photo? file,
    bool? liked,
    int? numLikes,
  }) => AlbumPhoto(
    pk ?? this.pk,
    rotation ?? this.rotation,
    file ?? this.file,
    liked ?? this.liked,
    numLikes ?? this.numLikes,
  );

  const AlbumPhoto(
    super.pk,
    super.rotation,
    super.file,
    this.liked,
    this.numLikes,
  );

  factory AlbumPhoto.fromJson(Map<String, dynamic> json) =>
      _$AlbumPhotoFromJson(json);
}

@JsonSerializable(explicitToJson: true)
class Photo {
  final String full;
  final String small;
  final String medium;
  final String large;

  const Photo(this.full, this.small, this.medium, this.large);
  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);

  Map<String, dynamic> toJson() => _$PhotoToJson(this);
}
