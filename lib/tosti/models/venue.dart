import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/tosti/models/shift.dart';
import 'package:reaxit/tosti/models/thaliedje.dart';

part 'venue.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TostiVenue {
  final int pk;
  final String name;
  final String slug;
  final String? colorInCalendar;
  final bool canBeReserved;

  @JsonKey(ignore: true)
  final TostiShift? shift;

  @JsonKey(ignore: true)
  final ThaliedjePlayer? player;

  TostiVenue(
    this.pk,
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
      TostiVenue(pk, name, slug, colorInCalendar, canBeReserved, shift, player);

  TostiVenue copyWithPlayer(ThaliedjePlayer? player) =>
      TostiVenue(pk, name, slug, colorInCalendar, canBeReserved, shift, player);
}
