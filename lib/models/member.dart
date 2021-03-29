// import 'package:flutter/material.dart';
// import 'package:json_annotation/json_annotation.dart';

// part 'member.g.dart';

// enum Programme { computingscience, informationscience }
// enum MembershipType { member, benefactor, honorary }

// @JsonSerializable(fieldRename: FieldRename.snake)
// class Member {
//   final int pk;
//   final MembershipType membershipType;
//   final Profile profile;

//   final List<Achievement>? achievements;
//   final List<Achievement>? societies;

//   const Member(
//     this.pk,
//     this.membershipType,
//     this.profile,
//     this.achievements,
//     this.societies,
//   );

//   factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);
// }

// @JsonSerializable(fieldRename: FieldRename.snake)
// class DetailMember implements Member {
//   final int pk;
//   final MembershipType membershipType;
//   final DetailProfile profile;

//   final List<Achievement>? achievements;
//   final List<Achievement>? societies;

//   DetailMember(
//     this.pk,
//     this.membershipType,
//     this.profile,
//     this.achievements,
//     this.societies,
//   );

//   factory DetailMember.fromJson(Map<String, dynamic> json) =>
//       _$DetailMemberFromJson(json);
// }

// class Profile {
//   final String displayName;
//   final String shortDisplayName;
//   final DateTime? birthday;
//   final String photo;
//   final Programme? programme;

// }

// class DetailProfile implements Profile {

// }

// @JsonSerializable()
// class Period {
//   final DateTime since;
//   final DateTime until;
//   final bool chair;
//   final String role;
//   Period(this.since, this.until, this.chair, this.role);
//   factory Period.fromJson(Map<String, dynamic> json) => _$PeriodFromJson(json);
// }

// @JsonSerializable()
// class Achievement {
//   final String name;
//   final List<Period> periods;

//   Achievement(this.name, this.periods);
//   factory Achievement.fromJson(Map<String, dynamic> json) =>
//       _$AchievementFromJson(json);
// }

// DateTime? _dateTimeFromJson(String? json) {
//   if (json == null) {
//     return null;
//   } else {
//     return DateTime.parse(json).toLocal();
//   }
// }
