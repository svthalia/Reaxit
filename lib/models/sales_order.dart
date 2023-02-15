import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models.dart';

part 'sales_order.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SalesOrder {
  final String pk;
  final int shift;

  final DateTime createdAt;
  final List<SalesOrderItem> orderItems;
  final String orderDescription;
  final bool ageRestricted;
  final String subtotal;
  final String? discount;
  final String totalAmount;
  final int numItems;

  final ListMember? payer;
  final Payment? payment;

  final Uri paymentUrl;

  @JsonKey(includeFromJson: false)
  bool? _tpayAllowed;

  /// Whether this order can be paid with Thalia Pay.
  /// See https://github.com/svthalia/concrexit/issues/1784.
  @JsonKey(includeFromJson: false)
  bool get tpayAllowed => _tpayAllowed ?? false;
  set tpayAllowed(bool value) => _tpayAllowed = value;

  bool get isPaid => payment != null;

  factory SalesOrder.fromJson(Map<String, dynamic> json) =>
      _$SalesOrderFromJson(json);

  SalesOrder(
    this.pk,
    this.shift,
    this.createdAt,
    this.orderItems,
    this.orderDescription,
    this.ageRestricted,
    this.subtotal,
    this.discount,
    this.totalAmount,
    this.numItems,
    this.payer,
    this.payment,
    this.paymentUrl,
  );

  SalesOrder copyWithPayment(Payment? newPayment) => SalesOrder(
        pk,
        shift,
        createdAt,
        orderItems,
        orderDescription,
        ageRestricted,
        subtotal,
        discount,
        totalAmount,
        numItems,
        payer,
        newPayment,
        paymentUrl,
      );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SalesOrderItem {
  final String product;
  final int amount;
  final String total;

  SalesOrderItem(this.product, this.amount, this.total);

  factory SalesOrderItem.fromJson(Map<String, dynamic> json) =>
      _$SalesOrderItemFromJson(json);
}
