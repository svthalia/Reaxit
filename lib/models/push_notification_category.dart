import 'package:json_annotation/json_annotation.dart';

part 'push_notification_category.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class PushNotificationCategory {
  final String key;
  final String name;
  final String description;

  factory PushNotificationCategory.fromJson(Map<String, dynamic> json) =>
      _$PushNotificationCategoryFromJson(json);

  const PushNotificationCategory(this.key, this.name, this.description);
}
