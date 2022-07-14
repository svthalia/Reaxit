import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TostiUser {
  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String displayName;
  final int association;

  TostiUser(
    this.id,
    this.firstName,
    this.lastName,
    this.fullName,
    this.displayName,
    this.association,
  );

  factory TostiUser.fromJson(Map<String, dynamic> json) =>
      _$TostiUserFromJson(json);
}
