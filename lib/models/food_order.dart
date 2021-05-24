import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models/member.dart';
import 'package:reaxit/models/payment.dart';
import 'package:reaxit/models/product.dart';

part 'food_order.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class FoodOrder {
  final int pk;
  final ListMember? member;
  final String? name;
  final Product product;
  final Payment? payment;

  bool get isPaid => payment != null;

  factory FoodOrder.fromJson(Map<String, dynamic> json) =>
      _$FoodOrderFromJson(json);

  const FoodOrder(
    this.pk,
    this.member,
    this.name,
    this.product,
    this.payment,
  ) : assert(
          member != null || name != null,
          'Either a member or name must be given. $member, $name',
        );
}
