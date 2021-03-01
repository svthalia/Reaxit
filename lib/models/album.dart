import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models/photo.dart';

part 'album.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Album {
  final int pk;
  final String title;
  @JsonKey(fromJson: _dateTimeFromJson)
  final DateTime date;
  final AlbumPhoto cover;
  final bool hidden;
  final bool shareable;
  final bool accessible;
  final List<AlbumPhoto> photos;

  Album(
    this.pk,
    this.title,
    this.date,
    this.cover,
    this.hidden,
    this.shareable,
    this.accessible,
    this.photos,
  );

  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);
}

DateTime _dateTimeFromJson(json) {
  if (json == null) {
    return null;
  } else {
    return DateTime.parse(json).toLocal();
  }
}
