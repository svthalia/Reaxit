import 'package:json_annotation/json_annotation.dart';

part 'device.g.dart';

/// Object used by the server to provide push notifications.
@JsonSerializable(fieldRename: FieldRename.snake)
class Device {
  final int pk;
  final String registrationId;
  final bool active;
  final String dateCreated;
  final String type;
  final List<String> receiveCategory;

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceToJson(this);

  const Device(this.pk, this.registrationId, this.active, this.dateCreated,
      this.type, this.receiveCategory);

  Device copyWithReceiveCategory(List<String> newReceiveCategory) =>
      Device(pk, registrationId, active, dateCreated, type, newReceiveCategory);
}
