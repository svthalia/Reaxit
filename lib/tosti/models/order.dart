import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/tosti/models.dart';

part 'order.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TostiOrder {
  final int id;
  final DateTime created;
  final TostiUser user;
  final TostiProduct product;
  final String orderPrice;
  final bool ready;
  final DateTime? readyAt;
  final bool paid;
  final DateTime? paidAt;

  const TostiOrder(
    this.id,
    this.created,
    this.user,
    this.product,
    this.orderPrice,
    this.ready,
    this.readyAt,
    this.paid,
    this.paidAt,
  );

  factory TostiOrder.fromJson(Map<String, dynamic> json) =>
      _$TostiOrderFromJson(json);
}
