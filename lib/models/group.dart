import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models.dart';

part 'group.g.dart';

enum MemberGroupType { committee, society, board }

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class SmallGroup {
  final int pk;
  final String name;
  final MemberGroupType type;
  final DateTime? since;
  final DateTime? until;
  final String contactAddress;

  const SmallGroup(
    this.pk,
    this.name,
    this.type,
    this.since,
    this.until,
    this.contactAddress,
  );

  factory SmallGroup.fromJson(Map<String, dynamic> json) =>
      _$SmallGroupFromJson(json);
  Map<String, dynamic> toJson() => _$SmallGroupToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ListGroup extends SmallGroup {
  final String description;
  final Photo photo;

  bool isActiveBoard() =>
      type == MemberGroupType.board &&
      (since?.isBefore(DateTime.now()) ?? false) &&
      !(until?.isBefore(DateTime.now()) ?? false);

  const ListGroup(
    super.pk,
    super.name,
    super.type,
    super.since,
    super.until,
    super.contactAddress,
    this.description,
    this.photo,
  );

  factory ListGroup.fromJson(Map<String, dynamic> json) =>
      _$ListGroupFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ListGroupToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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
  ) : super(pk, name, type, since, until, contactAddress, description, photo);

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GroupMembership {
  final ListMember member;
  final bool chair;
  final DateTime since;
  final DateTime? until;
  final String? role;
  const GroupMembership(
    this.member,
    this.chair,
    this.since,
    this.until,
    this.role,
  );
  factory GroupMembership.fromJson(Map<String, dynamic> json) =>
      _$GroupMembershipFromJson(json);
}
