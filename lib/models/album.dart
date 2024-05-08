import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models.dart';

part 'album.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ListAlbum {
  final String slug;
  final String title;
  final bool accessible;
  final bool shareable;

  const ListAlbum(this.slug, this.title, this.accessible, this.shareable);

  factory ListAlbum.fromJson(Map<String, dynamic> json) =>
      _$ListAlbumFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Album extends ListAlbum {
  final List<AlbumPhoto> photos;

  Album copyWith({
    String? slug,
    String? title,
    bool? accessible,
    bool? shareable,
    CoverPhoto? cover,
    List<AlbumPhoto>? photos,
  }) =>
      Album(
        slug ?? this.slug,
        title ?? this.title,
        accessible ?? this.accessible,
        shareable ?? this.shareable,
        photos ?? this.photos,
      );

  const Album.fromlist(
      super.slug, super.title, super.accessible, super.shareable, this.photos);

  const Album(
      super.slug, super.title, super.accessible, super.shareable, this.photos);

  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);
}
