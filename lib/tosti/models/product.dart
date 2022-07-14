import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TostiProduct {
  final int id;
  final String name;
  final String? icon;
  final bool available;
  final double currentPrice;
  final bool orderable;
  final bool ignoreShiftRestrictions;
  final int? maxAllowedPerShift;
  final String? barcode;

  const TostiProduct(
    this.id,
    this.name,
    this.icon,
    this.available,
    this.currentPrice,
    this.orderable,
    this.ignoreShiftRestrictions,
    this.maxAllowedPerShift,
    this.barcode,
  );

  factory TostiProduct.fromJson(Map<String, dynamic> json) =>
      _$TostiProductFromJson(json);
}
