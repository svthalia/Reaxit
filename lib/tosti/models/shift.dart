import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/tosti/models/user.dart';

part 'shift.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TostiShift {
  final int id;
  final int venue;
  final String venueName;
  final DateTime start;
  final DateTime end;
  final bool canOrder;
  final bool isActive;
  final bool finalized;
  final int amountOfOrders;
  final int maxOrdersPerUser;
  final int maxOrdersTotal;
  final List<TostiUser> assignees;

  TostiShift(
    this.id,
    this.venue,
    this.venueName,
    this.start,
    this.end,
    this.canOrder,
    this.isActive,
    this.finalized,
    this.amountOfOrders,
    this.maxOrdersPerUser,
    this.maxOrdersTotal,
    this.assignees,
  );

  factory TostiShift.fromJson(Map<String, dynamic> json) =>
      _$TostiShiftFromJson(json);
}
