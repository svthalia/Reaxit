import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models/member.dart';
import 'package:reaxit/models/photo.dart';

part 'group.g.dart';

enum MemberGroupType { committee, society, board }

@JsonSerializable(fieldRename: FieldRename.snake)
class ListGroup {
  final int pk;
  final String name;
  final MemberGroupType type;
  final DateTime? since;
  final DateTime? until;
  final String contactAddress;
  final Photo photo;

  const ListGroup(
    this.pk,
    this.name,
    this.type,
    this.since,
    this.until,
    this.contactAddress,
    this.photo,
  );

  factory ListGroup.fromJson(Map<String, dynamic> json) =>
      _$ListMemberGroupFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Group extends ListGroup {
  final List<ListMember> members;

  const Group(
    int pk,
    String name,
    MemberGroupType type,
    DateTime? since,
    DateTime? until,
    String contactAddress,
    Photo photo,
    this.members,
  ) : super(pk, name, type, since, until, contactAddress, photo);

  factory Group.fromJson(Map<String, dynamic> json) =>
      _$MemberGroupFromJson(json);
}
