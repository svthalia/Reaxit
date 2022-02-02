import 'package:json_annotation/json_annotation.dart';

part 'device.g.dart';

/// Object used by the server to provide push notifications.
@JsonSerializable(fieldRename: FieldRename.snake)
class Device {
  final int pk;
  final bool active;
  final String dateCreated;
  final String type;

  /// A list of categories of notifications
  /// that should be received on the device.
  final List<String> receiveCategory;

  /// A unique identifier for a device to which
  /// the backend can send push notifications.
  @JsonKey(name: 'registration_id')
  final String token;

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceToJson(this);

  const Device(this.pk, this.token, this.active, this.dateCreated, this.type,
      this.receiveCategory);

  Device copyWithReceiveCategory(List<String> newReceiveCategory) =>
      Device(pk, token, active, dateCreated, type, newReceiveCategory);
}
