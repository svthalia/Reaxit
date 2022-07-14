import 'package:json_annotation/json_annotation.dart';

part 'thaliedje.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ThaliedjePlayer {
  final int id;

  @JsonKey(defaultValue: 'noord')
  final String slug;
  final String displayName;
  final int venue;
  final ThaliedjeCurrentTrack? track;
  final bool isPlaying;
  final int? currentVolume;

  ThaliedjePlayer(this.id, this.slug, this.displayName, this.venue, this.track,
      this.isPlaying, this.currentVolume);

  factory ThaliedjePlayer.fromJson(Map<String, dynamic> json) =>
      _$ThaliedjePlayerFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ThaliedjeCurrentTrack {
  final Uri image;
  final String name;
  final List<String> artists;

  ThaliedjeCurrentTrack(this.image, this.name, this.artists);

  factory ThaliedjeCurrentTrack.fromJson(Map<String, dynamic> json) =>
      _$ThaliedjeCurrentTrackFromJson(json);
}
