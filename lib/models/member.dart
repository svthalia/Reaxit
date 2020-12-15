import 'package:json_annotation/json_annotation.dart';

part 'member.g.dart';

@JsonSerializable()
class ListMember {
  final int pk;
  @JsonKey(name: "starting_year")
  final int startingYear;
  @JsonKey(name: "display_name")
  final String displayName;
  @JsonKey(name: "membership_type")
  final String membershipType;
  final Avatar avatar;

  const ListMember(this.pk, this.startingYear, this.displayName,
      this.membershipType, this.avatar);

  factory ListMember.fromJson(Map<String, dynamic> json) =>
      _$ListMemberFromJson(json);
}

@JsonSerializable()
class DetailMember {
  final int pk;
  @JsonKey(name: "display_name")
  final String displayName;
  final Avatar avatar;
  final String profileDescription;
  final String birthday;
  @JsonKey(name: "starting_year")
  final int startingYear;
  final String programme;
  final String website;
  @JsonKey(name: "membership_type")
  final String membershipType;
  final List<Achievement> achievements;
  final List<Achievement> societies;

  const DetailMember(
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
      this.societies);

  factory DetailMember.fromJson(Map<String, dynamic> json) =>
      _$DetailMemberFromJson(json);
}

@JsonSerializable()
class Period {
  final DateTime since;
  final DateTime until;
  final bool chair;
  final String role;
  Period(this.since, [this.until = null, this.chair = false, this.role = null]);
  factory Period.fromJson(Map<String, dynamic> json) => _$PeriodFromJson(json);
}

@JsonSerializable()
class Achievement {
  final String name;
  final List<Period> periods;

  Achievement(this.name, [this.periods = null]);
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
