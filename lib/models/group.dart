import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models.dart';

part 'group.g.dart';

enum MemberGroupType { committee, society, board }

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ListGroup {
  final int pk;
  final String name;
  final MemberGroupType type;
  final String description;
  final DateTime? since;
  final DateTime? until;
  final String contactAddress;
  final Photo photo;

  bool isActiveBoard() =>
      type == MemberGroupType.board &&
      (since?.isBefore(DateTime.now()) ?? false) &&
      !(until?.isBefore(DateTime.now()) ?? false);

  const ListGroup(
    this.pk,
    this.name,
    this.type,
    this.description,
    this.since,
    this.until,
    this.contactAddress,
    this.photo,
  );

  factory ListGroup.fromJson(Map<String, dynamic> json) =>
      _$ListGroupFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Group extends ListGroup {
  final List<GroupMembership> members;

  const Group(
    int pk,
    String name,
    MemberGroupType type,
    String description,
    DateTime? since,
    DateTime? until,
    String contactAddress,
    Photo photo,
    this.members,
  ) : super(pk, name, type, description, since, until, contactAddress, photo);

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class GroupMembership {
  final ListMember member;
  final bool chair;
  final DateTime since;
  final DateTime? until;
  final String? role;
  const GroupMembership(
      this.member, this.chair, this.since, this.until, this.role);
  factory GroupMembership.fromJson(Map<String, dynamic> json) =>
      _$GroupMembershipFromJson(json);

  Map<String, dynamic> toJson() => _$GroupMembershipToJson(this);
}
