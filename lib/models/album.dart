import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models.dart';

part 'album.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ListAlbum {
  final String slug;
  final String title;
  final bool accessible;
  final bool shareable;
  final CoverPhoto? cover;

  const ListAlbum(
      this.slug, this.title, this.accessible, this.shareable, this.cover);

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
        cover ?? this.cover,
        photos ?? this.photos,
      );

  const Album.fromlist(String slug, String title, bool accessible,
      bool shareable, CoverPhoto cover, this.photos)
      : super(slug, title, accessible, shareable, cover);

  const Album(String slug, String title, bool accessible, bool shareable,
      CoverPhoto? cover, this.photos)
      : super(slug, title, accessible, shareable, cover);

  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);
}
