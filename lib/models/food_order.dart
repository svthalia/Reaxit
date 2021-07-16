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

  @JsonKey(ignore: true)
  bool? _tpayAllowed;

  /// Whether this order can be paid with Thalia Pay.
  /// See https://github.com/svthalia/concrexit/issues/1784.
  ///
  /// Warning: this is not properly set on orders retrieved
  /// through [ApiRepository.getFoodEvents].
  @JsonKey(ignore: true)
  bool get tpayAllowed => _tpayAllowed ?? false;
  @JsonKey(ignore: true)
  set tpayAllowed(bool value) => _tpayAllowed = value;

  bool get isPaid => payment != null;

  factory FoodOrder.fromJson(Map<String, dynamic> json) =>
      _$FoodOrderFromJson(json);

  FoodOrder(
    this.pk,
    this.member,
    this.name,
    this.product,
    this.payment,
  ) : assert(
          member != null || name != null,
          'Either a member or name must be given. $member, $name',
        );

  FoodOrder copyWithPayment(Payment? newPayment) =>
      FoodOrder(pk, member, name, product, newPayment);
}
