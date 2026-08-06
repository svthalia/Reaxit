import 'package:equatable/equatable.dart';
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

  SalesOrder._withtpay(
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
    this._tpayAllowed,
  );

  SalesOrder copyWithPayment(Payment? newPayment) => SalesOrder._withtpay(
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
    tpayAllowed,
  );

  SalesOrder copyWithItems(List<SalesOrderItem> newOrderItems) =>
      SalesOrder._withtpay(
        pk,
        shift,
        createdAt,
        newOrderItems,
        orderDescription,
        ageRestricted,
        subtotal,
        discount,
        totalAmount,
        numItems,
        payer,
        payment,
        paymentUrl,
        tpayAllowed,
      );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SalesOrderItem extends Equatable {
  final String product;
  final int amount;
  final String total;

  @override
  List<Object?> get props => [product, amount, total];

  const SalesOrderItem(this.product, this.amount, this.total);
  SalesOrderItem copyWithAmount(int amount) =>
      SalesOrderItem(product, amount, total);

  MinSalesOrderItem strip() => MinSalesOrderItem(product, amount);

  factory SalesOrderItem.fromJson(Map<String, dynamic> json) =>
      _$SalesOrderItemFromJson(json);

  Map<String, dynamic> toJson() => _$SalesOrderItemToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MinSalesOrderItem {
  final String product;
  final int amount;

  MinSalesOrderItem(this.product, this.amount);
  MinSalesOrderItem copyWithAmount(int amount) =>
      MinSalesOrderItem(product, amount);

  factory MinSalesOrderItem.fromJson(Map<String, dynamic> json) =>
      _$MinSalesOrderItemFromJson(json);

  Map<String, dynamic> toJson() => _$MinSalesOrderItemToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ListSalesOrder {
  final String pk;

  final DateTime createdAt;
  final String totalAmount;
  final int numItems;

  final List<MinSalesOrderItem> items;
  final ListMember? payer;
  final Payment? payment;

  @JsonKey(includeFromJson: false)
  bool? _tpayAllowed;

  /// Whether this order can be paid with Thalia Pay.
  /// See https://github.com/svthalia/concrexit/issues/1784.
  @JsonKey(includeFromJson: false)
  bool get tpayAllowed => _tpayAllowed ?? false;
  set tpayAllowed(bool value) => _tpayAllowed = value;

  bool get isPaid => payment != null;
  String? get name => payer?.profile.shortDisplayName;

  factory ListSalesOrder.fromJson(Map<String, dynamic> json) =>
      _$ListSalesOrderFromJson(json);

  ListSalesOrder(
    this.pk,
    this.createdAt,
    this.totalAmount,
    this.numItems,
    this.items,
    this.payer,
    this.payment,
  );

  ListSalesOrder copyWithPayment(Payment? newPayment) => ListSalesOrder(
    pk,
    createdAt,
    totalAmount,
    numItems,
    items,
    payer,
    newPayment,
  );
}
