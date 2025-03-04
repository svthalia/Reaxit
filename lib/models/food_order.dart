import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models.dart';

part 'food_order.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class FoodOrder {
  final int pk;
  final ListMember? member;
  final String? name;
  final Product product;
  final Payment? payment;

  @JsonKey(includeFromJson: false)
  bool? _tpayAllowed;

  /// Whether this order can be paid with Thalia Pay.
  /// See https://github.com/svthalia/concrexit/issues/1784.
  ///
  /// Warning: this is not properly set on orders retrieved
  /// through [ApiRepository.getFoodEvents].
  @JsonKey(includeFromJson: false)
  bool get tpayAllowed => _tpayAllowed ?? false;
  set tpayAllowed(bool value) => _tpayAllowed = value;

  bool get isPaid => payment != null;

  factory FoodOrder.fromJson(Map<String, dynamic> json) =>
      _$FoodOrderFromJson(json);

  FoodOrder(this.pk, this.member, this.name, this.product, this.payment)
    : assert(
        member != null || name != null,
        'Either a member or name must be given. $member, $name',
      );

  FoodOrder copyWithPayment(Payment? newPayment) =>
      FoodOrder(pk, member, name, product, newPayment);
}

/// Copy of [FoodOrder] where `member` is a [AdminListMember].
@JsonSerializable(fieldRename: FieldRename.snake)
class AdminFoodOrder implements FoodOrder {
  @override
  final int pk;
  @override
  final AdminListMember? member;
  @override
  final String? name;
  @override
  final Product product;
  @override
  final Payment? payment;

  @override
  @JsonKey(includeFromJson: false)
  bool? _tpayAllowed;

  /// Whether this order can be paid with Thalia Pay.
  /// See https://github.com/svthalia/concrexit/issues/1784.
  ///
  /// Warning: this is not properly set on orders retrieved
  /// through [ApiRepository.getFoodEvents].
  @override
  @JsonKey(includeFromJson: false)
  bool get tpayAllowed => _tpayAllowed ?? false;
  @override
  set tpayAllowed(bool value) => _tpayAllowed = value;

  @override
  bool get isPaid => payment != null;

  factory AdminFoodOrder.fromJson(Map<String, dynamic> json) =>
      _$AdminFoodOrderFromJson(json);

  AdminFoodOrder(this.pk, this.member, this.name, this.product, this.payment)
    : assert(
        member != null || name != null,
        'Either a member or name must be given. $member, $name',
      );

  @override
  AdminFoodOrder copyWithPayment(Payment? newPayment) =>
      AdminFoodOrder(pk, member, name, product, newPayment);
}
