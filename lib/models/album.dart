import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models/photo.dart';

part 'album.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ListAlbum {
  final String slug;
  final String title;
  final bool accessible;
  final bool shareable;
  final AlbumPhoto cover;

  const ListAlbum(
      this.slug, this.title, this.accessible, this.shareable, this.cover);

  factory ListAlbum.fromJson(Map<String, dynamic> json) =>
      _$ListAlbumFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Album extends ListAlbum {
  final List<AlbumPhoto> photos;

  const Album(String slug, String title, bool accessible, bool shareable,
      AlbumPhoto cover, this.photos)
      : super(slug, title, accessible, shareable, cover);

  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);
}
