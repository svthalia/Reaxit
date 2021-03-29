import 'package:json_annotation/json_annotation.dart';

import 'photo.dart';

part 'member.g.dart';

enum Programme { computingscience, informationscience }
enum MembershipType { member, benefactor, honorary }

@JsonSerializable(fieldRename: FieldRename.snake)
class Member {
  final int pk;
  final MembershipType membershipType;
  final Profile profile;

  final List<Achievement>? achievements;
  final List<Achievement>? societies;

  String get displayName => profile.displayName;
  String get shortDisplayName => profile.shortDisplayName;
  DateTime? get birthday => profile.birthday;
  Photo get photo => profile.photo;
  Programme? get programme => profile.programme;
  int get startingYear => profile.startingYear;
  Uri? get website => profile.website;
  String? get profileDescription => profile.profileDescription;

  const Member(
    this.pk,
    this.membershipType,
    this.profile,
    this.achievements,
    this.societies,
  );

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Profile {
  final String displayName;
  final String shortDisplayName;
  final DateTime? birthday;
  final Photo photo;
  final Programme? programme;
  final int startingYear;
  final Uri? website;
  final String? profileDescription;

  Profile(this.displayName, this.shortDisplayName, this.birthday, this.photo,
      this.programme, this.startingYear, this.website, this.profileDescription);
}

// @JsonSerializable(fieldRename: FieldRename.snake)
// class FullProfile implements Profile {
//   TODO: FullMember when /api/v2/members/me is available
// }

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

// DateTime? _dateTimeFromJson(String? json) {
//   if (json == null) {
//     return null;
//   } else {
//     return DateTime.parse(json).toLocal();
//   }
// }
