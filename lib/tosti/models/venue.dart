import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/tosti/models/shift.dart';
import 'package:reaxit/tosti/models/thaliedje.dart';

part 'venue.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TostiVenue {
  final int id;
  final String name;
  final String slug;
  final String? colorInCalendar;
  final bool canBeReserved;

  @JsonKey(includeFromJson: false)
  final TostiShift? shift;

  @JsonKey(includeFromJson: false)
  final ThaliedjePlayer? player;

  TostiVenue(
    this.id,
    this.name,
    this.slug,
    this.colorInCalendar,
    this.canBeReserved, [
    this.shift,
    this.player,
  ]);

  factory TostiVenue.fromJson(Map<String, dynamic> json) =>
      _$TostiVenueFromJson(json);

  TostiVenue copyWithShift(TostiShift? shift) =>
      TostiVenue(id, name, slug, colorInCalendar, canBeReserved, shift, player);

  TostiVenue copyWithPlayer(ThaliedjePlayer? player) =>
      TostiVenue(id, name, slug, colorInCalendar, canBeReserved, shift, player);
}
