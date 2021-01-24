import 'package:json_annotation/json_annotation.dart';

part 'member.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Member {
  final int pk;
  final String displayName;
  final Avatar avatar;
  final String profileDescription;
  @JsonKey(fromJson: _dateTimeFromJson)
  final DateTime birthday;
  final int startingYear;
  final String programme;
  final String website;
  final String membershipType;
  final List<Achievement> achievements;
  final List<Achievement> societies;

  const Member(
    this.pk,
    this.displayName,
    this.avatar,
    this.profileDescription,
    this.birthday,
    this.startingYear,
    this.programme,
    this.website,
    this.membershipType,
    this.achievements,
    this.societies,
  );

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);
}

@JsonSerializable()
class Period {
  final DateTime since;
  final DateTime until;
  final bool chair;
  final String role;
  Period(this.since, this.until, this.chair, this.role);
  factory Period.fromJson(Map<String, dynamic> json) => _$PeriodFromJson(json);
}

@JsonSerializable()
class Achievement {
  final String name;
  final List<Period> periods;

  Achievement(this.name, this.periods);
  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}

@JsonSerializable()
class Avatar {
  final String full;
  final String small;
  final String medium;
  final String large;

  Avatar(this.full, this.small, this.medium, this.large);
  factory Avatar.fromJson(Map<String, dynamic> json) => _$AvatarFromJson(json);
}

DateTime _dateTimeFromJson(json) {
  if (json == null) {
    return null;
  } else {
    return DateTime.parse(json).toLocal();
  }
}
